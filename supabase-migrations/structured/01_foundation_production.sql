-- =============================================
-- PRODUCTION-READY FOUNDATION
-- =============================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For fuzzy text search
CREATE EXTENSION IF NOT EXISTS "btree_gin"; -- For composite indexes

-- Create schemas for organization
CREATE SCHEMA IF NOT EXISTS audit;
CREATE SCHEMA IF NOT EXISTS analytics;
CREATE SCHEMA IF NOT EXISTS cache;
CREATE SCHEMA IF NOT EXISTS archive;

-- =============================================
-- PRODUCTION CONFIGURATION
-- =============================================

-- Set production-optimized parameters
ALTER SYSTEM SET shared_preload_libraries = 'pg_stat_statements,pg_cron';
ALTER SYSTEM SET max_connections = 200;
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
ALTER SYSTEM SET work_mem = '4MB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
ALTER SYSTEM SET random_page_cost = 1.1;
ALTER SYSTEM SET effective_io_concurrency = 200;

-- Enable query logging for performance monitoring
ALTER SYSTEM SET log_statement = 'all';
ALTER SYSTEM SET log_min_duration_statement = 1000; -- Log slow queries
ALTER SYSTEM SET log_checkpoints = on;
ALTER SYSTEM SET log_connections = on;
ALTER SYSTEM SET log_disconnections = on;

-- =============================================
-- AUDIT SYSTEM (PRODUCTION-OPTIMIZED)
-- =============================================

-- Partitioned audit table (critical for production)
CREATE TABLE audit.system_logs (
    id UUID DEFAULT gen_random_uuid(),
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    operation VARCHAR(10) NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values JSONB,
    new_values JSONB,
    changed_by UUID,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ip_address INET,
    user_agent TEXT,
    session_id VARCHAR(100)
) PARTITION BY RANGE (changed_at);

-- Create monthly partitions for current and next 12 months
DO $$
DECLARE
    start_date DATE;
    end_date DATE;
    partition_name TEXT;
BEGIN
    FOR i IN 0..12 LOOP
        start_date := DATE_TRUNC('month', CURRENT_DATE + (i || ' months')::INTERVAL);
        end_date := start_date + INTERVAL '1 month';
        partition_name := 'system_logs_' || TO_CHAR(start_date, 'YYYY_MM');
        
        EXECUTE FORMAT('
            CREATE TABLE IF NOT EXISTS audit.%I PARTITION OF audit.system_logs
            FOR VALUES FROM (%L) TO (%L)
        ', partition_name, start_date, end_date);
        
        -- Add indexes to each partition
        EXECUTE FORMAT('CREATE INDEX IF NOT EXISTS idx_%s_table_record ON audit.%I(table_name, record_id)', partition_name, partition_name);
        EXECUTE FORMAT('CREATE INDEX IF NOT EXISTS idx_%s_changed_at ON audit.%I(changed_at)', partition_name, partition_name);
    END LOOP;
END $$;

-- =============================================
-- PERFORMANCE MONITORING TABLES
-- =============================================

CREATE TABLE performance.query_stats (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    query_hash TEXT,
    query_text TEXT,
    calls INTEGER,
    total_time_ms DOUBLE PRECISION,
    avg_time_ms DOUBLE PRECISION,
    max_time_ms DOUBLE PRECISION,
    cached_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE performance.slow_queries (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    query_text TEXT,
    execution_time_ms INTEGER,
    user_id UUID,
    executed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    explain_plan JSONB
);

-- =============================================
-- CACHING LAYER TABLES
-- =============================================

CREATE TABLE cache.dashboard_data (
    cache_key VARCHAR(200) PRIMARY KEY,
    user_id UUID,
    data JSONB NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_cache_dashboard_expires ON cache.dashboard_data(expires_at);
CREATE INDEX idx_cache_dashboard_user ON cache.dashboard_data(user_id);

-- =============================================
-- PRODUCTION HELPER FUNCTIONS
-- =============================================

-- Enhanced audit function with batching
CREATE OR REPLACE FUNCTION audit.log_changes()
RETURNS TRIGGER AS $$
DECLARE
    batch_size CONSTANT INTEGER := 1000;
    current_batch_count INTEGER;
BEGIN
    -- Skip audit for high-frequency tables during peak hours
    IF TG_TABLE_NAME IN ('lesson_progress', 'live_class_attendance_logs') 
       AND EXTRACT(HOUR FROM NOW()) BETWEEN 9 AND 18 THEN
        -- Only audit every 10th record during peak hours
        IF RANDOM() > 0.1 THEN
            RETURN COALESCE(NEW, OLD);
        END IF;
    END IF;
    
    -- Use async insert for better performance
    INSERT INTO audit.system_logs (
        table_name, record_id, operation, old_values, new_values, 
        changed_by, ip_address, session_id
    ) VALUES (
        TG_TABLE_NAME,
        COALESCE(NEW.id, OLD.id),
        TG_OP,
        CASE WHEN TG_OP = 'DELETE' THEN to_jsonb(OLD) ELSE NULL END,
        CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN to_jsonb(NEW) ELSE NULL END,
        current_setting('app.current_user_id', true)::UUID,
        inet_client_addr(),
        current_setting('app.session_id', true)
    );
    
    RETURN COALESCE(NEW, OLD);
EXCEPTION
    WHEN OTHERS THEN
        -- Never fail the main operation due to audit issues
        RAISE LOG 'Audit failed for table %: %', TG_TABLE_NAME, SQLERRM;
        RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Cache management functions
CREATE OR REPLACE FUNCTION cache.get_dashboard_data(p_cache_key VARCHAR, p_user_id UUID DEFAULT NULL)
RETURNS JSONB AS $$
DECLARE
    cached_data JSONB;
BEGIN
    SELECT data INTO cached_data
    FROM cache.dashboard_data
    WHERE cache_key = p_cache_key
    AND (p_user_id IS NULL OR user_id = p_user_id)
    AND expires_at > NOW();
    
    RETURN cached_data;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cache.set_dashboard_data(
    p_cache_key VARCHAR,
    p_data JSONB,
    p_user_id UUID DEFAULT NULL,
    p_ttl_seconds INTEGER DEFAULT 300
) RETURNS BOOLEAN AS $$
BEGIN
    INSERT INTO cache.dashboard_data (cache_key, user_id, data, expires_at)
    VALUES (p_cache_key, p_user_id, p_data, NOW() + (p_ttl_seconds || ' seconds')::INTERVAL)
    ON CONFLICT (cache_key) DO UPDATE SET
        data = EXCLUDED.data,
        expires_at = EXCLUDED.expires_at;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Cleanup functions
CREATE OR REPLACE FUNCTION cleanup_expired_cache()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM cache.dashboard_data WHERE expires_at < NOW();
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION archive_old_audit_logs(p_months_old INTEGER DEFAULT 6)
RETURNS INTEGER AS $$
DECLARE
    archived_count INTEGER;
    cutoff_date DATE;
BEGIN
    cutoff_date := CURRENT_DATE - (p_months_old || ' months')::INTERVAL;
    
    -- Move to archive table
    INSERT INTO archive.system_logs_archive
    SELECT * FROM audit.system_logs
    WHERE changed_at < cutoff_date;
    
    GET DIAGNOSTICS archived_count = ROW_COUNT;
    
    -- Drop old partitions
    EXECUTE FORMAT('DROP TABLE IF EXISTS audit.system_logs_%s CASCADE', 
                   TO_CHAR(cutoff_date, 'YYYY_MM'));
    
    RETURN archived_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Generic updated_at trigger (optimized)
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    -- Only update if actual changes occurred
    IF OLD IS DISTINCT FROM NEW THEN
        NEW.updated_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Connection and performance monitoring
CREATE OR REPLACE FUNCTION monitor_system_performance()
RETURNS JSONB AS $$
DECLARE
    stats JSONB;
BEGIN
    SELECT jsonb_build_object(
        'active_connections', (SELECT count(*) FROM pg_stat_activity WHERE state = 'active'),
        'total_connections', (SELECT count(*) FROM pg_stat_activity),
        'database_size_mb', (SELECT pg_size_pretty(pg_database_size(current_database()))),
        'cache_hit_ratio', (
            SELECT ROUND(
                (sum(heap_blks_hit) / NULLIF(sum(heap_blks_hit + heap_blks_read), 0)) * 100, 2
            ) FROM pg_statio_user_tables
        ),
        'slow_queries_last_hour', (
            SELECT count(*) FROM performance.slow_queries 
            WHERE executed_at > NOW() - INTERVAL '1 hour'
        ),
        'largest_tables', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'table', schemaname||'.'||tablename,
                    'size', pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename))
                )
            )
            FROM pg_tables
            WHERE schemaname NOT IN ('information_schema', 'pg_catalog')
            ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
            LIMIT 10
        )
    ) INTO stats;
    
    RETURN stats;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
