-- =============================================
-- PRODUCTION-READY CORE TABLES
-- =============================================

-- Enhanced user profiles with production optimizations
CREATE TABLE user_profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('student', 'teacher', 'admin', 'coaching_center')),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    avatar_url TEXT,
    date_of_birth DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    
    -- Location with proper indexing
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(2) DEFAULT 'IN',
    pincode VARCHAR(10),
    coordinates POINT, -- For geo-queries
    
    -- Status fields
    is_active BOOLEAN DEFAULT true NOT NULL,
    is_deleted BOOLEAN DEFAULT false NOT NULL,
    is_verified BOOLEAN DEFAULT false NOT NULL,
    verification_level INTEGER DEFAULT 0 CHECK (verification_level >= 0 AND verification_level <= 3),
    
    -- Settings
    preferred_language VARCHAR(5) DEFAULT 'en' CHECK (preferred_language IN ('en', 'hi', 'ta', 'te', 'bn')),
    timezone VARCHAR(50) DEFAULT 'Asia/Kolkata',
    notification_preferences JSONB DEFAULT '{"email": true, "sms": false, "push": true}',
    
    -- Performance counters (denormalized for speed)
    login_count INTEGER DEFAULT 0,
    last_login_at TIMESTAMP WITH TIME ZONE,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE
) WITH (fillfactor = 90); -- Optimize for updates

-- Production-optimized indexes
CREATE INDEX CONCURRENTLY idx_user_profiles_type_active ON user_profiles(user_type) 
    WHERE is_active = true AND is_deleted = false;
CREATE INDEX CONCURRENTLY idx_user_profiles_location ON user_profiles(state, city) 
    WHERE is_deleted = false;
CREATE INDEX CONCURRENTLY idx_user_profiles_verification ON user_profiles(verification_level) 
    WHERE is_active = true;
CREATE INDEX CONCURRENTLY idx_user_profiles_last_login ON user_profiles(last_login_at DESC) 
    WHERE is_active = true;
-- Spatial index for location-based queries
CREATE INDEX CONCURRENTLY idx_user_profiles_coordinates ON user_profiles USING GIST(coordinates) 
    WHERE coordinates IS NOT NULL;

-- =============================================
-- COACHING CENTERS (PRODUCTION READY)
-- =============================================

CREATE TABLE coaching_centers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES user_profiles(id) ON DELETE RESTRICT UNIQUE,
    center_name VARCHAR(200) NOT NULL,
    center_code VARCHAR(20) UNIQUE NOT NULL,
    
    -- Contact and business info
    contact_email VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(20) NOT NULL,
    website_url TEXT,
    
    -- Structured address for better queries
    address_line_1 TEXT NOT NULL,
    address_line_2 TEXT,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    coordinates POINT, -- For nearby searches
    
    -- Business details
    registration_number VARCHAR(100),
    tax_id VARCHAR(50),
    business_type VARCHAR(50) DEFAULT 'coaching_center',
    
    -- Status and approval
    approval_status VARCHAR(20) DEFAULT 'pending' CHECK (approval_status IN ('pending', 'approved', 'rejected', 'suspended')),
    approved_by UUID REFERENCES user_profiles(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    
    -- Subscription and limits
    subscription_plan VARCHAR(20) DEFAULT 'basic' CHECK (subscription_plan IN ('basic', 'premium', 'enterprise')),
    subscription_expires_at TIMESTAMP WITH TIME ZONE,
    max_teachers INTEGER DEFAULT 5 CHECK (max_teachers > 0),
    max_courses INTEGER DEFAULT 20 CHECK (max_courses > 0),
    max_students INTEGER DEFAULT 500 CHECK (max_students > 0),
    
    -- Real-time counters (updated by background jobs)
    active_teachers INTEGER DEFAULT 0,
    published_courses INTEGER DEFAULT 0,
    total_students INTEGER DEFAULT 0,
    total_revenue DECIMAL(15,2) DEFAULT 0.00,
    
    -- Performance metrics
    average_rating DECIMAL(3,2) DEFAULT 0.0,
    total_reviews INTEGER DEFAULT 0,
    
    -- Status
    is_active BOOLEAN DEFAULT true NOT NULL,
    is_deleted BOOLEAN DEFAULT false NOT NULL,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE
) WITH (fillfactor = 85);

-- Production indexes for coaching centers
CREATE INDEX CONCURRENTLY idx_coaching_centers_approval_active ON coaching_centers(approval_status) 
    WHERE is_deleted = false;
CREATE INDEX CONCURRENTLY idx_coaching_centers_location ON coaching_centers(state, city) 
    WHERE is_active = true;
CREATE UNIQUE INDEX CONCURRENTLY idx_coaching_centers_code_active ON coaching_centers(center_code) 
    WHERE is_deleted = false;
CREATE INDEX CONCURRENTLY idx_coaching_centers_subscription ON coaching_centers(subscription_plan, subscription_expires_at) 
    WHERE is_active = true;
CREATE INDEX CONCURRENTLY idx_coaching_centers_coordinates ON coaching_centers USING GIST(coordinates) 
    WHERE coordinates IS NOT NULL;

-- =============================================
-- TEACHERS (PRODUCTION OPTIMIZED)
-- =============================================

CREATE TABLE teachers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES user_profiles(id) ON DELETE RESTRICT UNIQUE,
    coaching_center_id UUID REFERENCES coaching_centers(id) ON DELETE RESTRICT,
    
    employee_id VARCHAR(50),
    primary_subject VARCHAR(100) NOT NULL,
    secondary_subjects TEXT[], -- Array for multiple subjects
    experience_years INTEGER DEFAULT 0 CHECK (experience_years >= 0),
    qualifications JSONB DEFAULT '[]',
    bio TEXT,
    
    -- Teaching capabilities
    can_create_courses BOOLEAN DEFAULT true,
    can_conduct_live_classes BOOLEAN DEFAULT true,
    max_students_per_class INTEGER DEFAULT 50,
    
    -- Performance metrics (updated by background jobs)
    total_courses INTEGER DEFAULT 0,
    active_courses INTEGER DEFAULT 0,
    total_students INTEGER DEFAULT 0,
    total_revenue DECIMAL(12,2) DEFAULT 0.00,
    average_rating DECIMAL(3,2) DEFAULT 0.0,
    total_reviews INTEGER DEFAULT 0,
    
    -- Status and verification
    is_verified BOOLEAN DEFAULT false,
    verification_documents JSONB DEFAULT '[]',
    background_check_status VARCHAR(20) DEFAULT 'pending',
    
    -- Activity tracking
    last_course_created_at TIMESTAMP WITH TIME ZONE,
    last_class_conducted_at TIMESTAMP WITH TIME ZONE,
    
    -- Status
    is_active BOOLEAN DEFAULT true NOT NULL,
    is_deleted BOOLEAN DEFAULT false NOT NULL,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE
) WITH (fillfactor = 85);

-- Production indexes for teachers
CREATE INDEX CONCURRENTLY idx_teachers_center_active ON teachers(coaching_center_id) 
    WHERE is_active = true AND is_deleted = false;
CREATE INDEX CONCURRENTLY idx_teachers_subject ON teachers(primary_subject) 
    WHERE is_active = true;
CREATE INDEX CONCURRENTLY idx_teachers_rating ON teachers(average_rating DESC) 
    WHERE is_active = true AND is_verified = true;
CREATE INDEX CONCURRENTLY idx_teachers_subjects_gin ON teachers USING GIN(secondary_subjects) 
    WHERE is_active = true;

-- =============================================
-- STUDENTS (PRODUCTION OPTIMIZED)
-- =============================================

CREATE TABLE students (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES user_profiles(id) ON DELETE RESTRICT UNIQUE,
    student_id VARCHAR(20) UNIQUE NOT NULL,
    
    -- Academic information
    grade_level VARCHAR(20) NOT NULL CHECK (grade_level IN (
        'class_1', 'class_2', 'class_3', 'class_4', 'class_5',
        'class_6', 'class_7', 'class_8', 'class_9', 'class_10',
        'class_11', 'class_12', 'undergraduate', 'postgraduate', 'other'
    )),
    education_board VARCHAR(20) CHECK (education_board IN ('cbse', 'icse', 'state_board', 'other')),
    primary_subject VARCHAR(50),
    interests TEXT[], -- Array of interests
    
    -- Guardian information
    guardian_name VARCHAR(200),
    guardian_phone VARCHAR(20),
    guardian_email VARCHAR(255),
    guardian_relationship VARCHAR(20) DEFAULT 'parent',
    
    -- Learning preferences
    preferred_learning_style VARCHAR(20) CHECK (preferred_learning_style IN ('visual', 'auditory', 'kinesthetic', 'mixed')),
    study_time_preference VARCHAR(20) DEFAULT 'evening',
    daily_study_goal_minutes INTEGER DEFAULT 60,
    
    -- Performance metrics (updated by background jobs)
    courses_enrolled INTEGER DEFAULT 0 CHECK (courses_enrolled >= 0),
    courses_completed INTEGER DEFAULT 0 CHECK (courses_completed >= 0),
    total_study_hours DECIMAL(8,2) DEFAULT 0.0 CHECK (total_study_hours >= 0),
    current_streak INTEGER DEFAULT 0 CHECK (current_streak >= 0),
    longest_streak INTEGER DEFAULT 0,
    total_points INTEGER DEFAULT 0 CHECK (total_points >= 0),
    current_level INTEGER DEFAULT 1 CHECK (current_level >= 1),
    
    -- Achievements (stored as JSONB for flexibility)
    badges JSONB DEFAULT '[]',
    achievements JSONB DEFAULT '{}',
    certificates JSONB DEFAULT '[]',
    
    -- Activity tracking
    last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_course_enrolled_at TIMESTAMP WITH TIME ZONE,
    last_lesson_completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Status
    is_active BOOLEAN DEFAULT true NOT NULL,
    is_deleted BOOLEAN DEFAULT false NOT NULL,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT valid_courses_completed CHECK (courses_completed <= courses_enrolled),
    CONSTRAINT valid_streak CHECK (longest_streak >= current_streak)
) WITH (fillfactor = 80); -- Students update frequently

-- Production indexes for students
CREATE INDEX CONCURRENTLY idx_students_grade_board ON students(grade_level, education_board) 
    WHERE is_active = true;
CREATE INDEX CONCURRENTLY idx_students_activity ON students(last_activity_at DESC) 
    WHERE is_active = true;
CREATE UNIQUE INDEX CONCURRENTLY idx_students_student_id ON students(student_id) 
    WHERE is_deleted = false;
CREATE INDEX CONCURRENTLY idx_students_performance ON students(total_points DESC, current_level DESC) 
    WHERE is_active = true;
CREATE INDEX CONCURRENTLY idx_students_interests_gin ON students USING GIN(interests) 
    WHERE is_active = true;
CREATE INDEX CONCURRENTLY idx_students_badges_gin ON students USING GIN(badges) 
    WHERE is_active = true;

-- =============================================
-- PRODUCTION TRIGGERS AND FUNCTIONS
-- =============================================

-- Enhanced student ID generation with collision handling
CREATE OR REPLACE FUNCTION generate_student_id()
RETURNS TRIGGER AS $$
DECLARE
    new_id VARCHAR(20);
    year_suffix VARCHAR(2);
    attempt INTEGER := 0;
    max_attempts INTEGER := 100;
BEGIN
    IF NEW.student_id IS NOT NULL THEN
        RETURN NEW;
    END IF;
    
    year_suffix := RIGHT(EXTRACT(YEAR FROM NOW())::TEXT, 2);
    
    LOOP
        new_id := 'ST' || year_suffix || LPAD((RANDOM() * 999999)::INTEGER::TEXT, 6, '0');
        
        -- Check if ID already exists
        IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = new_id AND is_deleted = false) THEN
            NEW.student_id := new_id;
            EXIT;
        END IF;
        
        attempt := attempt + 1;
        IF attempt >= max_attempts THEN
            RAISE EXCEPTION 'Could not generate unique student ID after % attempts', max_attempts;
        END IF;
    END LOOP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- User profile creation with enhanced error handling
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER AS $$
DECLARE
    profile_type TEXT;
    first_name TEXT;
    last_name TEXT;
BEGIN
    -- Extract metadata safely
    profile_type := COALESCE(NEW.raw_user_meta_data->>'user_type', 'student');
    first_name := COALESCE(NEW.raw_user_meta_data->>'first_name', 'User');
    last_name := COALESCE(NEW.raw_user_meta_data->>'last_name', '');
    
    -- Validate and sanitize user type
    IF profile_type NOT IN ('student', 'teacher', 'admin', 'coaching_center') THEN
        profile_type := 'student';
    END IF;
    
    -- Create profile with proper error handling
    INSERT INTO user_profiles (
        id, user_type, first_name, last_name,
        preferred_language, timezone, login_count
    ) VALUES (
        NEW.id, profile_type, first_name, last_name,
        COALESCE(NEW.raw_user_meta_data->>'language', 'en'),
        COALESCE(NEW.raw_user_meta_data->>'timezone', 'Asia/Kolkata'),
        1
    );
    
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't fail user creation
        INSERT INTO audit.system_logs (table_name, operation, new_values, changed_at)
        VALUES ('user_profiles', 'ERROR', 
                jsonb_build_object('error', SQLERRM, 'user_id', NEW.id, 'sqlstate', SQLSTATE), 
                NOW());
        
        -- Create minimal profile to prevent auth issues
        INSERT INTO user_profiles (id, user_type, first_name, last_name)
        VALUES (NEW.id, 'student', 'User', '')
        ON CONFLICT (id) DO NOTHING;
        
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply triggers
CREATE TRIGGER trg_generate_student_id
    BEFORE INSERT ON students
    FOR EACH ROW EXECUTE FUNCTION generate_student_id();

CREATE TRIGGER trg_create_user_profile
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION create_user_profile();

-- Apply audit triggers (production-safe)
CREATE TRIGGER trg_audit_user_profiles AFTER INSERT OR UPDATE OR DELETE ON user_profiles 
    FOR EACH ROW EXECUTE FUNCTION audit.log_changes();
CREATE TRIGGER trg_audit_coaching_centers AFTER INSERT OR UPDATE OR DELETE ON coaching_centers 
    FOR EACH ROW EXECUTE FUNCTION audit.log_changes();
CREATE TRIGGER trg_audit_teachers AFTER INSERT OR UPDATE OR DELETE ON teachers 
    FOR EACH ROW EXECUTE FUNCTION audit.log_changes();
CREATE TRIGGER trg_audit_students AFTER INSERT OR UPDATE OR DELETE ON students 
    FOR EACH ROW EXECUTE FUNCTION audit.log_changes();

-- Apply update triggers
CREATE TRIGGER trg_updated_at_user_profiles BEFORE UPDATE ON user_profiles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_updated_at_coaching_centers BEFORE UPDATE ON coaching_centers 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_updated_at_teachers BEFORE UPDATE ON teachers 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_updated_at_students BEFORE UPDATE ON students 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
