-- =============================================
-- PRODUCTION-READY LMS DATABASE SCHEMA
-- Multi-Coaching Center Learning Management System
-- =============================================

-- Phase 1: Extensions and Core Functions
-- =============================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- Helper functions for RLS (Security Definer for elevated privileges)
CREATE OR REPLACE FUNCTION get_user_type()
RETURNS TEXT AS $$
BEGIN
    RETURN COALESCE((
        SELECT user_type
        FROM user_profiles
        WHERE id = auth.uid()
    ), 'anonymous');
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'anonymous';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM user_profiles 
        WHERE id = auth.uid() AND user_type = 'admin'
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION get_user_coaching_center_id()
RETURNS UUID AS $$
BEGIN
    RETURN (
        SELECT CASE
            WHEN up.user_type = 'coaching_center' THEN cc.id
            WHEN up.user_type = 'teacher' THEN t.coaching_center_id
            ELSE NULL
        END
        FROM user_profiles up
        LEFT JOIN coaching_centers cc ON cc.user_id = up.id
        LEFT JOIN teachers t ON t.user_id = up.id
        WHERE up.id = auth.uid()
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION get_student_id()
RETURNS UUID AS $$
BEGIN
    RETURN (
        SELECT id
        FROM students
        WHERE user_id = auth.uid()
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- =============================================
-- Phase 2: Core Tables
-- =============================================

-- User Profiles Table (extends auth.users)
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('student', 'teacher', 'admin', 'coaching_center')),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    avatar_url TEXT,
    date_of_birth DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    address JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    phone_verified BOOLEAN DEFAULT false,
    onboarding_completed BOOLEAN DEFAULT false,
    preferences JSONB DEFAULT '{}',
    last_seen TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT valid_phone CHECK (phone IS NULL OR phone ~* '^\+?[1-9]\d{9,14}$')
);

-- Coaching Centers Table
CREATE TABLE IF NOT EXISTS coaching_centers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE UNIQUE NOT NULL,
    center_name VARCHAR(200) NOT NULL,
    center_code VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    website_url TEXT,
    logo_url TEXT,
    contact_email VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(20) NOT NULL,
    address JSONB NOT NULL DEFAULT '{}',
    registration_number VARCHAR(100),
    tax_id VARCHAR(50),
    approval_status VARCHAR(20) DEFAULT 'pending' CHECK (approval_status IN ('pending', 'approved', 'rejected', 'suspended')),
    approved_by UUID REFERENCES user_profiles(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    subscription_plan VARCHAR(50) DEFAULT 'basic' CHECK (subscription_plan IN ('basic', 'premium', 'enterprise')),
    max_faculty_limit INTEGER DEFAULT 10 CHECK (max_faculty_limit > 0),
    max_courses_limit INTEGER DEFAULT 50 CHECK (max_courses_limit > 0),
    max_students_limit INTEGER DEFAULT 1000 CHECK (max_students_limit > 0),
    is_active BOOLEAN DEFAULT true,
    total_courses INTEGER DEFAULT 0 CHECK (total_courses >= 0),
    total_students INTEGER DEFAULT 0 CHECK (total_students >= 0),
    total_teachers INTEGER DEFAULT 0 CHECK (total_teachers >= 0),
    rating DECIMAL(3,2) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
    total_reviews INTEGER DEFAULT 0 CHECK (total_reviews >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT valid_contact_email CHECK (contact_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT valid_contact_phone CHECK (contact_phone ~* '^\+?[1-9]\d{9,14}$')
);

-- Course Categories Table (New - for better organization)
CREATE TABLE IF NOT EXISTS course_categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_id UUID REFERENCES course_categories(id) ON DELETE CASCADE,
    icon_url TEXT,
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Teachers Table
CREATE TABLE IF NOT EXISTS teachers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE UNIQUE NOT NULL,
    coaching_center_id UUID REFERENCES coaching_centers(id) ON DELETE CASCADE NOT NULL,
    employee_id VARCHAR(50),
    title VARCHAR(100), -- Dr., Prof., Mr., Ms., etc.
    specializations TEXT[] DEFAULT '{}',
    qualifications JSONB DEFAULT '[]',
    experience_years INTEGER DEFAULT 0 CHECK (experience_years >= 0),
    bio TEXT,
    hourly_rate DECIMAL(10,2) CHECK (hourly_rate >= 0),
    rating DECIMAL(3,2) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
    total_reviews INTEGER DEFAULT 0 CHECK (total_reviews >= 0),
    total_courses INTEGER DEFAULT 0 CHECK (total_courses >= 0),
    total_students_taught INTEGER DEFAULT 0 CHECK (total_students_taught >= 0),
    is_verified BOOLEAN DEFAULT false,
    can_create_courses BOOLEAN DEFAULT true,
    can_conduct_live_classes BOOLEAN DEFAULT true,
    can_grade_assignments BOOLEAN DEFAULT true,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT unique_employee_per_center UNIQUE(coaching_center_id, employee_id)
);

-- Enhanced Students Table
CREATE TABLE IF NOT EXISTS students (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE UNIQUE NOT NULL,
    student_id VARCHAR(50) UNIQUE NOT NULL,
    
    -- Academic Information (Enhanced for Indian System)
    grade_level VARCHAR(50) CHECK (grade_level IN (
        'class_1', 'class_2', 'class_3', 'class_4', 'class_5',
        'class_6', 'class_7', 'class_8', 'class_9', 'class_10',
        'class_11_science', 'class_11_commerce', 'class_11_arts',
        'class_12_science', 'class_12_commerce', 'class_12_arts',
        'ug_1st_year', 'ug_2nd_year', 'ug_3rd_year', 'ug_4th_year',
        'btech_1st_year', 'btech_2nd_year', 'btech_3rd_year', 'btech_4th_year',
        'mbbs_1st_year', 'mbbs_2nd_year', 'mbbs_3rd_year', 'mbbs_4th_year', 'mbbs_5th_year',
        'pg_1st_year', 'pg_2nd_year',
        'mba_1st_year', 'mba_2nd_year',
        'mtech_1st_year', 'mtech_2nd_year',
        'phd', 'working_professional', 'other'
    )),
    
    education_board VARCHAR(50) CHECK (education_board IN (
        'cbse', 'icse', 'state_board', 'igcse', 'ib', 'nios', 'other'
    )),
    
    primary_interest VARCHAR(100),
    secondary_interests TEXT[] DEFAULT '{}',
    
    -- Location Information
    state VARCHAR(100),
    city VARCHAR(100),
    pincode VARCHAR(10),
    
    -- Language Preferences
    preferred_language VARCHAR(10) DEFAULT 'en' CHECK (preferred_language IN (
        'en', 'hi', 'ta', 'te', 'bn', 'mr', 'gu', 'kn', 'ml', 'or', 'pa', 'as', 'ur'
    )),
    other_languages TEXT[] DEFAULT '{}',
    
    -- Institution Information
    school_name VARCHAR(200),
    institution_type VARCHAR(50) CHECK (institution_type IN (
        'school', 'college', 'university', 'coaching_center', 'self_study', 'other'
    )),
    
    -- Parent/Guardian Information
    parent_name VARCHAR(200),
    parent_phone VARCHAR(20),
    parent_email VARCHAR(255),
    guardian_relationship VARCHAR(50) DEFAULT 'parent' CHECK (guardian_relationship IN (
        'parent', 'guardian', 'sibling', 'relative', 'self', 'other'
    )),
    
    -- Learning Preferences and Goals
    learning_goals TEXT[] DEFAULT '{}',
    preferred_learning_style VARCHAR(50) CHECK (preferred_learning_style IN (
        'visual', 'auditory', 'kinesthetic', 'reading_writing', 'mixed'
    )),
    
    -- Competitive Exam Preparation
    competitive_exams TEXT[] DEFAULT '{}',
    target_exam_year INTEGER CHECK (target_exam_year >= EXTRACT(YEAR FROM NOW())),
    
    -- System Preferences
    timezone VARCHAR(50) DEFAULT 'Asia/Kolkata',
    
    -- Learning Statistics
    total_courses_enrolled INTEGER DEFAULT 0 CHECK (total_courses_enrolled >= 0),
    total_courses_completed INTEGER DEFAULT 0 CHECK (total_courses_completed >= 0),
    total_hours_learned DECIMAL(10,2) DEFAULT 0.0 CHECK (total_hours_learned >= 0),
    current_streak_days INTEGER DEFAULT 0 CHECK (current_streak_days >= 0),
    longest_streak_days INTEGER DEFAULT 0 CHECK (longest_streak_days >= 0),
    total_points INTEGER DEFAULT 0 CHECK (total_points >= 0),
    level INTEGER DEFAULT 1 CHECK (level >= 1 AND level <= 100),
    
    -- Achievements and Badges
    badges JSONB DEFAULT '[]',
    achievements JSONB DEFAULT '{}',
    
    -- Study Preferences
    daily_study_goal_minutes INTEGER DEFAULT 60 CHECK (daily_study_goal_minutes > 0),
    preferred_study_time VARCHAR(20) DEFAULT 'evening' CHECK (preferred_study_time IN (
        'early_morning', 'morning', 'afternoon', 'evening', 'night', 'flexible'
    )),
    
    -- Account Status
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    verification_method VARCHAR(50),
    subscription_status VARCHAR(20) DEFAULT 'free' CHECK (subscription_status IN ('free', 'premium', 'trial')),
    subscription_expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_date DATE,
    last_streak_update_date DATE,
    profile_completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CONSTRAINT valid_courses_completed CHECK (total_courses_completed <= total_courses_enrolled),
    CONSTRAINT valid_streak_days CHECK (longest_streak_days >= current_streak_days),
    CONSTRAINT valid_parent_email CHECK (parent_email IS NULL OR parent_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT valid_parent_phone CHECK (parent_phone IS NULL OR parent_phone ~* '^\+?[1-9]\d{9,14}$')
);

-- =============================================
-- Phase 3: Course Structure
-- =============================================

-- Courses Table (Enhanced)
CREATE TABLE IF NOT EXISTS courses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    coaching_center_id UUID REFERENCES coaching_centers(id) ON DELETE CASCADE NOT NULL,
    category_id UUID REFERENCES course_categories(id) ON DELETE SET NULL,
    primary_teacher_id UUID REFERENCES teachers(id) ON DELETE SET NULL,
    title VARCHAR(300) NOT NULL,
    slug VARCHAR(300) UNIQUE NOT NULL,
    description TEXT,
    short_description TEXT,
    thumbnail_url TEXT,
    trailer_video_url TEXT,
    course_content_overview TEXT,
    what_you_learn TEXT[] DEFAULT '{}',
    course_includes JSONB DEFAULT '{}',
    target_audience TEXT[] DEFAULT '{}',
    prerequisites TEXT[] DEFAULT '{}',
    learning_outcomes TEXT[] DEFAULT '{}',
    
    -- Course Classification
    level VARCHAR(20) DEFAULT 'beginner' CHECK (level IN ('beginner', 'intermediate', 'advanced', 'expert')),
    language VARCHAR(10) DEFAULT 'en',
    tags TEXT[] DEFAULT '{}',
    
    -- Pricing
    price DECIMAL(10,2) DEFAULT 0.00 CHECK (price >= 0),
    original_price DECIMAL(10,2) CHECK (original_price IS NULL OR original_price >= price),
    currency VARCHAR(3) DEFAULT 'INR',
    is_free BOOLEAN GENERATED ALWAYS AS (price = 0) STORED,
    
    -- Course Metrics
    duration_hours DECIMAL(8,2) DEFAULT 0 CHECK (duration_hours >= 0),
    total_lessons INTEGER DEFAULT 0 CHECK (total_lessons >= 0),
    total_chapters INTEGER DEFAULT 0 CHECK (total_chapters >= 0),
    total_assignments INTEGER DEFAULT 0 CHECK (total_assignments >= 0),
    total_quizzes INTEGER DEFAULT 0 CHECK (total_quizzes >= 0),
    
    -- Enrollment Settings
    max_enrollments INTEGER CHECK (max_enrollments IS NULL OR max_enrollments > 0),
    enrollment_start_date TIMESTAMP WITH TIME ZONE,
    enrollment_deadline TIMESTAMP WITH TIME ZONE,
    course_start_date TIMESTAMP WITH TIME ZONE,
    course_end_date TIMESTAMP WITH TIME ZONE,
    
    -- Status and Visibility
    is_published BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    is_archived BOOLEAN DEFAULT false,
    publish_date TIMESTAMP WITH TIME ZONE,
    
    -- Analytics
    enrollment_count INTEGER DEFAULT 0 CHECK (enrollment_count >= 0),
    completed_count INTEGER DEFAULT 0 CHECK (completed_count >= 0),
    rating DECIMAL(3,2) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
    total_reviews INTEGER DEFAULT 0 CHECK (total_reviews >= 0),
    completion_rate DECIMAL(5,2) DEFAULT 0.0 CHECK (completion_rate >= 0 AND completion_rate <= 100),
    view_count INTEGER DEFAULT 0 CHECK (view_count >= 0),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    published_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CONSTRAINT valid_enrollment_dates CHECK (enrollment_deadline IS NULL OR enrollment_start_date IS NULL OR enrollment_deadline >= enrollment_start_date),
    CONSTRAINT valid_course_dates CHECK (course_end_date IS NULL OR course_start_date IS NULL OR course_end_date >= course_start_date)
);

-- Course Teachers Junction Table (Many-to-Many)
CREATE TABLE IF NOT EXISTS course_teachers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    teacher_id UUID REFERENCES teachers(id) ON DELETE CASCADE NOT NULL,
    role VARCHAR(50) DEFAULT 'instructor' CHECK (role IN ('primary_instructor', 'co_instructor', 'guest_lecturer', 'teaching_assistant')),
    is_primary BOOLEAN DEFAULT false,
    permissions JSONB DEFAULT '{}',
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(course_id, teacher_id)
);

-- Chapters Table
CREATE TABLE IF NOT EXISTS chapters (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    title VARCHAR(300) NOT NULL,
    description TEXT,
    chapter_number INTEGER NOT NULL CHECK (chapter_number > 0),
    duration_minutes INTEGER DEFAULT 0 CHECK (duration_minutes >= 0),
    total_lessons INTEGER DEFAULT 0 CHECK (total_lessons >= 0),
    learning_objectives TEXT[] DEFAULT '{}',
    is_published BOOLEAN DEFAULT false,
    is_free BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(course_id, chapter_number),
    UNIQUE(course_id, sort_order)
);

-- Lessons Table (Enhanced)
CREATE TABLE IF NOT EXISTS lessons (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    chapter_id UUID REFERENCES chapters(id) ON DELETE CASCADE NOT NULL,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    title VARCHAR(300) NOT NULL,
    description TEXT,
    lesson_number INTEGER NOT NULL CHECK (lesson_number > 0),
    lesson_type VARCHAR(20) DEFAULT 'video' CHECK (lesson_type IN ('video', 'text', 'quiz', 'assignment', 'live_class', 'document', 'interactive')),
    
    -- Content Details
    content_url TEXT,
    video_duration INTEGER CHECK (video_duration IS NULL OR video_duration > 0),
    transcript TEXT,
    notes TEXT,
    attachments JSONB DEFAULT '[]',
    resources JSONB DEFAULT '[]',
    
    -- Settings
    is_published BOOLEAN DEFAULT false,
    is_free BOOLEAN DEFAULT false,
    is_downloadable BOOLEAN DEFAULT false,
    requires_completion BOOLEAN DEFAULT false,
    
    -- Analytics
    view_count INTEGER DEFAULT 0 CHECK (view_count >= 0),
    completion_count INTEGER DEFAULT 0 CHECK (completion_count >= 0),
    completion_rate DECIMAL(5,2) DEFAULT 0.0 CHECK (completion_rate >= 0 AND completion_rate <= 100),
    average_watch_time INTEGER DEFAULT 0 CHECK (average_watch_time >= 0),
    
    -- Ordering
    sort_order INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(chapter_id, lesson_number),
    UNIQUE(chapter_id, sort_order)
);

-- =============================================
-- Phase 4: Assessments & Testing
-- =============================================

-- Tests Table (Enhanced)
CREATE TABLE IF NOT EXISTS tests (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    chapter_id UUID REFERENCES chapters(id) ON DELETE CASCADE,
    lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE,
    coaching_center_id UUID REFERENCES coaching_centers(id) ON DELETE CASCADE NOT NULL,
    teacher_id UUID REFERENCES teachers(id) ON DELETE SET NULL,
    
    title VARCHAR(300) NOT NULL,
    description TEXT,
    instructions TEXT,
    
    test_type VARCHAR(20) DEFAULT 'quiz' CHECK (test_type IN ('quiz', 'assignment', 'exam', 'practice', 'assessment')),
    difficulty_level VARCHAR(20) DEFAULT 'medium' CHECK (difficulty_level IN ('easy', 'medium', 'hard', 'expert')),
    
    -- Question Settings
    total_questions INTEGER NOT NULL CHECK (total_questions > 0),
    total_marks DECIMAL(8,2) NOT NULL CHECK (total_marks > 0),
    passing_marks DECIMAL(8,2) NOT NULL CHECK (passing_marks >= 0 AND passing_marks <= total_marks),
    negative_marking BOOLEAN DEFAULT false,
    negative_marks_per_question DECIMAL(4,2) DEFAULT 0 CHECK (negative_marks_per_question >= 0),
    
    -- Time Settings
    time_limit_minutes INTEGER CHECK (time_limit_minutes IS NULL OR time_limit_minutes > 0),
    extra_time_minutes INTEGER DEFAULT 0 CHECK (extra_time_minutes >= 0),
    
    -- Attempt Settings
    attempts_allowed INTEGER DEFAULT 1 CHECK (attempts_allowed > 0),
    time_between_attempts_hours INTEGER DEFAULT 0 CHECK (time_between_attempts_hours >= 0),
    
    -- Display Settings
    show_results_immediately BOOLEAN DEFAULT true,
    show_correct_answers BOOLEAN DEFAULT true,
    show_explanations BOOLEAN DEFAULT true,
    randomize_questions BOOLEAN DEFAULT false,
    randomize_options BOOLEAN DEFAULT false,
    
    -- Scheduling
    available_from TIMESTAMP WITH TIME ZONE,
    available_until TIMESTAMP WITH TIME ZONE,
    
    -- Status
    is_published BOOLEAN DEFAULT false,
    is_proctored BOOLEAN DEFAULT false,
    
    -- Analytics
    attempt_count INTEGER DEFAULT 0 CHECK (attempt_count >= 0),
    average_score DECIMAL(5,2) DEFAULT 0 CHECK (average_score >= 0),
    pass_rate DECIMAL(5,2) DEFAULT 0 CHECK (pass_rate >= 0 AND pass_rate <= 100),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT valid_availability_dates CHECK (available_until IS NULL OR available_from IS NULL OR available_until >= available_from)
);

-- Test Questions Table (Enhanced)
CREATE TABLE IF NOT EXISTS test_questions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    test_id UUID REFERENCES tests(id) ON DELETE CASCADE NOT NULL,
    question_text TEXT NOT NULL,
    question_type VARCHAR(20) DEFAULT 'mcq' CHECK (question_type IN ('mcq', 'multiple_select', 'short_answer', 'essay', 'true_false', 'fill_blanks', 'matching')),
    
    -- Question Content
    options JSONB DEFAULT '[]',
    correct_answers JSONB NOT NULL,
    explanation TEXT,
    hints TEXT[],
    
    -- Question Settings
    marks DECIMAL(6,2) DEFAULT 1 CHECK (marks > 0),
    negative_marks DECIMAL(6,2) DEFAULT 0 CHECK (negative_marks >= 0),
    difficulty_level VARCHAR(10) DEFAULT 'medium' CHECK (difficulty_level IN ('easy', 'medium', 'hard')),
    
    -- Categorization
    topic VARCHAR(200),
    subtopic VARCHAR(200),
    tags TEXT[] DEFAULT '{}',
    
    -- Ordering and Display
    question_order INTEGER NOT NULL,
    time_limit_seconds INTEGER CHECK (time_limit_seconds IS NULL OR time_limit_seconds > 0),
    
    -- Analytics
    attempt_count INTEGER DEFAULT 0 CHECK (attempt_count >= 0),
    correct_count INTEGER DEFAULT 0 CHECK (correct_count >= 0),
    difficulty_score DECIMAL(3,2) DEFAULT 0.5 CHECK (difficulty_score >= 0 AND difficulty_score <= 1),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(test_id, question_order)
);

-- Test Results Table (Enhanced)
CREATE TABLE IF NOT EXISTS test_results (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    test_id UUID REFERENCES tests(id) ON DELETE CASCADE NOT NULL,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE NOT NULL,
    
    -- Attempt Details
    attempt_number INTEGER DEFAULT 1 CHECK (attempt_number > 0),
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    submitted_at TIMESTAMP WITH TIME ZONE,
    
    -- Scoring
    total_questions INTEGER NOT NULL CHECK (total_questions > 0),
    questions_attempted INTEGER DEFAULT 0 CHECK (questions_attempted >= 0 AND questions_attempted <= total_questions),
    correct_answers INTEGER DEFAULT 0 CHECK (correct_answers >= 0),
    incorrect_answers INTEGER DEFAULT 0 CHECK (incorrect_answers >= 0),
    skipped_questions INTEGER DEFAULT 0 CHECK (skipped_questions >= 0),
    
    score DECIMAL(8,2) NOT NULL DEFAULT 0 CHECK (score >= 0),
    total_marks DECIMAL(8,2) NOT NULL CHECK (total_marks > 0),
    percentage DECIMAL(5,2) GENERATED ALWAYS AS (
        CASE 
            WHEN total_marks > 0 THEN ROUND((score / total_marks * 100), 2)
            ELSE 0 
        END
    ) STORED,
    passed BOOLEAN DEFAULT false,
    grade VARCHAR(5),
    
    -- Time Tracking
    time_taken_minutes INTEGER CHECK (time_taken_minutes IS NULL OR time_taken_minutes >= 0),
    time_limit_minutes INTEGER,
    extra_time_used INTEGER DEFAULT 0 CHECK (extra_time_used >= 0),
    
    -- Answers and Analysis
    answers JSONB DEFAULT '{}',
    question_wise_analysis JSONB DEFAULT '{}',
    
    -- Status and Flags
    is_submitted BOOLEAN DEFAULT false,
    is_flagged BOOLEAN DEFAULT false,
    flag_reason TEXT,
    is_proctored BOOLEAN DEFAULT false,
    proctoring_data JSONB DEFAULT '{}',
    
    -- Analytics
    rank_in_test INTEGER,
    percentile DECIMAL(5,2),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(test_id, student_id, attempt_number),
    CONSTRAINT valid_question_counts CHECK (questions_attempted = correct_answers + incorrect_answers + skipped_questions)
);

-- =============================================
-- Phase 5: Assignments System
-- =============================================

-- Assignments Table (Enhanced)
CREATE TABLE IF NOT EXISTS assignments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    chapter_id UUID REFERENCES chapters(id) ON DELETE CASCADE,
    teacher_id UUID REFERENCES teachers(id) ON DELETE CASCADE NOT NULL,
    
    title VARCHAR(300) NOT NULL,
    description TEXT NOT NULL,
    instructions TEXT,
    
    assignment_type VARCHAR(30) DEFAULT 'project' CHECK (assignment_type IN ('quiz', 'project', 'essay', 'coding', 'presentation', 'research', 'case_study', 'lab_report')),
    submission_format VARCHAR(30) NOT NULL CHECK (submission_format IN ('file_upload', 'text_submission', 'github_link', 'url_submission', 'video_upload', 'multiple_files')),
    
    -- Grading
    total_marks DECIMAL(8,2) NOT NULL DEFAULT 100 CHECK (total_marks > 0),
    passing_marks DECIMAL(8,2) DEFAULT 40 CHECK (passing_marks >= 0 AND passing_marks <= total_marks),
    grading_rubric JSONB DEFAULT '{}',
    
    -- Timing
    assigned_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    due_date TIMESTAMP WITH TIME ZONE NOT NULL,
    late_submission_deadline TIMESTAMP WITH TIME ZONE,
    
    -- Settings
    allow_late_submission BOOLEAN DEFAULT true,
    late_penalty_percentage DECIMAL(5,2) DEFAULT 10 CHECK (late_penalty_percentage >= 0 AND late_penalty_percentage <= 100),
    is_group_assignment BOOLEAN DEFAULT false,
    max_group_size INTEGER DEFAULT 1 CHECK (max_group_size > 0),
    allow_resubmission BOOLEAN DEFAULT false,
    max_file_size_mb INTEGER DEFAULT 50 CHECK (max_file_size_mb > 0),
    allowed_file_types TEXT[] DEFAULT '{"pdf","doc","docx","txt","zip","jpg","png"}',
    
    -- Resources and References
    resources JSONB DEFAULT '[]',
    reference_materials JSONB DEFAULT '[]',
    sample_submissions JSONB DEFAULT '[]',
    
    -- Status
    is_published BOOLEAN DEFAULT false,
    is_archived BOOLEAN DEFAULT false,
    
    -- Analytics
    submission_count INTEGER DEFAULT 0 CHECK (submission_count >= 0),
    on_time_submissions INTEGER DEFAULT 0 CHECK (on_time_submissions >= 0),
    average_grade DECIMAL(5,2) DEFAULT 0 CHECK (average_grade >= 0),
    
    -- AI Features
    plagiarism_check_enabled BOOLEAN DEFAULT false,
    auto_grade_enabled BOOLEAN DEFAULT false,
    ai_feedback_enabled BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT valid_deadline CHECK (due_date > assigned_date),
    CONSTRAINT valid_late_deadline CHECK (late_submission_deadline IS NULL OR late_submission_deadline >= due_date)
);

-- Assignment Submissions Table (Enhanced)
CREATE TABLE IF NOT EXISTS assignment_submissions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    assignment_id UUID REFERENCES assignments(id) ON DELETE CASCADE NOT NULL,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE NOT NULL,
    
    -- Submission Content
    submission_text TEXT,
    submission_files JSONB DEFAULT '[]',
    submission_urls JSONB DEFAULT '[]',
    
    -- Submission Details
    attempt_number INTEGER DEFAULT 1 CHECK (attempt_number > 0),
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_late BOOLEAN DEFAULT false,
    
    -- Grading
    grade DECIMAL(8,2) CHECK (grade IS NULL OR grade >= 0),
    feedback TEXT,
    detailed_feedback JSONB DEFAULT '{}',
    graded_at TIMESTAMP WITH TIME ZONE,
    graded_by UUID REFERENCES teachers(id),
    
    -- Status
    submission_status VARCHAR(20) DEFAULT 'submitted' CHECK (submission_status IN ('draft', 'submitted', 'under_review', 'graded', 'returned', 'resubmission_required')),
    
    -- Quality Checks
    plagiarism_score DECIMAL(5,2) CHECK (plagiarism_score IS NULL OR (plagiarism_score >= 0 AND plagiarism_score <= 100)),
    plagiarism_report JSONB DEFAULT '{}',
    word_count INTEGER DEFAULT 0 CHECK (word_count >= 0),
    
    -- File Information
    total_file_size_mb DECIMAL(8,2) DEFAULT 0 CHECK (total_file_size_mb >= 0),
    file_count INTEGER DEFAULT 0 CHECK (file_count >= 0),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    
    UNIQUE(assignment_id, student_id, attempt_number)
);

-- =============================================
-- Phase 6: Enrollment & Progress Tracking
-- =============================================

-- Course Enrollments Table (Enhanced)
CREATE TABLE IF NOT EXISTS course_enrollments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE NOT NULL,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    
    -- Enrollment Details
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    enrollment_method VARCHAR(20) DEFAULT 'direct' CHECK (enrollment_method IN ('direct', 'invitation', 'bulk_import', 'api')),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'free', 'partial', 'refunded')),
    
    -- Progress Tracking
    progress_percentage DECIMAL(5,2) DEFAULT 0.0 CHECK (progress_percentage >= 0.0 AND progress_percentage <= 100.0),
    lessons_completed INTEGER DEFAULT 0 CHECK (lessons_completed >= 0),
    total_lessons_in_course INTEGER DEFAULT 0 CHECK (total_lessons_in_course >= 0),
    chapters_completed INTEGER DEFAULT 0 CHECK (chapters_completed >= 0),
    total_chapters_in_course INTEGER DEFAULT 0 CHECK (total_chapters_in_course >= 0),
    
    -- Time Tracking
    total_time_spent_minutes INTEGER DEFAULT 0 CHECK (total_time_spent_minutes >= 0),
    average_session_duration_minutes DECIMAL(6,2) DEFAULT 0 CHECK (average_session_duration_minutes >= 0),
    total_sessions INTEGER DEFAULT 0 CHECK (total_sessions >= 0),
    
    -- Completion
    completed_at TIMESTAMP WITH TIME ZONE,
    completion_percentage_required DECIMAL(5,2) DEFAULT 80.0 CHECK (completion_percentage_required > 0 AND completion_percentage_required <= 100),
    
    -- Access Control
    last_accessed_at TIMESTAMP WITH TIME ZONE,
    access_expires_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    
    -- Course Specific Progress
    current_chapter_id UUID REFERENCES chapters(id),
    current_lesson_id UUID REFERENCES lessons(id),
    bookmarked_lessons UUID[] DEFAULT '{}',
    notes TEXT,
    
    -- Certification
    certificate_issued BOOLEAN DEFAULT false,
    certificate_issued_at TIMESTAMP WITH TIME ZONE,
    certificate_id UUID,
    
    -- Feedback and Rating
    course_rating INTEGER CHECK (course_rating IS NULL OR (course_rating >= 1 AND course_rating <= 5)),
    course_review TEXT,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    
    -- Performance Metrics
    average_quiz_score DECIMAL(5,2) DEFAULT 0 CHECK (average_quiz_score >= 0),
    assignments_submitted INTEGER DEFAULT 0 CHECK (assignments_submitted >= 0),
    assignments_graded INTEGER DEFAULT 0 CHECK (assignments_graded >= 0),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(student_id, course_id),
    CONSTRAINT valid_lesson_progress CHECK (lessons_completed <= total_lessons_in_course),
    CONSTRAINT valid_chapter_progress CHECK (chapters_completed <= total_chapters_in_course),
    CONSTRAINT valid_completion_date CHECK (completed_at IS NULL OR completed_at >= enrolled_at)
);

-- Lesson Progress Table (Enhanced)
CREATE TABLE IF NOT EXISTS lesson_progress (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE NOT NULL,
    lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE NOT NULL,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    
    -- Progress Details
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Video Progress (for video lessons)
    watch_time_seconds INTEGER DEFAULT 0 CHECK (watch_time_seconds >= 0),
    total_video_duration_seconds INTEGER DEFAULT 0 CHECK (total_video_duration_seconds >= 0),
    last_video_position_seconds INTEGER DEFAULT 0 CHECK (last_video_position_seconds >= 0),
    video_completion_percentage DECIMAL(5,2) DEFAULT 0.0 CHECK (video_completion_percentage >= 0.0 AND video_completion_percentage <= 100.0),
    
    -- Reading Progress (for text lessons)
    reading_progress_percentage DECIMAL(5,2) DEFAULT 0.0 CHECK (reading_progress_percentage >= 0.0 AND reading_progress_percentage <= 100.0),
    reading_time_seconds INTEGER DEFAULT 0 CHECK (reading_time_seconds >= 0),
    
    -- Overall Progress
    overall_progress_percentage DECIMAL(5,2) DEFAULT 0.0 CHECK (overall_progress_percentage >= 0.0 AND overall_progress_percentage <= 100.0),
    is_completed BOOLEAN DEFAULT false,
    completion_criteria_met BOOLEAN DEFAULT false,
    
    -- Engagement Metrics
    total_visits INTEGER DEFAULT 1 CHECK (total_visits > 0),
    total_time_spent_seconds INTEGER DEFAULT 0 CHECK (total_time_spent_seconds >= 0),
    engagement_score DECIMAL(3,2) DEFAULT 0.0 CHECK (engagement_score >= 0.0 AND engagement_score <= 1.0),
    
    -- Notes and Bookmarks
    student_notes TEXT,
    bookmarks JSONB DEFAULT '[]', -- Array of timestamp bookmarks for videos
    is_bookmarked BOOLEAN DEFAULT false,
    
    -- Quality Metrics
    focus_time_seconds INTEGER DEFAULT 0 CHECK (focus_time_seconds >= 0), -- Time actually engaged
    distraction_count INTEGER DEFAULT 0 CHECK (distraction_count >= 0),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(student_id, lesson_id),
    CONSTRAINT valid_video_position CHECK (last_video_position_seconds <= total_video_duration_seconds)
);

-- =============================================
-- Phase 7: Live Classes System
-- =============================================

-- Live Classes Table (Enhanced)
CREATE TABLE IF NOT EXISTS live_classes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    coaching_center_id UUID REFERENCES coaching_centers(id) ON DELETE CASCADE NOT NULL,
    course_id UUID REFERENCES courses(id) ON DELETE SET NULL,
    chapter_id UUID REFERENCES chapters(id) ON DELETE SET NULL,
    primary_teacher_id UUID REFERENCES teachers(id) ON DELETE SET NULL,
    
    title VARCHAR(300) NOT NULL,
    description TEXT,
    agenda TEXT,
    learning_objectives TEXT[] DEFAULT '{}',
    
    -- Scheduling
    scheduled_start TIMESTAMP WITH TIME ZONE NOT NULL,
    scheduled_end TIMESTAMP WITH TIME ZONE NOT NULL,
    actual_start TIMESTAMP WITH TIME ZONE,
    actual_end TIMESTAMP WITH TIME ZONE,
    timezone VARCHAR(50) DEFAULT 'Asia/Kolkata',
    
    -- Settings
    max_participants INTEGER DEFAULT 100 CHECK (max_participants > 0),
    current_participants INTEGER DEFAULT 0 CHECK (current_participants >= 0),
    auto_record BOOLEAN DEFAULT false,
    allow_chat BOOLEAN DEFAULT true,
    allow_qa BOOLEAN DEFAULT true,
    allow_screen_sharing BOOLEAN DEFAULT false,
    require_approval BOOLEAN DEFAULT false,
    
    -- Meeting Details
    meeting_platform VARCHAR(20) DEFAULT 'zoom' CHECK (meeting_platform IN ('zoom', 'meet', 'teams', 'jitsi', 'custom')),
    meeting_url TEXT,
    meeting_id VARCHAR(100),
    meeting_password VARCHAR(100),
    dial_in_numbers JSONB DEFAULT '[]',
    
    -- Pricing
    price DECIMAL(10,2) DEFAULT 0.00 CHECK (price >= 0),
    currency VARCHAR(3) DEFAULT 'INR',
    is_free BOOLEAN GENERATED ALWAYS AS (price = 0) STORED,
    
    -- Content
    thumbnail_url TEXT,
    presentation_url TEXT,
    resources JSONB DEFAULT '[]',
    
    -- Status
    status VARCHAR(20) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'live', 'completed', 'cancelled', 'rescheduled')),
    cancellation_reason TEXT,
    
    -- Recording
    recording_url TEXT,
    recording_duration_minutes INTEGER CHECK (recording_duration_minutes IS NULL OR recording_duration_minutes > 0),
    recording_size_mb DECIMAL(8,2) CHECK (recording_size_mb IS NULL OR recording_size_mb > 0),
    recording_available_until TIMESTAMP WITH TIME ZONE,
    
    -- Analytics
    total_registered INTEGER DEFAULT 0 CHECK (total_registered >= 0),
    total_attended INTEGER DEFAULT 0 CHECK (total_attended >= 0),
    average_attendance_duration_minutes DECIMAL(6,2) DEFAULT 0 CHECK (average_attendance_duration_minutes >= 0),
    engagement_score DECIMAL(3,2) DEFAULT 0.0 CHECK (engagement_score >= 0.0 AND engagement_score <= 1.0),
    
    -- Feedback
    average_rating DECIMAL(3,2) DEFAULT 0.0 CHECK (average_rating >= 0.0 AND average_rating <= 5.0),
    total_feedback_count INTEGER DEFAULT 0 CHECK (total_feedback_count >= 0),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT valid_schedule_duration CHECK (scheduled_end > scheduled_start),
    CONSTRAINT valid_actual_duration CHECK (actual_end IS NULL OR actual_start IS NULL OR actual_end >= actual_start)
);

-- Live Class Enrollments Table (Enhanced)
CREATE TABLE IF NOT EXISTS live_class_enrollments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE NOT NULL,
    live_class_id UUID REFERENCES live_classes(id) ON DELETE CASCADE NOT NULL,
    
    -- Registration
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    enrollment_source VARCHAR(20) DEFAULT 'direct' CHECK (enrollment_source IN ('direct', 'course', 'invitation', 'bulk')),
    
    -- Attendance
    joined_at TIMESTAMP WITH TIME ZONE,
    left_at TIMESTAMP WITH TIME ZONE,
    attendance_duration_minutes INTEGER DEFAULT 0 CHECK (attendance_duration_minutes >= 0),
    attended BOOLEAN DEFAULT false,
    attendance_percentage DECIMAL(5,2) DEFAULT 0.0 CHECK (attendance_percentage >= 0.0 AND attendance_percentage <= 100.0),
    
    -- Engagement
    questions_asked INTEGER DEFAULT 0 CHECK (questions_asked >= 0),
    chat_messages_sent INTEGER DEFAULT 0 CHECK (chat_messages_sent >= 0),
    polls_participated INTEGER DEFAULT 0 CHECK (polls_participated >= 0),
    engagement_score DECIMAL(3,2) DEFAULT 0.0 CHECK (engagement_score >= 0.0 AND engagement_score <= 1.0),
    
    -- Technical Info
    connection_quality VARCHAR(10) DEFAULT 'good' CHECK (connection_quality IN ('poor', 'fair', 'good', 'excellent')),
    device_type VARCHAR(20),
    browser_info TEXT,
    
    -- Feedback
    session_rating INTEGER CHECK (session_rating IS NULL OR (session_rating >= 1 AND session_rating <= 5)),
    feedback_text TEXT,
    feedback_submitted_at TIMESTAMP WITH TIME ZONE,
    
    -- Status
    status VARCHAR(20) DEFAULT 'registered' CHECK (status IN ('registered', 'attended', 'missed', 'cancelled')),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(student_id, live_class_id),
    CONSTRAINT valid_attendance_time CHECK (left_at IS NULL OR joined_at IS NULL OR left_at >= joined_at)
);

-- =============================================
-- Phase 8: Payment & Transaction System
-- =============================================

-- Payment Methods Table
CREATE TABLE IF NOT EXISTS payment_methods (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL,
    provider VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    supports_refunds BOOLEAN DEFAULT true,
    processing_fee_percentage DECIMAL(5,2) DEFAULT 0 CHECK (processing_fee_percentage >= 0),
    min_amount DECIMAL(10,2) DEFAULT 0 CHECK (min_amount >= 0),
    max_amount DECIMAL(10,2) CHECK (max_amount IS NULL OR max_amount > min_amount),
    supported_currencies TEXT[] DEFAULT '{"INR"}',
    configuration JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Payments Table (Enhanced)
CREATE TABLE IF NOT EXISTS payments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE NOT NULL,
    
    -- Payment Items
    course_id UUID REFERENCES courses(id) ON DELETE SET NULL,
    live_class_id UUID REFERENCES live_classes(id) ON DELETE SET NULL,
    items JSONB DEFAULT '[]', -- For multiple item purchases
    
    payment_type VARCHAR(20) NOT NULL CHECK (payment_type IN ('course', 'live_class', 'bundle', 'subscription', 'certification')),
    
    -- Amount Details
    subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
    discount_amount DECIMAL(10,2) DEFAULT 0 CHECK (discount_amount >= 0),
    tax_amount DECIMAL(10,2) DEFAULT 0 CHECK (tax_amount >= 0),
    processing_fee DECIMAL(10,2) DEFAULT 0 CHECK (processing_fee >= 0),
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    currency VARCHAR(3) DEFAULT 'INR',
    
    -- Payment Processing
    payment_method_id UUID REFERENCES payment_methods(id),
    payment_gateway VARCHAR(50) NOT NULL,
    gateway_transaction_id VARCHAR(200),
    internal_transaction_id VARCHAR(100) UNIQUE NOT NULL DEFAULT gen_random_uuid()::TEXT,
    
    -- Status Tracking
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded', 'partially_refunded')),
    failure_reason TEXT,
    
    -- Timing
    initiated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Refund Information
    refund_amount DECIMAL(10,2) DEFAULT 0.00 CHECK (refund_amount >= 0 AND refund_amount <= total_amount),
    refund_reason TEXT,
    refunded_at TIMESTAMP WITH TIME ZONE,
    refunded_by UUID REFERENCES user_profiles(id),
    
    -- Coupon/Discount
    coupon_code VARCHAR(50),
    discount_type VARCHAR(20) CHECK (discount_type IN ('percentage', 'fixed', 'coupon')),
    discount_value DECIMAL(10,2) DEFAULT 0 CHECK (discount_value >= 0),
    
    -- Invoice
    invoice_number VARCHAR(50) UNIQUE,
    invoice_url TEXT,
    
    -- Metadata
    customer_details JSONB DEFAULT '{}',
    gateway_response JSONB DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT valid_refund_amount CHECK (refund_amount <= total_amount)
);

-- =============================================
-- Phase 9: Reviews & Feedback System
-- =============================================

-- Reviews Table (Enhanced)
CREATE TABLE IF NOT EXISTS reviews (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE NOT NULL,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    teacher_id UUID REFERENCES teachers(id) ON DELETE CASCADE,
    live_class_id UUID REFERENCES live_classes(id) ON DELETE CASCADE,
    coaching_center_id UUID REFERENCES coaching_centers(id) ON DELETE CASCADE,
    
    review_type VARCHAR(20) NOT NULL CHECK (review_type IN ('course', 'teacher', 'live_class', 'coaching_center')),
    
    -- Rating Breakdown
    overall_rating DECIMAL(2,1) NOT NULL CHECK (overall_rating >= 0.5 AND overall_rating <= 5.0),
    content_rating DECIMAL(2,1) CHECK (content_rating IS NULL OR (content_rating >= 0.5 AND content_rating <= 5.0)),
    instructor_rating DECIMAL(2,1) CHECK (instructor_rating IS NULL OR (instructor_rating >= 0.5 AND instructor_rating <= 5.0)),
    value_rating DECIMAL(2,1) CHECK (value_rating IS NULL OR (value_rating >= 0.5 AND value_rating <= 5.0)),
    difficulty_rating DECIMAL(2,1) CHECK (difficulty_rating IS NULL OR (difficulty_rating >= 0.5 AND difficulty_rating <= 5.0)),
    
    -- Review Content
    title VARCHAR(200),
    review_text TEXT,
    pros TEXT,
    cons TEXT,
    
    -- Verification
    is_verified_purchase BOOLEAN DEFAULT false,
    completed_percentage DECIMAL(5,2) DEFAULT 0 CHECK (completed_percentage >= 0 AND completed_percentage <= 100),
    
    -- Moderation
    is_published BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    moderation_status VARCHAR(20) DEFAULT 'approved' CHECK (moderation_status IN ('pending', 'approved', 'rejected', 'flagged')),
    moderation_reason TEXT,
    moderated_by UUID REFERENCES user_profiles(id),
    moderated_at TIMESTAMP WITH TIME ZONE,
    
    -- Engagement
    helpful_votes INTEGER DEFAULT 0 CHECK (helpful_votes >= 0),
    not_helpful_votes INTEGER DEFAULT 0 CHECK (not_helpful_votes >= 0),
    total_votes INTEGER GENERATED ALWAYS AS (helpful_votes + not_helpful_votes) STORED,
    helpfulness_score DECIMAL(3,2) DEFAULT 0.0 CHECK (helpfulness_score >= 0.0 AND helpfulness_score <= 1.0),
    
    -- Reporting
    report_count INTEGER DEFAULT 0 CHECK (report_count >= 0),
    last_reported_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Ensure at least one entity is being reviewed
    CONSTRAINT check_review_target CHECK (
        (course_id IS NOT NULL)::INTEGER + 
        (teacher_id IS NOT NULL)::INTEGER + 
        (live_class_id IS NOT NULL)::INTEGER + 
        (coaching_center_id IS NOT NULL)::INTEGER = 1
    )
    
);

-- Review Votes Table
CREATE TABLE IF NOT EXISTS review_votes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    review_id UUID REFERENCES reviews(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE NOT NULL,
    vote_type VARCHAR(15) NOT NULL CHECK (vote_type IN ('helpful', 'not_helpful')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(review_id, user_id)
);

-- Review Reports Table
CREATE TABLE IF NOT EXISTS review_reports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    review_id UUID REFERENCES reviews(id) ON DELETE CASCADE NOT NULL,
    reported_by UUID REFERENCES user_profiles(id) ON DELETE CASCADE NOT NULL,
    reason VARCHAR(50) NOT NULL CHECK (reason IN ('spam', 'inappropriate', 'fake', 'offensive', 'irrelevant', 'other')),
    description TEXT,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'dismissed')),
    resolved_by UUID REFERENCES user_profiles(id),
    resolved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(review_id, reported_by)
);

-- =============================================
-- Phase 10: Notification System
-- =============================================

-- Notification Templates Table
CREATE TABLE IF NOT EXISTS notification_templates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    title_template TEXT NOT NULL,
    message_template TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    channels TEXT[] DEFAULT '{"in_app"}' CHECK (channels <@ '{"in_app","email","sms","push"}'),
    is_active BOOLEAN DEFAULT true,
    variables JSONB DEFAULT '[]', -- Available template variables
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Notifications Table (Enhanced)
CREATE TABLE IF NOT EXISTS notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE NOT NULL,
    
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    
    notification_type VARCHAR(50) NOT NULL CHECK (notification_type IN (
        'course_enrollment', 'lesson_completed', 'assignment_due', 'assignment_graded',
        'live_class_reminder', 'live_class_started', 'payment_success', 'payment_failed',
        'certificate_issued', 'review_received', 'course_updated', 'system_maintenance',
        'achievement_unlocked', 'streak_milestone', 'new_course_available'
    )),
    
    -- Targeting
    reference_id UUID, -- ID of related entity (course, assignment, etc.)
    reference_type VARCHAR(50) CHECK (reference_type IN (
        'course', 'lesson', 'assignment', 'live_class', 'payment', 'certificate', 'review'
    )),
    
    -- Delivery
    channels TEXT[] DEFAULT '{"in_app"}' CHECK (channels <@ '{"in_app","email","sms","push"}'),
    delivery_status JSONB DEFAULT '{}', -- Status per channel
    
    -- Settings
    priority VARCHAR(10) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,
    
    -- Scheduling
    scheduled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    sent_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Categorization
    category VARCHAR(50) DEFAULT 'general' CHECK (category IN ('academic', 'financial', 'technical', 'marketing', 'general')),
    
    -- Action
    action_url TEXT,
    action_label VARCHAR(50),
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    template_id UUID REFERENCES notification_templates(id),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- Phase 11: Analytics & Reporting
-- =============================================

-- Analytics Events Table (Enhanced)
CREATE TABLE IF NOT EXISTS analytics_events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- User Information
    user_id UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    session_id VARCHAR(100),
    anonymous_id VARCHAR(100),
    
    -- Event Details
    event_name VARCHAR(100) NOT NULL,
    event_category VARCHAR(50) NOT NULL,
    event_action VARCHAR(100) NOT NULL,
    event_label VARCHAR(200),
    event_value DECIMAL(10,2),
    
    -- Context
    entity_type VARCHAR(50), -- course, lesson, assignment, etc.
    entity_id UUID,
    
    -- Properties
    properties JSONB DEFAULT '{}',
    user_properties JSONB DEFAULT '{}',
    
    -- Technical Details
    user_agent TEXT,
    ip_address INET,
    country VARCHAR(2),
    region VARCHAR(100),
    city VARCHAR(100),
    
    -- Device Information
    device_type VARCHAR(20) CHECK (device_type IN ('desktop', 'tablet', 'mobile', 'unknown')),
    device_model VARCHAR(100),
    browser VARCHAR(50),
    browser_version VARCHAR(20),
    os VARCHAR(50),
    os_version VARCHAR(20),
    screen_resolution VARCHAR(20),
    
    -- Page/App Context
    page_url TEXT,
    page_title VARCHAR(200),
    referrer TEXT,
    utm_source VARCHAR(100),
    utm_medium VARCHAR(100),
    utm_campaign VARCHAR(100),
    utm_content VARCHAR(100),
    utm_term VARCHAR(100),
    
    -- Timing
    client_timestamp TIMESTAMP WITH TIME ZONE,
    server_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Processing
    processed BOOLEAN DEFAULT false,
    processed_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Learning Analytics Summary Table
CREATE TABLE IF NOT EXISTS learning_analytics_daily (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- Dimensions
    date DATE NOT NULL,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    coaching_center_id UUID REFERENCES coaching_centers(id) ON DELETE CASCADE,
    
    -- Learning Metrics
    total_time_spent_minutes INTEGER DEFAULT 0 CHECK (total_time_spent_minutes >= 0),
    lessons_started INTEGER DEFAULT 0 CHECK (lessons_started >= 0),
    lessons_completed INTEGER DEFAULT 0 CHECK (lessons_completed >= 0),
    videos_watched INTEGER DEFAULT 0 CHECK (videos_watched >= 0),
    video_watch_time_minutes INTEGER DEFAULT 0 CHECK (video_watch_time_minutes >= 0),
    
    -- Assessment Metrics
    quizzes_attempted INTEGER DEFAULT 0 CHECK (quizzes_attempted >= 0),
    quizzes_passed INTEGER DEFAULT 0 CHECK (quizzes_passed >= 0),
    average_quiz_score DECIMAL(5,2) DEFAULT 0.0 CHECK (average_quiz_score >= 0),
    assignments_submitted INTEGER DEFAULT 0 CHECK (assignments_submitted >= 0),
    
    -- Engagement Metrics
    login_count INTEGER DEFAULT 0 CHECK (login_count >= 0),
    page_views INTEGER DEFAULT 0 CHECK (page_views >= 0),
    session_count INTEGER DEFAULT 0 CHECK (session_count >= 0),
    average_session_duration_minutes DECIMAL(8,2) DEFAULT 0 CHECK (average_session_duration_minutes >= 0),
    
    -- Progress Metrics
    progress_gained DECIMAL(5,2) DEFAULT 0.0 CHECK (progress_gained >= -100 AND progress_gained <= 100),
    streak_days INTEGER DEFAULT 0 CHECK (streak_days >= 0),
    points_earned INTEGER DEFAULT 0 CHECK (points_earned >= 0),
    
    -- Behavioral Metrics
    help_requests INTEGER DEFAULT 0 CHECK (help_requests >= 0),
    forum_posts INTEGER DEFAULT 0 CHECK (forum_posts >= 0),
    peer_interactions INTEGER DEFAULT 0 CHECK (peer_interactions >= 0),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(date, student_id, course_id)
);

-- =============================================
-- Phase 12: Business Logic Functions
-- =============================================

-- Function to calculate course progress
CREATE OR REPLACE FUNCTION calculate_course_progress(
    p_student_id UUID,
    p_course_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_total_lessons INTEGER := 0;
    v_completed_lessons INTEGER := 0;
    v_total_chapters INTEGER := 0;
    v_completed_chapters INTEGER := 0;
    v_progress_percentage DECIMAL(5,2) := 0.0;
    v_result JSONB;
BEGIN
    -- Get total lessons in course
    SELECT COUNT(*) INTO v_total_lessons
    FROM lessons l
    JOIN chapters c ON l.chapter_id = c.id
    WHERE c.course_id = p_course_id AND l.is_published = true;
    
    -- Get completed lessons
    SELECT COUNT(*) INTO v_completed_lessons
    FROM lesson_progress lp
    JOIN lessons l ON lp.lesson_id = l.id
    JOIN chapters c ON l.chapter_id = c.id
    WHERE lp.student_id = p_student_id 
    AND c.course_id = p_course_id 
    AND lp.is_completed = true;
    
    -- Get total chapters
    SELECT COUNT(*) INTO v_total_chapters
    FROM chapters
    WHERE course_id = p_course_id AND is_published = true;
    
    -- Calculate completed chapters (chapters where all lessons are completed)
    SELECT COUNT(*) INTO v_completed_chapters
    FROM (
        SELECT c.id
        FROM chapters c
        WHERE c.course_id = p_course_id AND c.is_published = true
        AND NOT EXISTS (
            SELECT 1 FROM lessons l
            LEFT JOIN lesson_progress lp ON (l.id = lp.lesson_id AND lp.student_id = p_student_id)
            WHERE l.chapter_id = c.id AND l.is_published = true
            AND (lp.is_completed IS NULL OR lp.is_completed = false)
        )
    ) completed_chaps;
    
    -- Calculate overall progress percentage
    IF v_total_lessons > 0 THEN
        v_progress_percentage := ROUND((v_completed_lessons::DECIMAL / v_total_lessons::DECIMAL) * 100, 2);
    END IF;
    
    -- Update course enrollment record
    UPDATE course_enrollments
    SET 
        progress_percentage = v_progress_percentage,
        lessons_completed = v_completed_lessons,
        total_lessons_in_course = v_total_lessons,
        chapters_completed = v_completed_chapters,
        total_chapters_in_course = v_total_chapters,
        completed_at = CASE 
            WHEN v_progress_percentage >= completion_percentage_required AND completed_at IS NULL 
            THEN NOW() 
            ELSE completed_at 
        END,
        updated_at = NOW()
    WHERE student_id = p_student_id AND course_id = p_course_id;
    
    v_result := jsonb_build_object(
        'student_id', p_student_id,
        'course_id', p_course_id,
        'progress_percentage', v_progress_percentage,
        'lessons_completed', v_completed_lessons,
        'total_lessons', v_total_lessons,
        'chapters_completed', v_completed_chapters,
        'total_chapters', v_total_chapters,
        'is_completed', v_progress_percentage >= 80.0
    );
    
    RETURN v_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update lesson progress
CREATE OR REPLACE FUNCTION update_lesson_progress(
    p_student_id UUID,
    p_lesson_id UUID,
    p_watch_time_seconds INTEGER DEFAULT 0,
    p_completion_percentage DECIMAL DEFAULT NULL,
    p_is_completed BOOLEAN DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_course_id UUID;
    v_lesson_duration INTEGER;
    v_calculated_percentage DECIMAL(5,2);
    v_is_completed BOOLEAN := COALESCE(p_is_completed, false);
    v_result JSONB;
BEGIN
    -- Get lesson details
    SELECT l.course_id, l.video_duration 
    INTO v_course_id, v_lesson_duration
    FROM lessons l
    JOIN chapters c ON l.chapter_id = c.id
    WHERE l.id = p_lesson_id;
    
    IF v_course_id IS NULL THEN
        RETURN jsonb_build_object('error', 'Lesson not found');
    END IF;
    
    -- Calculate completion percentage if not provided
    IF p_completion_percentage IS NULL THEN
        IF v_lesson_duration IS NOT NULL AND v_lesson_duration > 0 AND p_watch_time_seconds > 0 THEN
            v_calculated_percentage := LEAST(100.0, (p_watch_time_seconds::DECIMAL / v_lesson_duration::DECIMAL) * 100);
        ELSE
            v_calculated_percentage := CASE WHEN v_is_completed THEN 100.0 ELSE 0.0 END;
        END IF;
    ELSE
        v_calculated_percentage := p_completion_percentage;
    END IF;
    
    -- Determine completion status
    IF p_is_completed IS NULL THEN
        v_is_completed := v_calculated_percentage >= 80.0;
    END IF;
    
    -- Insert or update lesson progress
    INSERT INTO lesson_progress (
        student_id, lesson_id, course_id,
        watch_time_seconds, overall_progress_percentage,
        is_completed, last_accessed_at
    ) VALUES (
        p_student_id, p_lesson_id, v_course_id,
        p_watch_time_seconds, v_calculated_percentage,
        v_is_completed, NOW()
    )
    ON CONFLICT (student_id, lesson_id)
    DO UPDATE SET
        watch_time_seconds = GREATEST(lesson_progress.watch_time_seconds, EXCLUDED.watch_time_seconds),
        overall_progress_percentage = GREATEST(lesson_progress.overall_progress_percentage, EXCLUDED.overall_progress_percentage),
        is_completed = lesson_progress.is_completed OR EXCLUDED.is_completed,
        last_accessed_at = EXCLUDED.last_accessed_at,
        updated_at = NOW();
    
    -- Update course progress
    PERFORM calculate_course_progress(p_student_id, v_course_id);
    
    v_result := jsonb_build_object(
        'success', true,
        'lesson_id', p_lesson_id,
        'progress_percentage', v_calculated_percentage,
        'is_completed', v_is_completed
    );
    
    RETURN v_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to handle learning streak updates
CREATE OR REPLACE FUNCTION update_learning_streak(
    p_student_id UUID,
    p_timezone VARCHAR DEFAULT 'Asia/Kolkata'
)
RETURNS JSONB AS $$
DECLARE
    v_student RECORD;
    v_today DATE;
    v_yesterday DATE;
    v_new_streak INTEGER := 1;
    v_longest_streak INTEGER;
BEGIN
    -- Get student data
    SELECT 
        current_streak_days, 
        longest_streak_days, 
        last_login_date,
        last_streak_update_date
    INTO v_student
    FROM students
    WHERE id = p_student_id;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('error', 'Student not found');
    END IF;
    
    -- Get dates in user timezone
    v_today := (NOW() AT TIME ZONE p_timezone)::DATE;
    v_yesterday := v_today - INTERVAL '1 day';
    
    -- Skip if already updated today
    IF v_student.last_streak_update_date = v_today THEN
        RETURN jsonb_build_object(
            'success', true,
            'message', 'Streak already updated today',
            'current_streak', v_student.current_streak_days
        );
    END IF;
    
    -- Calculate new streak
    IF v_student.last_login_date = v_yesterday THEN
        -- Consecutive day - increment streak
        v_new_streak := v_student.current_streak_days + 1;
    ELSIF v_student.last_login_date = v_today THEN
        -- Same day - keep current streak
        v_new_streak := v_student.current_streak_days;
    ELSE
        -- Gap in learning - reset to 1
        v_new_streak := 1;
    END IF;
    
    v_longest_streak := GREATEST(v_student.longest_streak_days, v_new_streak);
    
    -- Update student record
    UPDATE students
    SET 
        current_streak_days = v_new_streak,
        longest_streak_days = v_longest_streak,
        last_login_date = v_today,
        last_streak_update_date = v_today,
        updated_at = NOW()
    WHERE id = p_student_id;
    
    RETURN jsonb_build_object(
        'success', true,
        'current_streak', v_new_streak,
        'longest_streak', v_longest_streak,
        'is_new_record', v_new_streak = v_longest_streak AND v_new_streak > v_student.longest_streak_days
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to enroll student in course
CREATE OR REPLACE FUNCTION enroll_student_in_course(
    p_student_id UUID,
    p_course_id UUID,
    p_payment_status VARCHAR DEFAULT 'free',
    p_enrollment_method VARCHAR DEFAULT 'direct'
)
RETURNS JSONB AS $$
DECLARE
    v_course RECORD;
    v_current_enrollments INTEGER;
    v_result JSONB;
BEGIN
    -- Get course details
    SELECT 
        title, max_enrollments, enrollment_deadline, 
        is_published, price, enrollment_count
    INTO v_course
    FROM courses
    WHERE id = p_course_id;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'error', 'Course not found');
    END IF;
    
    -- Validate course is published
    IF NOT v_course.is_published THEN
        RETURN jsonb_build_object('success', false, 'error', 'Course is not published');
    END IF;
    
    -- Check enrollment deadline
    IF v_course.enrollment_deadline IS NOT NULL AND NOW() > v_course.enrollment_deadline THEN
        RETURN jsonb_build_object('success', false, 'error', 'Enrollment deadline has passed');
    END IF;
    
    -- Check enrollment limit
    IF v_course.max_enrollments IS NOT NULL THEN
        SELECT COUNT(*) INTO v_current_enrollments
        FROM course_enrollments
        WHERE course_id = p_course_id AND is_active = true;
        
        IF v_current_enrollments >= v_course.max_enrollments THEN
            RETURN jsonb_build_object('success', false, 'error', 'Course enrollment limit reached');
        END IF;
    END IF;
    
    -- Check if already enrolled
    IF EXISTS (SELECT 1 FROM course_enrollments WHERE student_id = p_student_id AND course_id = p_course_id) THEN
        RETURN jsonb_build_object('success', false, 'error', 'Already enrolled in this course');
    END IF;
    
    -- Create enrollment
    INSERT INTO course_enrollments (
        student_id, course_id, payment_status, enrollment_method
    ) VALUES (
        p_student_id, p_course_id, p_payment_status, p_enrollment_method
    );
    
    -- Update student statistics
    UPDATE students
    SET 
        total_courses_enrolled = total_courses_enrolled + 1,
        updated_at = NOW()
    WHERE id = p_student_id;
    
    v_result := jsonb_build_object(
        'success', true,
        'message', 'Successfully enrolled in course',
        'course_title', v_course.title,
        'enrollment_date', NOW()
    );
    
    RETURN v_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- Phase 13: Triggers and Automation
-- =============================================

-- Trigger to create user profile on signup
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_profiles (
        id, user_type, first_name, last_name, email
    ) VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'user_type', 'student'),
        COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
        NEW.email
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION create_user_profile();

-- Trigger to auto-generate student ID
CREATE OR REPLACE FUNCTION generate_student_id()
RETURNS TRIGGER AS $$
DECLARE
    v_year VARCHAR(4) := EXTRACT(YEAR FROM NOW())::VARCHAR;
    v_sequence INTEGER;
    v_student_id VARCHAR(50);
BEGIN
    IF NEW.student_id IS NOT NULL THEN
        RETURN NEW;
    END IF;
    
    -- Get next sequence number for the year
    SELECT COALESCE(MAX(
        CASE 
            WHEN student_id ~ ('^STU' || v_year || '[0-9]+$')
            THEN SUBSTRING(student_id FROM LENGTH('STU' || v_year) + 1)::INTEGER
            ELSE 0
        END
    ), 0) + 1 INTO v_sequence
    FROM students;
    
    v_student_id := 'STU' || v_year || LPAD(v_sequence::TEXT, 6, '0');
    NEW.student_id := v_student_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_generate_student_id ON students;
CREATE TRIGGER trigger_generate_student_id
    BEFORE INSERT ON students
    FOR EACH ROW
    WHEN (NEW.student_id IS NULL)
    EXECUTE FUNCTION generate_student_id();

-- Trigger to update timestamps
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply update trigger to all relevant tables
DO $$
DECLARE
    t TEXT;
BEGIN
    FOR t IN 
        SELECT table_name 
        FROM information_schema.columns 
        WHERE column_name = 'updated_at' 
        AND table_schema = 'public'
    LOOP
        EXECUTE format('
            DROP TRIGGER IF EXISTS trigger_update_updated_at ON %I;
            CREATE TRIGGER trigger_update_updated_at
                BEFORE UPDATE ON %I
                FOR EACH ROW EXECUTE FUNCTION update_updated_at();
        ', t, t);
    END LOOP;
END $$;

-- Trigger to update course statistics
CREATE OR REPLACE FUNCTION update_course_stats()
RETURNS TRIGGER AS $$
DECLARE
    v_course_id UUID;
BEGIN
    -- Determine course ID based on operation and table
    IF TG_TABLE_NAME = 'course_enrollments' THEN
        v_course_id := COALESCE(NEW.course_id, OLD.course_id);
    ELSIF TG_TABLE_NAME = 'reviews' THEN
        v_course_id := COALESCE(NEW.course_id, OLD.course_id);
    ELSIF TG_TABLE_NAME = 'lessons' THEN
        SELECT course_id INTO v_course_id FROM chapters WHERE id = COALESCE(NEW.chapter_id, OLD.chapter_id);
    END IF;
    
    IF v_course_id IS NOT NULL THEN
        -- Update course statistics
        UPDATE courses
        SET 
            enrollment_count = (
                SELECT COUNT(*) FROM course_enrollments 
                WHERE course_id = v_course_id AND is_active = true
            ),
            total_lessons = (
                SELECT COUNT(*) FROM lessons l
                JOIN chapters c ON l.chapter_id = c.id
                WHERE c.course_id = v_course_id AND l.is_published = true
            ),
            total_chapters = (
                SELECT COUNT(*) FROM chapters 
                WHERE course_id = v_course_id AND is_published = true
            ),
            rating = COALESCE((
                SELECT ROUND(AVG(overall_rating), 2)
                FROM reviews
                WHERE course_id = v_course_id AND is_published = true
            ), 0),
            total_reviews = (
                SELECT COUNT(*) FROM reviews
                WHERE course_id = v_course_id AND is_published = true
            ),
            updated_at = NOW()
        WHERE id = v_course_id;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Apply course stats trigger
DROP TRIGGER IF EXISTS trigger_update_course_stats_enrollments ON course_enrollments;
CREATE TRIGGER trigger_update_course_stats_enrollments
    AFTER INSERT OR UPDATE OR DELETE ON course_enrollments
    FOR EACH ROW EXECUTE FUNCTION update_course_stats();

DROP TRIGGER IF EXISTS trigger_update_course_stats_reviews ON reviews;
CREATE TRIGGER trigger_update_course_stats_reviews
    AFTER INSERT OR UPDATE OR DELETE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_course_stats();

-- Trigger to update review vote counts
CREATE OR REPLACE FUNCTION update_review_vote_counts()
RETURNS TRIGGER AS $$
DECLARE
    v_review_id UUID := COALESCE(NEW.review_id, OLD.review_id);
    v_helpful_count INTEGER;
    v_not_helpful_count INTEGER;
BEGIN
    SELECT 
        COUNT(*) FILTER (WHERE vote_type = 'helpful'),
        COUNT(*) FILTER (WHERE vote_type = 'not_helpful')
    INTO v_helpful_count, v_not_helpful_count
    FROM review_votes
    WHERE review_id = v_review_id;
    
    UPDATE reviews
    SET 
        helpful_votes = v_helpful_count,
        not_helpful_votes = v_not_helpful_count,
        helpfulness_score = CASE 
            WHEN (v_helpful_count + v_not_helpful_count) > 0 
            THEN ROUND(v_helpful_count::DECIMAL / (v_helpful_count + v_not_helpful_count), 2)
            ELSE 0.0 
        END,
        updated_at = NOW()
    WHERE id = v_review_id;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_review_votes ON review_votes;
CREATE TRIGGER trigger_update_review_votes
    AFTER INSERT OR UPDATE OR DELETE ON review_votes
    FOR EACH ROW EXECUTE FUNCTION update_review_vote_counts();

-- Trigger for coaching center stats
CREATE OR REPLACE FUNCTION update_coaching_center_stats()
RETURNS TRIGGER AS $$
DECLARE
    v_center_id UUID;
BEGIN
    -- Get coaching center ID from different contexts
    IF TG_TABLE_NAME = 'courses' THEN
        v_center_id := COALESCE(NEW.coaching_center_id, OLD.coaching_center_id);
    ELSIF TG_TABLE_NAME = 'teachers' THEN
        v_center_id := COALESCE(NEW.coaching_center_id, OLD.coaching_center_id);
    END IF;
    
    IF v_center_id IS NOT NULL THEN
        UPDATE coaching_centers
        SET 
            total_courses = (
                SELECT COUNT(*) FROM courses 
                WHERE coaching_center_id = v_center_id AND is_published = true
            ),
            total_teachers = (
                SELECT COUNT(*) FROM teachers 
                WHERE coaching_center_id = v_center_id AND status = 'active'
            ),
            total_students = (
                SELECT COUNT(DISTINCT ce.student_id) 
                FROM course_enrollments ce
                JOIN courses c ON ce.course_id = c.id
                WHERE c.coaching_center_id = v_center_id AND ce.is_active = true
            ),
            updated_at = NOW()
        WHERE id = v_center_id;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_coaching_center_stats_courses ON courses;
CREATE TRIGGER trigger_coaching_center_stats_courses
    AFTER INSERT OR UPDATE OR DELETE ON courses
    FOR EACH ROW EXECUTE FUNCTION update_coaching_center_stats();

DROP TRIGGER IF EXISTS trigger_coaching_center_stats_teachers ON teachers;
CREATE TRIGGER trigger_coaching_center_stats_teachers
    AFTER INSERT OR UPDATE OR DELETE ON teachers
    FOR EACH ROW EXECUTE FUNCTION update_coaching_center_stats();

-- =============================================
-- Phase 14: Indexes for Performance
-- =============================================

-- Core entity indexes
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_type ON user_profiles(user_type) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON user_profiles(email);
CREATE INDEX IF NOT EXISTS idx_user_profiles_created_at ON user_profiles(created_at);

CREATE INDEX IF NOT EXISTS idx_coaching_centers_approval ON coaching_centers(approval_status, is_active);
CREATE INDEX IF NOT EXISTS idx_coaching_centers_code ON coaching_centers(center_code);

CREATE INDEX IF NOT EXISTS idx_students_student_id ON students(student_id);
CREATE INDEX IF NOT EXISTS idx_students_grade_level ON students(grade_level) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_students_location ON students(state, city);
CREATE INDEX IF NOT EXISTS idx_students_competitive_exams ON students USING GIN(competitive_exams);

CREATE INDEX IF NOT EXISTS idx_teachers_center ON teachers(coaching_center_id) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_teachers_specializations ON teachers USING GIN(specializations);

-- Course content indexes
CREATE INDEX IF NOT EXISTS idx_courses_center ON courses(coaching_center_id);
CREATE INDEX IF NOT EXISTS idx_courses_published ON courses(is_published, is_featured);
CREATE INDEX IF NOT EXISTS idx_courses_category ON courses(category_id);
CREATE INDEX IF NOT EXISTS idx_courses_rating ON courses(rating DESC, total_reviews DESC);
CREATE INDEX IF NOT EXISTS idx_courses_price ON courses(price, currency);
CREATE INDEX IF NOT EXISTS idx_courses_enrollment_dates ON courses(enrollment_start_date, enrollment_deadline);

CREATE INDEX IF NOT EXISTS idx_chapters_course_order ON chapters(course_id, sort_order);
CREATE INDEX IF NOT EXISTS idx_lessons_chapter_order ON lessons(chapter_id, sort_order);

-- Progress tracking indexes
CREATE INDEX IF NOT EXISTS idx_course_enrollments_student ON course_enrollments(student_id, is_active);
CREATE INDEX IF NOT EXISTS idx_course_enrollments_course ON course_enrollments(course_id, is_active);
CREATE INDEX IF NOT EXISTS idx_course_enrollments_progress ON course_enrollments(progress_percentage, completed_at);

CREATE INDEX IF NOT EXISTS idx_lesson_progress_student_course ON lesson_progress(student_id, course_id);
CREATE INDEX IF NOT EXISTS idx_lesson_progress_completion ON lesson_progress(is_completed, completed_at);

-- Assessment indexes
CREATE INDEX IF NOT EXISTS idx_tests_course ON tests(course_id, is_published);
CREATE INDEX IF NOT EXISTS idx_test_results_student ON test_results(student_id, completed_at);
CREATE INDEX IF NOT EXISTS idx_test_results_test ON test_results(test_id, percentage DESC);

CREATE INDEX IF NOT EXISTS idx_assignments_course_due ON assignments(course_id, due_date, is_published);
CREATE INDEX IF NOT EXISTS idx_assignment_submissions_assignment ON assignment_submissions(assignment_id, submitted_at);

-- Communication indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON notifications(user_id, is_read, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_scheduled ON notifications(scheduled_at) WHERE sent_at IS NULL;

-- Analytics indexes
CREATE INDEX IF NOT EXISTS idx_analytics_events_user_date ON analytics_events(user_id, server_timestamp);
CREATE INDEX IF NOT EXISTS idx_analytics_events_category ON analytics_events(event_category, event_action, server_timestamp);

CREATE INDEX IF NOT EXISTS idx_learning_analytics_daily_student ON learning_analytics_daily(student_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_learning_analytics_daily_course ON learning_analytics_daily(course_id, date DESC);

-- Payment and commerce indexes
CREATE INDEX IF NOT EXISTS idx_payments_student ON payments(student_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_payments_course ON payments(course_id) WHERE course_id IS NOT NULL;

-- Review indexes
CREATE INDEX IF NOT EXISTS idx_reviews_course_published ON reviews(course_id, is_published, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reviews_teacher ON reviews(teacher_id, is_published);
CREATE INDEX IF NOT EXISTS idx_review_votes_review ON review_votes(review_id);
-- Add these after the reviews table is created:
CREATE UNIQUE INDEX idx_reviews_unique_student_course 
    ON reviews(student_id, course_id) WHERE course_id IS NOT NULL;

CREATE UNIQUE INDEX idx_reviews_unique_student_teacher 
    ON reviews(student_id, teacher_id) WHERE teacher_id IS NOT NULL;

CREATE UNIQUE INDEX idx_reviews_unique_student_live_class 
    ON reviews(student_id, live_class_id) WHERE live_class_id IS NOT NULL;

CREATE UNIQUE INDEX idx_reviews_unique_student_center 
    ON reviews(student_id, coaching_center_id) WHERE coaching_center_id IS NOT NULL;


-- Live class indexes
CREATE INDEX IF NOT EXISTS idx_live_classes_scheduled ON live_classes(scheduled_start, status);
CREATE INDEX IF NOT EXISTS idx_live_class_enrollments_student ON live_class_enrollments(student_id, enrolled_at);

-- =============================================
-- Phase 15: Row Level Security (RLS) Policies
-- =============================================

-- Enable RLS on all tables
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE coaching_centers ENABLE ROW LEVEL SECURITY;
ALTER TABLE teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE chapters ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE test_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE test_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignment_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE live_classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE live_class_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

-- User Profiles Policies
CREATE POLICY "Users manage own profile" ON user_profiles
    FOR ALL USING (id = auth.uid());

CREATE POLICY "Admins manage all profiles" ON user_profiles
    FOR ALL USING (is_admin());

-- Coaching Centers Policies
CREATE POLICY "Centers manage own data" ON coaching_centers
    FOR ALL USING (user_id = auth.uid());

CREATE POLICY "Public view approved centers" ON coaching_centers
    FOR SELECT USING (approval_status = 'approved' AND is_active = true);

-- Students Policies
CREATE POLICY "Students manage own data" ON students
    FOR ALL USING (user_id = auth.uid());

CREATE POLICY "Teachers view enrolled students" ON students
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM course_enrollments ce
            JOIN courses c ON ce.course_id = c.id
            JOIN course_teachers ct ON c.id = ct.course_id
            JOIN teachers t ON ct.teacher_id = t.id
            WHERE ce.student_id = students.id AND t.user_id = auth.uid()
        )
    );

-- Teachers Policies
CREATE POLICY "Teachers manage own data" ON teachers
    FOR ALL USING (user_id = auth.uid());

CREATE POLICY "Centers manage their teachers" ON teachers
    FOR ALL USING (coaching_center_id = get_user_coaching_center_id());

-- Course Policies
CREATE POLICY "Public view published courses" ON courses
    FOR SELECT USING (is_published = true AND NOT is_archived);

CREATE POLICY "Centers manage own courses" ON courses
    FOR ALL USING (coaching_center_id = get_user_coaching_center_id());

CREATE POLICY "Teachers manage assigned courses" ON courses
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM course_teachers ct
            JOIN teachers t ON ct.teacher_id = t.id
            WHERE ct.course_id = courses.id AND t.user_id = auth.uid()
        )
    );

-- Enrollment Policies
CREATE POLICY "Students manage own enrollments" ON course_enrollments
    FOR ALL USING (student_id = get_student_id());

CREATE POLICY "Teachers view course enrollments" ON course_enrollments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM course_teachers ct
            JOIN teachers t ON ct.teacher_id = t.id
            WHERE ct.course_id = course_enrollments.course_id AND t.user_id = auth.uid()
        )
    );

-- Progress Policies
CREATE POLICY "Students manage own progress" ON lesson_progress
    FOR ALL USING (student_id = get_student_id());

CREATE POLICY "Teachers view student progress" ON lesson_progress
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM courses c
            JOIN course_teachers ct ON c.id = ct.course_id
            JOIN teachers t ON ct.teacher_id = t.id
            WHERE c.id = lesson_progress.course_id AND t.user_id = auth.uid()
        )
    );

-- Assessment Policies
CREATE POLICY "Students view published tests" ON tests
    FOR SELECT USING (
        is_published = true AND
        EXISTS (
            SELECT 1 FROM course_enrollments ce
            WHERE ce.course_id = tests.course_id AND ce.student_id = get_student_id()
        )
    );

CREATE POLICY "Teachers manage own tests" ON tests
    FOR ALL USING (
        teacher_id IN (SELECT id FROM teachers WHERE user_id = auth.uid())
    );

CREATE POLICY "Students manage own test results" ON test_results
    FOR ALL USING (student_id = get_student_id());

-- Assignment Policies
CREATE POLICY "Students view published assignments" ON assignments
    FOR SELECT USING (
        is_published = true AND
        EXISTS (
            SELECT 1 FROM course_enrollments ce
            WHERE ce.course_id = assignments.course_id AND ce.student_id = get_student_id()
        )
    );

CREATE POLICY "Teachers manage own assignments" ON assignments
    FOR ALL USING (
        teacher_id IN (SELECT id FROM teachers WHERE user_id = auth.uid())
    );

CREATE POLICY "Students manage own submissions" ON assignment_submissions
    FOR ALL USING (student_id = get_student_id());

-- Review Policies
CREATE POLICY "Public view published reviews" ON reviews
    FOR SELECT USING (is_published = true);

CREATE POLICY "Students manage own reviews" ON reviews
    FOR ALL USING (student_id = get_student_id());

CREATE POLICY "Users manage own review votes" ON review_votes
    FOR ALL USING (user_id = auth.uid());

-- Notification Policies
CREATE POLICY "Users manage own notifications" ON notifications
    FOR ALL USING (user_id = auth.uid());

-- Payment Policies
CREATE POLICY "Students view own payments" ON payments
    FOR SELECT USING (student_id = get_student_id());

CREATE POLICY "Students create own payments" ON payments
    FOR INSERT WITH CHECK (student_id = get_student_id());

-- Analytics Policies
CREATE POLICY "Users create own analytics" ON analytics_events
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- =============================================
-- Phase 16: Views for Common Queries
-- =============================================

-- Course Overview View
CREATE VIEW course_overview AS
SELECT 
    c.id,
    c.title,
    c.slug,
    c.short_description,
    c.thumbnail_url,
    c.price,
    c.currency,
    c.level,
    c.language,
    c.rating,
    c.total_reviews,
    c.enrollment_count,
    c.duration_hours,
    c.total_lessons,
    c.total_chapters,
    c.is_published,
    c.is_featured,
    c.created_at,
    
    -- Coaching Center Info
    cc.center_name,
    cc.logo_url as center_logo,
    
    -- Primary Teacher Info
    up.first_name || ' ' || up.last_name as primary_teacher_name,
    t.title as teacher_title,
    t.rating as teacher_rating,
    
    -- Category Info
    cat.name as category_name,
    cat.slug as category_slug
    
FROM courses c
LEFT JOIN coaching_centers cc ON c.coaching_center_id = cc.id
LEFT JOIN teachers t ON c.primary_teacher_id = t.id
LEFT JOIN user_profiles up ON t.user_id = up.id
LEFT JOIN course_categories cat ON c.category_id = cat.id;

-- Student Dashboard View
CREATE VIEW student_dashboard AS
SELECT 
    s.id as student_id,
    s.student_id as student_number,
    up.first_name || ' ' || up.last_name as full_name,
    s.grade_level,
    s.current_streak_days,
    s.total_points,
    s.level,
    s.total_courses_enrolled,
    s.total_courses_completed,
    s.total_hours_learned,
    
    -- Recent Activity
    (
        SELECT COUNT(*) 
        FROM lesson_progress lp 
        WHERE lp.student_id = s.id 
        AND lp.last_accessed_at >= NOW() - INTERVAL '7 days'
    ) as lessons_this_week,
    
    (
        SELECT COUNT(*) 
        FROM course_enrollments ce 
        WHERE ce.student_id = s.id 
        AND ce.last_accessed_at >= NOW() - INTERVAL '7 days'
    ) as active_courses_this_week
    
FROM students s
JOIN user_profiles up ON s.user_id = up.id
WHERE s.is_active = true;

-- Teacher Dashboard View
CREATE VIEW teacher_dashboard AS
SELECT 
    t.id as teacher_id,
    up.first_name || ' ' || up.last_name as full_name,
    t.title,
    t.rating,
    t.total_reviews,
    t.total_courses,
    t.total_students_taught,
    cc.center_name,
    
    -- Active Courses
    (
        SELECT COUNT(*) 
        FROM course_teachers ct 
        JOIN courses c ON ct.course_id = c.id
        WHERE ct.teacher_id = t.id AND c.is_published = true
    ) as active_courses,
    
    -- Pending Assignments to Grade
    (
        SELECT COUNT(*) 
        FROM assignment_submissions asub
        JOIN assignments a ON asub.assignment_id = a.id
        WHERE a.teacher_id = t.id 
        AND asub.submission_status = 'submitted'
        AND asub.grade IS NULL
    ) as pending_grading,
    
    -- Upcoming Live Classes
    (
        SELECT COUNT(*) 
        FROM live_classes lc
        WHERE lc.primary_teacher_id = t.id 
        AND lc.scheduled_start > NOW()
        AND lc.scheduled_start <= NOW() + INTERVAL '7 days'
        AND lc.status = 'scheduled'
    ) as upcoming_classes
    
FROM teachers t
JOIN user_profiles up ON t.user_id = up.id
JOIN coaching_centers cc ON t.coaching_center_id = cc.id
WHERE t.status = 'active';

-- Course Progress Summary View
CREATE VIEW course_progress_summary AS
SELECT 
    ce.student_id,
    ce.course_id,
    c.title as course_title,
    ce.progress_percentage,
    ce.lessons_completed,
    ce.total_lessons_in_course,
    ce.total_time_spent_minutes,
    ce.enrolled_at,
    ce.last_accessed_at,
    ce.completed_at,
    
    -- Next Lesson Info
    (
        SELECT l.id 
        FROM lessons l
        JOIN chapters ch ON l.chapter_id = ch.id
        LEFT JOIN lesson_progress lp ON (l.id = lp.lesson_id AND lp.student_id = ce.student_id)
        WHERE ch.course_id = ce.course_id 
        AND l.is_published = true
        AND (lp.is_completed IS NULL OR lp.is_completed = false)
        ORDER BY ch.sort_order, l.sort_order
        LIMIT 1
    ) as next_lesson_id,
    
    -- Performance Metrics
    CASE 
        WHEN ce.progress_percentage >= 80 THEN 'excellent'
        WHEN ce.progress_percentage >= 60 THEN 'good'
        WHEN ce.progress_percentage >= 40 THEN 'average'
        ELSE 'needs_attention'
    END as progress_status
    
FROM course_enrollments ce
JOIN courses c ON ce.course_id = c.id
WHERE ce.is_active = true;

-- =============================================
-- Phase 17: Sample Data Insertion Functions
-- =============================================

-- Function to insert sample course categories
CREATE OR REPLACE FUNCTION insert_sample_categories()
RETURNS VOID AS $$
BEGIN
    INSERT INTO course_categories (name, slug, description, is_active) VALUES
    ('Mathematics', 'mathematics', 'Mathematical subjects including algebra, calculus, geometry', true),
    ('Science', 'science', 'Physics, Chemistry, Biology and other scientific subjects', true),
    ('Computer Science', 'computer-science', 'Programming, algorithms, data structures, and technology', true),
    ('Language Arts', 'language-arts', 'English, Hindi, literature and communication skills', true),
    ('Social Studies', 'social-studies', 'History, geography, civics and social sciences', true),
    ('Competitive Exams', 'competitive-exams', 'JEE, NEET, UPSC and other competitive exam preparation', true),
    ('Professional Skills', 'professional-skills', 'Soft skills, leadership, and career development', true),
    ('Arts & Music', 'arts-music', 'Fine arts, music, dance and creative subjects', true);
    
    RAISE NOTICE 'Sample categories inserted successfully';
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Categories already exist, skipping insertion';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error inserting categories: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Function to insert sample payment methods
CREATE OR REPLACE FUNCTION insert_sample_payment_methods()
RETURNS VOID AS $$
BEGIN
    INSERT INTO payment_methods (name, display_name, provider, is_active, processing_fee_percentage) VALUES
    ('razorpay_card', 'Credit/Debit Card', 'Razorpay', true, 2.5),
    ('razorpay_upi', 'UPI', 'Razorpay', true, 1.5),
    ('razorpay_netbanking', 'Net Banking', 'Razorpay', true, 2.0),
    ('razorpay_wallet', 'Digital Wallet', 'Razorpay', true, 2.0),
    ('stripe_card', 'International Card', 'Stripe', true, 2.9),
    ('paypal', 'PayPal', 'PayPal', true, 3.5),
    ('bank_transfer', 'Bank Transfer', 'Manual', true, 0.0);
    
    RAISE NOTICE 'Sample payment methods inserted successfully';
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Payment methods already exist, skipping insertion';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error inserting payment methods: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Function to insert sample notification templates
CREATE OR REPLACE FUNCTION insert_sample_notification_templates()
RETURNS VOID AS $$
BEGIN
    INSERT INTO notification_templates (name, title_template, message_template, notification_type, channels) VALUES
    ('course_enrollment_success', 'Welcome to {{course_title}}!', 'You have successfully enrolled in {{course_title}}. Start learning now!', 'course_enrollment', '{"in_app","email"}'),
    ('lesson_completed', 'Lesson Completed! 🎉', 'Congratulations! You completed {{lesson_title}} in {{course_title}}', 'lesson_completed', '{"in_app"}'),
    ('assignment_due_reminder', 'Assignment Due Tomorrow', 'Your assignment "{{assignment_title}}" is due tomorrow. Submit before {{due_date}}', 'assignment_due', '{"in_app","email"}'),
    ('live_class_reminder', 'Live Class Starting Soon', 'Your live class "{{class_title}}" starts in {{time_until_start}}', 'live_class_reminder', '{"in_app","push"}'),
    ('certificate_issued', 'Certificate Ready! 🏆', 'Your certificate for {{course_title}} is ready. Download it now!', 'certificate_issued', '{"in_app","email"}'),
    ('payment_success', 'Payment Successful', 'Your payment of {{amount}} {{currency}} for {{item_name}} was successful', 'payment_success', '{"in_app","email"}'),
    ('streak_milestone', 'Learning Streak Milestone! 🔥', 'Amazing! You reached a {{streak_days}} day learning streak!', 'streak_milestone', '{"in_app"}');
    
    RAISE NOTICE 'Sample notification templates inserted successfully';
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Notification templates already exist, skipping insertion';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error inserting notification templates: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- Phase 18: Utility Functions
-- =============================================

-- Function to get course analytics
CREATE OR REPLACE FUNCTION get_course_analytics(p_course_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
    v_total_enrollments INTEGER;
    v_active_enrollments INTEGER;
    v_completed_enrollments INTEGER;
    v_avg_progress DECIMAL(5,2);
    v_avg_rating DECIMAL(3,2);
BEGIN
    SELECT 
        COUNT(*),
        COUNT(*) FILTER (WHERE is_active = true),
        COUNT(*) FILTER (WHERE completed_at IS NOT NULL),
        AVG(progress_percentage)
    INTO v_total_enrollments, v_active_enrollments, v_completed_enrollments, v_avg_progress
    FROM course_enrollments
    WHERE course_id = p_course_id;
    
    SELECT AVG(overall_rating)
    INTO v_avg_rating
    FROM reviews
    WHERE course_id = p_course_id AND is_published = true;
    
    v_result := jsonb_build_object(
        'course_id', p_course_id,
        'total_enrollments', COALESCE(v_total_enrollments, 0),
        'active_enrollments', COALESCE(v_active_enrollments, 0),
        'completed_enrollments', COALESCE(v_completed_enrollments, 0),
        'completion_rate', CASE 
            WHEN v_total_enrollments > 0 
            THEN ROUND((v_completed_enrollments::DECIMAL / v_total_enrollments::DECIMAL) * 100, 2)
            ELSE 0 
        END,
        'average_progress', COALESCE(v_avg_progress, 0),
        'average_rating', COALESCE(v_avg_rating, 0),
        'generated_at', NOW()
    );
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to generate course completion certificate
CREATE OR REPLACE FUNCTION generate_completion_certificate(
    p_student_id UUID,
    p_course_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_enrollment RECORD;
    v_course RECORD;
    v_student RECORD;
    v_certificate_id UUID;
    v_certificate_number VARCHAR(100);
    v_verification_code VARCHAR(50);
BEGIN
    -- Check if student completed the course
    SELECT * INTO v_enrollment
    FROM course_enrollments
    WHERE student_id = p_student_id AND course_id = p_course_id
    AND progress_percentage >= completion_percentage_required
    AND completed_at IS NOT NULL;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'error', 'Course not completed or enrollment not found');
    END IF;
    
    -- Check if certificate already exists
    IF EXISTS (SELECT 1 FROM certificates WHERE student_id = p_student_id AND course_id = p_course_id) THEN
        RETURN jsonb_build_object('success', false, 'error', 'Certificate already issued');
    END IF;
    
    -- Get course and student details
    SELECT c.*, cc.center_name
    INTO v_course
    FROM courses c
    JOIN coaching_centers cc ON c.coaching_center_id = cc.id
    WHERE c.id = p_course_id;
    
    SELECT s.*, up.first_name, up.last_name
    INTO v_student
    FROM students s
    JOIN user_profiles up ON s.user_id = up.id
    WHERE s.id = p_student_id;
    
    -- Generate certificate details
    v_certificate_id := gen_random_uuid();
    v_certificate_number := 'CERT-' || EXTRACT(YEAR FROM NOW()) || '-' || UPPER(SUBSTRING(v_certificate_id::TEXT, 1, 8));
    v_verification_code := UPPER(SUBSTRING(MD5(v_certificate_id::TEXT || NOW()::TEXT), 1, 10));
    
    -- Insert certificate record
    INSERT INTO certificates (
        id, student_id, course_id, coaching_center_id, teacher_id,
        certificate_number, certificate_name, verification_code,
        completion_percentage, grade
    ) VALUES (
        v_certificate_id, p_student_id, p_course_id, v_course.coaching_center_id, v_course.primary_teacher_id,
        v_certificate_number, 
        'Certificate of Completion - ' || v_course.title,
        v_verification_code,
        v_enrollment.progress_percentage,
        CASE 
            WHEN v_enrollment.progress_percentage >= 95 THEN 'A+'
            WHEN v_enrollment.progress_percentage >= 90 THEN 'A'
            WHEN v_enrollment.progress_percentage >= 85 THEN 'B+'
            WHEN v_enrollment.progress_percentage >= 80 THEN 'B'
            ELSE 'C'
        END
    );
    
    -- Update enrollment record
    UPDATE course_enrollments
    SET 
        certificate_issued = true,
        certificate_issued_at = NOW(),
        certificate_id = v_certificate_id
    WHERE student_id = p_student_id AND course_id = p_course_id;
    
    RETURN jsonb_build_object(
        'success', true,
        'certificate_id', v_certificate_id,
        'certificate_number', v_certificate_number,
        'verification_code', v_verification_code,
        'student_name', v_student.first_name || ' ' || v_student.last_name,
        'course_title', v_course.title,
        'completion_date', v_enrollment.completed_at,
        'grade', CASE 
            WHEN v_enrollment.progress_percentage >= 95 THEN 'A+'
            WHEN v_enrollment.progress_percentage >= 90 THEN 'A'
            WHEN v_enrollment.progress_percentage >= 85 THEN 'B+'
            WHEN v_enrollment.progress_percentage >= 80 THEN 'B'
            ELSE 'C'
        END
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- Phase 19: Database Maintenance Functions
-- =============================================

-- Function to cleanup old analytics data
CREATE OR REPLACE FUNCTION cleanup_old_analytics_data(days_to_keep INTEGER DEFAULT 90)
RETURNS JSONB AS $$
DECLARE
    v_deleted_count INTEGER;
    v_cutoff_date TIMESTAMP WITH TIME ZONE;
BEGIN
    v_cutoff_date := NOW() - (days_to_keep || ' days')::INTERVAL;
    
    DELETE FROM analytics_events 
    WHERE server_timestamp < v_cutoff_date;
    
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
    
    RETURN jsonb_build_object(
        'success', true,
        'deleted_records', v_deleted_count,
        'cutoff_date', v_cutoff_date
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update course statistics (can be run periodically)
CREATE OR REPLACE FUNCTION refresh_course_statistics()
RETURNS JSONB AS $$
DECLARE
    v_updated_count INTEGER := 0;
    v_course_record RECORD;
BEGIN
    FOR v_course_record IN 
        SELECT id FROM courses WHERE is_published = true
    LOOP
        UPDATE courses
        SET 
            enrollment_count = (
                SELECT COUNT(*) FROM course_enrollments 
                WHERE course_id = v_course_record.id AND is_active = true
            ),
            completed_count = (
                SELECT COUNT(*) FROM course_enrollments 
                WHERE course_id = v_course_record.id AND completed_at IS NOT NULL
            ),
            rating = COALESCE((
                SELECT ROUND(AVG(overall_rating), 2)
                FROM reviews
                WHERE course_id = v_course_record.id AND is_published = true
            ), 0),
            total_reviews = (
                SELECT COUNT(*) FROM reviews
                WHERE course_id = v_course_record.id AND is_published = true
            ),
            completion_rate = CASE
                WHEN (SELECT COUNT(*) FROM course_enrollments WHERE course_id = v_course_record.id AND is_active = true) > 0
                THEN ROUND(
                    (SELECT COUNT(*)::DECIMAL FROM course_enrollments WHERE course_id = v_course_record.id AND completed_at IS NOT NULL) /
                    (SELECT COUNT(*)::DECIMAL FROM course_enrollments WHERE course_id = v_course_record.id AND is_active = true) * 100, 2
                )
                ELSE 0
            END,
            updated_at = NOW()
        WHERE id = v_course_record.id;
        
        v_updated_count := v_updated_count + 1;
    END LOOP;
    
    RETURN jsonb_build_object(
        'success', true,
        'updated_courses', v_updated_count,
        'timestamp', NOW()
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- Phase 20: Final Setup and Initialization
-- =============================================

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated, anon;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated;

-- Grant select permissions on views
GRANT SELECT ON course_overview TO authenticated, anon;
GRANT SELECT ON student_dashboard TO authenticated;
GRANT SELECT ON teacher_dashboard TO authenticated;
GRANT SELECT ON course_progress_summary TO authenticated;

-- Initialize with sample data
DO $$
BEGIN
    PERFORM insert_sample_categories();
    PERFORM insert_sample_payment_methods();
    PERFORM insert_sample_notification_templates();
    
    RAISE NOTICE 'Database initialization completed successfully!';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error during initialization: %', SQLERRM;
END $$;

-- =============================================
-- COMMENTS AND DOCUMENTATION
-- =============================================

COMMENT ON DATABASE postgres IS 'Production LMS Database - Multi-Coaching Center Learning Management System';

-- Table comments
COMMENT ON TABLE user_profiles IS 'Extended user profiles for all user types in the system';
COMMENT ON TABLE coaching_centers IS 'Coaching center/institute information and settings';
COMMENT ON TABLE teachers IS 'Teacher profiles with qualifications and specializations';
COMMENT ON TABLE students IS 'Student profiles with academic information and learning preferences';
COMMENT ON TABLE courses IS 'Course catalog with detailed information and settings';
COMMENT ON TABLE course_enrollments IS 'Student course enrollments with progress tracking';
COMMENT ON TABLE lesson_progress IS 'Detailed lesson-level progress tracking';
COMMENT ON TABLE tests IS 'Assessments, quizzes, and examinations';
COMMENT ON TABLE assignments IS 'Course assignments and projects';
COMMENT ON TABLE live_classes IS 'Scheduled live classes and webinars';
COMMENT ON TABLE payments IS 'Payment transactions and billing information';
COMMENT ON TABLE reviews IS 'Course and teacher reviews with ratings';
COMMENT ON TABLE notifications IS 'System notifications and alerts';
COMMENT ON TABLE analytics_events IS 'User interaction and engagement tracking';

-- Function comments
COMMENT ON FUNCTION calculate_course_progress IS 'Calculates and updates student progress for a specific course';
COMMENT ON FUNCTION update_lesson_progress IS 'Updates lesson-level progress and completion status';
COMMENT ON FUNCTION update_learning_streak IS 'Manages student learning streak calculations';
COMMENT ON FUNCTION enroll_student_in_course IS 'Handles course enrollment with validation';
COMMENT ON FUNCTION generate_completion_certificate IS 'Generates completion certificates for qualified students';

DO $$
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'PRODUCTION LMS DATABASE SETUP COMPLETE!';
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Database includes:';
    RAISE NOTICE '• Comprehensive table structure with constraints';
    RAISE NOTICE '• Row Level Security (RLS) policies';
    RAISE NOTICE '• Performance indexes';
    RAISE NOTICE '• Business logic functions';
    RAISE NOTICE '• Automated triggers';
    RAISE NOTICE '• Analytics and reporting views';
    RAISE NOTICE '• Sample data and templates';
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Next steps:';
    RAISE NOTICE '1. Configure Supabase Storage buckets';
    RAISE NOTICE '2. Set up authentication policies';
    RAISE NOTICE '3. Configure email templates';
    RAISE NOTICE '4. Set up cron jobs for maintenance';
    RAISE NOTICE '==============================================';
END $$;