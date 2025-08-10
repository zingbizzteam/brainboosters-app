-- =============================================
-- PRODUCTION-READY ROW LEVEL SECURITY
-- =============================================

-- Enable RLS on all core tables
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE coaching_centers ENABLE ROW LEVEL SECURITY;
ALTER TABLE teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE chapters ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignment_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE test_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE test_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE live_classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE live_class_registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_reports ENABLE ROW LEVEL SECURITY;

-- =============================================
-- OPTIMIZED RLS HELPER FUNCTIONS
-- =============================================

-- Get current user type (cached for performance)
CREATE OR REPLACE FUNCTION auth.get_user_type()
RETURNS TEXT AS $$
DECLARE
    user_type_cache TEXT;
BEGIN
    -- Try to get from cache first
    user_type_cache := current_setting('app.user_type', true);
    
    IF user_type_cache IS NOT NULL THEN
        RETURN user_type_cache;
    END IF;
    
    -- Get from database and cache
    SELECT up.user_type INTO user_type_cache
    FROM user_profiles up 
    WHERE up.id = auth.uid() AND up.is_active = true AND up.is_deleted = false;
    
    -- Cache the result for the session
    IF user_type_cache IS NOT NULL THEN
        PERFORM set_config('app.user_type', user_type_cache, false);
    END IF;
    
    RETURN COALESCE(user_type_cache, 'anonymous');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Get current user's coaching center ID (cached)
CREATE OR REPLACE FUNCTION auth.get_user_coaching_center_id()
RETURNS UUID AS $$
DECLARE
    center_id_cache UUID;
BEGIN
    -- Try cache first
    center_id_cache := current_setting('app.coaching_center_id', true)::UUID;
    
    IF center_id_cache IS NOT NULL THEN
        RETURN center_id_cache;
    END IF;
    
    -- Get from database based on user type
    CASE auth.get_user_type()
        WHEN 'coaching_center' THEN
            SELECT cc.id INTO center_id_cache
            FROM coaching_centers cc 
            WHERE cc.user_id = auth.uid() AND cc.is_active = true AND cc.is_deleted = false;
            
        WHEN 'teacher' THEN
            SELECT t.coaching_center_id INTO center_id_cache
            FROM teachers t 
            WHERE t.user_id = auth.uid() AND t.is_active = true AND t.is_deleted = false;
            
        ELSE
            center_id_cache := NULL;
    END CASE;
    
    -- Cache the result
    IF center_id_cache IS NOT NULL THEN
        PERFORM set_config('app.coaching_center_id', center_id_cache::TEXT, false);
    END IF;
    
    RETURN center_id_cache;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Check if user is admin
CREATE OR REPLACE FUNCTION auth.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN auth.get_user_type() = 'admin';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Check if user is student
CREATE OR REPLACE FUNCTION auth.is_student()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN auth.get_user_type() = 'student';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Check if user is teacher
CREATE OR REPLACE FUNCTION auth.is_teacher()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN auth.get_user_type() = 'teacher';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Check if user is coaching center owner
CREATE OR REPLACE FUNCTION auth.is_coaching_center()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN auth.get_user_type() = 'coaching_center';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- =============================================
-- USER PROFILES RLS POLICIES
-- =============================================

-- Users can view and edit their own profiles
CREATE POLICY "users_own_profile" ON user_profiles 
    FOR ALL USING (id = auth.uid());

-- Admins can access all profiles
CREATE POLICY "admins_all_profiles" ON user_profiles 
    FOR ALL USING (auth.is_admin());

-- Coaching centers can view profiles of their teachers and students (through enrollments)
CREATE POLICY "coaching_centers_view_related_profiles" ON user_profiles 
    FOR SELECT USING (
        auth.is_coaching_center() AND (
            -- Teachers of the coaching center
            id IN (
                SELECT t.user_id FROM teachers t 
                WHERE t.coaching_center_id = auth.get_user_coaching_center_id()
            ) OR
            -- Students enrolled in coaching center's courses
            id IN (
                SELECT s.user_id FROM students s
                JOIN course_enrollments ce ON s.id = ce.student_id
                JOIN courses c ON ce.course_id = c.id
                WHERE c.coaching_center_id = auth.get_user_coaching_center_id()
                AND ce.is_active = true
            )
        )
    );

-- =============================================
-- COACHING CENTERS RLS POLICIES
-- =============================================

-- Coaching centers can manage their own data
CREATE POLICY "coaching_centers_own_data" ON coaching_centers 
    FOR ALL USING (user_id = auth.uid());

-- Public can view approved coaching centers
CREATE POLICY "public_view_approved_centers" ON coaching_centers 
    FOR SELECT USING (
        approval_status = 'approved' AND is_active = true AND is_deleted = false
    );

-- Admins can access all coaching centers
CREATE POLICY "admins_all_coaching_centers" ON coaching_centers 
    FOR ALL USING (auth.is_admin());

-- =============================================
-- TEACHERS RLS POLICIES
-- =============================================

-- Teachers can manage their own data
CREATE POLICY "teachers_own_data" ON teachers 
    FOR ALL USING (user_id = auth.uid());

-- Coaching centers can manage their teachers
CREATE POLICY "coaching_centers_manage_teachers" ON teachers 
    FOR ALL USING (
        coaching_center_id = auth.get_user_coaching_center_id() AND 
        auth.is_coaching_center()
    );

-- Public can view active verified teachers
CREATE POLICY "public_view_teachers" ON teachers 
    FOR SELECT USING (
        is_verified = true AND is_active = true AND is_deleted = false
    );

-- Students can view teachers of courses they're enrolled in
CREATE POLICY "students_view_course_teachers" ON teachers 
    FOR SELECT USING (
        auth.is_student() AND
        id IN (
            SELECT c.primary_teacher_id 
            FROM courses c
            JOIN course_enrollments ce ON c.id = ce.course_id
            JOIN students s ON ce.student_id = s.id
            WHERE s.user_id = auth.uid() AND ce.is_active = true
        )
    );

-- Admins can access all teachers
CREATE POLICY "admins_all_teachers" ON teachers 
    FOR ALL USING (auth.is_admin());

-- =============================================
-- STUDENTS RLS POLICIES
-- =============================================

-- Students can manage their own data
CREATE POLICY "students_own_data" ON students 
    FOR ALL USING (user_id = auth.uid());

-- Teachers can view students enrolled in their courses
CREATE POLICY "teachers_view_enrolled_students" ON students 
    FOR SELECT USING (
        auth.is_teacher() AND
        id IN (
            SELECT ce.student_id 
            FROM course_enrollments ce
            JOIN courses c ON ce.course_id = c.id
            WHERE c.primary_teacher_id IN (
                SELECT t.id FROM teachers t WHERE t.user_id = auth.uid()
            ) AND ce.is_active = true
        )
    );

-- Coaching centers can view students enrolled in their courses
CREATE POLICY "coaching_centers_view_students" ON students 
    FOR SELECT USING (
        auth.is_coaching_center() AND
        id IN (
            SELECT ce.student_id 
            FROM course_enrollments ce
            JOIN courses c ON ce.course_id = c.id
            WHERE c.coaching_center_id = auth.get_user_coaching_center_id()
            AND ce.is_active = true
        )
    );

-- Admins can access all students
CREATE POLICY "admins_all_students" ON students 
    FOR ALL USING (auth.is_admin());

-- =============================================
-- COURSES RLS POLICIES
-- =============================================

-- Public can view published courses
CREATE POLICY "public_view_published_courses" ON courses 
    FOR SELECT USING (
        status = 'published' AND is_active = true AND is_deleted = false
    );

-- Coaching centers can manage their courses
CREATE POLICY "coaching_centers_manage_courses" ON courses 
    FOR ALL USING (
        coaching_center_id = auth.get_user_coaching_center_id() AND 
        (auth.is_coaching_center() OR auth.is_teacher())
    );

-- Teachers can manage courses they're assigned to
CREATE POLICY "teachers_manage_assigned_courses" ON courses 
    FOR ALL USING (
        auth.is_teacher() AND
        primary_teacher_id IN (
            SELECT t.id FROM teachers t WHERE t.user_id = auth.uid()
        )
    );

-- Students can view courses they're enrolled in (including unpublished for preview)
CREATE POLICY "students_view_enrolled_courses" ON courses 
    FOR SELECT USING (
        auth.is_student() AND
        id IN (
            SELECT ce.course_id 
            FROM course_enrollments ce
            JOIN students s ON ce.student_id = s.id
            WHERE s.user_id = auth.uid() AND ce.is_active = true
        )
    );

-- Admins can access all courses
CREATE POLICY "admins_all_courses" ON courses 
    FOR ALL USING (auth.is_admin());

-- =============================================
-- CHAPTERS AND LESSONS RLS POLICIES
-- =============================================

-- Same access as parent course
CREATE POLICY "chapters_follow_course_access" ON chapters 
    FOR ALL USING (
        course_id IN (
            SELECT c.id FROM courses c WHERE (
                -- Public published courses
                (c.status = 'published' AND c.is_active = true AND c.is_deleted = false) OR
                -- Coaching center/teacher courses
                (c.coaching_center_id = auth.get_user_coaching_center_id() AND 
                 (auth.is_coaching_center() OR auth.is_teacher())) OR
                -- Teacher assigned courses
                (auth.is_teacher() AND c.primary_teacher_id IN (
                    SELECT t.id FROM teachers t WHERE t.user_id = auth.uid()
                )) OR
                -- Student enrolled courses
                (auth.is_student() AND c.id IN (
                    SELECT ce.course_id FROM course_enrollments ce
                    JOIN students s ON ce.student_id = s.id
                    WHERE s.user_id = auth.uid() AND ce.is_active = true
                )) OR
                -- Admin access
                auth.is_admin()
            )
        )
    );

CREATE POLICY "lessons_follow_course_access" ON lessons 
    FOR ALL USING (
        course_id IN (
            SELECT c.id FROM courses c WHERE (
                -- Public published courses
                (c.status = 'published' AND c.is_active = true AND c.is_deleted = false) OR
                -- Coaching center/teacher courses
                (c.coaching_center_id = auth.get_user_coaching_center_id() AND 
                 (auth.is_coaching_center() OR auth.is_teacher())) OR
                -- Teacher assigned courses
                (auth.is_teacher() AND c.primary_teacher_id IN (
                    SELECT t.id FROM teachers t WHERE t.user_id = auth.uid()
                )) OR
                -- Student enrolled courses
                (auth.is_student() AND c.id IN (
                    SELECT ce.course_id FROM course_enrollments ce
                    JOIN students s ON ce.student_id = s.id
                    WHERE s.user_id = auth.uid() AND ce.is_active = true
                )) OR
                -- Admin access
                auth.is_admin()
            )
        )
    );

-- =============================================
-- ENROLLMENTS AND PROGRESS RLS POLICIES
-- =============================================

-- Students can manage their own enrollments
CREATE POLICY "students_own_enrollments" ON course_enrollments 
    FOR ALL USING (
        student_id IN (
            SELECT s.id FROM students s WHERE s.user_id = auth.uid()
        )
    );

-- Teachers and coaching centers can view enrollments for their courses
CREATE POLICY "teachers_view_course_enrollments" ON course_enrollments 
    FOR SELECT USING (
        course_id IN (
            SELECT c.id FROM courses c WHERE (
                (auth.is_teacher() AND c.primary_teacher_id IN (
                    SELECT t.id FROM teachers t WHERE t.user_id = auth.uid()
                )) OR
                (auth.is_coaching_center() AND c.coaching_center_id = auth.get_user_coaching_center_id())
            )
        )
    );

-- Students can manage their own lesson progress
CREATE POLICY "students_own_lesson_progress" ON lesson_progress 
    FOR ALL USING (
        student_id IN (
            SELECT s.id FROM students s WHERE s.user_id = auth.uid()
        )
    );

-- Teachers can view progress for their courses
CREATE POLICY "teachers_view_lesson_progress" ON lesson_progress 
    FOR SELECT USING (
        course_id IN (
            SELECT c.id FROM courses c WHERE (
                (auth.is_teacher() AND c.primary_teacher_id IN (
                    SELECT t.id FROM teachers t WHERE t.user_id = auth.uid()
                )) OR
                (auth.is_coaching_center() AND c.coaching_center_id = auth.get_user_coaching_center_id())
            )
        )
    );

-- =============================================
-- ASSIGNMENTS AND TESTS RLS POLICIES
-- =============================================

-- Teachers can manage assignments for their courses
CREATE POLICY "teachers_manage_assignments" ON assignments 
    FOR ALL USING (
        teacher_id IN (
            SELECT t.id FROM teachers t WHERE t.user_id = auth.uid()
        ) OR
        course_id IN (
            SELECT c.id FROM courses c 
            WHERE c.coaching_center_id = auth.get_user_coaching_center_id() 
            AND auth.is_coaching_center()
        )
    );

-- Students can view assignments for enrolled courses
CREATE POLICY "students_view_course_assignments" ON assignments 
    FOR SELECT USING (
        auth.is_student() AND
        course_id IN (
            SELECT ce.course_id 
            FROM course_enrollments ce
            JOIN students s ON ce.student_id = s.id
            WHERE s.user_id = auth.uid() AND ce.is_active = true
        )
    );

-- Students can manage their own assignment submissions
CREATE POLICY "students_own_assignment_submissions" ON assignment_submissions 
    FOR ALL USING (
        student_id IN (
            SELECT s.id FROM students s WHERE s.user_id = auth.uid()
        )
    );

-- Teachers can view/grade submissions for their assignments
CREATE POLICY "teachers_view_assignment_submissions" ON assignment_submissions 
    FOR ALL USING (
        assignment_id IN (
            SELECT a.id FROM assignments a
            JOIN teachers t ON a.teacher_id = t.id
            WHERE t.user_id = auth.uid()
        ) OR
        assignment_id IN (
            SELECT a.id FROM assignments a
            JOIN courses c ON a.course_id = c.id
            WHERE c.coaching_center_id = auth.get_user_coaching_center_id() 
            AND auth.is_coaching_center()
        )
    );

-- Similar policies for tests
CREATE POLICY "teachers_manage_tests" ON tests 
    FOR ALL USING (
        teacher_id IN (
            SELECT t.id FROM teachers t WHERE t.user_id = auth.uid()
        ) OR
        course_id IN (
            SELECT c.id FROM courses c 
            WHERE c.coaching_center_id = auth.get_user_coaching_center_id() 
            AND auth.is_coaching_center()
        )
    );

CREATE POLICY "students_view_course_tests" ON tests 
    FOR SELECT USING (
        auth.is_student() AND
        course_id IN (
            SELECT ce.course_id 
            FROM course_enrollments ce
            JOIN students s ON ce.student_id = s.id
            WHERE s.user_id = auth.uid() AND ce.is_active = true
        )
    );

CREATE POLICY "teachers_manage_test_questions" ON test_questions 
    FOR ALL USING (
        test_id IN (
            SELECT t.id FROM tests t
            JOIN teachers te ON t.teacher_id = te.id
            WHERE te.user_id = auth.uid()
        )
    );

CREATE POLICY "students_own_test_attempts" ON test_attempts 
    FOR ALL USING (
        student_id IN (
            SELECT s.id FROM students s WHERE s.user_id = auth.uid()
        )
    );

-- =============================================
-- LIVE CLASSES RLS POLICIES
-- =============================================

-- Teachers and coaching centers can manage their live classes
CREATE POLICY "teachers_manage_live_classes" ON live_classes 
    FOR ALL USING (
        teacher_id IN (
            SELECT t.id FROM teachers t WHERE t.user_id = auth.uid()
        ) OR
        coaching_center_id = auth.get_user_coaching_center_id()
    );

-- Public can view scheduled live classes
CREATE POLICY "public_view_scheduled_live_classes" ON live_classes 
    FOR SELECT USING (
        status = 'scheduled' AND is_active = true AND is_deleted = false
    );

-- Students can manage their live class registrations
CREATE POLICY "students_manage_live_registrations" ON live_class_registrations 
    FOR ALL USING (
        student_id IN (
            SELECT s.id FROM students s WHERE s.user_id = auth.uid()
        )
    );

-- Teachers can view registrations for their classes
CREATE POLICY "teachers_view_live_registrations" ON live_class_registrations 
    FOR SELECT USING (
        live_class_id IN (
            SELECT lc.id FROM live_classes lc
            JOIN teachers t ON lc.teacher_id = t.id
            WHERE t.user_id = auth.uid()
        ) OR
        live_class_id IN (
            SELECT lc.id FROM live_classes lc
            WHERE lc.coaching_center_id = auth.get_user_coaching_center_id()
            AND auth.is_coaching_center()
        )
    );

-- =============================================
-- PAYMENTS RLS POLICIES
-- =============================================

-- Students can view their own payments
CREATE POLICY "students_own_payments" ON payments 
    FOR SELECT USING (
        student_id IN (
            SELECT s.id FROM students s WHERE s.user_id = auth.uid()
        )
    );

-- Coaching centers can view payments for their courses/classes
CREATE POLICY "coaching_centers_view_payments" ON payments 
    FOR SELECT USING (
        auth.is_coaching_center() AND (
            (item_type = 'course' AND item_id IN (
                SELECT c.id FROM courses c 
                WHERE c.coaching_center_id = auth.get_user_coaching_center_id()
            )) OR
            (item_type = 'live_class' AND item_id IN (
                SELECT lc.id FROM live_classes lc 
                WHERE lc.coaching_center_id = auth.get_user_coaching_center_id()
            ))
        )
    );

-- =============================================
-- COUPONS RLS POLICIES
-- =============================================

-- Coaching centers can manage their own coupons
CREATE POLICY "coaching_centers_manage_coupons" ON coupons 
    FOR ALL USING (
        coaching_center_id = auth.get_user_coaching_center_id() AND 
        auth.is_coaching_center()
    );

-- Public can view active coupons (for validation)
CREATE POLICY "public_view_active_coupons" ON coupons 
    FOR SELECT USING (
        is_active = true AND 
        valid_from <= NOW() AND 
        valid_until >= NOW()
    );

-- =============================================
-- REPORTS RLS POLICIES
-- =============================================

-- Users can manage their own reports
CREATE POLICY "users_own_reports" ON custom_reports 
    FOR ALL USING (created_by = auth.uid());

-- Shared reports can be viewed by allowed users
CREATE POLICY "shared_reports_access" ON custom_reports 
    FOR SELECT USING (
        visibility = 'shared' AND (
            auth.uid() = ANY(shared_with_users) OR
            auth.get_user_type() = ANY(allowed_user_types)
        )
    );

-- Public reports can be viewed by anyone
CREATE POLICY "public_reports_access" ON custom_reports 
    FOR SELECT USING (visibility = 'public' AND is_active = true);

-- Coaching center reports can be viewed by coaching center users
CREATE POLICY "coaching_center_reports_access" ON custom_reports 
    FOR SELECT USING (
        visibility = 'shared' AND 
        coaching_center_id = auth.get_user_coaching_center_id() AND
        (auth.is_coaching_center() OR auth.is_teacher())
    );

-- =============================================
-- ADMIN OVERRIDE POLICIES (HIGHEST PRIORITY)
-- =============================================

-- Admins can access everything (applied to all tables)
DO $$
DECLARE
    table_name TEXT;
    tables TEXT[] := ARRAY[
        'user_profiles', 'coaching_centers', 'teachers', 'students', 
        'courses', 'chapters', 'lessons', 'course_enrollments', 
        'lesson_progress', 'assignments', 'assignment_submissions',
        'tests', 'test_questions', 'test_attempts', 'live_classes',
        'live_class_registrations', 'payments', 'coupons', 'custom_reports'
    ];
BEGIN
    FOREACH table_name IN ARRAY tables LOOP
        EXECUTE FORMAT('
            CREATE POLICY "admin_override_%s" ON %I 
                FOR ALL USING (auth.is_admin())
        ', table_name, table_name);
    END LOOP;
END $$;

-- =============================================
-- PERFORMANCE OPTIMIZATION FOR RLS
-- =============================================

-- Create function to set user context at session start (for caching)
CREATE OR REPLACE FUNCTION auth.set_user_context()
RETURNS VOID AS $$
DECLARE
    current_user_type TEXT;
    current_center_id UUID;
BEGIN
    -- Get and cache user type
    SELECT up.user_type INTO current_user_type
    FROM user_profiles up 
    WHERE up.id = auth.uid() AND up.is_active = true AND up.is_deleted = false;
    
    IF current_user_type IS NOT NULL THEN
        PERFORM set_config('app.user_type', current_user_type, false);
        
        -- Cache coaching center ID for relevant user types
        IF current_user_type IN ('coaching_center', 'teacher') THEN
            CASE current_user_type
                WHEN 'coaching_center' THEN
                    SELECT cc.id INTO current_center_id
                    FROM coaching_centers cc 
                    WHERE cc.user_id = auth.uid() AND cc.is_active = true AND cc.is_deleted = false;
                    
                WHEN 'teacher' THEN
                    SELECT t.coaching_center_id INTO current_center_id
                    FROM teachers t 
                    WHERE t.user_id = auth.uid() AND t.is_active = true AND t.is_deleted = false;
            END CASE;
            
            IF current_center_id IS NOT NULL THEN
                PERFORM set_config('app.coaching_center_id', current_center_id::TEXT, false);
            END IF;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Clear user context (call on logout)
CREATE OR REPLACE FUNCTION auth.clear_user_context()
RETURNS VOID AS $$
BEGIN
    PERFORM set_config('app.user_type', NULL, false);
    PERFORM set_config('app.coaching_center_id', NULL, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
