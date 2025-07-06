### **Phase 1: Foundation (Core Schema)**

**File: `01_extensions_and_functions.sql`**

```sql
-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Helper functions for RLS (must be created first)
CREATE OR REPLACE FUNCTION get_user_type()
RETURNS TEXT AS $$
BEGIN
    RETURN (
        SELECT user_type
        FROM user_profiles
        WHERE id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM auth.users 
        WHERE id = auth.uid() AND 
        raw_user_meta_data->>'user_type' = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

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
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION get_student_id()
RETURNS UUID AS $$
BEGIN
    RETURN (
        SELECT id
        FROM students
        WHERE user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION is_teacher_assigned_to_course(course_id_param UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM courses c
        JOIN teachers t ON c.teacher_id = t.id
        WHERE c.id = course_id_param
        AND t.user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**File: `02_user_profiles.sql`**

```sql
-- User Profiles Table (extends auth.users)
CREATE TABLE user_profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('student', 'teacher', 'admin', 'coaching_center')),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    avatar_url TEXT,
    date_of_birth DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    address JSONB,
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    phone_verified BOOLEAN DEFAULT false,
    onboarding_completed BOOLEAN DEFAULT false,
    preferences JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Trigger to create profile on user signup
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_profiles (id, user_type, first_name, last_name)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'user_type', 'student'),
        COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'last_name', '')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION create_user_profile();
```

**File: `03_coaching_centers.sql`**

```sql
-- Coaching Centers Table
CREATE TABLE coaching_centers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE UNIQUE,
    center_name VARCHAR(200) NOT NULL,
    center_code VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    website_url TEXT,
    logo_url TEXT,
    contact_email VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(20) NOT NULL,
    address JSONB NOT NULL,
    registration_number VARCHAR(100),
    tax_id VARCHAR(50),
    approval_status VARCHAR(20) DEFAULT 'pending' CHECK (approval_status IN ('pending', 'approved', 'rejected', 'suspended')),
    approved_by UUID REFERENCES user_profiles(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    subscription_plan VARCHAR(50) DEFAULT 'basic',
    max_faculty_limit INTEGER DEFAULT 10,
    max_courses_limit INTEGER DEFAULT 50,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    total_courses INTEGER DEFAULT 0,
total_students INTEGER DEFAULT 0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**File: `04_teachers.sql`**

```sql
-- Teachers Table
CREATE TABLE teachers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE UNIQUE,
    coaching_center_id UUID REFERENCES coaching_centers(id) ON DELETE CASCADE,
    employee_id VARCHAR(50),
    specializations TEXT[] DEFAULT '{}',
    qualifications JSONB DEFAULT '[]',
    experience_years INTEGER DEFAULT 0,
    bio TEXT,
    hourly_rate DECIMAL(10,2),
    rating DECIMAL(3,2) DEFAULT 0.0,
    total_reviews INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT false,
    can_create_courses BOOLEAN DEFAULT true,
    can_conduct_live_classes BOOLEAN DEFAULT true,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**File: `05_students.sql`**

```sql
-- Students Table
CREATE TABLE students (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE UNIQUE,
    student_id VARCHAR(50) UNIQUE,
    grade_level VARCHAR(20),
    school_name VARCHAR(200),
    parent_name VARCHAR(200),
    parent_phone VARCHAR(20),
    parent_email VARCHAR(255),
    learning_goals TEXT[] DEFAULT '{}',
    preferred_learning_style VARCHAR(50),
    timezone VARCHAR(50) DEFAULT 'UTC',
    total_courses_enrolled INTEGER DEFAULT 0,
    total_courses_completed INTEGER DEFAULT 0,
    total_hours_learned DECIMAL(10,2) DEFAULT 0.0,
    current_streak_days INTEGER DEFAULT 0,
    longest_streak_days INTEGER DEFAULT 0,
    total_points INTEGER DEFAULT 0,
    level INTEGER DEFAULT 1,
    badges JSONB DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_date DATE,
    last_streak_update_date DATE
);
```

### **Phase 2: Course Structure**

**File: `06_courses.sql`**

```sql
-- Courses Table
CREATE TABLE courses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    coaching_center_id UUID REFERENCES coaching_centers(id) ON DELETE CASCADE,
    teacher_id UUID REFERENCES teachers(id) ON DELETE SET NULL,
    title VARCHAR(300) NOT NULL,
    slug VARCHAR(300) UNIQUE NOT NULL,
    description TEXT,
    short_description TEXT,
    thumbnail_url TEXT,
    trailer_video_url TEXT,
    about TEXT,
    what_you_learn TEXT[],
    course_includes JSONB DEFAULT '{}',
    target_audience TEXT[],
    course_requirements TEXT[],
    category VARCHAR(100) NOT NULL,
    subcategory VARCHAR(100),
    level VARCHAR(20) CHECK (level IN ('beginner', 'intermediate', 'advanced', 'expert')),
    language VARCHAR(10) DEFAULT 'en',
    price DECIMAL(10,2) DEFAULT 0.00,
    original_price DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'USD',
    duration_hours DECIMAL(5,2),
    total_lessons INTEGER DEFAULT 0,
    max_enrollments INTEGER,
    enrollment_deadline TIMESTAMP WITH TIME ZONE,
    total_chapters INTEGER DEFAULT 0,
    prerequisites TEXT[] DEFAULT '{}',
    learning_outcomes TEXT[] DEFAULT '{}',
    tags TEXT[] DEFAULT '{}',
    is_published BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    enrollment_count INTEGER DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0.0,
    total_reviews INTEGER DEFAULT 0,
    completion_rate DECIMAL(5,2) DEFAULT 0.0,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    published_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT check_price_logic CHECK (
        price >= 0 AND
        (original_price IS NULL OR original_price >= price)
    )
);

-- Course Teachers Junction Table
CREATE TABLE course_teachers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    teacher_id UUID REFERENCES teachers(id) ON DELETE CASCADE,
    role VARCHAR(50) DEFAULT 'instructor',
    is_primary BOOLEAN DEFAULT false,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT check_valid_role CHECK (role IN ('instructor', 'co-instructor', 'guest', 'assistant')),
    UNIQUE(course_id, teacher_id)
);
```

**File: `07_chapters.sql`**

```sql
-- Chapters Table
CREATE TABLE chapters (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(300) NOT NULL,
    description TEXT,
    chapter_number INTEGER NOT NULL,
    duration_minutes INTEGER DEFAULT 0,
    total_lessons INTEGER DEFAULT 0,
    is_published BOOLEAN DEFAULT false,
    is_free BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(course_id, chapter_number)
);
```

**File: `08_lessons.sql`**

```sql
-- Lessons Table
CREATE TABLE lessons (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    chapter_id UUID REFERENCES chapters(id) ON DELETE CASCADE,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(300) NOT NULL,
    description TEXT,
    lesson_number INTEGER NOT NULL,
    lesson_type VARCHAR(20) DEFAULT 'video' CHECK (lesson_type IN ('video', 'text', 'quiz', 'assignment', 'live')),
    content_url TEXT,
    video_duration INTEGER,
    transcript TEXT,
    attachments JSONB DEFAULT '[]',
    is_published BOOLEAN DEFAULT false,
    is_free BOOLEAN DEFAULT false,
    view_count INTEGER DEFAULT 0,
    completion_rate DECIMAL(5,2) DEFAULT 0.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(chapter_id, lesson_number)
);
```

### **Phase 3: Interactive Features**

**File: `09_live_classes.sql`**

```sql
-- Live Classes Table
CREATE TABLE live_classes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    coaching_center_id UUID REFERENCES coaching_centers(id) ON DELETE CASCADE,
    teacher_id UUID REFERENCES teachers(id) ON DELETE SET NULL,
    course_id UUID REFERENCES courses(id) ON DELETE SET NULL,
    title VARCHAR(300) NOT NULL,
    description TEXT,
    scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_minutes INTEGER NOT NULL,
    max_participants INTEGER DEFAULT 100,
    current_participants INTEGER DEFAULT 0,
    meeting_url TEXT,
    thumbnail_url TEXT,
    meeting_id VARCHAR(100),
    meeting_password VARCHAR(50),
    price DECIMAL(10,2) DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'USD',
    is_free BOOLEAN DEFAULT true,
    status VARCHAR(20) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'live', 'completed', 'cancelled')),
    recording_url TEXT,
    chat_enabled BOOLEAN DEFAULT true,
    q_and_a_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT check_duration_positive CHECK (duration_minutes > 0)
);
```

**File: `10_tests.sql`**

```sql
-- Tests Table
CREATE TABLE tests (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    chapter_id UUID REFERENCES chapters(id) ON DELETE CASCADE,
    lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE,
    coaching_center_id UUID REFERENCES coaching_centers(id) ON DELETE CASCADE,
    teacher_id UUID REFERENCES teachers(id) ON DELETE SET NULL,
    title VARCHAR(300) NOT NULL,
    description TEXT,
    test_type VARCHAR(20) DEFAULT 'quiz' CHECK (test_type IN ('quiz', 'assignment', 'exam', 'practice')),
    total_questions INTEGER NOT NULL,
    total_marks INTEGER NOT NULL,
    passing_marks INTEGER NOT NULL,
    time_limit_minutes INTEGER,
    attempts_allowed INTEGER DEFAULT 1,
    show_results_immediately BOOLEAN DEFAULT true,
    randomize_questions BOOLEAN DEFAULT false,
    is_published BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Test Questions Table
CREATE TABLE test_questions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    test_id UUID REFERENCES tests(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    question_type VARCHAR(20) DEFAULT 'mcq' CHECK (question_type IN ('mcq', 'multiple_select', 'short_answer', 'essay', 'true_false')),
    options JSONB,
    correct_answers JSONB NOT NULL,
    marks INTEGER DEFAULT 1,
    explanation TEXT,
    question_order INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Test Results Table (Fixed Version)
CREATE TABLE test_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    test_id UUID NOT NULL REFERENCES tests(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    score DECIMAL(5,2) NOT NULL,
    total_marks DECIMAL(5,2) NOT NULL,
    percentage DECIMAL(5,2) GENERATED ALWAYS AS (
        CASE 
            WHEN total_marks > 0 THEN ROUND((score / total_marks * 100), 2)
            ELSE 0 
        END
    ) STORED,
    passed BOOLEAN DEFAULT FALSE, -- Regular column instead of generated
    time_taken_minutes INTEGER,
    answers JSONB DEFAULT '{}',
    is_submitted BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(test_id, student_id) -- Ensures only one attempt per student per test
);

```

### **Phase 4: Enrollment \& Progress**

**File: `11_enrollments.sql`**

```sql
-- Course Enrollments Table
CREATE TABLE course_enrollments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    progress_percentage DECIMAL(5,2) DEFAULT 0.0,
    total_time_spent INTEGER DEFAULT 0,
    last_accessed_at TIMESTAMP WITH TIME ZONE,
    last_lesson_id UUID REFERENCES lessons(id),
    completion_certificate_url TEXT,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    lessons_completed INTEGER DEFAULT 0,
    total_lessons_in_course INTEGER DEFAULT 0,
    UNIQUE(student_id, course_id),
    CONSTRAINT check_progress_range CHECK (progress_percentage >= 0.0 AND progress_percentage <= 100.0),
    CONSTRAINT check_enrollment_dates CHECK (completed_at IS NULL OR completed_at >= enrolled_at)
);

-- Live Class Enrollments Table
CREATE TABLE live_class_enrollments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE,
    live_class_id UUID REFERENCES live_classes(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    attended BOOLEAN DEFAULT false,
    attendance_duration INTEGER DEFAULT 0,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    feedback TEXT,
    UNIQUE(student_id, live_class_id)
);
```

**File: `12_lesson_progress.sql`**

```sql
-- Lesson Progress Table
CREATE TABLE lesson_progress (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE,
    lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    time_spent INTEGER DEFAULT 0,
    progress_percentage DECIMAL(5,2) DEFAULT 0.0,
    last_position INTEGER DEFAULT 0,
    is_completed BOOLEAN DEFAULT false,
    watch_time_seconds INTEGER DEFAULT 0,
    deleted_at TIMESTAMP WITH TIME ZONE,
    last_watched_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(student_id, lesson_id),
    CONSTRAINT check_lesson_progress_range CHECK (progress_percentage >= 0.0 AND progress_percentage <= 100.0)
);
```

### **Phase 5: Business Logic Functions**

**File: `13_progress_functions.sql`**

```sql
-- Learning streak calculation function
CREATE OR REPLACE FUNCTION update_learning_streak(p_student_id UUID, p_user_timezone VARCHAR(50) DEFAULT 'IST')
RETURNS VOID AS $$
DECLARE
    v_user_today DATE;
    v_user_yesterday DATE;
    v_last_login_date DATE;
    v_last_streak_update DATE;
    v_current_streak INTEGER;
    v_longest_streak INTEGER;
    v_timezone VARCHAR(50);
BEGIN
    SELECT
        last_login_date,
        last_streak_update_date,
        current_streak_days,
        longest_streak_days,
        COALESCE(timezone, 'UTC')
    INTO
        v_last_login_date,
        v_last_streak_update,
        v_current_streak,
        v_longest_streak,
        v_timezone
    FROM students
    WHERE id = p_student_id;

    v_timezone := COALESCE(p_user_timezone, v_timezone, 'UTC');
    v_user_today := (NOW() AT TIME ZONE v_timezone)::DATE;
    v_user_yesterday := v_user_today - INTERVAL '1 day';

    IF v_last_streak_update = v_user_today THEN
        RETURN;
    END IF;

    IF v_last_login_date IS NULL THEN
        v_current_streak := 1;
    ELSIF v_last_login_date = v_user_yesterday THEN
        v_current_streak := v_current_streak + 1;
    ELSIF v_last_login_date = v_user_today THEN
        RETURN;
    ELSE
        v_current_streak := 1;
    END IF;

    v_longest_streak := GREATEST(v_longest_streak, v_current_streak);

    UPDATE students
    SET
        last_login_date = v_user_today,
        last_streak_update_date = v_user_today,
        current_streak_days = v_current_streak,
        longest_streak_days = v_longest_streak,
        timezone = v_timezone
    WHERE id = p_student_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Lesson progress calculation function
CREATE OR REPLACE FUNCTION calculate_lesson_progress(
    p_student_id UUID,
    p_lesson_id UUID,
    p_watch_time_seconds INTEGER DEFAULT 0,
    p_is_completed BOOLEAN DEFAULT FALSE
)
RETURNS VOID AS $$
DECLARE
    v_course_id UUID;
    v_lesson_duration INTEGER;
    v_progress_percentage DECIMAL(5,2);
    v_existing_progress RECORD;
BEGIN
    SELECT course_id, video_duration
    INTO v_course_id, v_lesson_duration
    FROM lessons
    WHERE id = p_lesson_id;

    IF v_course_id IS NULL THEN
        RAISE EXCEPTION 'Lesson not found: %', p_lesson_id;
    END IF;

    SELECT watch_time_seconds, is_completed, progress_percentage
    INTO v_existing_progress
    FROM lesson_progress
    WHERE student_id = p_student_id AND lesson_id = p_lesson_id;

    IF p_is_completed THEN
        v_progress_percentage := 100.0;
    ELSIF v_lesson_duration > 0 AND p_watch_time_seconds > 0 THEN
        v_progress_percentage := LEAST(100.0, (p_watch_time_seconds::DECIMAL / v_lesson_duration::DECIMAL) * 100);
    ELSE
        v_progress_percentage := 0.0;
    END IF;

    IF v_existing_progress IS NULL OR
       p_watch_time_seconds > v_existing_progress.watch_time_seconds OR
       (p_is_completed AND NOT v_existing_progress.is_completed) THEN

        INSERT INTO lesson_progress (
            student_id, lesson_id, course_id,
            time_spent, watch_time_seconds, progress_percentage,
            is_completed, last_watched_at, started_at
        ) VALUES (
            p_student_id, p_lesson_id, v_course_id,
            p_watch_time_seconds, p_watch_time_seconds, v_progress_percentage,
            p_is_completed, NOW(), NOW()
        )
        ON CONFLICT (student_id, lesson_id)
        DO UPDATE SET
            time_spent = GREATEST(lesson_progress.time_spent, EXCLUDED.time_spent),
            watch_time_seconds = GREATEST(lesson_progress.watch_time_seconds, EXCLUDED.watch_time_seconds),
            progress_percentage = GREATEST(lesson_progress.progress_percentage, EXCLUDED.progress_percentage),
            is_completed = lesson_progress.is_completed OR EXCLUDED.is_completed,
            last_watched_at = EXCLUDED.last_watched_at
        WHERE
            EXCLUDED.watch_time_seconds > lesson_progress.watch_time_seconds OR
            (EXCLUDED.is_completed AND NOT lesson_progress.is_completed);

        PERFORM pg_notify('course_progress_update',
            json_build_object(
                'student_id', p_student_id,
                'course_id', v_course_id
            )::text
        );
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Course progress calculation function
CREATE OR REPLACE FUNCTION calculate_course_progress(
    p_student_id UUID,
    p_course_id UUID
)
RETURNS VOID AS $$
DECLARE
    v_total_lessons INTEGER;
    v_completed_lessons INTEGER;
    v_total_watch_time INTEGER;
    v_course_progress DECIMAL(5,2);
    v_is_course_completed BOOLEAN := FALSE;
BEGIN
    SELECT COUNT(*) INTO v_total_lessons
    FROM lessons
    WHERE course_id = p_course_id AND is_published = TRUE;

    SELECT
        COUNT(CASE WHEN lp.is_completed THEN 1 END),
        COALESCE(SUM(lp.watch_time_seconds), 0)
    INTO v_completed_lessons, v_total_watch_time
    FROM lesson_progress lp
    JOIN lessons l ON lp.lesson_id = l.id
    WHERE lp.student_id = p_student_id
    AND l.course_id = p_course_id;

    IF v_total_lessons > 0 THEN
        v_course_progress := (v_completed_lessons::DECIMAL / v_total_lessons::DECIMAL) * 100;
        v_is_course_completed := (v_completed_lessons = v_total_lessons);
    ELSE
        v_course_progress := 0.0;
    END IF;

    UPDATE course_enrollments
    SET
        progress_percentage = v_course_progress,
        lessons_completed = v_completed_lessons,
        total_lessons_in_course = v_total_lessons,
        total_time_spent = v_total_watch_time / 60,
        completed_at = CASE WHEN v_is_course_completed AND completed_at IS NULL THEN NOW() ELSE completed_at END,
        last_accessed_at = NOW()
    WHERE student_id = p_student_id AND course_id = p_course_id;

    UPDATE courses
    SET completion_rate = (
        SELECT AVG(progress_percentage)
        FROM course_enrollments
        WHERE course_id = p_course_id AND is_active = TRUE
    )
    WHERE id = p_course_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### **Phase 6: Payment \& Reviews**

**File: `14_payments.sql`**

```sql
-- Payments Table
CREATE TABLE payments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE,
    course_id UUID REFERENCES courses(id) ON DELETE SET NULL,
    live_class_id UUID REFERENCES live_classes(id) ON DELETE SET NULL,
    payment_type VARCHAR(20) NOT NULL CHECK (payment_type IN ('course', 'live_class', 'bundle')),
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    payment_method VARCHAR(50) NOT NULL,
    payment_gateway VARCHAR(50) NOT NULL,
    transaction_id VARCHAR(200) UNIQUE NOT NULL,
    gateway_transaction_id VARCHAR(200),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded', 'cancelled')),
    payment_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    refund_amount DECIMAL(10,2) DEFAULT 0.00,
    refund_date TIMESTAMP WITH TIME ZONE,
    refund_reason TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**File: `15_reviews.sql`**

```sql
-- Reviews Table
CREATE TABLE reviews (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    teacher_id UUID REFERENCES teachers(id) ON DELETE CASCADE,
    live_class_id UUID REFERENCES live_classes(id) ON DELETE SET NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    pros TEXT,
    cons TEXT,
    is_verified_purchase BOOLEAN DEFAULT false,
    is_published BOOLEAN DEFAULT true,
    helpful_votes_count  INTEGER DEFAULT 0,
    not_helpful_votes_count INTEGER DEFAULT 0,
    reported_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(student_id, course_id)
);


```

## **Phase 7: System Configuration \& Analytics**

**File: `16_system_config.sql`**

```sql
-- =============================================
-- SYSTEM CONFIGURATION TABLES
-- =============================================

-- App Configuration Table
CREATE TABLE app_config (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value JSONB NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Audit Logs Table
CREATE TABLE audit_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    user_type VARCHAR(20),
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    success BOOLEAN DEFAULT true,
    error_message TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```


## **Phase 8: Analytics \& Tracking**

**File: `17_analytics.sql`**

```sql
-- =============================================
-- ANALYTICS AND TRACKING TABLES
-- =============================================

-- Analytics Events Table
CREATE TABLE analytics_events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    session_id VARCHAR(100),
    event_type VARCHAR(100) NOT NULL,
    event_category VARCHAR(50) NOT NULL,
    event_action VARCHAR(100) NOT NULL,
    event_label VARCHAR(200),
    event_value DECIMAL(10,2),
    properties JSONB DEFAULT '{}',
    user_agent TEXT,
    ip_address INET,
    referrer TEXT,
    page_url TEXT,
    device_type VARCHAR(20),
    browser VARCHAR(50),
    os VARCHAR(50),
    country VARCHAR(2),
    city VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Learning Analytics Table
CREATE TABLE learning_analytics (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    lesson_id UUID REFERENCES lessons(id) ON DELETE SET NULL,
    date DATE NOT NULL,
    time_spent_minutes INTEGER DEFAULT 0,
    lessons_completed INTEGER DEFAULT 0,
    quizzes_attempted INTEGER DEFAULT 0,
    quizzes_passed INTEGER DEFAULT 0,
    average_quiz_score DECIMAL(5,2) DEFAULT 0.0,
    streak_days INTEGER DEFAULT 0,
    points_earned INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(student_id, course_id, date)
);
```


## **Phase 9: Communication \& Notifications**

**File: `18_communications.sql`**

```sql
-- =============================================
-- COMMUNICATION AND NOTIFICATION TABLES
-- =============================================

-- Notifications Table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL CHECK (notification_type IN (
        'course_update', 'live_class_reminder', 'assignment_due', 'enrollment',
        'payment_success', 'certificate_issued', 'review_received', 'system_update'
    )),
    reference_id UUID,
    reference_type VARCHAR(50) CHECK (reference_type IN (
        'course', 'live_class', 'test', 'assignment', 'payment', 'certificate'
    )),
    is_read BOOLEAN DEFAULT FALSE,
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    scheduled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```


## **Phase 10: Assessment \& Assignment System**

**File: `19_assessments.sql`**

```sql
-- =============================================
-- ASSESSMENT AND ASSIGNMENT TABLES
-- =============================================

-- Assignments Table
CREATE TABLE assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    chapter_id UUID REFERENCES chapters(id) ON DELETE CASCADE,
    teacher_id UUID NOT NULL REFERENCES teachers(id) ON DELETE CASCADE,
    title VARCHAR(300) NOT NULL,
    description TEXT NOT NULL,
    assignment_type VARCHAR(20) NOT NULL CHECK (assignment_type IN ('quiz', 'project', 'essay', 'coding', 'presentation', 'research')),
    total_marks INTEGER NOT NULL DEFAULT 100,
    due_date TIMESTAMP WITH TIME ZONE NOT NULL,
    submission_format VARCHAR(20) NOT NULL CHECK (submission_format IN ('file_upload', 'text_submission', 'github_link', 'url_submission', 'video_upload')),
    instructions TEXT,
    resources JSONB DEFAULT '[]',
    rubric JSONB DEFAULT '{}',
    is_published BOOLEAN DEFAULT FALSE,
    is_group_assignment BOOLEAN DEFAULT FALSE,
    max_group_size INTEGER DEFAULT 1,
    allow_late_submission BOOLEAN DEFAULT TRUE,
    late_penalty_percentage DECIMAL(5,2) DEFAULT 0.00,
    submission_count INTEGER DEFAULT 0,
    auto_grade BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Assignment Submissions Table
CREATE TABLE assignment_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_id UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    submission_url TEXT,
    submission_text TEXT,
    submission_files JSONB DEFAULT '[]',
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    grade DECIMAL(5,2),
    feedback TEXT,
    graded_at TIMESTAMP WITH TIME ZONE,
    graded_by UUID REFERENCES teachers(id),
    is_late BOOLEAN DEFAULT FALSE,
    submission_status VARCHAR(20) DEFAULT 'submitted' CHECK (submission_status IN ('draft', 'submitted', 'graded', 'returned')),
    attempt_number INTEGER DEFAULT 1,
    plagiarism_score DECIMAL(5,2),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(assignment_id, student_id, attempt_number)
);
```


## **Phase 11: Certification System**

**File: `20_certifications.sql`**

```sql
-- =============================================
-- CERTIFICATION SYSTEM TABLES
-- =============================================

-- Certificates Table
CREATE TABLE certificates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    coaching_center_id UUID NOT NULL REFERENCES coaching_centers(id) ON DELETE CASCADE,
    teacher_id UUID NOT NULL REFERENCES teachers(id) ON DELETE CASCADE,
    certificate_number VARCHAR(100) UNIQUE NOT NULL,
    certificate_name VARCHAR(255) NOT NULL,
    issued_date DATE NOT NULL DEFAULT CURRENT_DATE,
    certificate_url TEXT,
    verification_code VARCHAR(50) UNIQUE NOT NULL,
    is_verified BOOLEAN DEFAULT TRUE,
    completion_percentage DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    grade VARCHAR(20),
    skills_acquired TEXT[],
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```


## **Phase 12: E-commerce \& Marketing**

**File: `21_ecommerce.sql`**

```sql
-- =============================================
-- E-COMMERCE AND MARKETING TABLES
-- =============================================

-- Coupons Table
CREATE TABLE coupons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    coaching_center_id UUID NOT NULL REFERENCES coaching_centers(id) ON DELETE CASCADE,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
    discount_value DECIMAL(10,2) NOT NULL CHECK (discount_value > 0),
    minimum_amount DECIMAL(10,2) DEFAULT 0,
    maximum_discount DECIMAL(10,2),
    valid_from TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    valid_until TIMESTAMP WITH TIME ZONE NOT NULL,
    usage_limit INTEGER DEFAULT NULL, -- NULL means unlimited
    used_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    applicable_courses UUID[] DEFAULT '{}', -- Array of course IDs
    applicable_categories TEXT[] DEFAULT '{}', -- Array of category names
    user_restrictions JSONB DEFAULT '{}', -- JSON for user-specific restrictions
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT valid_discount_value CHECK (
        (discount_type = 'percentage' AND discount_value <= 100) OR
        (discount_type = 'fixed' AND discount_value > 0)
    ),
    CONSTRAINT valid_dates CHECK (valid_until > valid_from),
    CONSTRAINT valid_usage CHECK (used_count <= COALESCE(usage_limit, used_count + 1))
);

-- Wishlists Table (Shopping Cart)
CREATE TABLE wishlists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    priority INTEGER DEFAULT 1, -- 1=low, 2=medium, 3=high
    notes TEXT,
    UNIQUE(student_id, course_id) -- Prevent duplicate entries
);
```


## **Phase 13: Learning Paths System**

**File: `22_learning_paths.sql`**

```sql
-- =============================================
-- LEARNING PATHS SYSTEM TABLES
-- =============================================

-- Learning Paths Table
CREATE TABLE learning_paths (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    coaching_center_id UUID NOT NULL REFERENCES coaching_centers(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    difficulty_level VARCHAR(20) DEFAULT 'beginner' CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
    estimated_duration_hours INTEGER DEFAULT 0,
    total_courses INTEGER DEFAULT 0,
    thumbnail_url TEXT,
    is_published BOOLEAN DEFAULT FALSE,
    enrollment_count INTEGER DEFAULT 0,
    price DECIMAL(10,2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'INR',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Learning Path Courses Junction Table
CREATE TABLE learning_path_courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    learning_path_id UUID NOT NULL REFERENCES learning_paths(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    course_order INTEGER NOT NULL,
    is_required BOOLEAN DEFAULT TRUE,
    unlock_after_course_id UUID REFERENCES courses(id), -- Course that must be completed first
    UNIQUE(learning_path_id, course_id),
    UNIQUE(learning_path_id, course_order)
);
```


## **Phase 14: Review Enhancement System**

**File: `23_review_enhancements.sql`**

```sql
-- =============================================
-- REVIEW ENHANCEMENT SYSTEM TABLES
-- =============================================

-- Review Helpful Votes Table
CREATE TABLE review_helpful_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    vote_type VARCHAR(15) NOT NULL CHECK (vote_type IN ('helpful', 'not_helpful')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(review_id, user_id) -- Prevent duplicate votes from same user
);
```


## **Phase 15: Business Logic \& Triggers**

**File: `24_triggers_functions.sql`**

```sql
-- =============================================
-- BUSINESS LOGIC FUNCTIONS AND TRIGGERS
-- =============================================

-- Function to vote on a review
CREATE OR REPLACE FUNCTION vote_on_review(
    p_review_id UUID,
    p_user_id UUID,
    p_vote_type VARCHAR(15)
)
RETURNS JSONB AS $$
DECLARE
    existing_vote review_helpful_votes%ROWTYPE;
    result JSONB;
BEGIN
    -- Check if user already voted on this review
    SELECT * INTO existing_vote
    FROM review_helpful_votes
    WHERE review_id = p_review_id AND user_id = p_user_id;

    IF existing_vote.id IS NOT NULL THEN
        -- Update existing vote
        UPDATE review_helpful_votes
        SET vote_type = p_vote_type, created_at = NOW()
        WHERE id = existing_vote.id;

        result := jsonb_build_object(
            'success', true,
            'message', 'Vote updated successfully',
            'action', 'updated'
        );
    ELSE
        -- Insert new vote
        INSERT INTO review_helpful_votes (review_id, user_id, vote_type)
        VALUES (p_review_id, p_user_id, p_vote_type);

        result := jsonb_build_object(
            'success', true,
            'message', 'Vote recorded successfully',
            'action', 'created'
        );
    END IF;

    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Error recording vote: ' || SQLERRM
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update review vote counts
CREATE OR REPLACE FUNCTION update_review_vote_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        UPDATE reviews SET
            helpful_votes_count = (
                SELECT COUNT(*) FROM review_helpful_votes
                WHERE review_id = NEW.review_id AND vote_type = 'helpful'
            ),
            not_helpful_votes_count = (
                SELECT COUNT(*) FROM review_helpful_votes
                WHERE review_id = NEW.review_id AND vote_type = 'not_helpful'
            )
        WHERE id = NEW.review_id;
        RETURN NEW;
    END IF;

    IF TG_OP = 'DELETE' THEN
        UPDATE reviews SET
            helpful_votes_count = (
                SELECT COUNT(*) FROM review_helpful_votes
                WHERE review_id = OLD.review_id AND vote_type = 'helpful'
            ),
            not_helpful_votes_count = (
                SELECT COUNT(*) FROM review_helpful_votes
                WHERE review_id = OLD.review_id AND vote_type = 'not_helpful'
            )
        WHERE id = OLD.review_id;
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update vote counts
CREATE TRIGGER trigger_update_review_vote_counts
    AFTER INSERT OR UPDATE OR DELETE ON review_helpful_votes
    FOR EACH ROW EXECUTE FUNCTION update_review_vote_counts();

-- Validation functions and triggers
CREATE OR REPLACE FUNCTION validate_lesson_sequence()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM lessons
        WHERE chapter_id = NEW.chapter_id
        AND lesson_number = NEW.lesson_number
        AND id != NEW.id
    ) THEN
        RAISE EXCEPTION 'Lesson number % already exists in chapter', NEW.lesson_number;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_lesson_sequence
    BEFORE INSERT OR UPDATE ON lessons
    FOR EACH ROW
    EXECUTE FUNCTION validate_lesson_sequence();

-- Course enrollment validation
CREATE OR REPLACE FUNCTION validate_course_enrollment()
RETURNS TRIGGER AS $$
DECLARE
    v_course_data RECORD;
    v_current_enrollments INTEGER;
BEGIN
    SELECT max_enrollments, enrollment_deadline, is_published
    INTO v_course_data
    FROM courses
    WHERE id = NEW.course_id;

    IF NOT v_course_data.is_published THEN
        RAISE EXCEPTION 'Cannot enroll in unpublished course';
    END IF;

    IF v_course_data.enrollment_deadline IS NOT NULL AND
       NOW() > v_course_data.enrollment_deadline THEN
        RAISE EXCEPTION 'Enrollment deadline has passed';
    END IF;

    IF v_course_data.max_enrollments IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_current_enrollments
        FROM course_enrollments
        WHERE course_id = NEW.course_id AND is_active = true;

        IF v_current_enrollments >= v_course_data.max_enrollments THEN
            RAISE EXCEPTION 'Course enrollment limit reached';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_validate_enrollment
    BEFORE INSERT ON course_enrollments
    FOR EACH ROW
    EXECUTE FUNCTION validate_course_enrollment();

-- Update enrollment count
CREATE OR REPLACE FUNCTION update_course_enrollment_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE courses
        SET enrollment_count = (
            SELECT COUNT(*)
            FROM course_enrollments
            WHERE course_id = NEW.course_id AND is_active = true
        )
        WHERE id = NEW.course_id;
        RETURN NEW;
    END IF;

    IF TG_OP = 'UPDATE' THEN
        UPDATE courses
        SET enrollment_count = (
            SELECT COUNT(*)
            FROM course_enrollments
            WHERE course_id = NEW.course_id AND is_active = true
        )
        WHERE id = NEW.course_id;
        RETURN NEW;
    END IF;

    IF TG_OP = 'DELETE' THEN
        UPDATE courses
        SET enrollment_count = (
            SELECT COUNT(*)
            FROM course_enrollments
            WHERE course_id = OLD.course_id AND is_active = true
        )
        WHERE id = OLD.course_id;
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update course rating
CREATE OR REPLACE FUNCTION update_course_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE courses
    SET
        rating = COALESCE((
            SELECT ROUND(AVG(rating)::numeric, 2)
            FROM reviews
            WHERE course_id = COALESCE(NEW.course_id, OLD.course_id) AND is_published = true
        ), 0.0),
        total_reviews = (
            SELECT COUNT(*)
            FROM reviews
            WHERE course_id = COALESCE(NEW.course_id, OLD.course_id) AND is_published = true
        )
    WHERE id = COALESCE(NEW.course_id, OLD.course_id);
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_course_rating
    AFTER INSERT OR UPDATE OR DELETE ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_course_rating();

CREATE TRIGGER trg_update_enrollment_count
    AFTER INSERT OR UPDATE OR DELETE ON course_enrollments
    FOR EACH ROW
    EXECUTE FUNCTION update_course_enrollment_count();

-- Function to get app configuration
CREATE OR REPLACE FUNCTION get_app_config(config_key_param VARCHAR)
RETURNS JSONB AS $$
DECLARE
    config_data JSONB;
BEGIN
    SELECT config_value INTO config_data
    FROM app_config
    WHERE config_key = config_key_param AND is_active = true;

    RETURN COALESCE(config_data, '{}'::JSONB);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to validate coupon
CREATE OR REPLACE FUNCTION validate_coupon(
    coupon_code VARCHAR,
    course_id_param UUID,
    student_id_param UUID
)
RETURNS JSONB AS $$
DECLARE
    coupon_record coupons%ROWTYPE;
    result JSONB;
BEGIN
    SELECT * INTO coupon_record
    FROM coupons
    WHERE code = coupon_code
    AND is_active = true
    AND valid_from <= NOW()
    AND valid_until >= NOW()
    AND (usage_limit IS NULL OR used_count < usage_limit);

    IF coupon_record.id IS NULL THEN
        RETURN jsonb_build_object(
            'valid', false,
            'message', 'Invalid or expired coupon code'
        );
    END IF;

    -- Check if course is applicable
    IF array_length(coupon_record.applicable_courses, 1) > 0
       AND NOT (course_id_param = ANY(coupon_record.applicable_courses)) THEN
        RETURN jsonb_build_object(
            'valid', false,
            'message', 'Coupon not applicable for this course'
        );
    END IF;

    RETURN jsonb_build_object(
        'valid', true,
        'discount_type', coupon_record.discount_type,
        'discount_value', coupon_record.discount_value,
        'minimum_amount', coupon_record.minimum_amount,
        'maximum_discount', coupon_record.maximum_discount
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update assignment submission count
CREATE OR REPLACE FUNCTION update_assignment_submission_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE assignments
        SET submission_count = submission_count + 1
        WHERE id = NEW.assignment_id;
        RETURN NEW;
    END IF;

    IF TG_OP = 'DELETE' THEN
        UPDATE assignments
        SET submission_count = submission_count - 1
        WHERE id = OLD.assignment_id;
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for submission count
CREATE TRIGGER trigger_update_assignment_submission_count
    AFTER INSERT OR DELETE ON assignment_submissions
    FOR EACH ROW EXECUTE FUNCTION update_assignment_submission_count();

-- Function to check if submission is late
CREATE OR REPLACE FUNCTION check_late_submission()
RETURNS TRIGGER AS $$
BEGIN
    NEW.is_late := NEW.submitted_at > (
        SELECT due_date FROM assignments WHERE id = NEW.assignment_id
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for late submission check
CREATE TRIGGER trigger_check_late_submission
    BEFORE INSERT OR UPDATE ON assignment_submissions
    FOR EACH ROW EXECUTE FUNCTION check_late_submission();

-- Add this function for assignment submissions
CREATE OR REPLACE FUNCTION submit_assignment(
    p_assignment_id UUID,
    p_student_id UUID,
    p_submission_url TEXT DEFAULT NULL,
    p_submission_text TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    assignment_record assignments%ROWTYPE;
    new_attempt INTEGER;
BEGIN
    -- Get assignment details
    SELECT * INTO assignment_record
    FROM assignments
    WHERE id = p_assignment_id AND is_published = true;
    
    IF assignment_record.id IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Assignment not found or not published'
        );
    END IF;
    
    -- Check if late submission is allowed
    IF NOW() > assignment_record.due_date AND NOT assignment_record.allow_late_submission THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Late submissions are not allowed for this assignment'
        );
    END IF;
    
    -- Get next attempt number
    SELECT COALESCE(MAX(attempt_number), 0) + 1 INTO new_attempt
    FROM assignment_submissions
    WHERE assignment_id = p_assignment_id AND student_id = p_student_id;
    
    -- Insert submission
    INSERT INTO assignment_submissions (
        assignment_id, student_id, submission_url, submission_text, attempt_number
    ) VALUES (
        p_assignment_id, p_student_id, p_submission_url, p_submission_text, new_attempt
    );
    
    RETURN jsonb_build_object(
        'success', true,
        'message', 'Assignment submitted successfully',
        'attempt_number', new_attempt
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Error submitting assignment: ' || SQLERRM
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update test result passed status
CREATE OR REPLACE FUNCTION update_test_result_passed_status()
RETURNS TRIGGER AS $$
DECLARE
    test_passing_marks DECIMAL(5,2);
    calculated_percentage DECIMAL(5,2);
BEGIN
    -- Get the passing marks for this test
    SELECT passing_marks INTO test_passing_marks
    FROM tests
    WHERE id = NEW.test_id;
    
    -- Calculate percentage
    IF NEW.total_marks > 0 THEN
        calculated_percentage := ROUND((NEW.score / NEW.total_marks * 100), 2);
    ELSE
        calculated_percentage := 0;
    END IF;
    
    -- Update passed status
    NEW.passed := calculated_percentage >= test_passing_marks;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update passed status
CREATE TRIGGER trigger_update_test_result_passed_status
    BEFORE INSERT OR UPDATE ON test_results
    FOR EACH ROW EXECUTE FUNCTION update_test_result_passed_status();


-- Add this function for updating coaching center statistics
CREATE OR REPLACE FUNCTION update_coaching_center_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- Update stats for affected coaching center
    UPDATE coaching_centers SET 
        total_courses = (
            SELECT COUNT(*) 
            FROM courses 
            WHERE coaching_center_id = coaching_centers.id AND is_published = true
        ),
        total_students = (
            SELECT COUNT(DISTINCT student_id) 
            FROM course_enrollments ce 
            JOIN courses c ON ce.course_id = c.id 
            WHERE c.coaching_center_id = coaching_centers.id
        ),
        updated_at = NOW()
    WHERE id = COALESCE(NEW.coaching_center_id, OLD.coaching_center_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

```


## **Phase 16: Performance Indexes**

**File: `25_indexes.sql`**

```sql
-- =============================================
-- PERFORMANCE OPTIMIZATION INDEXES
-- =============================================

-- Core Entity Indexes
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_profiles_user_type ON user_profiles(user_type);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_profiles_active ON user_profiles(is_active) WHERE is_active = true;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_coaching_centers_approval_status ON coaching_centers(approval_status);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_coaching_centers_active ON coaching_centers(is_active) WHERE is_active = true;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_teachers_coaching_center ON teachers(coaching_center_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_teachers_verified ON teachers(is_verified) WHERE is_verified = true;
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_teachers_specializations ON teachers USING GIN(specializations);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_students_user_id ON students(user_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_students_learning_goals ON students USING GIN(learning_goals);

-- Course and Content Indexes
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_courses_coaching_center ON courses(coaching_center_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_courses_published ON courses(is_published) WHERE is_published = true;
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_courses_category ON courses(category);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_courses_rating ON courses(rating DESC);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_courses_tags ON courses USING GIN(tags);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_chapters_course ON chapters(course_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_chapters_course_number ON chapters(course_id, chapter_number);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_lessons_chapter ON lessons(chapter_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_lessons_course ON lessons(course_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_lessons_published ON lessons(is_published) WHERE is_published = true;

-- Learning Progress Indexes
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_course_enrollments_student ON course_enrollments(student_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_course_enrollments_course ON course_enrollments(course_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_course_enrollments_active ON course_enrollments(is_active) WHERE is_active = true;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_lesson_progress_student_course ON lesson_progress(student_id, course_id, is_completed);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_lesson_progress_lesson ON lesson_progress(lesson_id);

-- Business Transaction Indexes
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_payments_student ON payments(student_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_payments_status ON payments(status);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_payments_date ON payments(payment_date DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_reviews_course ON reviews(course_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_reviews_published ON reviews(is_published) WHERE is_published = true;

-- Analytics Indexes
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_analytics_events_user ON analytics_events(user_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_analytics_events_created_at ON analytics_events(created_at DESC);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_analytics_events_category_action ON analytics_events(event_category, event_action);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_learning_analytics_student ON learning_analytics(student_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_learning_analytics_date ON learning_analytics(date DESC);

-- New Table Indexes
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_type ON notifications(notification_type);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);
CREATE INDEX idx_notifications_expires_at ON notifications(expires_at);

CREATE INDEX idx_certificates_student_id ON certificates(student_id);
CREATE INDEX idx_certificates_course_id ON certificates(course_id);
CREATE INDEX idx_certificates_verification_code ON certificates(verification_code);
CREATE INDEX idx_certificates_certificate_number ON certificates(certificate_number);
CREATE INDEX idx_certificates_issued_date ON certificates(issued_date);

CREATE INDEX idx_review_helpful_votes_review_id ON review_helpful_votes(review_id);
CREATE INDEX idx_review_helpful_votes_user_id ON review_helpful_votes(user_id);

CREATE INDEX idx_coupons_coaching_center_id ON coupons(coaching_center_id);
CREATE INDEX idx_coupons_code ON coupons(code);
CREATE INDEX idx_coupons_valid_dates ON coupons(valid_from, valid_until);
CREATE INDEX idx_coupons_is_active ON coupons(is_active);

CREATE INDEX idx_wishlists_student_id ON wishlists(student_id);
CREATE INDEX idx_wishlists_course_id ON wishlists(course_id);
CREATE INDEX idx_wishlists_added_at ON wishlists(added_at);

CREATE INDEX idx_learning_paths_coaching_center_id ON learning_paths(coaching_center_id);
CREATE INDEX idx_learning_path_courses_path_id ON learning_path_courses(learning_path_id);
CREATE INDEX idx_learning_path_courses_course_id ON learning_path_courses(course_id);

CREATE INDEX idx_app_config_key ON app_config(config_key);
CREATE INDEX idx_app_config_is_active ON app_config(is_active);
CREATE INDEX idx_app_config_is_public ON app_config(is_public);

CREATE INDEX idx_assignments_course_id ON assignments(course_id);
CREATE INDEX idx_assignments_chapter_id ON assignments(chapter_id);
CREATE INDEX idx_assignments_teacher_id ON assignments(teacher_id);
CREATE INDEX idx_assignments_due_date ON assignments(due_date);
CREATE INDEX idx_assignments_is_published ON assignments(is_published);

CREATE INDEX idx_assignment_submissions_assignment_id ON assignment_submissions(assignment_id);
CREATE INDEX idx_assignment_submissions_student_id ON assignment_submissions(student_id);
CREATE INDEX idx_assignment_submissions_submitted_at ON assignment_submissions(submitted_at);
CREATE INDEX idx_assignment_submissions_graded_by ON assignment_submissions(graded_by);
CREATE INDEX idx_assignment_submissions_status ON assignment_submissions(submission_status);

CREATE INDEX idx_test_results_test_id ON test_results(test_id);
CREATE INDEX idx_test_results_student_id ON test_results(student_id);
CREATE INDEX idx_test_results_completed_at ON test_results(completed_at);
CREATE INDEX idx_test_results_passed ON test_results(passed);
```


## **Phase 17: Row Level Security**

**File: `26_rls_policies.sql`**

```sql
-- =============================================
-- ROW LEVEL SECURITY POLICIES
-- =============================================

-- Enable RLS on all tables
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE coaching_centers ENABLE ROW LEVEL SECURITY;
ALTER TABLE teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE chapters ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE live_classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE test_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE live_class_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_helpful_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_paths ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_path_courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE wishlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignment_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE test_results ENABLE ROW LEVEL SECURITY;


-- Core Entity Policies
CREATE POLICY "Users can view their own profile" ON user_profiles
    FOR SELECT USING (id = auth.uid());

CREATE POLICY "Users can insert their own profile" ON user_profiles
    FOR INSERT WITH CHECK (id = auth.uid());

CREATE POLICY "Users can update their own profile" ON user_profiles
    FOR UPDATE USING (id = auth.uid()) WITH CHECK (id = auth.uid());

CREATE POLICY "Admins can view all profiles" ON user_profiles
    FOR SELECT USING (is_admin());

-- Coaching Centers Policies
CREATE POLICY "Coaching centers can view their own data" ON coaching_centers
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Coaching centers can update their own data" ON coaching_centers
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Coaching centers can insert their own data" ON coaching_centers
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Public can view approved coaching centers" ON coaching_centers
    FOR SELECT USING (approval_status = 'approved' AND is_active = true);

-- Students Policies
CREATE POLICY "Students can view their own data" ON students
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Students can update their own data" ON students
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Students can insert their own data" ON students
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Teachers Policies
CREATE POLICY "Teachers can view their own data" ON teachers
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Teachers can update their own data" ON teachers
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Coaching centers can manage their teachers" ON teachers
    FOR ALL USING (coaching_center_id = get_user_coaching_center_id());

-- Course Content Policies
CREATE POLICY "Public can view published courses" ON courses
    FOR SELECT USING (is_published = true);

CREATE POLICY "Coaching centers can manage their courses" ON courses
    FOR ALL USING (coaching_center_id = get_user_coaching_center_id());

CREATE POLICY "Assigned teachers can view their courses" ON courses
    FOR SELECT USING (
        teacher_id IN (
            SELECT id FROM teachers WHERE user_id = auth.uid()
        )
    );

-- Assessment Policies
CREATE POLICY "Teachers can manage their assignments" ON assignments
    FOR ALL USING (
        teacher_id IN (
            SELECT id FROM teachers WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Students can view published assignments for enrolled courses" ON assignments
    FOR SELECT USING (
        is_published = true AND
        course_id IN (
            SELECT ce.course_id FROM course_enrollments ce
            JOIN students s ON ce.student_id = s.id
            WHERE s.user_id = auth.uid()
        )
    );

CREATE POLICY "Students can manage their own submissions" ON assignment_submissions
    FOR ALL USING (
        student_id IN (
            SELECT id FROM students WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Teachers can view and grade submissions for their assignments" ON assignment_submissions
    FOR ALL USING (
        assignment_id IN (
            SELECT id FROM assignments WHERE teacher_id IN (
                SELECT id FROM teachers WHERE user_id = auth.uid()
            )
        )
    );

-- Test Results Policies

CREATE POLICY "Students can view their own test results" ON test_results
    FOR SELECT USING (
        student_id IN (
            SELECT id FROM students WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Students can insert their own test results" ON test_results
    FOR INSERT WITH CHECK (
        student_id IN (
            SELECT id FROM students WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Teachers can view test results for their tests" ON test_results
    FOR SELECT USING (
        test_id IN (
            SELECT id FROM tests WHERE teacher_id IN (
                SELECT id FROM teachers WHERE user_id = auth.uid()
            )
        )
    );

-- E-commerce Policies
CREATE POLICY "Coaching centers can manage their coupons" ON coupons
    FOR ALL USING (
        coaching_center_id IN (
            SELECT id FROM coaching_centers WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Students can view active coupons" ON coupons
    FOR SELECT USING (is_active = true AND valid_until > NOW());

CREATE POLICY "Students can manage their own wishlist" ON wishlists
    FOR ALL USING (
        student_id IN (
            SELECT id FROM students WHERE user_id = auth.uid()
        )
    );

-- Learning Path Policies
CREATE POLICY "Coaching centers can manage their learning paths" ON learning_paths
    FOR ALL USING (
        coaching_center_id IN (
            SELECT id FROM coaching_centers WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Everyone can view published learning paths" ON learning_paths
    FOR SELECT USING (is_published = true);

-- Review Enhancement Policies
CREATE POLICY "Users can view all review votes" ON review_helpful_votes
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can vote on reviews" ON review_helpful_votes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own votes" ON review_helpful_votes
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own votes" ON review_helpful_votes
    FOR DELETE USING (auth.uid() = user_id);

-- Certificate Policies
CREATE POLICY "Students can view their own certificates" ON certificates
    FOR SELECT USING (
        student_id IN (
            SELECT id FROM students WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Teachers can view certificates for their courses" ON certificates
    FOR SELECT USING (
        teacher_id IN (
            SELECT id FROM teachers WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "System can insert certificates" ON certificates
    FOR INSERT WITH CHECK (true);

-- Notification Policies
CREATE POLICY "Users can view their own notifications" ON notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "System can insert notifications" ON notifications
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update their own notifications" ON notifications
    FOR UPDATE USING (auth.uid() = user_id);

-- App Config Policies
CREATE POLICY "Everyone can view public configs" ON app_config
    FOR SELECT USING (is_public = true AND is_active = true);

CREATE POLICY "Admins can manage all configs" ON app_config
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE id = auth.uid() AND
            (raw_user_meta_data->>'user_type' = 'admin' )
        )
    );

-- Analytics Policies
CREATE POLICY "Users can insert analytics events" ON analytics_events
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Students can view their learning analytics" ON learning_analytics
    FOR SELECT USING (student_id = get_student_id());

-- Audit Policies
CREATE POLICY "Users can view their own audit logs" ON audit_logs
    FOR SELECT USING (user_id = auth.uid());
```


### **Phase 11: Sample Data**

**File: `20_sample_data.sql`**

```sql

```

**Create Storage Buckets**

1. `avatars` (Public)
2. `course-content` (Private)
3. `assignments` (Private)
4. `certificates` (Private)
5. `live-class-recordings` (Private)
6. `app-assets` (Public)
