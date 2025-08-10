-- =============================================
-- PRODUCTION-READY LEARNING PROGRESS SYSTEM
-- =============================================

-- Course enrollments with enhanced tracking
CREATE TABLE course_enrollments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE NOT NULL,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    
    -- Enrollment details
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    enrollment_source VARCHAR(50) DEFAULT 'direct' CHECK (enrollment_source IN ('direct', 'invitation', 'bulk_import', 'trial')),
    
    -- Progress tracking
    progress_percentage DECIMAL(5,2) DEFAULT 0.0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    lessons_completed INTEGER DEFAULT 0 CHECK (lessons_completed >= 0),
    chapters_completed INTEGER DEFAULT 0 CHECK (chapters_completed >= 0),
    assignments_submitted INTEGER DEFAULT 0 CHECK (assignments_submitted >= 0),
    tests_completed INTEGER DEFAULT 0 CHECK (tests_completed >= 0),
    
    -- Time tracking
    total_study_minutes INTEGER DEFAULT 0 CHECK (total_study_minutes >= 0),
    last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_lesson_completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Completion tracking
    completed_at TIMESTAMP WITH TIME ZONE,
    completion_certificate_issued BOOLEAN DEFAULT false,
    certificate_url TEXT,
    
    -- Performance metrics
    overall_score DECIMAL(5,2) DEFAULT 0.0 CHECK (overall_score >= 0 AND overall_score <= 100),
    total_points_earned INTEGER DEFAULT 0,
    
    -- Course feedback
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review TEXT,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    
    -- Status and settings
    is_active BOOLEAN DEFAULT true NOT NULL,
    is_deleted BOOLEAN DEFAULT false NOT NULL,
    notifications_enabled BOOLEAN DEFAULT true,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    UNIQUE(student_id, course_id)
) WITH (fillfactor = 80);

-- Production indexes for enrollments
CREATE INDEX CONCURRENTLY idx_enrollments_student_active ON course_enrollments(student_id, is_active) 
    WHERE is_deleted = false;
CREATE INDEX CONCURRENTLY idx_enrollments_course_active ON course_enrollments(course_id, is_active) 
    WHERE is_deleted = false;
CREATE INDEX CONCURRENTLY idx_enrollments_progress ON course_enrollments(progress_percentage DESC) 
    WHERE is_active = true;
CREATE INDEX CONCURRENTLY idx_enrollments_completion ON course_enrollments(completed_at DESC) 
    WHERE completed_at IS NOT NULL;
CREATE INDEX CONCURRENTLY idx_enrollments_last_accessed ON course_enrollments(last_accessed_at DESC) 
    WHERE is_active = true;

-- =============================================
-- LESSON PROGRESS (PARTITIONED FOR SCALE)
-- =============================================

CREATE TABLE lesson_progress (
    id UUID DEFAULT gen_random_uuid(),
    student_id UUID REFERENCES students(id) ON DELETE CASCADE NOT NULL,
    lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE NOT NULL,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    enrollment_id UUID REFERENCES course_enrollments(id) ON DELETE CASCADE NOT NULL,
    
    -- Progress tracking
    first_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    completion_percentage DECIMAL(5,2) DEFAULT 0.0 CHECK (completion_percentage >= 0 AND completion_percentage <= 100),
    is_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Video-specific tracking
    total_watch_time_seconds INTEGER DEFAULT 0,
    video_progress_markers JSONB DEFAULT '{}', -- Track specific video timestamps
    playback_speed DECIMAL(3,2) DEFAULT 1.0,
    
    -- Interaction tracking
    pause_count INTEGER DEFAULT 0,
    seek_count INTEGER DEFAULT 0,
    replay_count INTEGER DEFAULT 0,
    note_count INTEGER DEFAULT 0,
    
    -- Assessment results (if lesson has quiz/assessment)
    quiz_attempts INTEGER DEFAULT 0,
    best_quiz_score DECIMAL(5,2) DEFAULT 0.0,
    latest_quiz_score DECIMAL(5,2) DEFAULT 0.0,
    
    -- Learning analytics
    attention_score DECIMAL(5,2) DEFAULT 0.0, -- Based on interaction patterns
    difficulty_rating INTEGER CHECK (difficulty_rating >= 1 AND difficulty_rating <= 5),
    
    -- Status
    is_deleted BOOLEAN DEFAULT false NOT NULL,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    UNIQUE(student_id, lesson_id)
) PARTITION BY RANGE (created_at);

-- Create monthly partitions for lesson_progress
DO $$
DECLARE
    start_date DATE;
    end_date DATE;
    partition_name TEXT;
BEGIN
    FOR i IN 0..12 LOOP
        start_date := DATE_TRUNC('month', CURRENT_DATE + (i || ' months')::INTERVAL);
        end_date := start_date + INTERVAL '1 month';
        partition_name := 'lesson_progress_' || TO_CHAR(start_date, 'YYYY_MM');
        
        EXECUTE FORMAT('
            CREATE TABLE IF NOT EXISTS %I PARTITION OF lesson_progress
            FOR VALUES FROM (%L) TO (%L)
        ', partition_name, start_date, end_date);
        
        -- Add indexes to each partition
        EXECUTE FORMAT('CREATE INDEX IF NOT EXISTS idx_%s_student_course ON %I(student_id, course_id)', partition_name, partition_name);
        EXECUTE FORMAT('CREATE INDEX IF NOT EXISTS idx_%s_completion ON %I(is_completed, completed_at DESC)', partition_name, partition_name);
        EXECUTE FORMAT('CREATE INDEX IF NOT EXISTS idx_%s_lesson ON %I(lesson_id)', partition_name, partition_name);
    END LOOP;
END $$;

-- =============================================
-- ASSIGNMENTS SYSTEM
-- =============================================

CREATE TABLE assignments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE, -- Optional: assignment can be standalone
    teacher_id UUID REFERENCES teachers(id) ON DELETE SET NULL NOT NULL,
    
    -- Assignment details
    title VARCHAR(300) NOT NULL,
    description TEXT NOT NULL,
    instructions TEXT,
    
    -- Assignment configuration
    assignment_type VARCHAR(50) DEFAULT 'essay' CHECK (assignment_type IN (
        'essay', 'multiple_choice', 'coding', 'file_upload', 'presentation', 
        'project', 'research', 'practical', 'group_work', 'peer_review'
    )),
    
    -- Submission settings
    max_file_size_mb INTEGER DEFAULT 10 CHECK (max_file_size_mb > 0),
    allowed_file_types TEXT[] DEFAULT '{pdf,doc,docx,txt}',
    max_submissions INTEGER DEFAULT 1 CHECK (max_submissions > 0),
    allow_late_submissions BOOLEAN DEFAULT false,
    
    -- Grading configuration
    total_marks DECIMAL(8,2) NOT NULL CHECK (total_marks > 0),
    passing_marks DECIMAL(8,2) NOT NULL CHECK (passing_marks >= 0 AND passing_marks <= total_marks),
    grading_rubric JSONB DEFAULT '{}',
    auto_grade BOOLEAN DEFAULT false,
    
    -- Timing
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    due_date TIMESTAMP WITH TIME ZONE NOT NULL,
    late_submission_deadline TIMESTAMP WITH TIME ZONE,
    
    -- Assignment resources
    reference_materials JSONB DEFAULT '[]',
    sample_submissions JSONB DEFAULT '[]',
    
    -- Status and settings
    is_published BOOLEAN DEFAULT false,
    is_mandatory BOOLEAN DEFAULT true,
    group_assignment BOOLEAN DEFAULT false,
    peer_review_required BOOLEAN DEFAULT false,
    
    -- Analytics (updated by background jobs)
    total_submissions INTEGER DEFAULT 0,
    total_graded INTEGER DEFAULT 0,
    average_score DECIMAL(5,2) DEFAULT 0.0,
    
    -- System status
    is_active BOOLEAN DEFAULT true NOT NULL,
    is_deleted BOOLEAN DEFAULT false NOT NULL,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT valid_due_date CHECK (due_date > assigned_at),
    CONSTRAINT valid_late_deadline CHECK (late_submission_deadline IS NULL OR late_submission_deadline > due_date)
);

-- Assignment submissions
CREATE TABLE assignment_submissions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    assignment_id UUID REFERENCES assignments(id) ON DELETE CASCADE NOT NULL,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE NOT NULL,
    enrollment_id UUID REFERENCES course_enrollments(id) ON DELETE CASCADE NOT NULL,
    
    -- Submission details
    submission_number INTEGER DEFAULT 1 CHECK (submission_number > 0),
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    is_late_submission BOOLEAN DEFAULT false,
    
    -- Content
    submission_text TEXT,
    submitted_files JSONB DEFAULT '[]', -- File URLs and metadata
    submission_data JSONB DEFAULT '{}', -- For structured submissions
    
    -- Grading
    is_graded BOOLEAN DEFAULT false,
    score DECIMAL(8,2) CHECK (score IS NULL OR score >= 0),
    max_score DECIMAL(8,2),
    grade VARCHAR(10), -- A, B, C, etc.
    
    -- Feedback
    teacher_feedback TEXT,
    graded_by UUID REFERENCES teachers(id) ON DELETE SET NULL,
    graded_at TIMESTAMP WITH TIME ZONE,
    feedback_files JSONB DEFAULT '[]',
    
    -- Status
    submission_status VARCHAR(30) DEFAULT 'submitted' CHECK (submission_status IN (
        'draft', 'submitted', 'under_review', 'graded', 'needs_revision', 'resubmitted'
    )),
    
    -- System
    is_deleted BOOLEAN DEFAULT false NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    UNIQUE(assignment_id, student_id, submission_number)
);

-- =============================================
-- TESTS/QUIZZES SYSTEM
-- =============================================

CREATE TABLE tests (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE, -- Optional
    teacher_id UUID REFERENCES teachers(id) ON DELETE SET NULL NOT NULL,
    
    -- Test details
    title VARCHAR(300) NOT NULL,
    description TEXT,
    instructions TEXT,
    
    -- Test configuration
    test_type VARCHAR(30) DEFAULT 'quiz' CHECK (test_type IN (
        'quiz', 'exam', 'practice_test', 'assessment', 'mock_test', 'final_exam'
    )),
    
    -- Question and timing settings
    total_questions INTEGER NOT NULL CHECK (total_questions > 0),
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
    
    -- Attempt settings
    max_attempts INTEGER DEFAULT 1 CHECK (max_attempts > 0),
    shuffle_questions BOOLEAN DEFAULT true,
    shuffle_options BOOLEAN DEFAULT true,
    show_results_immediately BOOLEAN DEFAULT true,
    show_correct_answers BOOLEAN DEFAULT false,
    
    -- Grading
    total_marks DECIMAL(8,2) NOT NULL CHECK (total_marks > 0),
    passing_marks DECIMAL(8,2) NOT NULL CHECK (passing_marks >= 0 AND passing_marks <= total_marks),
    
    -- Scheduling
    available_from TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    available_until TIMESTAMP WITH TIME ZONE,
    
    -- Test settings
    is_proctored BOOLEAN DEFAULT false,
    require_camera BOOLEAN DEFAULT false,
    require_microphone BOOLEAN DEFAULT false,
    prevent_copy_paste BOOLEAN DEFAULT true,
    full_screen_required BOOLEAN DEFAULT false,
    
    -- Security settings
    ip_restrictions TEXT[], -- Allowed IP addresses
    password_protected BOOLEAN DEFAULT false,
    test_password VARCHAR(100),
    
    -- Analytics (updated by background jobs)
    total_attempts INTEGER DEFAULT 0,
    total_completed INTEGER DEFAULT 0,
    average_score DECIMAL(5,2) DEFAULT 0.0,
    average_duration_minutes INTEGER DEFAULT 0,
    
    -- Status
    is_published BOOLEAN DEFAULT false,
    is_mandatory BOOLEAN DEFAULT true,
    
    -- System status
    is_active BOOLEAN DEFAULT true NOT NULL,
    is_deleted BOOLEAN DEFAULT false NOT NULL,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT valid_availability_period CHECK (available_until IS NULL OR available_until > available_from)
);

-- Test questions
CREATE TABLE test_questions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    test_id UUID REFERENCES tests(id) ON DELETE CASCADE NOT NULL,
    
    -- Question content
    question_text TEXT NOT NULL,
    question_type VARCHAR(30) DEFAULT 'multiple_choice' CHECK (question_type IN (
        'multiple_choice', 'true_false', 'short_answer', 'long_answer', 
        'fill_in_blank', 'matching', 'ordering', 'code'
    )),
    
    -- Question settings
    question_order INTEGER NOT NULL,
    marks DECIMAL(6,2) NOT NULL CHECK (marks > 0),
    difficulty_level INTEGER DEFAULT 2 CHECK (difficulty_level >= 1 AND difficulty_level <= 5),
    
    -- Options for MCQ/True-False
    options JSONB DEFAULT '[]', -- [{"text": "Option A", "is_correct": false}]
    
    -- Answer configuration
    correct_answer TEXT, -- For short answer, fill in blank
    answer_explanation TEXT,
    
    -- Question media
    question_image_url TEXT,
    question_audio_url TEXT,
    
    -- Analytics
    total_attempts INTEGER DEFAULT 0,
    correct_attempts INTEGER DEFAULT 0,
    
    -- System
    is_active BOOLEAN DEFAULT true NOT NULL,
    is_deleted BOOLEAN DEFAULT false NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    UNIQUE(test_id, question_order)
);

-- Test attempts (partitioned by date)
CREATE TABLE test_attempts (
    id UUID DEFAULT gen_random_uuid(),
    test_id UUID REFERENCES tests(id) ON DELETE CASCADE NOT NULL,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE NOT NULL,
    enrollment_id UUID REFERENCES course_enrollments(id) ON DELETE CASCADE NOT NULL,
    
    -- Attempt details
    attempt_number INTEGER NOT NULL CHECK (attempt_number > 0),
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    submitted_at TIMESTAMP WITH TIME ZONE,
    
    -- Results
    is_completed BOOLEAN DEFAULT false,
    score DECIMAL(8,2) DEFAULT 0.0,
    max_score DECIMAL(8,2) NOT NULL,
    percentage DECIMAL(5,2) GENERATED ALWAYS AS (
        CASE WHEN max_score > 0 THEN ROUND((score / max_score) * 100, 2) ELSE 0 END
    ) STORED,
    is_passed BOOLEAN,
    
    -- Timing
    duration_seconds INTEGER DEFAULT 0,
    time_remaining_seconds INTEGER,
    
    -- Answers
    answers JSONB DEFAULT '{}', -- {"question_id": "selected_answer"}
    
    -- Security and proctoring
    ip_address INET,
    user_agent TEXT,
    browser_info JSONB DEFAULT '{}',
    proctoring_violations JSONB DEFAULT '[]',
    
    -- Status
    attempt_status VARCHAR(30) DEFAULT 'in_progress' CHECK (attempt_status IN (
        'in_progress', 'completed', 'timed_out', 'abandoned', 'disqualified'
    )),
    
    -- System
    is_deleted BOOLEAN DEFAULT false NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    UNIQUE(test_id, student_id, attempt_number)
) PARTITION BY RANGE (created_at);

-- Create monthly partitions for test_attempts
DO $$
DECLARE
    start_date DATE;
    end_date DATE;
    partition_name TEXT;
BEGIN
    FOR i IN 0..12 LOOP
        start_date := DATE_TRUNC('month', CURRENT_DATE + (i || ' months')::INTERVAL);
        end_date := start_date + INTERVAL '1 month';
        partition_name := 'test_attempts_' || TO_CHAR(start_date, 'YYYY_MM');
        
        EXECUTE FORMAT('
            CREATE TABLE IF NOT EXISTS %I PARTITION OF test_attempts
            FOR VALUES FROM (%L) TO (%L)
        ', partition_name, start_date, end_date);
        
        -- Add indexes to each partition
        EXECUTE FORMAT('CREATE INDEX IF NOT EXISTS idx_%s_test_student ON %I(test_id, student_id)', partition_name, partition_name);
        EXECUTE FORMAT('CREATE INDEX IF NOT EXISTS idx_%s_completed ON %I(is_completed, submitted_at DESC)', partition_name, partition_name);
        EXECUTE FORMAT('CREATE INDEX IF NOT EXISTS idx_%s_student ON %I(student_id)', partition_name, partition_name);
    END LOOP;
END $$;

-- =============================================
-- PRODUCTION INDEXES
-- =============================================

-- Assignments indexes
CREATE INDEX CONCURRENTLY idx_assignments_course ON assignments(course_id) 
    WHERE is_deleted = false;
CREATE INDEX CONCURRENTLY idx_assignments_teacher ON assignments(teacher_id) 
    WHERE is_deleted = false;
CREATE INDEX CONCURRENTLY idx_assignments_due_date ON assignments(due_date) 
    WHERE is_published = true;
CREATE INDEX CONCURRENTLY idx_assignments_type ON assignments(assignment_type) 
    WHERE is_published = true;

-- Assignment submissions indexes
CREATE INDEX CONCURRENTLY idx_submissions_assignment ON assignment_submissions(assignment_id) 
    WHERE is_deleted = false;
CREATE INDEX CONCURRENTLY idx_submissions_student ON assignment_submissions(student_id) 
    WHERE is_deleted = false;
CREATE INDEX CONCURRENTLY idx_submissions_grading ON assignment_submissions(is_graded, graded_at DESC) 
    WHERE is_deleted = false;
CREATE INDEX CONCURRENTLY idx_submissions_status ON assignment_submissions(submission_status);

-- Tests indexes
CREATE INDEX CONCURRENTLY idx_tests_course ON tests(course_id) 
    WHERE is_deleted = false;
CREATE INDEX CONCURRENTLY idx_tests_availability ON tests(available_from, available_until) 
    WHERE is_published = true;
CREATE INDEX CONCURRENTLY idx_tests_type ON tests(test_type) 
    WHERE is_published = true;

-- Test questions indexes
CREATE INDEX CONCURRENTLY idx_test_questions_test ON test_questions(test_id, question_order) 
    WHERE is_deleted = false;
CREATE INDEX CONCURRENTLY idx_test_questions_difficulty ON test_questions(difficulty_level);

-- =============================================
-- STORED PROCEDURES FOR LEARNING PROGRESS
-- =============================================

-- Update lesson progress with comprehensive tracking
CREATE OR REPLACE FUNCTION sp_update_lesson_progress(
    p_student_id UUID,
    p_lesson_id UUID,
    p_watch_time_seconds INTEGER DEFAULT 0,
    p_completion_percentage DECIMAL DEFAULT NULL,
    p_interaction_data JSONB DEFAULT '{}'
) RETURNS JSONB AS $$
DECLARE
    v_course_id UUID;
    v_enrollment_id UUID;
    v_lesson_duration INTEGER;
    v_calculated_percentage DECIMAL(5,2);
    v_is_completed BOOLEAN;
    v_points_earned INTEGER := 0;
    result JSONB;
BEGIN
    -- Get course and enrollment info
    SELECT l.course_id INTO v_course_id
    FROM lessons l 
    WHERE l.id = p_lesson_id AND l.is_published = true;
    
    IF v_course_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Lesson not found');
    END IF;
    
    -- Get enrollment ID
    SELECT id INTO v_enrollment_id
    FROM course_enrollments
    WHERE student_id = p_student_id AND course_id = v_course_id AND is_active = true;
    
    IF v_enrollment_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Student not enrolled in course');
    END IF;
    
    -- Get lesson duration
    SELECT video_duration_seconds INTO v_lesson_duration
    FROM lessons WHERE id = p_lesson_id;
    
    -- Calculate completion percentage
    v_calculated_percentage := COALESCE(p_completion_percentage, 
        CASE WHEN v_lesson_duration > 0 
             THEN LEAST(100.0, (p_watch_time_seconds::DECIMAL / v_lesson_duration) * 100)
             ELSE 100.0 END
    );
    
    v_is_completed := v_calculated_percentage >= 90.0;
    
    -- Calculate points earned
    IF v_is_completed THEN
        v_points_earned := 10; -- Base points for completion
    END IF;
    
    -- Upsert lesson progress
    INSERT INTO lesson_progress (
        student_id, lesson_id, course_id, enrollment_id,
        total_watch_time_seconds, completion_percentage, is_completed,
        completed_at, last_accessed_at,
        pause_count, seek_count, replay_count
    ) VALUES (
        p_student_id, p_lesson_id, v_course_id, v_enrollment_id,
        p_watch_time_seconds, v_calculated_percentage, v_is_completed,
        CASE WHEN v_is_completed THEN NOW() ELSE NULL END, NOW(),
        COALESCE((p_interaction_data->>'pause_count')::INTEGER, 0),
        COALESCE((p_interaction_data->>'seek_count')::INTEGER, 0),
        COALESCE((p_interaction_data->>'replay_count')::INTEGER, 0)
    )
    ON CONFLICT (student_id, lesson_id) DO UPDATE SET
        total_watch_time_seconds = GREATEST(lesson_progress.total_watch_time_seconds, EXCLUDED.total_watch_time_seconds),
        completion_percentage = GREATEST(lesson_progress.completion_percentage, EXCLUDED.completion_percentage),
        is_completed = lesson_progress.is_completed OR EXCLUDED.is_completed,
        completed_at = COALESCE(lesson_progress.completed_at, EXCLUDED.completed_at),
        last_accessed_at = EXCLUDED.last_accessed_at,
        pause_count = EXCLUDED.pause_count,
        seek_count = EXCLUDED.seek_count,
        replay_count = EXCLUDED.replay_count,
        updated_at = NOW()
    WHERE EXCLUDED.total_watch_time_seconds > lesson_progress.total_watch_time_seconds
       OR (EXCLUDED.is_completed AND NOT lesson_progress.is_completed);
    
    -- Update enrollment progress (async via notification)
    PERFORM pg_notify('course_progress_update', 
        jsonb_build_object(
            'student_id', p_student_id, 
            'course_id', v_course_id,
            'enrollment_id', v_enrollment_id,
            'lesson_completed', v_is_completed,
            'points_earned', v_points_earned
        )::text
    );
    
    result := jsonb_build_object(
        'success', true,
        'completion_percentage', v_calculated_percentage,
        'is_completed', v_is_completed,
        'points_earned', v_points_earned
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Submit assignment with comprehensive validation
CREATE OR REPLACE FUNCTION sp_submit_assignment(
    p_assignment_id UUID,
    p_student_id UUID,
    p_submission_text TEXT DEFAULT NULL,
    p_submitted_files JSONB DEFAULT '[]',
    p_submission_data JSONB DEFAULT '{}'
) RETURNS JSONB AS $$
DECLARE
    v_assignment assignments%ROWTYPE;
    v_enrollment_id UUID;
    v_existing_submissions INTEGER;
    v_is_late BOOLEAN := false;
    v_submission_id UUID;
    result JSONB;
BEGIN
    -- Get assignment details
    SELECT * INTO v_assignment FROM assignments WHERE id = p_assignment_id AND is_published = true;
    
    IF v_assignment.id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Assignment not found');
    END IF;
    
    -- Check if student is enrolled
    SELECT id INTO v_enrollment_id
    FROM course_enrollments
    WHERE student_id = p_student_id AND course_id = v_assignment.course_id AND is_active = true;
    
    IF v_enrollment_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Student not enrolled in course');
    END IF;
    
    -- Check existing submissions
    SELECT COUNT(*) INTO v_existing_submissions
    FROM assignment_submissions
    WHERE assignment_id = p_assignment_id AND student_id = p_student_id AND is_deleted = false;
    
    IF v_existing_submissions >= v_assignment.max_submissions THEN
        RETURN jsonb_build_object('success', false, 'message', 'Maximum submission limit reached');
    END IF;
    
    -- Check if late submission
    v_is_late := NOW() > v_assignment.due_date;
    
    IF v_is_late AND NOT v_assignment.allow_late_submissions THEN
        RETURN jsonb_build_object('success', false, 'message', 'Late submissions not allowed');
    END IF;
    
    IF v_is_late AND v_assignment.late_submission_deadline IS NOT NULL AND NOW() > v_assignment.late_submission_deadline THEN
        RETURN jsonb_build_object('success', false, 'message', 'Late submission deadline passed');
    END IF;
    
    -- Create submission
    INSERT INTO assignment_submissions (
        assignment_id, student_id, enrollment_id,
        submission_number, submission_text, submitted_files, submission_data,
        is_late_submission, max_score
    ) VALUES (
        p_assignment_id, p_student_id, v_enrollment_id,
        v_existing_submissions + 1, p_submission_text, p_submitted_files, p_submission_data,
        v_is_late, v_assignment.total_marks
    ) RETURNING id INTO v_submission_id;
    
    -- Update assignment statistics
    UPDATE assignments SET
        total_submissions = total_submissions + 1,
        updated_at = NOW()
    WHERE id = p_assignment_id;
    
    -- Update enrollment
    UPDATE course_enrollments SET
        assignments_submitted = assignments_submitted + 1,
        last_accessed_at = NOW(),
        updated_at = NOW()
    WHERE id = v_enrollment_id;
    
    result := jsonb_build_object(
        'success', true,
        'submission_id', v_submission_id,
        'submission_number', v_existing_submissions + 1,
        'is_late_submission', v_is_late,
        'message', 'Assignment submitted successfully'
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Start test attempt with security checks
CREATE OR REPLACE FUNCTION sp_start_test_attempt(
    p_test_id UUID,
    p_student_id UUID,
    p_test_password VARCHAR DEFAULT NULL
) RETURNS JSONB AS $$
DECLARE
    v_test tests%ROWTYPE;
    v_enrollment_id UUID;
    v_existing_attempts INTEGER;
    v_attempt_id UUID;
    v_questions JSONB;
    result JSONB;
BEGIN
    -- Get test details
    SELECT * INTO v_test FROM tests WHERE id = p_test_id AND is_published = true;
    
    IF v_test.id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Test not found');
    END IF;
    
    -- Check availability period
    IF v_test.available_from > NOW() THEN
        RETURN jsonb_build_object('success', false, 'message', 'Test not yet available');
    END IF;
    
    IF v_test.available_until IS NOT NULL AND v_test.available_until < NOW() THEN
        RETURN jsonb_build_object('success', false, 'message', 'Test is no longer available');
    END IF;
    
    -- Check password if required
    IF v_test.password_protected AND (p_test_password IS NULL OR p_test_password != v_test.test_password) THEN
        RETURN jsonb_build_object('success', false, 'message', 'Invalid test password');
    END IF;
    
    -- Check enrollment
    SELECT id INTO v_enrollment_id
    FROM course_enrollments
    WHERE student_id = p_student_id AND course_id = v_test.course_id AND is_active = true;
    
    IF v_enrollment_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Student not enrolled in course');
    END IF;
    
    -- Check attempt limit
    SELECT COUNT(*) INTO v_existing_attempts
    FROM test_attempts
    WHERE test_id = p_test_id AND student_id = p_student_id AND is_deleted = false;
    
    IF v_existing_attempts >= v_test.max_attempts THEN
        RETURN jsonb_build_object('success', false, 'message', 'Maximum attempts reached');
    END IF;
    
    -- Get shuffled questions
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', q.id,
            'question_text', q.question_text,
            'question_type', q.question_type,
            'marks', q.marks,
            'options', CASE 
                WHEN v_test.shuffle_options AND q.question_type = 'multiple_choice'
                THEN (SELECT jsonb_agg(opt ORDER BY random()) FROM jsonb_array_elements(q.options) opt)
                ELSE q.options
            END,
            'question_image_url', q.question_image_url
        )
        ORDER BY CASE WHEN v_test.shuffle_questions THEN random() ELSE q.question_order END
    ) INTO v_questions
    FROM test_questions q
    WHERE q.test_id = p_test_id AND q.is_active = true AND q.is_deleted = false;
    
    -- Create test attempt
    INSERT INTO test_attempts (
        test_id, student_id, enrollment_id, attempt_number,
        max_score, time_remaining_seconds, ip_address, user_agent
    ) VALUES (
        p_test_id, p_student_id, v_enrollment_id, v_existing_attempts + 1,
        v_test.total_marks, v_test.duration_minutes * 60,
        inet_client_addr(), current_setting('request.headers', true)::jsonb->>'user-agent'
    ) RETURNING id INTO v_attempt_id;
    
    result := jsonb_build_object(
        'success', true,
        'attempt_id', v_attempt_id,
        'attempt_number', v_existing_attempts + 1,
        'duration_minutes', v_test.duration_minutes,
        'total_marks', v_test.total_marks,
        'questions', v_questions,
        'settings', jsonb_build_object(
            'prevent_copy_paste', v_test.prevent_copy_paste,
            'full_screen_required', v_test.full_screen_required,
            'show_results_immediately', v_test.show_results_immediately
        )
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply audit triggers
CREATE TRIGGER trg_audit_enrollments AFTER INSERT OR UPDATE OR DELETE ON course_enrollments 
    FOR EACH ROW EXECUTE FUNCTION audit.log_changes();
CREATE TRIGGER trg_audit_assignments AFTER INSERT OR UPDATE OR DELETE ON assignments 
    FOR EACH ROW EXECUTE FUNCTION audit.log_changes();
CREATE TRIGGER trg_audit_assignment_submissions AFTER INSERT OR UPDATE OR DELETE ON assignment_submissions 
    FOR EACH ROW EXECUTE FUNCTION audit.log_changes();
CREATE TRIGGER trg_audit_tests AFTER INSERT OR UPDATE OR DELETE ON tests 
    FOR EACH ROW EXECUTE FUNCTION audit.log_changes();
CREATE TRIGGER trg_audit_test_questions AFTER INSERT OR UPDATE OR DELETE ON test_questions 
    FOR EACH ROW EXECUTE FUNCTION audit.log_changes();

-- Apply update triggers
CREATE TRIGGER trg_updated_at_enrollments BEFORE UPDATE ON course_enrollments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_updated_at_assignments BEFORE UPDATE ON assignments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_updated_at_assignment_submissions BEFORE UPDATE ON assignment_submissions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_updated_at_tests BEFORE UPDATE ON tests 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_updated_at_test_attempts BEFORE UPDATE ON test_attempts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
