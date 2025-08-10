-- =============================================
-- PRODUCTION-READY ANALYTICS & REPORTS SYSTEM
-- =============================================

-- Custom reports configuration with advanced features
CREATE TABLE custom_reports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_by UUID REFERENCES user_profiles(id) ON DELETE CASCADE NOT NULL,
    coaching_center_id UUID REFERENCES coaching_centers(id) ON DELETE CASCADE, -- NULL for admin reports
    
    -- Report metadata
    report_name VARCHAR(255) NOT NULL,
    description TEXT,
    report_category VARCHAR(50) DEFAULT 'custom' CHECK (report_category IN (
        'student_performance', 'course_analytics', 'financial', 'engagement', 
        'attendance', 'assessment', 'custom', 'compliance'
    )),
    
    -- Report configuration
    data_sources TEXT[] NOT NULL, -- Tables/views to query
    base_query TEXT, -- Base SQL query
    filters JSONB DEFAULT '{}', -- Default filters
    grouping JSONB DEFAULT '{}', -- Group by configurations
    sorting JSONB DEFAULT '{}', -- Sort configurations
    aggregations JSONB DEFAULT '{}', -- SUM, AVG, COUNT configurations
    
    -- Visualization settings
    chart_type VARCHAR(50) DEFAULT 'table' CHECK (chart_type IN (
        'table', 'bar_chart', 'line_chart', 'pie_chart', 'donut_chart', 
        'area_chart', 'scatter_plot', 'heatmap', 'gauge', 'funnel'
    )),
    chart_config JSONB DEFAULT '{}',
    columns_config JSONB DEFAULT '{}', -- Column visibility, formatting
    
    -- Access control and sharing
    visibility VARCHAR(20) DEFAULT 'private' CHECK (visibility IN ('private', 'shared', 'public')),
    allowed_user_types TEXT[] DEFAULT '{}',
    shared_with_users UUID[] DEFAULT '{}',
    
    -- Scheduling and automation
    is_scheduled BOOLEAN DEFAULT false,
    schedule_cron VARCHAR(100), -- Cron expression for scheduling
    auto_email_recipients TEXT[] DEFAULT '{}',
    
    -- Performance and caching
    cache_duration_minutes INTEGER DEFAULT 60,
    last_executed_at TIMESTAMP WITH TIME ZONE,
    execution_count INTEGER DEFAULT 0,
    average_execution_time_ms INTEGER DEFAULT 0,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    is_deleted BOOLEAN DEFAULT false,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Report executions with detailed tracking
CREATE TABLE report_executions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    report_id UUID REFERENCES custom_reports(id) ON DELETE CASCADE NOT NULL,
    executed_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    
    -- Execution details
    execution_type VARCHAR(20) DEFAULT 'manual' CHECK (execution_type IN ('manual', 'scheduled', 'api')),
    execution_time_ms INTEGER,
    row_count INTEGER,
    
    -- Applied filters and parameters
    applied_filters JSONB DEFAULT '{}',
    date_range JSONB DEFAULT '{}',
    custom_parameters JSONB DEFAULT '{}',
    
    -- Output and export
    output_format VARCHAR(10) DEFAULT 'json' CHECK (output_format IN ('json', 'csv', 'xlsx', 'pdf')),
    file_url TEXT,
    file_size_bytes INTEGER,
    
    -- Status and error handling
    status VARCHAR(20) DEFAULT 'running' CHECK (status IN ('running', 'completed', 'failed', 'timeout', 'cancelled')),
    error_message TEXT,
    error_details JSONB DEFAULT '{}',
    
    -- Performance metrics
    query_execution_time_ms INTEGER,
    data_processing_time_ms INTEGER,
    export_time_ms INTEGER,
    
    executed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- =============================================
-- MATERIALIZED VIEWS FOR HIGH-PERFORMANCE ANALYTICS
-- =============================================

-- Comprehensive student performance analytics
CREATE MATERIALIZED VIEW analytics.student_performance_summary AS
SELECT 
    s.id as student_id,
    s.student_id as student_code,
    up.first_name || ' ' || up.last_name as student_name,
    up.city,
    up.state,
    s.grade_level,
    s.education_board,
    s.primary_subject,
    
    -- Course metrics
    s.courses_enrolled,
    s.courses_completed,
    CASE 
        WHEN s.courses_enrolled > 0 
        THEN ROUND((s.courses_completed::DECIMAL / s.courses_enrolled) * 100, 2)
        ELSE 0 
    END as completion_rate_percentage,
    
    -- Study time metrics
    s.total_study_hours,
    CASE 
        WHEN s.courses_completed > 0 
        THEN ROUND(s.total_study_hours / s.courses_completed, 2)
        ELSE 0 
    END as avg_hours_per_course,
    
    -- Engagement metrics
    s.current_streak,
    s.longest_streak,
    s.total_points,
    s.current_level,
    
    -- Assessment performance
    COALESCE(avg_test_scores.average_score, 0) as average_test_score,
    COALESCE(test_stats.total_tests_taken, 0) as total_tests_taken,
    COALESCE(test_stats.tests_passed, 0) as tests_passed,
    COALESCE(assignment_stats.assignments_submitted, 0) as assignments_submitted,
    COALESCE(assignment_stats.average_assignment_score, 0) as average_assignment_score,
    
    -- Activity metrics
    s.last_activity_at,
    EXTRACT(DAYS FROM NOW() - s.last_activity_at) as days_since_last_activity,
    
    -- Live class participation
    COALESCE(live_class_stats.classes_attended, 0) as live_classes_attended,
    COALESCE(live_class_stats.average_attendance_duration, 0) as avg_class_attendance_minutes,
    
    -- Performance score (weighted calculation)
    ROUND(
        (COALESCE(s.courses_completed, 0) * 0.25 + 
         COALESCE(s.current_streak, 0) * 0.15 + 
         COALESCE(s.total_points / 1000.0, 0) * 0.20 +
         COALESCE(avg_test_scores.average_score / 10.0, 0) * 0.25 +
         COALESCE(assignment_stats.average_assignment_score / 10.0, 0) * 0.15), 2
    ) as performance_score,
    
    -- Risk indicators
    CASE 
        WHEN EXTRACT(DAYS FROM NOW() - s.last_activity_at) > 14 THEN 'at_risk'
        WHEN s.current_streak = 0 AND s.courses_enrolled > 0 THEN 'needs_attention'
        WHEN s.courses_completed::DECIMAL / NULLIF(s.courses_enrolled, 0) < 0.3 THEN 'low_completion'
        ELSE 'active'
    END as risk_category,
    
    -- Last updated
    NOW() as last_calculated_at
    
FROM students s
JOIN user_profiles up ON s.user_id = up.id
LEFT JOIN (
    SELECT 
        ta.student_id,
        AVG(ta.percentage) as average_score
    FROM test_attempts ta
    WHERE ta.is_completed = true AND ta.created_at >= NOW() - INTERVAL '6 months'
    GROUP BY ta.student_id
) avg_test_scores ON s.id = avg_test_scores.student_id
LEFT JOIN (
    SELECT 
        ta.student_id,
        COUNT(*) as total_tests_taken,
        COUNT(*) FILTER (WHERE ta.is_passed = true) as tests_passed
    FROM test_attempts ta
    WHERE ta.is_completed = true AND ta.created_at >= NOW() - INTERVAL '6 months'
    GROUP BY ta.student_id
) test_stats ON s.id = test_stats.student_id
LEFT JOIN (
    SELECT 
        asub.student_id,
        COUNT(*) as assignments_submitted,
        AVG(asub.score * 100.0 / asub.max_score) as average_assignment_score
    FROM assignment_submissions asub
    WHERE asub.is_graded = true AND asub.created_at >= NOW() - INTERVAL '6 months'
    GROUP BY asub.student_id
) assignment_stats ON s.id = assignment_stats.student_id
LEFT JOIN (
    SELECT 
        lcr.student_id,
        COUNT(*) FILTER (WHERE lcr.attended = true) as classes_attended,
        AVG(lcr.total_attendance_minutes) as average_attendance_duration
    FROM live_class_registrations lcr
    WHERE lcr.created_at >= NOW() - INTERVAL '6 months'
    GROUP BY lcr.student_id
) live_class_stats ON s.id = live_class_stats.student_id
WHERE s.is_active = true AND s.is_deleted = false;

-- Course performance analytics with detailed metrics
CREATE MATERIALIZED VIEW analytics.course_performance_summary AS
SELECT 
    c.id as course_id,
    c.title,
    c.category,
    c.difficulty_level,
    cc.center_name as coaching_center,
    cc.id as coaching_center_id,
    up.first_name || ' ' || up.last_name as primary_teacher,
    
    -- Basic metrics
    c.enrollment_count,
    c.completion_count,
    CASE 
        WHEN c.enrollment_count > 0 
        THEN ROUND((c.completion_count::DECIMAL / c.enrollment_count) * 100, 2)
        ELSE 0 
    END as completion_rate_percentage,
    
    -- Content metrics
    c.total_lessons,
    c.total_duration_minutes,
    CASE 
        WHEN c.total_lessons > 0 
        THEN ROUND(c.total_duration_minutes::DECIMAL / c.total_lessons, 1)
        ELSE 0 
    END as avg_lesson_duration,
    
    -- Rating and feedback
    c.average_rating,
    c.total_reviews,
    
    -- Financial metrics
    c.price,
    COALESCE(revenue_data.total_revenue, 0) as total_revenue,
    COALESCE(revenue_data.net_revenue, 0) as net_revenue,
    CASE 
        WHEN c.enrollment_count > 0 
        THEN ROUND(COALESCE(revenue_data.total_revenue, 0) / c.enrollment_count, 2)
        ELSE 0 
    END as revenue_per_student,
    
    -- Progress analytics
    COALESCE(progress_stats.avg_progress_percentage, 0) as avg_student_progress,
    COALESCE(progress_stats.students_25_percent, 0) as students_25_percent_complete,
    COALESCE(progress_stats.students_50_percent, 0) as students_50_percent_complete,
    COALESCE(progress_stats.students_75_percent, 0) as students_75_percent_complete,
    COALESCE(progress_stats.students_completed, 0) as students_completed,
    
    -- Engagement metrics
    COALESCE(engagement_stats.avg_study_time_per_student, 0) as avg_study_time_per_student,
    COALESCE(engagement_stats.active_students_last_week, 0) as active_students_last_week,
    COALESCE(engagement_stats.retention_rate_30_days, 0) as retention_rate_30_days,
    
    -- Assessment performance
    COALESCE(assessment_stats.avg_test_score, 0) as average_test_score,
    COALESCE(assessment_stats.avg_assignment_score, 0) as average_assignment_score,
    
    -- Time-based metrics
    COALESCE(time_stats.avg_completion_days, 0) as avg_completion_days,
    
    -- Course health score (composite metric)
    ROUND(
        (COALESCE(c.average_rating, 0) * 0.2 +
         CASE WHEN c.enrollment_count > 0 THEN (c.completion_count::DECIMAL / c.enrollment_count) * 100 * 0.3 ELSE 0 END +
         COALESCE(engagement_stats.retention_rate_30_days, 0) * 0.25 +
         COALESCE(assessment_stats.avg_test_score, 0) * 0.25), 2
    ) as course_health_score,
    
    -- Last updated
    NOW() as last_calculated_at
    
FROM courses c
JOIN coaching_centers cc ON c.coaching_center_id = cc.id
LEFT JOIN teachers t ON c.primary_teacher_id = t.id
LEFT JOIN user_profiles up ON t.user_id = up.id
LEFT JOIN (
    SELECT 
        p.item_id as course_id,
        SUM(p.final_amount) FILTER (WHERE p.status = 'completed') as total_revenue,
        SUM(p.final_amount) FILTER (WHERE p.status = 'completed') - SUM(p.refund_amount) as net_revenue
    FROM payments p
    WHERE p.item_type = 'course'
    GROUP BY p.item_id
) revenue_data ON c.id = revenue_data.course_id
LEFT JOIN (
    SELECT 
        ce.course_id,
        AVG(ce.progress_percentage) as avg_progress_percentage,
        COUNT(*) FILTER (WHERE ce.progress_percentage >= 25) as students_25_percent,
        COUNT(*) FILTER (WHERE ce.progress_percentage >= 50) as students_50_percent,
        COUNT(*) FILTER (WHERE ce.progress_percentage >= 75) as students_75_percent,
        COUNT(*) FILTER (WHERE ce.completed_at IS NOT NULL) as students_completed
    FROM course_enrollments ce
    WHERE ce.is_active = true
    GROUP BY ce.course_id
) progress_stats ON c.id = progress_stats.course_id
LEFT JOIN (
    SELECT 
        ce.course_id,
        AVG(ce.total_study_minutes) as avg_study_time_per_student,
        COUNT(*) FILTER (WHERE ce.last_accessed_at >= NOW() - INTERVAL '7 days') as active_students_last_week,
        ROUND(
            COUNT(*) FILTER (WHERE ce.last_accessed_at >= NOW() - INTERVAL '30 days')::DECIMAL / 
            NULLIF(COUNT(*), 0) * 100, 2
        ) as retention_rate_30_days
    FROM course_enrollments ce
    WHERE ce.is_active = true
    GROUP BY ce.course_id
) engagement_stats ON c.id = engagement_stats.course_id
LEFT JOIN (
    SELECT 
        t.course_id,
        AVG(ta.percentage) as avg_test_score
    FROM tests t
    JOIN test_attempts ta ON t.id = ta.test_id
    WHERE ta.is_completed = true
    GROUP BY t.course_id
    UNION ALL
    SELECT 
        a.course_id,
        AVG(asub.score * 100.0 / asub.max_score) as avg_assignment_score
    FROM assignments a
    JOIN assignment_submissions asub ON a.id = asub.assignment_id
    WHERE asub.is_graded = true
    GROUP BY a.course_id
) assessment_stats ON c.id = assessment_stats.course_id
LEFT JOIN (
    SELECT 
        ce.course_id,
        AVG(EXTRACT(DAYS FROM ce.completed_at - ce.enrolled_at)) as avg_completion_days
    FROM course_enrollments ce
    WHERE ce.completed_at IS NOT NULL
    GROUP BY ce.course_id
) time_stats ON c.id = time_stats.course_id
WHERE c.status = 'published' AND c.is_deleted = false;

-- Financial analytics with comprehensive revenue tracking
CREATE MATERIALIZED VIEW analytics.financial_summary AS
SELECT 
    cc.id as coaching_center_id,
    cc.center_name,
    cc.subscription_plan,
    
    -- Time dimensions
    DATE_TRUNC('month', p.created_at) as month_year,
    EXTRACT(YEAR FROM p.created_at) as year,
    EXTRACT(MONTH FROM p.created_at) as month,
    EXTRACT(QUARTER FROM p.created_at) as quarter,
    
    -- Payment volume metrics
    COUNT(*) as total_transactions,
    COUNT(*) FILTER (WHERE p.status = 'completed') as successful_payments,
    COUNT(*) FILTER (WHERE p.status = 'failed') as failed_payments,
    ROUND(
        COUNT(*) FILTER (WHERE p.status = 'completed')::DECIMAL / 
        NULLIF(COUNT(*), 0) * 100, 2
    ) as success_rate_percentage,
    
    -- Revenue metrics (all in base currency)
    SUM(p.base_amount) FILTER (WHERE p.status = 'completed') as gross_revenue,
    SUM(p.discount_amount) FILTER (WHERE p.status = 'completed') as total_discounts,
    SUM(p.tax_amount) FILTER (WHERE p.status = 'completed') as total_taxes,
    SUM(p.processing_fee) FILTER (WHERE p.status = 'completed') as total_processing_fees,
    SUM(p.final_amount) FILTER (WHERE p.status = 'completed') as net_revenue,
    SUM(p.refund_amount) as total_refunds,
    SUM(p.final_amount) FILTER (WHERE p.status = 'completed') - SUM(p.refund_amount) as adjusted_net_revenue,
    
    -- Average transaction metrics
    AVG(p.final_amount) FILTER (WHERE p.status = 'completed') as avg_transaction_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY p.final_amount) FILTER (WHERE p.status = 'completed') as median_transaction_value,
    
    -- Payment method breakdown
    COUNT(*) FILTER (WHERE p.payment_method = 'upi' AND p.status = 'completed') as upi_payments,
    COUNT(*) FILTER (WHERE p.payment_method IN ('credit_card', 'debit_card') AND p.status = 'completed') as card_payments,
    COUNT(*) FILTER (WHERE p.payment_method = 'netbanking' AND p.status = 'completed') as netbanking_payments,
    COUNT(*) FILTER (WHERE p.payment_method = 'wallet' AND p.status = 'completed') as wallet_payments,
    
    -- Revenue by payment method
    SUM(p.final_amount) FILTER (WHERE p.payment_method = 'upi' AND p.status = 'completed') as upi_revenue,
    SUM(p.final_amount) FILTER (WHERE p.payment_method IN ('credit_card', 'debit_card') AND p.status = 'completed') as card_revenue,
    SUM(p.final_amount) FILTER (WHERE p.payment_method = 'netbanking' AND p.status = 'completed') as netbanking_revenue,
    
    -- Item type breakdown
    COUNT(*) FILTER (WHERE p.item_type = 'course' AND p.status = 'completed') as course_sales,
    COUNT(*) FILTER (WHERE p.item_type = 'live_class' AND p.status = 'completed') as live_class_sales,
    SUM(p.final_amount) FILTER (WHERE p.item_type = 'course' AND p.status = 'completed') as course_revenue,
    SUM(p.final_amount) FILTER (WHERE p.item_type = 'live_class' AND p.status = 'completed') as live_class_revenue,
    
    -- Discount and promotion metrics
    COUNT(*) FILTER (WHERE p.coupon_code IS NOT NULL AND p.status = 'completed') as transactions_with_coupons,
    AVG(p.discount_amount) FILTER (WHERE p.coupon_code IS NOT NULL AND p.status = 'completed') as avg_discount_per_coupon,
    
    -- Customer metrics
    COUNT(DISTINCT p.student_id) FILTER (WHERE p.status = 'completed') as unique_customers,
    
    -- Last calculated
    NOW() as last_calculated_at
    
FROM payments p
LEFT JOIN courses c ON p.item_type = 'course' AND p.item_id = c.id
LEFT JOIN live_classes lc ON p.item_type = 'live_class' AND p.item_id = lc.id
LEFT JOIN coaching_centers cc ON COALESCE(c.coaching_center_id, lc.coaching_center_id) = cc.id
WHERE p.created_at >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '24 months')
GROUP BY 
    cc.id, cc.center_name, cc.subscription_plan,
    DATE_TRUNC('month', p.created_at),
    EXTRACT(YEAR FROM p.created_at),
    EXTRACT(MONTH FROM p.created_at),
    EXTRACT(QUARTER FROM p.created_at);

-- =============================================
-- ANALYTICS STORED PROCEDURES
-- =============================================

-- Get comprehensive student dashboard analytics
CREATE OR REPLACE FUNCTION sp_get_student_analytics_dashboard(
    p_student_id UUID,
    p_date_from DATE DEFAULT NULL,
    p_date_to DATE DEFAULT NULL
) RETURNS JSONB AS $$
DECLARE
    analytics_data JSONB;
    date_from DATE;
    date_to DATE;
BEGIN
    date_from := COALESCE(p_date_from, CURRENT_DATE - INTERVAL '30 days');
    date_to := COALESCE(p_date_to, CURRENT_DATE);
    
    SELECT jsonb_build_object(
        'student_overview', jsonb_build_object(
            'student_name', spa.student_name,
            'student_code', spa.student_code,
            'grade_level', spa.grade_level,
            'performance_score', spa.performance_score,
            'risk_category', spa.risk_category,
            'current_streak', spa.current_streak,
            'total_points', spa.total_points,
            'current_level', spa.current_level
        ),
        'academic_progress', jsonb_build_object(
            'courses_enrolled', spa.courses_enrolled,
            'courses_completed', spa.courses_completed,
            'completion_rate', spa.completion_rate_percentage,
            'total_study_hours', spa.total_study_hours,
            'avg_hours_per_course', spa.avg_hours_per_course
        ),
        'assessment_performance', jsonb_build_object(
            'total_tests_taken', spa.total_tests_taken,
            'tests_passed', spa.tests_passed,
            'average_test_score', spa.average_test_score,
            'assignments_submitted', spa.assignments_submitted,
            'average_assignment_score', spa.average_assignment_score
        ),
        'engagement_metrics', jsonb_build_object(
            'live_classes_attended', spa.live_classes_attended,
            'avg_class_attendance_minutes', spa.avg_class_attendance_minutes,
            'days_since_last_activity', spa.days_since_last_activity,
            'longest_streak', spa.longest_streak
        ),
        'recent_activity', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'date', lp.last_accessed_at::date,
                    'lesson_title', l.title,
                    'course_title', c.title,
                    'watch_time_minutes', ROUND(lp.total_watch_time_seconds / 60.0, 1),
                    'completion_percentage', lp.completion_percentage,
                    'is_completed', lp.is_completed
                )
                ORDER BY lp.last_accessed_at DESC
            )
            FROM lesson_progress lp
            JOIN lessons l ON lp.lesson_id = l.id
            JOIN courses c ON lp.course_id = c.id
            WHERE lp.student_id = p_student_id
            AND lp.last_accessed_at::date BETWEEN date_from AND date_to
            LIMIT 20
        ),
        'course_progress_details', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'course_id', c.id,
                    'course_title', c.title,
                    'progress_percentage', ce.progress_percentage,
                    'lessons_completed', ce.lessons_completed,
                    'total_lessons', c.total_lessons,
                    'last_accessed', ce.last_accessed_at,
                    'enrollment_date', ce.enrolled_at,
                    'study_time_minutes', ce.total_study_minutes
                )
                ORDER BY ce.last_accessed_at DESC
            )
            FROM course_enrollments ce
            JOIN courses c ON ce.course_id = c.id
            WHERE ce.student_id = p_student_id AND ce.is_active = true
        ),
        'time_spent_trend', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'date', daily_data.date,
                    'study_minutes', daily_data.total_minutes,
                    'lessons_completed', daily_data.lessons_completed
                )
                ORDER BY daily_data.date
            )
            FROM (
                SELECT 
                    lp.last_accessed_at::date as date,
                    SUM(lp.total_watch_time_seconds / 60) as total_minutes,
                    COUNT(*) FILTER (WHERE lp.is_completed = true) as lessons_completed
                FROM lesson_progress lp
                WHERE lp.student_id = p_student_id
                AND lp.last_accessed_at::date BETWEEN date_from AND date_to
                GROUP BY lp.last_accessed_at::date
                ORDER BY date
            ) daily_data
        )
    ) INTO analytics_data
    FROM analytics.student_performance_summary spa
    WHERE spa.student_id = p_student_id;
    
    RETURN COALESCE(analytics_data, '{}'::jsonb);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get coaching center comprehensive analytics
CREATE OR REPLACE FUNCTION sp_get_coaching_center_analytics(
    p_coaching_center_id UUID,
    p_date_from DATE DEFAULT NULL,
    p_date_to DATE DEFAULT NULL
) RETURNS JSONB AS $$
DECLARE
    analytics_data JSONB;
    date_from DATE;
    date_to DATE;
BEGIN
    date_from := COALESCE(p_date_from, CURRENT_DATE - INTERVAL '30 days');
    date_to := COALESCE(p_date_to, CURRENT_DATE);
    
    WITH center_overview AS (
        SELECT 
            cc.center_name,
            cc.subscription_plan,
            COUNT(DISTINCT c.id) as total_courses,
            COUNT(DISTINCT t.id) as total_teachers,
            COUNT(DISTINCT ce.student_id) as total_students,
            COUNT(DISTINCT ce.id) as total_enrollments,
            AVG(c.average_rating) as avg_course_rating,
            SUM(fs.net_revenue) as total_revenue
        FROM coaching_centers cc
        LEFT JOIN courses c ON cc.id = c.coaching_center_id AND c.status = 'published'
        LEFT JOIN teachers t ON cc.id = t.coaching_center_id AND t.is_active = true
        LEFT JOIN course_enrollments ce ON c.id = ce.course_id AND ce.is_active = true
        LEFT JOIN analytics.financial_summary fs ON cc.id = fs.coaching_center_id 
            AND fs.month_year BETWEEN date_from AND date_to
        WHERE cc.id = p_coaching_center_id
        GROUP BY cc.center_name, cc.subscription_plan
    )
    SELECT jsonb_build_object(
        'center_overview', jsonb_build_object(
            'center_name', co.center_name,
            'subscription_plan', co.subscription_plan,
            'total_courses', co.total_courses,
            'total_teachers', co.total_teachers,
            'total_students', co.total_students,
            'total_enrollments', co.total_enrollments,
            'avg_course_rating', ROUND(co.avg_course_rating, 2),
            'total_revenue', COALESCE(co.total_revenue, 0)
        ),
        'top_performing_courses', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'course_id', cps.course_id,
                    'title', cps.title,
                    'enrollment_count', cps.enrollment_count,
                    'completion_rate', cps.completion_rate_percentage,
                    'average_rating', cps.average_rating,
                    'total_revenue', cps.total_revenue,
                    'course_health_score', cps.course_health_score
                )
                ORDER BY cps.course_health_score DESC
            )
            FROM analytics.course_performance_summary cps
            WHERE cps.coaching_center_id = p_coaching_center_id
            LIMIT 10
        ),
        'student_performance_distribution', (
            SELECT jsonb_build_object(
                'high_performers', COUNT(*) FILTER (WHERE spa.performance_score >= 80),
                'average_performers', COUNT(*) FILTER (WHERE spa.performance_score BETWEEN 50 AND 79.99),
                'low_performers', COUNT(*) FILTER (WHERE spa.performance_score < 50),
                'at_risk_students', COUNT(*) FILTER (WHERE spa.risk_category = 'at_risk'),
                'avg_performance_score', ROUND(AVG(spa.performance_score), 2)
            )
            FROM analytics.student_performance_summary spa
            JOIN course_enrollments ce ON spa.student_id = ce.student_id
            JOIN courses c ON ce.course_id = c.id
            WHERE c.coaching_center_id = p_coaching_center_id
            AND ce.is_active = true
        ),
        'revenue_trends', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'month', fs.month_year,
                    'net_revenue', fs.net_revenue,
                    'successful_payments', fs.successful_payments,
                    'unique_customers', fs.unique_customers,
                    'avg_transaction_value', ROUND(fs.avg_transaction_value, 2)
                )
                ORDER BY fs.month_year
            )
            FROM analytics.financial_summary fs
            WHERE fs.coaching_center_id = p_coaching_center_id
            AND fs.month_year BETWEEN date_from AND date_to
        ),
        'teacher_performance', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'teacher_name', up.first_name || ' ' || up.last_name,
                    'total_courses', t.total_courses,
                    'total_students', t.total_students,
                    'average_rating', t.average_rating,
                    'revenue_generated', t.total_revenue
                )
                ORDER BY t.average_rating DESC
            )
            FROM teachers t
            JOIN user_profiles up ON t.user_id = up.id
            WHERE t.coaching_center_id = p_coaching_center_id
            AND t.is_active = true
            LIMIT 10
        )
    ) INTO analytics_data
    FROM center_overview co;
    
    RETURN COALESCE(analytics_data, '{}'::jsonb);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Generate and execute custom report
CREATE OR REPLACE FUNCTION sp_generate_custom_report(
    p_report_id UUID,
    p_user_id UUID,
    p_applied_filters JSONB DEFAULT '{}',
    p_export_format VARCHAR DEFAULT 'json',
    p_date_range JSONB DEFAULT '{}'
) RETURNS JSONB AS $$
DECLARE
    v_report custom_reports%ROWTYPE;
    v_execution_id UUID;
    v_query_text TEXT;
    v_result JSONB;
    v_row_count INTEGER;
    v_start_time TIMESTAMP WITH TIME ZONE;
    v_execution_time INTEGER;
    v_file_url TEXT;
    final_result JSONB;
BEGIN
    v_start_time := clock_timestamp();
    
    -- Get report configuration
    SELECT * INTO v_report 
    FROM custom_reports 
    WHERE id = p_report_id AND is_active = true AND is_deleted = false;
    
    IF v_report.id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Report not found or inactive');
    END IF;
    
    -- Check permissions (simplified - expand based on your needs)
    IF v_report.visibility = 'private' AND v_report.created_by != p_user_id THEN
        RETURN jsonb_build_object('success', false, 'message', 'Access denied');
    END IF;
    
    -- Create execution record
    INSERT INTO report_executions (
        report_id, executed_by, execution_type, applied_filters, 
        date_range, output_format, status
    ) VALUES (
        p_report_id, p_user_id, 'manual', p_applied_filters,
        p_date_range, p_export_format, 'running'
    ) RETURNING id INTO v_execution_id;
    
    -- Build and execute query based on report category
    CASE v_report.report_category
        WHEN 'student_performance' THEN
            v_query_text := '
                SELECT jsonb_agg(
                    jsonb_build_object(
                        ''student_name'', student_name,
                        ''student_code'', student_code,
                        ''grade_level'', grade_level,
                        ''completion_rate'', completion_rate_percentage,
                        ''performance_score'', performance_score,
                        ''total_study_hours'', total_study_hours,
                        ''risk_category'', risk_category
                    )
                ) as data, COUNT(*) as row_count
                FROM analytics.student_performance_summary
                WHERE 1=1
            ';
            
            -- Apply filters
            IF p_applied_filters ? 'grade_level' THEN
                v_query_text := v_query_text || ' AND grade_level = ''' || (p_applied_filters->>'grade_level') || '''';
            END IF;
            
            IF p_applied_filters ? 'state' THEN
                v_query_text := v_query_text || ' AND state = ''' || (p_applied_filters->>'state') || '''';
            END IF;
            
            IF p_applied_filters ? 'risk_category' THEN
                v_query_text := v_query_text || ' AND risk_category = ''' || (p_applied_filters->>'risk_category') || '''';
            END IF;
            
        WHEN 'course_analytics' THEN
            v_query_text := '
                SELECT jsonb_agg(
                    jsonb_build_object(
                        ''course_title'', title,
                        ''category'', category,
                        ''enrollment_count'', enrollment_count,
                        ''completion_rate'', completion_rate_percentage,
                        ''average_rating'', average_rating,
                        ''total_revenue'', total_revenue,
                        ''course_health_score'', course_health_score
                    )
                ) as data, COUNT(*) as row_count
                FROM analytics.course_performance_summary
                WHERE 1=1
            ';
            
            IF p_applied_filters ? 'category' THEN
                v_query_text := v_query_text || ' AND category = ''' || (p_applied_filters->>'category') || '''';
            END IF;
            
            IF p_applied_filters ? 'coaching_center_id' THEN
                v_query_text := v_query_text || ' AND coaching_center_id = ''' || (p_applied_filters->>'coaching_center_id') || '''';
            END IF;
            
        WHEN 'financial' THEN
            v_query_text := '
                SELECT jsonb_agg(
                    jsonb_build_object(
                        ''month'', month_year,
                        ''center_name'', center_name,
                        ''net_revenue'', net_revenue,
                        ''successful_payments'', successful_payments,
                        ''success_rate'', success_rate_percentage,
                        ''unique_customers'', unique_customers
                    )
                ) as data, COUNT(*) as row_count
                FROM analytics.financial_summary
                WHERE 1=1
            ';
            
            IF p_date_range ? 'date_from' THEN
                v_query_text := v_query_text || ' AND month_year >= ''' || (p_date_range->>'date_from') || '''';
            END IF;
            
            IF p_date_range ? 'date_to' THEN
                v_query_text := v_query_text || ' AND month_year <= ''' || (p_date_range->>'date_to') || '''';
            END IF;
            
        ELSE
            -- Use custom base query if provided
            v_query_text := COALESCE(v_report.base_query, 'SELECT jsonb_build_object() as data, 0 as row_count');
    END CASE;
    
    -- Execute the query
    BEGIN
        EXECUTE v_query_text INTO v_result, v_row_count;
    EXCEPTION
        WHEN OTHERS THEN
            -- Update execution with error
            UPDATE report_executions SET
                status = 'failed',
                error_message = SQLERRM,
                execution_time_ms = EXTRACT(MILLISECONDS FROM clock_timestamp() - v_start_time)::INTEGER
            WHERE id = v_execution_id;
            
            RETURN jsonb_build_object(
                'success', false,
                'message', 'Query execution failed: ' || SQLERRM,
                'execution_id', v_execution_id
            );
    END;
    
    -- Calculate execution time
    v_execution_time := EXTRACT(MILLISECONDS FROM clock_timestamp() - v_start_time)::INTEGER;
    
    -- Handle file export if requested
    IF p_export_format != 'json' THEN
        -- In a real implementation, you would generate file exports here
        -- For now, we'll just set a placeholder URL
        v_file_url := '/exports/report_' || v_execution_id || '.' || p_export_format;
    END IF;
    
    -- Update execution record
    UPDATE report_executions SET
        status = 'completed',
        execution_time_ms = v_execution_time,
        row_count = v_row_count,
        file_url = v_file_url
    WHERE id = v_execution_id;
    
    -- Update report statistics
    UPDATE custom_reports SET
        last_executed_at = NOW(),
        execution_count = execution_count + 1,
        average_execution_time_ms = ROUND((average_execution_time_ms * (execution_count - 1) + v_execution_time) / execution_count)
    WHERE id = p_report_id;
    
    final_result := jsonb_build_object(
        'success', true,
        'execution_id', v_execution_id,
        'report_name', v_report.report_name,
        'execution_time_ms', v_execution_time,
        'row_count', v_row_count,
        'export_format', p_export_format,
        'file_url', v_file_url,
        'data', v_result
    );
    
    RETURN final_result;
EXCEPTION
    WHEN OTHERS THEN
        -- Final error handler
        UPDATE report_executions SET
            status = 'failed',
            error_message = SQLERRM,
            execution_time_ms = EXTRACT(MILLISECONDS FROM clock_timestamp() - v_start_time)::INTEGER
        WHERE id = v_execution_id;
        
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Report generation failed: ' || SQLERRM,
            'execution_id', v_execution_id
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Refresh all materialized views (for scheduled maintenance)
CREATE OR REPLACE FUNCTION sp_refresh_analytics_views()
RETURNS JSONB AS $$
DECLARE
    start_time TIMESTAMP WITH TIME ZONE;
    total_time INTEGER;
    refresh_results JSONB[];
    view_name TEXT;
    view_start TIMESTAMP WITH TIME ZONE;
    view_time INTEGER;
BEGIN
    start_time := clock_timestamp();
    
    -- Refresh student performance summary
    view_start := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY analytics.student_performance_summary;
    view_time := EXTRACT(MILLISECONDS FROM clock_timestamp() - view_start)::INTEGER;
    refresh_results := array_append(refresh_results, 
        jsonb_build_object('view', 'student_performance_summary', 'time_ms', view_time, 'status', 'success'));
    
    -- Refresh course performance summary
    view_start := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY analytics.course_performance_summary;
    view_time := EXTRACT(MILLISECONDS FROM clock_timestamp() - view_start)::INTEGER;
    refresh_results := array_append(refresh_results, 
        jsonb_build_object('view', 'course_performance_summary', 'time_ms', view_time, 'status', 'success'));
    
    -- Refresh financial summary
    view_start := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY analytics.financial_summary;
    view_time := EXTRACT(MILLISECONDS FROM clock_timestamp() - view_start)::INTEGER;
    refresh_results := array_append(refresh_results, 
        jsonb_build_object('view', 'financial_summary', 'time_ms', view_time, 'status', 'success'));
    
    total_time := EXTRACT(MILLISECONDS FROM clock_timestamp() - start_time)::INTEGER;
    
    RETURN jsonb_build_object(
        'success', true,
        'message', 'All analytics views refreshed successfully',
        'total_time_ms', total_time,
        'refreshed_at', NOW(),
        'views', refresh_results
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Analytics refresh failed: ' || SQLERRM,
            'failed_at', NOW()
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- ANALYTICS INDEXES
-- =============================================

-- Create unique indexes for materialized views
CREATE UNIQUE INDEX CONCURRENTLY idx_student_performance_summary_student_id 
    ON analytics.student_performance_summary(student_id);
CREATE INDEX CONCURRENTLY idx_student_performance_summary_grade_state 
    ON analytics.student_performance_summary(grade_level, state);
CREATE INDEX CONCURRENTLY idx_student_performance_summary_performance_score 
    ON analytics.student_performance_summary(performance_score DESC);

CREATE UNIQUE INDEX CONCURRENTLY idx_course_performance_summary_course_id 
    ON analytics.course_performance_summary(course_id);
CREATE INDEX CONCURRENTLY idx_course_performance_summary_center 
    ON analytics.course_performance_summary(coaching_center_id);
CREATE INDEX CONCURRENTLY idx_course_performance_summary_health_score 
    ON analytics.course_performance_summary(course_health_score DESC);

CREATE INDEX CONCURRENTLY idx_financial_summary_center_month 
    ON analytics.financial_summary(coaching_center_id, month_year);
CREATE INDEX CONCURRENTLY idx_financial_summary_month 
    ON analytics.financial_summary(month_year DESC);

-- Report tables indexes
CREATE INDEX CONCURRENTLY idx_custom_reports_created_by ON custom_reports(created_by) 
    WHERE is_active = true AND is_deleted = false;
CREATE INDEX CONCURRENTLY idx_custom_reports_category ON custom_reports(report_category) 
    WHERE is_active = true;
CREATE INDEX CONCURRENTLY idx_report_executions_report ON report_executions(report_id);
CREATE INDEX CONCURRENTLY idx_report_executions_executed_at ON report_executions(executed_at DESC);

-- Apply audit triggers
CREATE TRIGGER trg_audit_custom_reports AFTER INSERT OR UPDATE OR DELETE ON custom_reports 
    FOR EACH ROW EXECUTE FUNCTION audit.log_changes();
CREATE TRIGGER trg_updated_at_custom_reports BEFORE UPDATE ON custom_reports 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
