-- =============================================
-- PRODUCTION BACKGROUND JOBS & MAINTENANCE
-- =============================================

-- Background job queue table for async processing
CREATE TABLE background_jobs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    job_type VARCHAR(100) NOT NULL,
    job_name VARCHAR(200) NOT NULL,
    payload JSONB DEFAULT '{}',
    priority INTEGER DEFAULT 5 CHECK (priority >= 1 AND priority <= 10),
    
    -- Scheduling
    scheduled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    failed_at TIMESTAMP WITH TIME ZONE,
    
    -- Retry logic
    max_attempts INTEGER DEFAULT 3,
    current_attempt INTEGER DEFAULT 0,
    last_error TEXT,
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN (
        'pending', 'processing', 'completed', 'failed', 'cancelled'
    )),
    
    -- Metadata
    created_by UUID REFERENCES user_profiles(id),
    progress_percentage INTEGER DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Indexes for job queue
CREATE INDEX CONCURRENTLY idx_background_jobs_status_priority ON background_jobs(status, priority DESC, scheduled_at) 
    WHERE status IN ('pending', 'processing');
CREATE INDEX CONCURRENTLY idx_background_jobs_type ON background_jobs(job_type);
CREATE INDEX CONCURRENTLY idx_background_jobs_scheduled ON background_jobs(scheduled_at) 
    WHERE status = 'pending';

-- System maintenance logs
CREATE TABLE maintenance_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    maintenance_type VARCHAR(100) NOT NULL,
    description TEXT,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Results
    status VARCHAR(20) DEFAULT 'running' CHECK (status IN ('running', 'completed', 'failed')),
    records_processed INTEGER DEFAULT 0,
    records_affected INTEGER DEFAULT 0,
    execution_time_ms INTEGER,
    error_message TEXT,
    
    -- Details
    details JSONB DEFAULT '{}',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- =============================================
-- STATISTICS UPDATE FUNCTIONS
-- =============================================

-- Update student statistics (run every 2 hours)
CREATE OR REPLACE FUNCTION sp_update_student_statistics(p_batch_size INTEGER DEFAULT 500)
RETURNS JSONB AS $$
DECLARE
    v_log_id UUID;
    v_start_time TIMESTAMP WITH TIME ZONE;
    v_processed INTEGER := 0;
    v_updated INTEGER := 0;
    student_batch RECORD;
    result JSONB;
BEGIN
    v_start_time := clock_timestamp();
    
    -- Create maintenance log
    INSERT INTO maintenance_logs (maintenance_type, description)
    VALUES ('student_statistics', 'Updating student statistics and metrics')
    RETURNING id INTO v_log_id;
    
    -- Process students in batches
    FOR student_batch IN
        SELECT id FROM students 
        WHERE is_active = true 
        AND (updated_at < NOW() - INTERVAL '2 hours' OR total_study_hours = 0)
        ORDER BY last_activity_at DESC
        LIMIT p_batch_size
    LOOP
        UPDATE students SET
            courses_enrolled = (
                SELECT COUNT(*) 
                FROM course_enrollments ce 
                WHERE ce.student_id = student_batch.id AND ce.is_active = true
            ),
            courses_completed = (
                SELECT COUNT(*) 
                FROM course_enrollments ce 
                WHERE ce.student_id = student_batch.id AND ce.completed_at IS NOT NULL
            ),
            total_study_hours = (
                SELECT COALESCE(SUM(lp.total_watch_time_seconds / 3600.0), 0)
                FROM lesson_progress lp 
                WHERE lp.student_id = student_batch.id
            ),
            last_activity_at = (
                SELECT GREATEST(
                    MAX(lp.last_accessed_at),
                    MAX(ce.last_accessed_at),
                    MAX(ta.submitted_at),
                    MAX(asub.updated_at)
                )
                FROM lesson_progress lp
                FULL OUTER JOIN course_enrollments ce ON lp.student_id = ce.student_id
                FULL OUTER JOIN test_attempts ta ON lp.student_id = ta.student_id
                FULL OUTER JOIN assignment_submissions asub ON lp.student_id = asub.student_id
                WHERE lp.student_id = student_batch.id 
                OR ce.student_id = student_batch.id
                OR ta.student_id = student_batch.id
                OR asub.student_id = student_batch.id
            ),
            updated_at = NOW()
        WHERE id = student_batch.id;
        
        GET DIAGNOSTICS v_updated = ROW_COUNT;
        v_processed := v_processed + 1;
    END LOOP;
    
    -- Update maintenance log
    UPDATE maintenance_logs SET
        status = 'completed',
        completed_at = NOW(),
        records_processed = v_processed,
        records_affected = v_updated,
        execution_time_ms = EXTRACT(MILLISECONDS FROM clock_timestamp() - v_start_time)::INTEGER,
        details = jsonb_build_object('batch_size', p_batch_size)
    WHERE id = v_log_id;
    
    result := jsonb_build_object(
        'success', true,
        'processed', v_processed,
        'updated', v_updated,
        'execution_time_ms', EXTRACT(MILLISECONDS FROM clock_timestamp() - v_start_time)::INTEGER
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update course statistics (run every hour)
CREATE OR REPLACE FUNCTION sp_update_course_statistics(p_batch_size INTEGER DEFAULT 200)
RETURNS JSONB AS $$
DECLARE
    v_log_id UUID;
    v_start_time TIMESTAMP WITH TIME ZONE;
    v_processed INTEGER := 0;
    v_updated INTEGER := 0;
    course_batch RECORD;
    result JSONB;
BEGIN
    v_start_time := clock_timestamp();
    
    INSERT INTO maintenance_logs (maintenance_type, description)
    VALUES ('course_statistics', 'Updating course enrollment and performance statistics')
    RETURNING id INTO v_log_id;
    
    FOR course_batch IN
        SELECT id FROM courses 
        WHERE status = 'published' 
        AND (updated_at < NOW() - INTERVAL '1 hour' OR enrollment_count = 0)
        ORDER BY created_at DESC
        LIMIT p_batch_size
    LOOP
        UPDATE courses SET
            enrollment_count = (
                SELECT COUNT(*) 
                FROM course_enrollments ce 
                WHERE ce.course_id = course_batch.id AND ce.is_active = true
            ),
            completion_count = (
                SELECT COUNT(*) 
                FROM course_enrollments ce 
                WHERE ce.course_id = course_batch.id AND ce.completed_at IS NOT NULL
            ),
            total_lessons = (
                SELECT COUNT(*) 
                FROM lessons l 
                WHERE l.course_id = course_batch.id AND l.is_published = true AND l.is_deleted = false
            ),
            total_duration_minutes = (
                SELECT COALESCE(SUM(l.estimated_completion_minutes), 0)
                FROM lessons l 
                WHERE l.course_id = course_batch.id AND l.is_published = true AND l.is_deleted = false
            ),
            total_revenue = (
                SELECT COALESCE(SUM(p.final_amount), 0)
                FROM payments p 
                WHERE p.item_type = 'course' AND p.item_id = course_batch.id AND p.status = 'completed'
            ),
            average_rating = (
                SELECT COALESCE(AVG(ce.rating), 0)
                FROM course_enrollments ce
                WHERE ce.course_id = course_batch.id AND ce.rating IS NOT NULL
            ),
            total_reviews = (
                SELECT COUNT(*)
                FROM course_enrollments ce
                WHERE ce.course_id = course_batch.id AND ce.rating IS NOT NULL
            ),
            updated_at = NOW()
        WHERE id = course_batch.id;
        
        v_processed := v_processed + 1;
    END LOOP;
    
    UPDATE maintenance_logs SET
        status = 'completed',
        completed_at = NOW(),
        records_processed = v_processed,
        execution_time_ms = EXTRACT(MILLISECONDS FROM clock_timestamp() - v_start_time)::INTEGER
    WHERE id = v_log_id;
    
    result := jsonb_build_object(
        'success', true,
        'processed', v_processed,
        'execution_time_ms', EXTRACT(MILLISECONDS FROM clock_timestamp() - v_start_time)::INTEGER
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update teacher statistics (run daily)
CREATE OR REPLACE FUNCTION sp_update_teacher_statistics(p_batch_size INTEGER DEFAULT 100)
RETURNS JSONB AS $$
DECLARE
    v_log_id UUID;
    v_start_time TIMESTAMP WITH TIME ZONE;
    v_processed INTEGER := 0;
    teacher_batch RECORD;
    result JSONB;
BEGIN
    v_start_time := clock_timestamp();
    
    INSERT INTO maintenance_logs (maintenance_type, description)
    VALUES ('teacher_statistics', 'Updating teacher performance metrics')
    RETURNING id INTO v_log_id;
    
    FOR teacher_batch IN
        SELECT id FROM teachers 
        WHERE is_active = true 
        AND (updated_at < NOW() - INTERVAL '24 hours' OR total_courses = 0)
        LIMIT p_batch_size
    LOOP
        UPDATE teachers SET
            total_courses = (
                SELECT COUNT(DISTINCT c.id) 
                FROM courses c 
                WHERE c.primary_teacher_id = teacher_batch.id AND c.status = 'published'
            ),
            active_courses = (
                SELECT COUNT(DISTINCT c.id) 
                FROM courses c 
                WHERE c.primary_teacher_id = teacher_batch.id 
                AND c.status = 'published' 
                AND EXISTS (
                    SELECT 1 FROM course_enrollments ce 
                    WHERE ce.course_id = c.id AND ce.last_accessed_at >= NOW() - INTERVAL '30 days'
                )
            ),
            total_students = (
                SELECT COUNT(DISTINCT ce.student_id) 
                FROM course_enrollments ce
                JOIN courses c ON ce.course_id = c.id
                WHERE c.primary_teacher_id = teacher_batch.id AND ce.is_active = true
            ),
            total_revenue = (
                SELECT COALESCE(SUM(p.final_amount), 0)
                FROM payments p
                JOIN courses c ON p.item_type = 'course' AND p.item_id = c.id
                WHERE c.primary_teacher_id = teacher_batch.id AND p.status = 'completed'
            ),
            average_rating = (
                SELECT COALESCE(AVG(c.average_rating), 0)
                FROM courses c
                WHERE c.primary_teacher_id = teacher_batch.id AND c.total_reviews > 0
            ),
            total_reviews = (
                SELECT COALESCE(SUM(c.total_reviews), 0)
                FROM courses c
                WHERE c.primary_teacher_id = teacher_batch.id
            ),
            last_course_created_at = (
                SELECT MAX(c.created_at)
                FROM courses c
                WHERE c.primary_teacher_id = teacher_batch.id
            ),
            last_class_conducted_at = (
                SELECT MAX(lc.actual_end)
                FROM live_classes lc
                WHERE lc.teacher_id = teacher_batch.id AND lc.status = 'completed'
            ),
            updated_at = NOW()
        WHERE id = teacher_batch.id;
        
        v_processed := v_processed + 1;
    END LOOP;
    
    UPDATE maintenance_logs SET
        status = 'completed',
        completed_at = NOW(),
        records_processed = v_processed,
        execution_time_ms = EXTRACT(MILLISECONDS FROM clock_timestamp() - v_start_time)::INTEGER
    WHERE id = v_log_id;
    
    result := jsonb_build_object(
        'success', true,
        'processed', v_processed,
        'execution_time_ms', EXTRACT(MILLISECONDS FROM clock_timestamp() - v_start_time)::INTEGER
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update coaching center statistics (run daily)
CREATE OR REPLACE FUNCTION sp_update_coaching_center_statistics(p_batch_size INTEGER DEFAULT 50)
RETURNS JSONB AS $$
DECLARE
    v_log_id UUID;
    v_start_time TIMESTAMP WITH TIME ZONE;
    v_processed INTEGER := 0;
    center_batch RECORD;
    result JSONB;
BEGIN
    v_start_time := clock_timestamp();
    
    INSERT INTO maintenance_logs (maintenance_type, description)
    VALUES ('coaching_center_statistics', 'Updating coaching center metrics')
    RETURNING id INTO v_log_id;
    
    FOR center_batch IN
        SELECT id FROM coaching_centers 
        WHERE is_active = true 
        AND (updated_at < NOW() - INTERVAL '24 hours' OR total_students = 0)
        LIMIT p_batch_size
    LOOP
        UPDATE coaching_centers SET
            active_teachers = (
                SELECT COUNT(*) 
                FROM teachers t 
                WHERE t.coaching_center_id = center_batch.id AND t.is_active = true
            ),
            published_courses = (
                SELECT COUNT(*) 
                FROM courses c 
                WHERE c.coaching_center_id = center_batch.id AND c.status = 'published'
            ),
            total_students = (
                SELECT COUNT(DISTINCT ce.student_id) 
                FROM course_enrollments ce
                JOIN courses c ON ce.course_id = c.id
                WHERE c.coaching_center_id = center_batch.id AND ce.is_active = true
            ),
            total_revenue = (
                SELECT COALESCE(SUM(p.final_amount), 0)
                FROM payments p
                LEFT JOIN courses c ON p.item_type = 'course' AND p.item_id = c.id
                LEFT JOIN live_classes lc ON p.item_type = 'live_class' AND p.item_id = lc.id
                WHERE (c.coaching_center_id = center_batch.id OR lc.coaching_center_id = center_batch.id)
                AND p.status = 'completed'
            ),
            average_rating = (
                SELECT COALESCE(AVG(c.average_rating), 0)
                FROM courses c
                WHERE c.coaching_center_id = center_batch.id AND c.total_reviews > 0
            ),
            total_reviews = (
                SELECT COALESCE(SUM(c.total_reviews), 0)
                FROM courses c
                WHERE c.coaching_center_id = center_batch.id
            ),
            updated_at = NOW()
        WHERE id = center_batch.id;
        
        v_processed := v_processed + 1;
    END LOOP;
    
    UPDATE maintenance_logs SET
        status = 'completed',
        completed_at = NOW(),
        records_processed = v_processed,
        execution_time_ms = EXTRACT(MILLISECONDS FROM clock_timestamp() - v_start_time)::INTEGER
    WHERE id = v_log_id;
    
    result := jsonb_build_object(
        'success', true,
        'processed', v_processed,
        'execution_time_ms', EXTRACT(MILLISECONDS FROM clock_timestamp() - v_start_time)::INTEGER
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- CLEANUP AND MAINTENANCE FUNCTIONS
-- =============================================

-- Archive old audit logs (run weekly)
CREATE OR REPLACE FUNCTION sp_archive_old_audit_logs(p_months_old INTEGER DEFAULT 6)
RETURNS JSONB AS $$
DECLARE
    v_log_id UUID;
    v_start_time TIMESTAMP WITH TIME ZONE;
    v_archived INTEGER := 0;
    v_cutoff_date TIMESTAMP WITH TIME ZONE;
    partition_record RECORD;
    result JSONB;
BEGIN
    v_start_time := clock_timestamp();
    v_cutoff_date := NOW() - (p_months_old || ' months')::INTERVAL;
    
    INSERT INTO maintenance_logs (maintenance_type, description)
    VALUES ('audit_log_archive', 'Archiving old audit log partitions older than ' || p_months_old || ' months')
    RETURNING id INTO v_log_id;
    
    -- Create archive table if it doesn't exist
    CREATE TABLE IF NOT EXISTS archive.system_logs_archive (
        LIKE audit.system_logs INCLUDING ALL
    );
    
    -- Archive old partitions
    FOR partition_record IN
        SELECT schemaname, tablename, pg_get_expr(pg_class.relpartbound, pg_class.oid, true) as partition_bound
        FROM pg_tables 
        JOIN pg_class ON pg_tables.tablename = pg_class.relname
        JOIN pg_namespace ON pg_class.relnamespace = pg_namespace.oid
        WHERE schemaname = 'audit' 
        AND tablename LIKE 'system_logs_%'
        AND tablename != 'system_logs'
        AND pg_class.relpartbound IS NOT NULL
    LOOP
        -- Extract partition date and check if it's old enough to archive
        IF partition_record.tablename ~ '^\w+_\d{4}_\d{2}$' THEN
            DECLARE
                partition_date DATE;
                partition_month TEXT;
            BEGIN
                partition_month := RIGHT(partition_record.tablename, 7); -- Get YYYY_MM
                partition_date := TO_DATE(partition_month, 'YYYY_MM');
                
                IF partition_date < DATE_TRUNC('month', v_cutoff_date) THEN
                    -- Move data to archive
                    EXECUTE FORMAT('
                        INSERT INTO archive.system_logs_archive 
                        SELECT * FROM audit.%I
                    ', partition_record.tablename);
                    
                    GET DIAGNOSTICS v_archived = ROW_COUNT;
                    
                    -- Drop the old partition
                    EXECUTE FORMAT('DROP TABLE audit.%I', partition_record.tablename);
                    
                    RAISE NOTICE 'Archived % records from partition %', v_archived, partition_record.tablename;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    RAISE WARNING 'Failed to archive partition %: %', partition_record.tablename, SQLERRM;
                    CONTINUE;
            END;
        END IF;
    END LOOP;
    
    UPDATE maintenance_logs SET
        status = 'completed',
        completed_at = NOW(),
        records_processed = v_archived,
        execution_time_ms = EXTRACT(MILLISECONDS FROM clock_timestamp() - v_start_time)::INTEGER,
        details = jsonb_build_object('cutoff_date', v_cutoff_date, 'months_old', p_months_old)
    WHERE id = v_log_id;
    
    result := jsonb_build_object(
        'success', true,
        'archived_records', v_archived,
        'cutoff_date', v_cutoff_date,
        'execution_time_ms', EXTRACT(MILLISECONDS FROM clock_timestamp() - v_start_time)::INTEGER
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Clean up expired cache entries (run every hour)
CREATE OR REPLACE FUNCTION sp_cleanup_expired_cache()
RETURNS JSONB AS $$
DECLARE
    v_log_id UUID;
    v_start_time TIMESTAMP WITH TIME ZONE;
    v_deleted INTEGER := 0;
    result JSONB;
BEGIN
    v_start_time := clock_timestamp();
    
    INSERT INTO maintenance_logs (maintenance_type, description)
    VALUES ('cache_cleanup', 'Cleaning up expired cache entries')
    RETURNING id INTO v_log_id;
    
    -- Delete expired cache entries
    DELETE FROM cache.dashboard_data 
    WHERE expires_at < NOW();
    
    GET DIAGNOSTICS v_deleted = ROW_COUNT;
    
    UPDATE maintenance_logs SET
        status = 'completed',
        completed_at = NOW(),
        records_affected = v_deleted,
        execution_time_ms = EXTRACT(MILLISECONDS FROM clock_timestamp() - v_start_time)::INTEGER
    WHERE id = v_log_id;
    
    result := jsonb_build_object(
        'success', true,
        'deleted_entries', v_deleted,
        'execution_time_ms', EXTRACT(MILLISECONDS FROM clock_timestamp() - v_start_time)::INTEGER
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Clean up old completed background jobs (run daily)
CREATE OR REPLACE FUNCTION sp_cleanup_old_background_jobs(p_days_old INTEGER DEFAULT 7)
RETURNS JSONB AS $$
DECLARE
    v_log_id UUID;
    v_start_time TIMESTAMP WITH TIME ZONE;
    v_deleted INTEGER := 0;
    result JSONB;
BEGIN
    v_start_time := clock_timestamp();
    
    INSERT INTO maintenance_logs (maintenance_type, description)
    VALUES ('background_jobs_cleanup', 'Cleaning up old completed background jobs older than ' || p_days_old || ' days')
    RETURNING id INTO v_log_id;
    
    DELETE FROM background_jobs 
    WHERE status IN ('completed', 'failed', 'cancelled')
    AND updated_at < NOW() - (p_days_old || ' days')::INTERVAL;
    
    GET DIAGNOSTICS v_deleted = ROW_COUNT;
    
    UPDATE maintenance_logs SET
        status = 'completed',
        completed_at = NOW(),
        records_affected = v_deleted,
        execution_time_ms = EXTRACT(MILLISECONDS FROM clock_timestamp() - v_start_time)::INTEGER,
        details = jsonb_build_object('days_old', p_days_old)
    WHERE id = v_log_id;
    
    result := jsonb_build_object(
        'success', true,
        'deleted_jobs', v_deleted,
        'execution_time_ms', EXTRACT(MILLISECONDS FROM clock_timestamp() - v_start_time)::INTEGER
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update database statistics (run weekly)
CREATE OR REPLACE FUNCTION sp_update_database_statistics()
RETURNS JSONB AS $$
DECLARE
    v_log_id UUID;
    v_start_time TIMESTAMP WITH TIME ZONE;
    result JSONB;
BEGIN
    v_start_time := clock_timestamp();
    
    INSERT INTO maintenance_logs (maintenance_type, description)
    VALUES ('database_statistics', 'Updating PostgreSQL statistics for query optimization')
    RETURNING id INTO v_log_id;
    
    -- Update table statistics
    ANALYZE;
    
    -- Refresh materialized views
    REFRESH MATERIALIZED VIEW CONCURRENTLY analytics.student_performance_summary;
    REFRESH MATERIALIZED VIEW CONCURRENTLY analytics.course_performance_summary;
    REFRESH MATERIALIZED VIEW CONCURRENTLY analytics.financial_summary;
    
    UPDATE maintenance_logs SET
        status = 'completed',
        completed_at = NOW(),
        execution_time_ms = EXTRACT(MILLISECONDS FROM clock_timestamp() - v_start_time)::INTEGER
    WHERE id = v_log_id;
    
    result := jsonb_build_object(
        'success', true,
        'message', 'Database statistics and materialized views updated successfully',
        'execution_time_ms', EXTRACT(MILLISECONDS FROM clock_timestamp() - v_start_time)::INTEGER
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- BACKGROUND JOB PROCESSING FUNCTIONS
-- =============================================

-- Process background jobs (called by job runner)
CREATE OR REPLACE FUNCTION sp_process_background_jobs(p_max_jobs INTEGER DEFAULT 10)
RETURNS JSONB AS $$
DECLARE
    v_processed INTEGER := 0;
    v_failed INTEGER := 0;
    job_record RECORD;
    job_result JSONB;
    result JSONB;
BEGIN
    -- Get pending jobs ordered by priority and scheduled time
    FOR job_record IN
        SELECT * FROM background_jobs
        WHERE status = 'pending' 
        AND scheduled_at <= NOW()
        ORDER BY priority DESC, scheduled_at ASC
        LIMIT p_max_jobs
        FOR UPDATE SKIP LOCKED
    LOOP
        BEGIN
            -- Mark job as processing
            UPDATE background_jobs SET
                status = 'processing',
                started_at = NOW(),
                current_attempt = current_attempt + 1,
                updated_at = NOW()
            WHERE id = job_record.id;
            
            -- Execute job based on type
            CASE job_record.job_type
                WHEN 'update_student_statistics' THEN
                    job_result := sp_update_student_statistics(
                        COALESCE((job_record.payload->>'batch_size')::INTEGER, 500)
                    );
                    
                WHEN 'update_course_statistics' THEN
                    job_result := sp_update_course_statistics(
                        COALESCE((job_record.payload->>'batch_size')::INTEGER, 200)
                    );
                    
                WHEN 'update_teacher_statistics' THEN
                    job_result := sp_update_teacher_statistics(
                        COALESCE((job_record.payload->>'batch_size')::INTEGER, 100)
                    );
                    
                WHEN 'cleanup_expired_cache' THEN
                    job_result := sp_cleanup_expired_cache();
                    
                WHEN 'refresh_analytics_views' THEN
                    job_result := sp_refresh_analytics_views();
                    
                ELSE
                    job_result := jsonb_build_object('success', false, 'message', 'Unknown job type');
            END CASE;
            
            -- Mark job as completed or failed
            IF (job_result->>'success')::BOOLEAN THEN
                UPDATE background_jobs SET
                    status = 'completed',
                    completed_at = NOW(),
                    progress_percentage = 100,
                    updated_at = NOW()
                WHERE id = job_record.id;
                
                v_processed := v_processed + 1;
            ELSE
                UPDATE background_jobs SET
                    status = CASE 
                        WHEN current_attempt >= max_attempts THEN 'failed'
                        ELSE 'pending'
                    END,
                    failed_at = CASE 
                        WHEN current_attempt >= max_attempts THEN NOW()
                        ELSE NULL
                    END,
                    scheduled_at = CASE
                        WHEN current_attempt < max_attempts THEN NOW() + (current_attempt || ' minutes')::INTERVAL
                        ELSE scheduled_at
                    END,
                    last_error = job_result->>'message',
                    updated_at = NOW()
                WHERE id = job_record.id;
                
                v_failed := v_failed + 1;
            END IF;
            
        EXCEPTION
            WHEN OTHERS THEN
                -- Handle unexpected errors
                UPDATE background_jobs SET
                    status = CASE 
                        WHEN current_attempt >= max_attempts THEN 'failed'
                        ELSE 'pending'
                    END,
                    failed_at = CASE 
                        WHEN current_attempt >= max_attempts THEN NOW()
                        ELSE NULL
                    END,
                    scheduled_at = CASE
                        WHEN current_attempt < max_attempts THEN NOW() + (current_attempt || ' minutes')::INTERVAL
                        ELSE scheduled_at
                    END,
                    last_error = 'Unexpected error: ' || SQLERRM,
                    updated_at = NOW()
                WHERE id = job_record.id;
                
                v_failed := v_failed + 1;
        END;
    END LOOP;
    
    result := jsonb_build_object(
        'success', true,
        'processed', v_processed,
        'failed', v_failed,
        'total', v_processed + v_failed
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Schedule a background job
CREATE OR REPLACE FUNCTION sp_schedule_background_job(
    p_job_type VARCHAR,
    p_job_name VARCHAR,
    p_payload JSONB DEFAULT '{}',
    p_priority INTEGER DEFAULT 5,
    p_scheduled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    p_created_by UUID DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_job_id UUID;
BEGIN
    INSERT INTO background_jobs (
        job_type, job_name, payload, priority, scheduled_at, created_by
    ) VALUES (
        p_job_type, p_job_name, p_payload, p_priority, p_scheduled_at, p_created_by
    ) RETURNING id INTO v_job_id;
    
    RETURN v_job_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- SCHEDULED MAINTENANCE SETUP
-- =============================================

-- If pg_cron is available, schedule maintenance jobs
DO $$
BEGIN
    -- Check if pg_cron extension exists
    IF EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'pg_cron') THEN
        -- Create the extension if it doesn't exist
        CREATE EXTENSION IF NOT EXISTS pg_cron;
        
        -- Schedule maintenance jobs
        PERFORM cron.schedule('update-student-stats', '0 */2 * * *', 'SELECT sp_update_student_statistics(500);'); -- Every 2 hours
        PERFORM cron.schedule('update-course-stats', '30 * * * *', 'SELECT sp_update_course_statistics(200);'); -- Every hour at :30
        PERFORM cron.schedule('update-teacher-stats', '0 2 * * *', 'SELECT sp_update_teacher_statistics(100);'); -- Daily at 2 AM
        PERFORM cron.schedule('update-center-stats', '0 3 * * *', 'SELECT sp_update_coaching_center_statistics(50);'); -- Daily at 3 AM
        PERFORM cron.schedule('cleanup-cache', '0 * * * *', 'SELECT sp_cleanup_expired_cache();'); -- Every hour
        PERFORM cron.schedule('cleanup-jobs', '0 4 * * *', 'SELECT sp_cleanup_old_background_jobs(7);'); -- Daily at 4 AM
        PERFORM cron.schedule('archive-audit-logs', '0 5 * * 0', 'SELECT sp_archive_old_audit_logs(6);'); -- Weekly on Sunday at 5 AM
        PERFORM cron.schedule('update-db-statistics', '0 6 * * 0', 'SELECT sp_update_database_statistics();'); -- Weekly on Sunday at 6 AM
        PERFORM cron.schedule('refresh-analytics', '0 1 * * *', 'SELECT sp_refresh_analytics_views();'); -- Daily at 1 AM
        
        RAISE NOTICE 'Scheduled maintenance jobs created successfully';
    ELSE
        RAISE NOTICE 'pg_cron extension not available. Use external job scheduler to run maintenance functions';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Failed to setup pg_cron: %', SQLERRM;
END $$;

-- Apply audit triggers to maintenance tables
CREATE TRIGGER trg_updated_at_background_jobs BEFORE UPDATE ON background_jobs 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
