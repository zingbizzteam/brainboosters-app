
-- Create these buckets in Supabase Dashboard:

1. avatars (Public) - User profile pictures
2. course-content (Private) - Course videos, documents, materials
3. assignments (Private) - Student submissions and teacher feedback
4. certificates (Private) - Course completion certificates
5. live-class-recordings (Private) - Recorded live sessions
6. app-assets (Public) - App logos, icons, static content


A comprehensive SQL models for your e-learning application with Supabase. This will include all the tables, indexes, RLS policies, and sample data you need.

## Core Authentication \& User Management


### 00_user_profiles.sql

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


-- no need for Sample Data
```
### 01_auth_user.sql

```sql
-- First, insert into auth.users with all required fields
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    recovery_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
) VALUES 
(
    '00000000-0000-0000-0000-000000000000',
    '550e8400-e29b-41d4-a716-446655440001',
    'authenticated',
    'authenticated',
    'john.admin@example.com',
    crypt('123456', gen_salt('bf')),
    NOW(),
    NULL,
    NULL,
    '{"provider": "email", "providers": ["email"]}',
    '{"user_type": "admin", "first_name": "John", "last_name": "Admin"}',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
),
(
    '00000000-0000-0000-0000-000000000000',
    '550e8400-e29b-41d4-a716-446655440002',
    'authenticated',
    'authenticated',
    'alice.johnson@example.com',
    crypt('123456', gen_salt('bf')),
    NOW(),
    NULL,
    NULL,
    '{"provider": "email", "providers": ["email"]}',
    '{"user_type": "student", "first_name": "Alice", "last_name": "Johnson"}',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
),
(
    '00000000-0000-0000-0000-000000000000',
    '550e8400-e29b-41d4-a716-446655440003',
    'authenticated',
    'authenticated',
    'bob.smith@example.com',
    crypt('123456', gen_salt('bf')),
    NOW(),
    NULL,
    NULL,
    '{"provider": "email", "providers": ["email"]}',
    '{"user_type": "student", "first_name": "Bob", "last_name": "Smith"}',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
),
(
    '00000000-0000-0000-0000-000000000000',
    '550e8400-e29b-41d4-a716-446655440004',
    'authenticated',
    'authenticated',
    'teched.institute@example.com',
    crypt('123456', gen_salt('bf')),
    NOW(),
    NULL,
    NULL,
    '{"provider": "email", "providers": ["email"]}',
    '{"user_type": "coaching_center", "first_name": "TechEd", "last_name": "Institute"}',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
),
(
    '00000000-0000-0000-0000-000000000000',
    '550e8400-e29b-41d4-a716-446655440005',
    'authenticated',
    'authenticated',
    'sarah.wilson@example.com',
    crypt('123456', gen_salt('bf')),
    NOW(),
    NULL,
    NULL,
    '{"provider": "email", "providers": ["email"]}',
    '{"user_type": "teacher", "first_name": "Sarah", "last_name": "Wilson"}',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
);

-- Then, insert corresponding records into auth.identities (REQUIRED for email/password auth)
INSERT INTO auth.identities (
    provider_id,
    user_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
) VALUES 
(
    '550e8400-e29b-41d4-a716-446655440001',
    '550e8400-e29b-41d4-a716-446655440001',
    '{"sub": "550e8400-e29b-41d4-a716-446655440001", "email": "john.admin@example.com", "email_verified": true, "phone_verified": false}',
    'email',
    NULL,
    NOW(),
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440002',
    '550e8400-e29b-41d4-a716-446655440002',
    '{"sub": "550e8400-e29b-41d4-a716-446655440002", "email": "alice.johnson@example.com", "email_verified": true, "phone_verified": false}',
    'email',
    NULL,
    NOW(),
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440003',
    '550e8400-e29b-41d4-a716-446655440003',
    '{"sub": "550e8400-e29b-41d4-a716-446655440003", "email": "bob.smith@example.com", "email_verified": true, "phone_verified": false}',
    'email',
    NULL,
    NOW(),
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440004',
    '550e8400-e29b-41d4-a716-446655440004',
    '{"sub": "550e8400-e29b-41d4-a716-446655440004", "email": "teched.institute@example.com", "email_verified": true, "phone_verified": false}',
    'email',
    NULL,
    NOW(),
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440005',
    '550e8400-e29b-41d4-a716-446655440005',
    '{"sub": "550e8400-e29b-41d4-a716-446655440005", "email": "sarah.wilson@example.com", "email_verified": true, "phone_verified": false}',
    'email',
    NULL,
    NOW(),
    NOW()
);
```

### 02_coaching_centers.sql

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
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sample Data
INSERT INTO coaching_centers (id, user_id, center_name, center_code, description, contact_email, contact_phone, address, approval_status, max_faculty_limit, max_courses_limit) VALUES
('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440004', 'TechEd Institute', 'TECH001', 'Leading technology education center', 'admin@teched.com', '+1234567893', '{"street": "123 Tech St", "city": "San Francisco", "state": "CA", "zip": "94105", "country": "USA"}', 'approved', 25, 100);
```


### 03_teachers.sql

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

-- Sample Data
INSERT INTO teachers (id, user_id, coaching_center_id, employee_id, specializations, qualifications, experience_years, bio, hourly_rate, rating, total_reviews, is_verified) VALUES
('770e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440001', 'EMP001', '{"JavaScript", "React", "Node.js"}', '[{"degree": "M.S. Computer Science", "institution": "Stanford University", "year": 2018}]', 5, 'Experienced full-stack developer and educator', 75.00, 4.8, 156, true);
```


### 04_students.sql

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
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sample Data
INSERT INTO students (id, user_id, student_id, grade_level, learning_goals, total_courses_enrolled, total_courses_completed, total_hours_learned, current_streak_days, total_points, level) VALUES
('880e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'STU001', '12th Grade', '{"Web Development", "Programming Fundamentals"}', 3, 1, 45.5, 7, 1250, 3),
('880e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440003', 'STU002', 'College', '{"Data Science", "Python Programming"}', 2, 0, 23.0, 3, 680, 2);
```


## Course Management System

### 05_courses.sql

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
    category VARCHAR(100) NOT NULL,
    subcategory VARCHAR(100),
    level VARCHAR(20) CHECK (level IN ('beginner', 'intermediate', 'advanced', 'expert')),
    language VARCHAR(10) DEFAULT 'en',
    price DECIMAL(10,2) DEFAULT 0.00,
    original_price DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'USD',
    duration_hours DECIMAL(5,2),
    total_lessons INTEGER DEFAULT 0,
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
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sample Data
INSERT INTO courses (id, coaching_center_id, teacher_id, title, slug, description, short_description, category, level, price, original_price, duration_hours, total_lessons, total_chapters, prerequisites, learning_outcomes, tags, is_published, enrollment_count, rating, total_reviews) VALUES
('990e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440001', 'Complete React.js Masterclass', 'complete-reactjs-masterclass', 'Master React.js from basics to advanced concepts with hands-on projects', 'Learn React.js with practical projects', 'Programming', 'intermediate', 99.99, 149.99, 25.5, 45, 8, '{"Basic JavaScript", "HTML/CSS"}', '{"Build React Applications", "State Management", "Component Architecture"}', '{"React", "JavaScript", "Frontend"}', true, 234, 4.7, 89),
('990e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440001', 'Python Data Science Bootcamp', 'python-data-science-bootcamp', 'Comprehensive data science course using Python', 'Learn data science with Python', 'Data Science', 'beginner', 79.99, 119.99, 30.0, 52, 10, '{"Basic Programming"}', '{"Data Analysis", "Machine Learning", "Data Visualization"}', '{"Python", "Data Science", "ML"}', true, 156, 4.8, 67);
```


### 06_chapters.sql

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
    UNIQUE(course_id, chapter_number)
);

-- Sample Data
INSERT INTO chapters (id, course_id, title, description, chapter_number, duration_minutes, total_lessons, is_published, is_free) VALUES
('aa0e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001', 'Introduction to React', 'Getting started with React fundamentals', 1, 180, 6, true, true),
('aa0e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440001', 'Components and JSX', 'Understanding React components and JSX syntax', 2, 240, 8, true, false),
('aa0e8400-e29b-41d4-a716-446655440003', '990e8400-e29b-41d4-a716-446655440001', 'State and Props', 'Managing component state and props', 3, 300, 10, true, false),
('aa0e8400-e29b-41d4-a716-446655440004', '990e8400-e29b-41d4-a716-446655440002', 'Python Basics', 'Introduction to Python programming', 1, 200, 7, true, true),
('aa0e8400-e29b-41d4-a716-446655440005', '990e8400-e29b-41d4-a716-446655440002', 'Data Structures', 'Working with Python data structures', 2, 280, 9, true, false);
```


### 07_lessons.sql

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
    video_duration INTEGER, -- in seconds
    transcript TEXT,
    attachments JSONB DEFAULT '[]',
    is_published BOOLEAN DEFAULT false,
    is_free BOOLEAN DEFAULT false,
    view_count INTEGER DEFAULT 0,
    completion_rate DECIMAL(5,2) DEFAULT 0.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(chapter_id, lesson_number)
);

-- Sample Data
INSERT INTO lessons (id, chapter_id, course_id, title, description, lesson_number, lesson_type, content_url, video_duration, is_published, is_free, view_count) VALUES
('bb0e8400-e29b-41d4-a716-446655440001', 'aa0e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001', 'What is React?', 'Introduction to React library', 1, 'video', 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 900, true, true, 456),
('bb0e8400-e29b-41d4-a716-446655440002', 'aa0e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001', 'Setting up Development Environment', 'Installing Node.js and creating React app', 2, 'video', 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', 1200, true, true, 389),
('bb0e8400-e29b-41d4-a716-446655440003', 'aa0e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440001', 'Your First Component', 'Creating and rendering React components', 1, 'video', 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4', 1500, true, false, 234),
('bb0e8400-e29b-41d4-a716-446655440004', 'aa0e8400-e29b-41d4-a716-446655440004', '990e8400-e29b-41d4-a716-446655440002', 'Python Installation', 'Installing Python and setting up IDE', 1, 'video', 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4', 800, true, true, 298);
```


## Live Classes \& Tests

### 08_live_classes.sql

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
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sample Data
INSERT INTO live_classes (id, coaching_center_id, teacher_id, course_id, title, description, scheduled_at, duration_minutes, max_participants, price, status) VALUES
('cc0e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001', 'React Hooks Deep Dive', 'Advanced session on React Hooks', '2025-07-15 14:00:00+00', 90, 50, 29.99, 'scheduled'),
('cc0e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440002', 'Data Visualization with Python', 'Creating charts and graphs with matplotlib', '2025-07-20 16:00:00+00', 120, 75, 0.00, 'scheduled');
```


### 09_tests.sql

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
    options JSONB, -- For MCQ questions
    correct_answers JSONB NOT NULL, -- Array of correct answers
    marks INTEGER DEFAULT 1,
    explanation TEXT,
    question_order INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sample Data
INSERT INTO tests (id, course_id, chapter_id, coaching_center_id, teacher_id, title, description, test_type, total_questions, total_marks, passing_marks, time_limit_minutes, is_published) VALUES
('dd0e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001', 'aa0e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440001', 'React Basics Quiz', 'Test your understanding of React fundamentals', 'quiz', 10, 20, 12, 30, true);

INSERT INTO test_questions (id, test_id, question_text, question_type, options, correct_answers, marks, explanation, question_order) VALUES
('ee0e8400-e29b-41d4-a716-446655440001', 'dd0e8400-e29b-41d4-a716-446655440001', 'What does JSX stand for?', 'mcq', '["JavaScript XML", "JavaScript Extension", "Java Syntax Extension", "JavaScript Syntax"]', '["JavaScript XML"]', 2, 'JSX stands for JavaScript XML, which allows writing HTML in React', 1),
('ee0e8400-e29b-41d4-a716-446655440002', 'dd0e8400-e29b-41d4-a716-446655440001', 'React components must return a single element.', 'true_false', '["True", "False"]', '["True"]', 2, 'React components must return a single parent element or use React Fragment', 2);
```


## Enrollment \& Progress Tracking

### 10_enrollments.sql

```sql
-- Course Enrollments Table
CREATE TABLE course_enrollments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    progress_percentage DECIMAL(5,2) DEFAULT 0.0,
    total_time_spent INTEGER DEFAULT 0, -- in minutes
    last_accessed_at TIMESTAMP WITH TIME ZONE,
    last_lesson_id UUID REFERENCES lessons(id),
    completion_certificate_url TEXT,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    UNIQUE(student_id, course_id)
);

-- Lesson Progress Table
CREATE TABLE lesson_progress (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE,
    lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    time_spent INTEGER DEFAULT 0, -- in seconds
    progress_percentage DECIMAL(5,2) DEFAULT 0.0,
    last_position INTEGER DEFAULT 0, -- for video lessons
    is_completed BOOLEAN DEFAULT false,
    UNIQUE(student_id, lesson_id)
);

-- Live Class Enrollments Table
CREATE TABLE live_class_enrollments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE,
    live_class_id UUID REFERENCES live_classes(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    attended BOOLEAN DEFAULT false,
    attendance_duration INTEGER DEFAULT 0, -- in minutes
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    feedback TEXT,
    UNIQUE(student_id, live_class_id)
);

-- Sample Data
INSERT INTO course_enrollments (id, student_id, course_id, progress_percentage, total_time_spent, last_accessed_at, rating, review_text) VALUES
('ff0e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001', 65.5, 890, NOW() - INTERVAL '2 hours', 5, 'Excellent course with clear explanations'),
('ff0e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440002', 23.0, 420, NOW() - INTERVAL '1 day', 4, 'Good content but could use more examples');

INSERT INTO lesson_progress (id, student_id, lesson_id, course_id, completed_at, time_spent, progress_percentage, is_completed) VALUES
('110e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440001', 'bb0e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001', NOW() - INTERVAL '3 days', 900, 100.0, true),
('110e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440001', 'bb0e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440001', NOW() - INTERVAL '2 days', 1200, 100.0, true);
```


## Payment \& Reviews

### 11_payments.sql

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

-- Sample Data
INSERT INTO payments (id, student_id, course_id, payment_type, amount, payment_method, payment_gateway, transaction_id, gateway_transaction_id, status, payment_date) VALUES
('120e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001', 'course', 99.99, 'credit_card', 'stripe', 'TXN_001_2025', 'pi_1234567890', 'completed', NOW() - INTERVAL '5 days'),
('120e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440002', 'course', 79.99, 'paypal', 'paypal', 'TXN_002_2025', 'PAYID-123456', 'completed', NOW() - INTERVAL '3 days');
```


### 12_reviews.sql

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
    helpful_count INTEGER DEFAULT 0,
    reported_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(student_id, course_id)
);

-- Sample Data
INSERT INTO reviews (id, student_id, course_id, teacher_id, rating, review_text, pros, cons, is_verified_purchase, helpful_count) VALUES
('130e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440001', 5, 'Outstanding course! Sarah explains complex concepts very clearly.', 'Clear explanations, good examples, responsive instructor', 'Could use more advanced projects', true, 12),
('130e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440002', '770e8400-e29b-41d4-a716-446655440001', 4, 'Good introduction to data science. Well structured content.', 'Comprehensive coverage, practical examples', 'Some sections could be more detailed', true, 8);
```


## Utilities \& Analytics

### 13_app_utils.sql

```sql
-- App Configuration and Utilities
CREATE TABLE app_config (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value JSONB NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sample Data
INSERT INTO app_config (config_key, config_value, description) VALUES
('supported_languages', '["en", "ta", "hi" ]', 'List of supported languages in the app'),
('learning_goals', '["Web Development", "Mobile Development", "Data Science", "Machine Learning", "DevOps", "Cybersecurity", "UI/UX Design", "Digital Marketing"]', 'Available learning goals for students'),
('course_categories', '["Programming", "Data Science", "Design", "Business", "Marketing", "Personal Development", "Language Learning", "Test Preparation"]', 'Available course categories'),
('skill_levels', '["beginner", "intermediate", "advanced", "expert"]', 'Available skill levels'),
('payment_gateways', '{"stripe": {"enabled": true, "currencies": ["USD", "EUR", "GBP"]}, "paypal": {"enabled": true, "currencies": ["USD", "EUR"]}, "razorpay": {"enabled": true, "currencies": ["INR"]}}', 'Supported payment gateways and currencies'),
('notification_settings', '{"email": {"enabled": true, "types": ["enrollment", "course_updates", "reminders"]}, "push": {"enabled": true, "types": ["live_class", "assignments", "achievements"]}}', 'Notification configuration'),
('gamification_settings', '{"points_per_lesson": 10, "points_per_quiz": 20, "streak_bonus": 5, "level_thresholds": [0, 100, 300, 600, 1000, 1500, 2500, 4000, 6000, 10000]}', 'Gamification and reward system settings');
```


### 14_analytics_events.sql

```sql
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

-- Sample Data
INSERT INTO analytics_events (user_id, session_id, event_type, event_category, event_action, event_label, properties, device_type, browser, country) VALUES
('550e8400-e29b-41d4-a716-446655440002', 'sess_123456', 'page_view', 'course', 'view_lesson', 'React Basics', '{"lesson_id": "bb0e8400-e29b-41d4-a716-446655440001", "duration": 900}', 'desktop', 'Chrome', 'US'),
('550e8400-e29b-41d4-a716-446655440003', 'sess_789012', 'engagement', 'quiz', 'complete_quiz', 'Python Basics Quiz', '{"quiz_id": "dd0e8400-e29b-41d4-a716-446655440001", "score": 85, "time_taken": 1200}', 'mobile', 'Safari', 'CA');

INSERT INTO learning_analytics (student_id, course_id, date, time_spent_minutes, lessons_completed, quizzes_attempted, quizzes_passed, average_quiz_score, points_earned) VALUES
('880e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001', CURRENT_DATE - INTERVAL '1 day', 120, 3, 1, 1, 95.0, 50),
('880e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440002', CURRENT_DATE - INTERVAL '1 day', 90, 2, 0, 0, 0.0, 20);
```


### 15_audit_logs.sql

```sql
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

-- Function to log audit events
CREATE OR REPLACE FUNCTION log_audit_event()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_logs (
        user_id,
        action,
        resource_type,
        resource_id,
        old_values,
        new_values,
        created_at
    ) VALUES (
        auth.uid(),
        TG_OP,
        TG_TABLE_NAME,
        COALESCE(NEW.id, OLD.id),
        CASE WHEN TG_OP = 'DELETE' THEN to_jsonb(OLD) ELSE NULL END,
        CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN to_jsonb(NEW) ELSE NULL END,
        NOW()
    );
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Sample Data
INSERT INTO audit_logs (user_id, user_type, action, resource_type, resource_id, new_values, ip_address) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'admin', 'UPDATE', 'coaching_centers', '660e8400-e29b-41d4-a716-446655440001', '{"approval_status": "approved"}', '192.168.1.1'),
('550e8400-e29b-41d4-a716-446655440004', 'coaching_center', 'INSERT', 'courses', '990e8400-e29b-41d4-a716-446655440001', '{"title": "Complete React.js Masterclass", "is_published": true}', '192.168.1.2');
```

Now I'll create the indexes and RLS policies:

## Database Indexes

### 16_indexes.sql

```sql
-- User Profiles Indexes
CREATE INDEX idx_user_profiles_user_type ON user_profiles(user_type);
CREATE INDEX idx_user_profiles_email_verified ON user_profiles(email_verified) WHERE email_verified = true;
CREATE INDEX idx_user_profiles_active ON user_profiles(is_active) WHERE is_active = true;

-- Coaching Centers Indexes
CREATE INDEX idx_coaching_centers_approval_status ON coaching_centers(approval_status);
CREATE INDEX idx_coaching_centers_center_code ON coaching_centers(center_code);
CREATE INDEX idx_coaching_centers_active ON coaching_centers(is_active) WHERE is_active = true;

-- Teachers Indexes
CREATE INDEX idx_teachers_coaching_center ON teachers(coaching_center_id);
CREATE INDEX idx_teachers_verified ON teachers(is_verified) WHERE is_verified = true;
CREATE INDEX idx_teachers_specializations ON teachers USING GIN(specializations);
CREATE INDEX idx_teachers_rating ON teachers(rating DESC);

-- Students Indexes
CREATE INDEX idx_students_user_id ON students(user_id);
CREATE INDEX idx_students_grade_level ON students(grade_level);
CREATE INDEX idx_students_learning_goals ON students USING GIN(learning_goals);

-- Courses Indexes
CREATE INDEX idx_courses_coaching_center ON courses(coaching_center_id);
CREATE INDEX idx_courses_teacher ON courses(teacher_id);
CREATE INDEX idx_courses_published ON courses(is_published) WHERE is_published = true;
CREATE INDEX idx_courses_category ON courses(category);
CREATE INDEX idx_courses_level ON courses(level);
CREATE INDEX idx_courses_price ON courses(price);
CREATE INDEX idx_courses_rating ON courses(rating DESC);
CREATE INDEX idx_courses_enrollment_count ON courses(enrollment_count DESC);
CREATE INDEX idx_courses_tags ON courses USING GIN(tags);
CREATE INDEX idx_courses_slug ON courses(slug);

-- Chapters Indexes
CREATE INDEX idx_chapters_course ON chapters(course_id);
CREATE INDEX idx_chapters_published ON chapters(is_published) WHERE is_published = true;
CREATE INDEX idx_chapters_course_number ON chapters(course_id, chapter_number);

-- Lessons Indexes
CREATE INDEX idx_lessons_chapter ON lessons(chapter_id);
CREATE INDEX idx_lessons_course ON lessons(course_id);
CREATE INDEX idx_lessons_published ON lessons(is_published) WHERE is_published = true;
CREATE INDEX idx_lessons_type ON lessons(lesson_type);
CREATE INDEX idx_lessons_chapter_number ON lessons(chapter_id, lesson_number);

-- Live Classes Indexes
CREATE INDEX idx_live_classes_coaching_center ON live_classes(coaching_center_id);
CREATE INDEX idx_live_classes_teacher ON live_classes(teacher_id);
CREATE INDEX idx_live_classes_course ON live_classes(course_id);
CREATE INDEX idx_live_classes_scheduled_at ON live_classes(scheduled_at);
CREATE INDEX idx_live_classes_status ON live_classes(status);

-- Tests Indexes
CREATE INDEX idx_tests_course ON tests(course_id);
CREATE INDEX idx_tests_chapter ON tests(chapter_id);
CREATE INDEX idx_tests_published ON tests(is_published) WHERE is_published = true;
CREATE INDEX idx_test_questions_test ON test_questions(test_id);

-- Enrollments Indexes
CREATE INDEX idx_course_enrollments_student ON course_enrollments(student_id);
CREATE INDEX idx_course_enrollments_course ON course_enrollments(course_id);
CREATE INDEX idx_course_enrollments_active ON course_enrollments(is_active) WHERE is_active = true;
CREATE INDEX idx_course_enrollments_completed ON course_enrollments(completed_at) WHERE completed_at IS NOT NULL;

CREATE INDEX idx_lesson_progress_student ON lesson_progress(student_id);
CREATE INDEX idx_lesson_progress_lesson ON lesson_progress(lesson_id);
CREATE INDEX idx_lesson_progress_course ON lesson_progress(course_id);
CREATE INDEX idx_lesson_progress_completed ON lesson_progress(is_completed) WHERE is_completed = true;

CREATE INDEX idx_live_class_enrollments_student ON live_class_enrollments(student_id);
CREATE INDEX idx_live_class_enrollments_class ON live_class_enrollments(live_class_id);

-- Payments Indexes
CREATE INDEX idx_payments_student ON payments(student_id);
CREATE INDEX idx_payments_course ON payments(course_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_date ON payments(payment_date DESC);
CREATE INDEX idx_payments_transaction_id ON payments(transaction_id);

-- Reviews Indexes
CREATE INDEX idx_reviews_course ON reviews(course_id);
CREATE INDEX idx_reviews_teacher ON reviews(teacher_id);
CREATE INDEX idx_reviews_student ON reviews(student_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_published ON reviews(is_published) WHERE is_published = true;

-- Analytics Indexes
CREATE INDEX idx_analytics_events_user ON analytics_events(user_id);
CREATE INDEX idx_analytics_events_type ON analytics_events(event_type);
CREATE INDEX idx_analytics_events_category ON analytics_events(event_category);
CREATE INDEX idx_analytics_events_created_at ON analytics_events(created_at DESC);

CREATE INDEX idx_learning_analytics_student ON learning_analytics(student_id);
CREATE INDEX idx_learning_analytics_course ON learning_analytics(course_id);
CREATE INDEX idx_learning_analytics_date ON learning_analytics(date DESC);

-- Audit Logs Indexes
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
```


## Row Level Security Policies

### 17_rls_policies.sql

```sql
-- =============================================
-- COMPLETE RLS POLICIES (FIXED VERSION)
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

-- =============================================
-- HELPER FUNCTIONS
-- =============================================

-- Helper function to get user type
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

-- Helper function to check if user is admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN (
        SELECT user_type = 'admin'
        FROM user_profiles 
        WHERE id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Helper function to get coaching center id for user
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

-- Helper function to get student id for user
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

-- Helper function to check if teacher is assigned to course
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

-- =============================================
-- STORAGE POLICIES
-- =============================================

-- Avatar storage policies (using your existing bucket name)
CREATE POLICY "Users can upload their own avatars" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'avatars' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can update their own avatars" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'avatars' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete their own avatars" ON storage.objects
FOR DELETE USING (
  bucket_id = 'avatars' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Public can view avatars" ON storage.objects
FOR SELECT USING (bucket_id = 'avatars');

-- =============================================
-- USER PROFILES POLICIES (FIXED)
-- =============================================

-- Users can view their own profile
CREATE POLICY "Users can view their own profile" ON user_profiles
    FOR SELECT USING (id = auth.uid());

-- Users can INSERT their own profile (for trigger/signup)
CREATE POLICY "Users can insert their own profile" ON user_profiles
    FOR INSERT WITH CHECK (id = auth.uid());

-- Users can update their own profile (FIXED - removed OLD references)
CREATE POLICY "Users can update their own profile" ON user_profiles
    FOR UPDATE USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

-- Admins can view all profiles
CREATE POLICY "Admins can view all profiles" ON user_profiles
    FOR SELECT USING (is_admin());

-- Admins can update all profiles (for banning/suspending)
CREATE POLICY "Admins can update all profiles" ON user_profiles
    FOR UPDATE USING (is_admin());

-- =============================================
-- COACHING CENTERS POLICIES
-- =============================================

-- Coaching centers can view their own data
CREATE POLICY "Coaching centers can view their own data" ON coaching_centers
    FOR SELECT USING (user_id = auth.uid());

-- Coaching centers can update their own data
CREATE POLICY "Coaching centers can update their own data" ON coaching_centers
    FOR UPDATE USING (user_id = auth.uid());

-- Coaching centers can insert their own data (registration)
CREATE POLICY "Coaching centers can insert their own data" ON coaching_centers
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Admins can view all coaching centers
CREATE POLICY "Admins can view all coaching centers" ON coaching_centers
    FOR SELECT USING (is_admin());

-- Admins can update all coaching centers (approval/suspension)
CREATE POLICY "Admins can update all coaching centers" ON coaching_centers
    FOR UPDATE USING (is_admin());

-- Public can view approved coaching centers
CREATE POLICY "Public can view approved coaching centers" ON coaching_centers
    FOR SELECT USING (approval_status = 'approved' AND is_active = true);

-- =============================================
-- TEACHERS POLICIES
-- =============================================

-- Teachers can view their own data
CREATE POLICY "Teachers can view their own data" ON teachers
    FOR SELECT USING (user_id = auth.uid());

-- Teachers can update their own data
CREATE POLICY "Teachers can update their own data" ON teachers
    FOR UPDATE USING (user_id = auth.uid());

-- Coaching centers can manage their teachers
CREATE POLICY "Coaching centers can manage their teachers" ON teachers
    FOR ALL USING (coaching_center_id = get_user_coaching_center_id());

-- Coaching centers can insert teachers
CREATE POLICY "Coaching centers can insert teachers" ON teachers
    FOR INSERT WITH CHECK (coaching_center_id = get_user_coaching_center_id());

-- Admins can view all teachers
CREATE POLICY "Admins can view all teachers" ON teachers
    FOR SELECT USING (is_admin());

-- Admins can update all teachers (for suspension)
CREATE POLICY "Admins can update all teachers" ON teachers
    FOR UPDATE USING (is_admin());

-- Public can view verified teachers
CREATE POLICY "Public can view verified teachers" ON teachers
    FOR SELECT USING (is_verified = true);

-- =============================================
-- STUDENTS POLICIES
-- =============================================

-- Students can view their own data
CREATE POLICY "Students can view their own data" ON students
    FOR SELECT USING (user_id = auth.uid());

-- Students can update their own data
CREATE POLICY "Students can update their own data" ON students
    FOR UPDATE USING (user_id = auth.uid());

-- Students can insert their own data (profile setup)
CREATE POLICY "Students can insert their own data" ON students
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Admins can view all students
CREATE POLICY "Admins can view all students" ON students
    FOR SELECT USING (is_admin());

-- Coaching centers can view their enrolled students
CREATE POLICY "Coaching centers can view enrolled students" ON students
    FOR SELECT USING (
        get_user_coaching_center_id() IS NOT NULL AND
        id IN (
            SELECT ce.student_id 
            FROM course_enrollments ce
            JOIN courses c ON ce.course_id = c.id
            WHERE c.coaching_center_id = get_user_coaching_center_id()
        )
    );

-- =============================================
-- COURSES POLICIES
-- =============================================

-- Public can view published courses
CREATE POLICY "Public can view published courses" ON courses
    FOR SELECT USING (is_published = true);

-- Coaching centers can manage their courses
CREATE POLICY "Coaching centers can manage their courses" ON courses
    FOR ALL USING (coaching_center_id = get_user_coaching_center_id());

-- Coaching centers can insert courses
CREATE POLICY "Coaching centers can insert courses" ON courses
    FOR INSERT WITH CHECK (coaching_center_id = get_user_coaching_center_id());

-- Assigned teachers can view and update their courses
CREATE POLICY "Assigned teachers can manage their courses" ON courses
    FOR SELECT USING (
        teacher_id IN (
            SELECT id FROM teachers WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Assigned teachers can update their courses" ON courses
    FOR UPDATE USING (
        teacher_id IN (
            SELECT id FROM teachers WHERE user_id = auth.uid()
        )
    );

-- Admins can view all courses
CREATE POLICY "Admins can view all courses" ON courses
    FOR SELECT USING (is_admin());

-- =============================================
-- CHAPTERS POLICIES
-- =============================================

-- Public can view published chapters
CREATE POLICY "Public can view published chapters" ON chapters
    FOR SELECT USING (
        is_published = true AND 
        course_id IN (SELECT id FROM courses WHERE is_published = true)
    );

-- Coaching centers can manage their course chapters
CREATE POLICY "Coaching centers can manage chapters" ON chapters
    FOR ALL USING (
        course_id IN (
            SELECT id FROM courses 
            WHERE coaching_center_id = get_user_coaching_center_id()
        )
    );

-- Assigned teachers can manage chapters
CREATE POLICY "Assigned teachers can manage chapters" ON chapters
    FOR ALL USING (is_teacher_assigned_to_course(course_id));

-- =============================================
-- LESSONS POLICIES
-- =============================================

-- Enrolled students can view lessons
CREATE POLICY "Enrolled students can view lessons" ON lessons
    FOR SELECT USING (
        is_published = true AND (
            is_free = true OR
            course_id IN (
                SELECT course_id FROM course_enrollments 
                WHERE student_id = get_student_id() AND is_active = true
            )
        )
    );

-- Coaching centers can manage their course lessons
CREATE POLICY "Coaching centers can manage lessons" ON lessons
    FOR ALL USING (
        course_id IN (
            SELECT id FROM courses 
            WHERE coaching_center_id = get_user_coaching_center_id()
        )
    );

-- Assigned teachers can manage lessons
CREATE POLICY "Assigned teachers can manage lessons" ON lessons
    FOR ALL USING (is_teacher_assigned_to_course(course_id));

-- =============================================
-- LIVE CLASSES POLICIES
-- =============================================

-- Students can view live classes for enrolled courses
CREATE POLICY "Students can view live classes" ON live_classes
    FOR SELECT USING (
        course_id IN (
            SELECT course_id FROM course_enrollments 
            WHERE student_id = get_student_id() AND is_active = true
        ) OR course_id IS NULL  -- Public live classes
    );

-- Coaching centers can manage their live classes
CREATE POLICY "Coaching centers can manage live classes" ON live_classes
    FOR ALL USING (coaching_center_id = get_user_coaching_center_id());

-- Assigned teachers can manage their live classes
CREATE POLICY "Assigned teachers can manage live classes" ON live_classes
    FOR ALL USING (
        teacher_id IN (
            SELECT id FROM teachers WHERE user_id = auth.uid()
        )
    );

-- =============================================
-- TESTS POLICIES
-- =============================================

-- Students can view tests for enrolled courses
CREATE POLICY "Students can view tests" ON tests
    FOR SELECT USING (
        is_published = true AND
        course_id IN (
            SELECT course_id FROM course_enrollments 
            WHERE student_id = get_student_id() AND is_active = true
        )
    );

-- Coaching centers can manage tests
CREATE POLICY "Coaching centers can manage tests" ON tests
    FOR ALL USING (coaching_center_id = get_user_coaching_center_id());

-- Assigned teachers can manage tests
CREATE POLICY "Assigned teachers can manage tests" ON tests
    FOR ALL USING (
        teacher_id IN (
            SELECT id FROM teachers WHERE user_id = auth.uid()
        )
    );

-- =============================================
-- TEST QUESTIONS POLICIES
-- =============================================

-- Students can view test questions during tests
CREATE POLICY "Students can view test questions" ON test_questions
    FOR SELECT USING (
        test_id IN (
            SELECT id FROM tests 
            WHERE is_published = true AND
            course_id IN (
                SELECT course_id FROM course_enrollments 
                WHERE student_id = get_student_id() AND is_active = true
            )
        )
    );

-- Coaching centers can manage test questions
CREATE POLICY "Coaching centers can manage test questions" ON test_questions
    FOR ALL USING (
        test_id IN (
            SELECT id FROM tests 
            WHERE coaching_center_id = get_user_coaching_center_id()
        )
    );

-- Assigned teachers can manage test questions
CREATE POLICY "Assigned teachers can manage test questions" ON test_questions
    FOR ALL USING (
        test_id IN (
            SELECT t.id FROM tests t
            WHERE t.teacher_id IN (
                SELECT id FROM teachers WHERE user_id = auth.uid()
            )
        )
    );

-- =============================================
-- COURSE ENROLLMENTS POLICIES
-- =============================================

-- Students can view their enrollments
CREATE POLICY "Students can view their enrollments" ON course_enrollments
    FOR SELECT USING (student_id = get_student_id());

-- Students can insert their enrollments
CREATE POLICY "Students can insert their enrollments" ON course_enrollments
    FOR INSERT WITH CHECK (student_id = get_student_id());

-- Students can update their enrollments
CREATE POLICY "Students can update their enrollments" ON course_enrollments
    FOR UPDATE USING (student_id = get_student_id());

-- Coaching centers can view their course enrollments
CREATE POLICY "Coaching centers can view enrollments" ON course_enrollments
    FOR SELECT USING (
        course_id IN (
            SELECT id FROM courses 
            WHERE coaching_center_id = get_user_coaching_center_id()
        )
    );

-- =============================================
-- LESSON PROGRESS POLICIES
-- =============================================

-- Students can manage their lesson progress
CREATE POLICY "Students can manage lesson progress" ON lesson_progress
    FOR ALL USING (student_id = get_student_id());

-- =============================================
-- LIVE CLASS ENROLLMENTS POLICIES
-- =============================================

-- Students can manage their live class enrollments
CREATE POLICY "Students can manage live class enrollments" ON live_class_enrollments
    FOR ALL USING (student_id = get_student_id());

-- Coaching centers can view enrollments for their classes
CREATE POLICY "Coaching centers can view live class enrollments" ON live_class_enrollments
    FOR SELECT USING (
        live_class_id IN (
            SELECT id FROM live_classes 
            WHERE coaching_center_id = get_user_coaching_center_id()
        )
    );

-- =============================================
-- PAYMENTS POLICIES
-- =============================================

-- Students can view their payments
CREATE POLICY "Students can view their payments" ON payments
    FOR SELECT USING (student_id = get_student_id());

-- Students can insert their payments
CREATE POLICY "Students can insert their payments" ON payments
    FOR INSERT WITH CHECK (student_id = get_student_id());

-- Admins can view all payments
CREATE POLICY "Admins can view all payments" ON payments
    FOR SELECT USING (is_admin());

-- Coaching centers can view payments for their courses
CREATE POLICY "Coaching centers can view course payments" ON payments
    FOR SELECT USING (
        course_id IN (
            SELECT id FROM courses 
            WHERE coaching_center_id = get_user_coaching_center_id()
        )
    );

-- =============================================
-- REVIEWS POLICIES
-- =============================================

-- Students can manage their reviews
CREATE POLICY "Students can manage their reviews" ON reviews
    FOR ALL USING (student_id = get_student_id());

-- Public can view published reviews
CREATE POLICY "Public can view published reviews" ON reviews
    FOR SELECT USING (is_published = true);

-- Coaching centers can view reviews for their courses
CREATE POLICY "Coaching centers can view course reviews" ON reviews
    FOR SELECT USING (
        course_id IN (
            SELECT id FROM courses 
            WHERE coaching_center_id = get_user_coaching_center_id()
        )
    );

-- =============================================
-- APP CONFIG POLICIES
-- =============================================

-- Public can view active app config
CREATE POLICY "Public can view active app config" ON app_config
    FOR SELECT USING (is_active = true);

-- Admins can manage app config
CREATE POLICY "Admins can manage app config" ON app_config
    FOR ALL USING (is_admin());

-- =============================================
-- ANALYTICS POLICIES
-- =============================================

-- Users can insert their own analytics events
CREATE POLICY "Users can insert analytics events" ON analytics_events
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Admins can view all analytics
CREATE POLICY "Admins can view all analytics" ON analytics_events
    FOR SELECT USING (is_admin());

-- Coaching centers can view analytics for their content
CREATE POLICY "Coaching centers can view their analytics" ON analytics_events
    FOR SELECT USING (
        properties->>'course_id' IN (
            SELECT id::text FROM courses 
            WHERE coaching_center_id = get_user_coaching_center_id()
        )
    );

-- Students can view their learning analytics
CREATE POLICY "Students can view their learning analytics" ON learning_analytics
    FOR SELECT USING (student_id = get_student_id());

-- Students can insert their learning analytics
CREATE POLICY "Students can insert learning analytics" ON learning_analytics
    FOR INSERT WITH CHECK (student_id = get_student_id());

-- Students can update their learning analytics
CREATE POLICY "Students can update learning analytics" ON learning_analytics
    FOR UPDATE USING (student_id = get_student_id());

-- =============================================
-- AUDIT LOGS POLICIES
-- =============================================

-- Admins can view all audit logs
CREATE POLICY "Admins can view all audit logs" ON audit_logs
    FOR SELECT USING (is_admin());

-- Users can view their own audit logs
CREATE POLICY "Users can view their own audit logs" ON audit_logs
    FOR SELECT USING (user_id = auth.uid());

-- System can insert audit logs
CREATE POLICY "System can insert audit logs" ON audit_logs
    FOR INSERT WITH CHECK (true);

SELECT 'All RLS policies created successfully' AS status;

```

This comprehensive SQL schema provides[^1_1][^1_2][^1_3]:

**Key Features:**

- **Complete user management** with role-based access (student, teacher, admin, coaching center)
- **Course structure** with chapters and lessons
- **Live classes** with enrollment tracking
- **Payment processing** with multiple gateway support
- **Progress tracking** and analytics for students
- **Review and rating system**
- **Comprehensive audit logging**
- **Role-based security** with RLS policies

**Analytics Capabilities:**

- Student learning progress tracking
- Course performance metrics
- Payment and enrollment analytics
- User engagement tracking
- Audit trail for all changes

**Security Features:**

- Row Level Security (RLS) policies for all tables
- Coaching center approval workflow
- Faculty management by coaching centers
- Proper data isolation between organizations

**Scalability:**

- Comprehensive indexing strategy for performance[^1_4][^1_5]
- Optimized queries with proper foreign key relationships
- Analytics tables for reporting without impacting transactional performance[^1_6]

The schema supports all your requirements including coaching center registration approval, faculty management, student enrollment tracking, and comprehensive analytics while maintaining security and performance through proper indexing and RLS policies[^1_7][^1_8].

<div style="text-align: center">⁂</div>

[^1_1]: https://supabase.com/docs/guides/getting-started/tutorials/with-react

[^1_2]: https://supabase.com/docs/guides/auth/users

[^1_3]: https://vertabelo.com/blog/database-design-management-system/

[^1_4]: https://app.studyraid.com/en/read/8395/231624/implementing-database-indexing-strategies

[^1_5]: https://supabase.com/docs/guides/database/query-optimization

[^1_6]: https://www.tinybird.co/blog-posts/can-i-use-supabase-for-user-facing-analytics

[^1_7]: https://supabase.com/features/role-based-access-control

[^1_8]: https://www.permit.io/blog/how-to-implement-rbac-in-supabase

[^1_9]: https://www.youtube.com/watch?v=efNX5x7O0cY

[^1_10]: https://www.enfintechnologies.com/e-learning-app-development-trends-and-best-practices-a-comprehensive-guide/

[^1_11]: https://www.reddit.com/r/Supabase/comments/1g7fprk/workflow_for_registering_companies_that_need/

[^1_12]: https://supabase.com/features/logs-analytics

[^1_13]: https://supabase.com/features/reports-and-metrics

[^1_14]: https://supabase.com/docs/guides/local-development/seeding-your-database

[^1_15]: https://supabase.com/docs/guides/auth

[^1_16]: https://dev.to/dailydevtips1/adding-a-user-profile-to-our-supabase-user-3fph

[^1_17]: https://supabase.com

[^1_18]: https://supabase.com/docs/guides/database/overview

[^1_19]: https://supabase.com/database

[^1_20]: https://easternpeak.com/blog/elearning-mlearning-educational-app-development/

[^1_21]: https://shakuro.com/blog/e-learning-app-design-and-how-to-make-it-better

[^1_22]: https://supabase.com/docs/guides/database/postgres/custom-claims-and-role-based-access-control-rbac

[^1_23]: https://www.linkedin.com/learning/supabase-essential-training/access-control

[^1_24]: https://www.linkedin.com/posts/metadesign-solutions_supabase-tutorial-series-part-1-of-5-introduction-activity-7276868055803052032-sp2K

[^1_25]: https://supabase.com/features/ai-integrations

[^1_26]: https://clickhouse.com/blog/adding-real-time-analytics-to-a-supabase-application

[^1_27]: https://supabase.com/docs/guides/database/tables

[^1_28]: https://www.reddit.com/r/Supabase/comments/15pu5gn/how_do_you_organize_business_logic_with_sql_in/

[^1_29]: https://docs.lovable.dev/integrations/supabase

[^1_30]: https://cube.dev/blog/supabase-tutorial-fast-data-visualization-apps

[^1_31]: https://elearningindustry.com/best-practices-for-data-management-in-elearning

[^1_32]: https://www.sarasanalytics.com/blog/data-modeling-best-practices

[^1_33]: https://help.hcl-software.com/commerce/8.0.0/database/refs/rdb_datamodel_payment_index.html

[^1_34]: https://stackoverflow.com/questions/7261891/database-design-structure-for-storing-courses-chapters-topics-subtopics

[^1_35]: https://www.youtube.com/watch?v=yoCTIqthNRw

[^1_36]: https://gloriumtech.com/e-learning-app-development-a-complete-guide/

[^1_37]: https://bootstrapped.app/feature/how-to-build-user-authentication-registration-with-supabase

[^1_38]: https://www.youtube.com/watch?v=yAzRJTI1EJo

[^1_39]: https://uibakery.io/templates/supabase-admin

[^1_40]: https://dev.to/akkilah/how-to-implement-role-based-access-with-supabase-3a2

[^1_41]: https://github.com/KunalSalunkhe12/Student-Progress-Tracker

[^1_42]: https://www.coursera.org/learn/intro-to-supabase

[^1_43]: https://stormwindstudios.com/courses/supabase-crash-course

[^1_44]: https://www.reddit.com/r/Supabase/comments/1bo5jq1/how_to_break_down_seedsql_into_multiple_files/

[^1_45]: https://zone-www-dot-9obe9a1tk-supabase.vercel.app/docs/guides/storage

[^1_46]: https://stackoverflow.com/questions/1015364/worth-the-headache-to-organize-sql-files-by-application-subject

[^1_47]: https://supabase.com/docs/guides/storage/quickstart

