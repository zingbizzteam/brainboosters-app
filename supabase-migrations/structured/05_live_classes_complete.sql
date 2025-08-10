-- =============================================
-- PRODUCTION-READY LIVE CLASSES SYSTEM
-- =============================================

-- Enhanced live classes with full production features
CREATE TABLE live_classes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    coaching_center_id UUID REFERENCES coaching_centers(id) ON DELETE RESTRICT NOT NULL,
    teacher_id UUID REFERENCES teachers(id) ON DELETE RESTRICT NOT NULL,
    course_id UUID REFERENCES courses(id) ON DELETE SET NULL, -- Can be standalone
    
    -- Class details
    title VARCHAR(300) NOT NULL,
    description TEXT,
    class_type VARCHAR(30) DEFAULT 'lecture' CHECK (class_type IN (
        'lecture', 'workshop', 'discussion', 'doubt_solving', 'test_review', 
        'mock_test', 'group_study', 'one_on_one', 'webinar'
    )),
    
    -- Scheduling with timezone support
    scheduled_start TIMESTAMP WITH TIME ZONE NOT NULL,
    scheduled_end TIMESTAMP WITH TIME ZONE NOT NULL,
    timezone VARCHAR(50) DEFAULT 'Asia/Kolkata',
    
    -- Actual timing (for analytics)
    actual_start TIMESTAMP WITH TIME ZONE,
    actual_end TIMESTAMP WITH TIME ZONE,
    
    -- Capacity and enrollment
    max_attendees INTEGER DEFAULT 100 CHECK (max_attendees > 0),
    current_registrations INTEGER DEFAULT 0,
    
    -- Pricing
    is_free BOOLEAN DEFAULT true,
    price DECIMAL(10,2) DEFAULT 0.00 CHECK (price >= 0),
    currency VARCHAR(3) DEFAULT 'INR',
    
    -- Meeting platform configuration
    meeting_platform VARCHAR(30) DEFAULT 'zoom' CHECK (meeting_platform IN (
        'zoom', 'google_meet', 'microsoft_teams', 'webex', 'jitsi', 'custom'
    )),
    meeting_id VARCHAR(200),
    meeting_password VARCHAR(100),
    meeting_url TEXT,
    
    -- Class materials and resources
    agenda JSONB DEFAULT '[]',
    pre_class_materials JSONB DEFAULT '[]',
    class_notes TEXT,
    resource_links JSONB DEFAULT '[]',
    
    -- Recording settings
    recording_enabled BOOLEAN DEFAULT true,
    auto_record BOOLEAN DEFAULT false,
    recording_url TEXT,
    recording_duration_minutes INTEGER DEFAULT 0,
    
    -- Interactive features
    chat_enabled BOOLEAN DEFAULT true,
    polls_enabled BOOLEAN DEFAULT true,
    breakout_rooms_enabled BOOLEAN DEFAULT false,
    whiteboard_enabled BOOLEAN DEFAULT true,
    screen_sharing_enabled BOOLEAN DEFAULT true,
    
    -- Attendance tracking
    attendance_required BOOLEAN DEFAULT false,
    minimum_attendance_percentage INTEGER DEFAULT 75 CHECK (minimum_attendance_percentage >= 0 AND minimum_attendance_percentage <= 100),
    
    -- Status and workflow
    status VARCHAR(30) DEFAULT 'scheduled' CHECK (status IN (
        'scheduled', 'live', 'completed', 'cancelled', 'postponed', 'technical_issue'
    )),
    cancellation_reason TEXT,
    postponed_to TIMESTAMP WITH TIME ZONE,
    
    -- Performance metrics (updated by background jobs)
    total_registrations INTEGER DEFAULT 0,
    actual_attendees INTEGER DEFAULT 0,
    peak_concurrent_users INTEGER DEFAULT 0,
    average_attendance_duration INTEGER DEFAULT 0, -- minutes
    engagement_score DECIMAL(5,2) DEFAULT 0.0,
    
    -- Feedback and ratings
    average_rating DECIMAL(3,2) DEFAULT 0.0,
    total_feedback_count INTEGER DEFAULT 0,
    
    -- System fields
    is_active BOOLEAN DEFAULT true NOT NULL,
    is_deleted BOOLEAN DEFAULT false NOT NULL,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT valid_schedule CHECK (scheduled_end > scheduled_start),
    CONSTRAINT valid_postponed_date CHECK (postponed_to IS NULL OR postponed_to > scheduled_start)
) WITH (fillfactor = 85);

-- Live class registrations with enhanced tracking
CREATE TABLE live_class_registrations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    live_class_id UUID REFERENCES live_classes(id) ON DELETE CASCADE NOT NULL,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE NOT NULL,
    
    -- Registration details
    registered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    registration_source VARCHAR(50) DEFAULT 'direct' CHECK (registration_source IN (
        'direct', 'course_enrollment', 'invitation', 'bulk_import', 'waitlist'
    )),
    
    -- Payment information (for paid classes)
    payment_status VARCHAR(20) DEFAULT 'free' CHECK (payment_status IN (
        'free', 'paid', 'pending', 'failed', 'refunded'
    )),
    payment_id UUID REFERENCES payments(id),
    
    -- Attendance tracking
    attended BOOLEAN DEFAULT false,
    joined_at TIMESTAMP WITH TIME ZONE,
    left_at TIMESTAMP WITH TIME ZONE,
    total_attendance_minutes INTEGER DEFAULT 0,
    attendance_percentage DECIMAL(5,2) DEFAULT 0.0,
    
    -- Engagement metrics
    chat_messages_sent INTEGER DEFAULT 0,
    polls_participated INTEGER DEFAULT 0,
    questions_asked INTEGER DEFAULT 0,
    screen_shares INTEGER DEFAULT 0,
    reactions_count INTEGER DEFAULT 0,
    
    -- Technical details
    device_type VARCHAR(30),
    browser_info JSONB DEFAULT '{}',
    connection_issues INTEGER DEFAULT 0,
    
    -- Post-class feedback
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    feedback_text TEXT,
    feedback_submitted_at TIMESTAMP WITH TIME ZONE,
    
    -- Status management
    status VARCHAR(30) DEFAULT 'registered' CHECK (status IN (
        'registered', 'confirmed', 'attended', 'missed', 'cancelled', 'waitlisted'
    )),
    cancellation_reason TEXT,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    
    -- Notifications
    reminder_sent BOOLEAN DEFAULT false,
    follow_up_sent BOOLEAN DEFAULT false,
    
    -- System
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    UNIQUE(live_class_id, student_id)
);

-- Live class attendance logs (detailed session tracking)
CREATE TABLE live_class_attendance_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    registration_id UUID REFERENCES live_class_registrations(id) ON DELETE CASCADE NOT NULL,
    live_class_id UUID REFERENCES live_classes(id) ON DELETE CASCADE NOT NULL,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE NOT NULL,
    
    -- Session details
    session_start TIMESTAMP WITH TIME ZONE NOT NULL,
    session_end TIMESTAMP WITH TIME ZONE,
    duration_minutes INTEGER,
    
    -- Technical information
    ip_address INET,
    device_type VARCHAR(30),
    browser VARCHAR(50),
    operating_system VARCHAR(50),
    connection_quality VARCHAR(20) CHECK (connection_quality IN ('excellent', 'good', 'fair', 'poor')),
    
    -- Engagement during session
    screen_focus_percentage DECIMAL(5,2) DEFAULT 0.0,
    interaction_count INTEGER DEFAULT 0,
    video_on_percentage DECIMAL(5,2) DEFAULT 0.0,
    audio_on_percentage DECIMAL(5,2) DEFAULT 0.0,
    
    -- Session events
    events_log JSONB DEFAULT '[]', -- Join, leave, chat, poll responses, etc.
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Live class polls
CREATE TABLE live_class_polls (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    live_class_id UUID REFERENCES live_classes(id) ON DELETE CASCADE NOT NULL,
    teacher_id UUID REFERENCES teachers(id) ON DELETE SET NULL NOT NULL,
    
    -- Poll details
    question TEXT NOT NULL,
    poll_type VARCHAR(20) DEFAULT 'multiple_choice' CHECK (poll_type IN (
        'multiple_choice', 'true_false', 'open_ended', 'rating', 'yes_no'
    )),
    options JSONB DEFAULT '[]', -- For MCQ polls
    
    -- Timing
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ends_at TIMESTAMP WITH TIME ZONE,
    
    -- Settings
    allow_multiple_answers BOOLEAN DEFAULT false,
    show_results_immediately BOOLEAN DEFAULT true,
    anonymous_responses BOOLEAN DEFAULT false,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    is_closed BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Poll responses
CREATE TABLE live_class_poll_responses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    poll_id UUID REFERENCES live_class_polls(id) ON DELETE CASCADE NOT NULL,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE NOT NULL,
    
    selected_options INTEGER[], -- For MCQ
    text_response TEXT, -- For open-ended
    rating_value INTEGER CHECK (rating_value >= 1 AND rating_value <= 5), -- For rating polls
    
    responded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    UNIQUE(poll_id, student_id)
);

-- =============================================
-- PRODUCTION INDEXES FOR LIVE CLASSES
-- =============================================

-- Live classes indexes
CREATE INDEX CONCURRENTLY idx_live_classes_center_teacher ON live_classes(coaching_center_id, teacher_id) 
    WHERE is_deleted = false;
CREATE INDEX CONCURRENTLY idx_live_classes_scheduled ON live_classes(scheduled_start) 
    WHERE status IN ('scheduled', 'live');
CREATE INDEX CONCURRENTLY idx_live_classes_status ON live_classes(status) 
    WHERE is_active = true;
CREATE INDEX CONCURRENTLY idx_live_classes_course ON live_classes(course_id) 
    WHERE course_id IS NOT NULL AND is_deleted = false;

-- Registrations indexes
CREATE INDEX CONCURRENTLY idx_live_registrations_class ON live_class_registrations(live_class_id) 
    WHERE is_active = true;
CREATE INDEX CONCURRENTLY idx_live_registrations_student ON live_class_registrations(student_id) 
    WHERE is_active = true;
CREATE INDEX CONCURRENTLY idx_live_registrations_payment ON live_class_registrations(payment_status) 
    WHERE payment_status != 'free';
CREATE INDEX CONCURRENTLY idx_live_registrations_attendance ON live_class_registrations(attended) 
    WHERE is_active = true;

-- Attendance logs indexes
CREATE INDEX CONCURRENTLY idx_attendance_logs_registration ON live_class_attendance_logs(registration_id);
CREATE INDEX CONCURRENTLY idx_attendance_logs_session_start ON live_class_attendance_logs(session_start DESC);
CREATE INDEX CONCURRENTLY idx_attendance_logs_class ON live_class_attendance_logs(live_class_id);

-- Polls indexes
CREATE INDEX CONCURRENTLY idx_live_polls_class ON live_class_polls(live_class_id) 
    WHERE is_active = true;
CREATE INDEX CONCURRENTLY idx_poll_responses_poll ON live_class_poll_responses(poll_id);

-- =============================================
-- LIVE CLASSES STORED PROCEDURES
-- =============================================

-- Register for live class with validation
CREATE OR REPLACE FUNCTION sp_register_for_live_class(
    p_live_class_id UUID,
    p_student_id UUID,
    p_registration_source VARCHAR DEFAULT 'direct'
) RETURNS JSONB AS $$
DECLARE
    v_class live_classes%ROWTYPE;
    v_enrollment_id UUID;
    v_existing_registration BOOLEAN;
    v_payment_required BOOLEAN;
    result JSONB;
BEGIN
    -- Get live class details
    SELECT * INTO v_class 
    FROM live_classes 
    WHERE id = p_live_class_id AND status = 'scheduled' AND is_active = true;
    
    IF v_class.id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Live class not found or not available');
    END IF;
    
    -- Check if class is in the future
    IF v_class.scheduled_start <= NOW() THEN
        RETURN jsonb_build_object('success', false, 'message', 'Cannot register for past or ongoing classes');
    END IF;
    
    -- Check capacity
    IF v_class.current_registrations >= v_class.max_attendees THEN
        RETURN jsonb_build_object('success', false, 'message', 'Class is full');
    END IF;
    
    -- Check if already registered
    SELECT EXISTS(
        SELECT 1 FROM live_class_registrations 
        WHERE live_class_id = p_live_class_id AND student_id = p_student_id AND is_active = true
    ) INTO v_existing_registration;
    
    IF v_existing_registration THEN
        RETURN jsonb_build_object('success', false, 'message', 'Already registered for this class');
    END IF;
    
    -- Check course enrollment if class is linked to a course
    IF v_class.course_id IS NOT NULL THEN
        SELECT id INTO v_enrollment_id
        FROM course_enrollments
        WHERE student_id = p_student_id AND course_id = v_class.course_id AND is_active = true;
        
        IF v_enrollment_id IS NULL THEN
            RETURN jsonb_build_object('success', false, 'message', 'Must be enrolled in course to attend this class');
        END IF;
    END IF;
    
    -- Determine payment requirement
    v_payment_required := NOT v_class.is_free AND v_class.price > 0;
    
    -- Create registration
    INSERT INTO live_class_registrations (
        live_class_id, student_id, registration_source,
        payment_status, status
    ) VALUES (
        p_live_class_id, p_student_id, p_registration_source,
        CASE WHEN v_payment_required THEN 'pending' ELSE 'free' END,
        'registered'
    );
    
    -- Update class registration count
    UPDATE live_classes 
    SET current_registrations = current_registrations + 1,
        total_registrations = total_registrations + 1,
        updated_at = NOW()
    WHERE id = p_live_class_id;
    
    result := jsonb_build_object(
        'success', true,
        'message', 'Successfully registered for live class',
        'class_title', v_class.title,
        'scheduled_start', v_class.scheduled_start,
        'meeting_url', CASE WHEN NOT v_payment_required THEN v_class.meeting_url ELSE NULL END,
        'payment_required', v_payment_required,
        'amount', CASE WHEN v_payment_required THEN v_class.price ELSE 0 END
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Record attendance with detailed tracking
CREATE OR REPLACE FUNCTION sp_record_live_class_attendance(
    p_registration_id UUID,
    p_action VARCHAR, -- 'join', 'leave', 'heartbeat'
    p_session_data JSONB DEFAULT '{}'
) RETURNS JSONB AS $$
DECLARE
    v_registration live_class_registrations%ROWTYPE;
    v_class live_classes%ROWTYPE;
    v_session_duration INTEGER;
    result JSONB;
BEGIN
    -- Get registration details
    SELECT lcr.*, lc.*
    INTO v_registration, v_class
    FROM live_class_registrations lcr
    JOIN live_classes lc ON lcr.live_class_id = lc.id
    WHERE lcr.id = p_registration_id AND lcr.is_active = true;
    
    IF v_registration.id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Registration not found');
    END IF;
    
    CASE p_action
        WHEN 'join' THEN
            -- Record join time
            UPDATE live_class_registrations 
            SET joined_at = NOW(),
                attended = true,
                device_type = COALESCE(p_session_data->>'device_type', device_type),
                browser_info = p_session_data,
                status = 'attended'
            WHERE id = p_registration_id;
            
            -- Create attendance log entry
            INSERT INTO live_class_attendance_logs (
                registration_id, live_class_id, student_id,
                session_start, ip_address, device_type, browser,
                connection_quality
            ) VALUES (
                p_registration_id, v_registration.live_class_id, v_registration.student_id,
                NOW(), inet_client_addr(),
                p_session_data->>'device_type',
                p_session_data->>'browser',
                COALESCE(p_session_data->>'connection_quality', 'good')
            );
            
        WHEN 'leave' THEN
            -- Calculate session duration
            SELECT EXTRACT(EPOCH FROM (NOW() - joined_at))/60 INTO v_session_duration
            FROM live_class_registrations
            WHERE id = p_registration_id;
            
            -- Update leave time and duration
            UPDATE live_class_registrations 
            SET left_at = NOW(),
                total_attendance_minutes = GREATEST(total_attendance_minutes, COALESCE(v_session_duration, 0)),
                updated_at = NOW()
            WHERE id = p_registration_id;
            
            -- Update attendance log
            UPDATE live_class_attendance_logs 
            SET session_end = NOW(),
                duration_minutes = v_session_duration,
                screen_focus_percentage = COALESCE((p_session_data->>'focus_percentage')::DECIMAL, 0),
                interaction_count = COALESCE((p_session_data->>'interactions')::INTEGER, 0)
            WHERE registration_id = p_registration_id 
            AND session_end IS NULL
            ORDER BY session_start DESC 
            LIMIT 1;
            
        WHEN 'heartbeat' THEN
            -- Update engagement metrics
            UPDATE live_class_registrations 
            SET chat_messages_sent = COALESCE((p_session_data->>'chat_count')::INTEGER, chat_messages_sent),
                polls_participated = COALESCE((p_session_data->>'poll_responses')::INTEGER, polls_participated),
                questions_asked = COALESCE((p_session_data->>'questions')::INTEGER, questions_asked),
                updated_at = NOW()
            WHERE id = p_registration_id;
    END CASE;
    
    result := jsonb_build_object(
        'success', true,
        'action', p_action,
        'timestamp', NOW()
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get live class dashboard for teacher
CREATE OR REPLACE FUNCTION sp_get_live_class_dashboard(
    p_teacher_id UUID,
    p_date_from DATE DEFAULT NULL,
    p_date_to DATE DEFAULT NULL
) RETURNS JSONB AS $$
DECLARE
    dashboard_data JSONB;
    date_from DATE;
    date_to DATE;
BEGIN
    date_from := COALESCE(p_date_from, CURRENT_DATE - INTERVAL '30 days');
    date_to := COALESCE(p_date_to, CURRENT_DATE + INTERVAL '30 days');
    
    SELECT jsonb_build_object(
        'upcoming_classes', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', lc.id,
                    'title', lc.title,
                    'scheduled_start', lc.scheduled_start,
                    'scheduled_end', lc.scheduled_end,
                    'registrations', lc.current_registrations,
                    'max_attendees', lc.max_attendees,
                    'status', lc.status
                )
                ORDER BY lc.scheduled_start
            )
            FROM live_classes lc
            WHERE lc.teacher_id = p_teacher_id
            AND lc.scheduled_start BETWEEN NOW() AND (CURRENT_DATE + INTERVAL '7 days')::TIMESTAMP
            AND lc.status = 'scheduled'
        ),
        'recent_classes', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', lc.id,
                    'title', lc.title,
                    'scheduled_start', lc.scheduled_start,
                    'actual_attendees', lc.actual_attendees,
                    'average_rating', lc.average_rating,
                    'engagement_score', lc.engagement_score
                )
                ORDER BY lc.scheduled_start DESC
            )
            FROM live_classes lc
            WHERE lc.teacher_id = p_teacher_id
            AND lc.scheduled_start::date BETWEEN date_from AND date_to
            AND lc.status = 'completed'
            LIMIT 10
        ),
        'statistics', (
            SELECT jsonb_build_object(
                'total_classes', COUNT(*),
                'total_attendees', SUM(lc.actual_attendees),
                'average_attendance_rate', ROUND(AVG(
                    CASE WHEN lc.total_registrations > 0 
                         THEN (lc.actual_attendees::DECIMAL / lc.total_registrations) * 100 
                         ELSE 0 END
                ), 2),
                'average_rating', ROUND(AVG(lc.average_rating), 2),
                'total_hours_taught', ROUND(SUM(
                    EXTRACT(EPOCH FROM (lc.actual_end - lc.actual_start))/3600
                ), 1)
            )
            FROM live_classes lc
            WHERE lc.teacher_id = p_teacher_id
            AND lc.scheduled_start::date BETWEEN date_from AND date_to
            AND lc.status = 'completed'
        )
    ) INTO dashboard_data;
    
    RETURN COALESCE(dashboard_data, '{}'::jsonb);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply audit and update triggers
CREATE TRIGGER trg_audit_live_classes AFTER INSERT OR UPDATE OR DELETE ON live_classes 
    FOR EACH ROW EXECUTE FUNCTION audit.log_changes();
CREATE TRIGGER trg_audit_live_registrations AFTER INSERT OR UPDATE OR DELETE ON live_class_registrations 
    FOR EACH ROW EXECUTE FUNCTION audit.log_changes();

CREATE TRIGGER trg_updated_at_live_classes BEFORE UPDATE ON live_classes 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_updated_at_live_registrations BEFORE UPDATE ON live_class_registrations 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
