-- Complete Functions
-- Generated: 2025-10-25T15:36:11.674Z

-- Function: calculate_course_progress
-- Generated: 2025-10-25T15:36:11.674Z

CREATE OR REPLACE FUNCTION public.calculate_course_progress(p_student_id uuid, p_course_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

-- Function: cleanup_old_analytics_data
-- Generated: 2025-10-25T15:36:11.675Z

CREATE OR REPLACE FUNCTION public.cleanup_old_analytics_data(days_to_keep integer DEFAULT 90)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

-- Function: enroll_student_in_course
-- Generated: 2025-10-25T15:36:11.675Z

CREATE OR REPLACE FUNCTION public.enroll_student_in_course(p_student_id uuid, p_course_id uuid, p_payment_status character varying DEFAULT 'free'::character varying, p_enrollment_method character varying DEFAULT 'direct'::character varying)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

-- Function: generate_completion_certificate
-- Generated: 2025-10-25T15:36:11.676Z

CREATE OR REPLACE FUNCTION public.generate_completion_certificate(p_student_id uuid, p_course_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

-- Function: generate_student_id
-- Generated: 2025-10-25T15:36:11.676Z

CREATE OR REPLACE FUNCTION public.generate_student_id()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

-- Function: get_course_analytics
-- Generated: 2025-10-25T15:36:11.676Z

CREATE OR REPLACE FUNCTION public.get_course_analytics(p_course_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

-- Function: get_student_id
-- Generated: 2025-10-25T15:36:11.677Z

CREATE OR REPLACE FUNCTION public.get_student_id()
 RETURNS uuid
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
AS $function$
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
$function$
;

-- Function: get_user_coaching_center_id
-- Generated: 2025-10-25T15:36:11.677Z

CREATE OR REPLACE FUNCTION public.get_user_coaching_center_id()
 RETURNS uuid
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
AS $function$
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
$function$
;

-- Function: get_user_type
-- Generated: 2025-10-25T15:36:11.677Z

CREATE OR REPLACE FUNCTION public.get_user_type()
 RETURNS text
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
AS $function$
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
$function$
;

-- Function: handle_new_user
-- Generated: 2025-10-25T15:36:11.678Z

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_user_type TEXT;
  v_first_name TEXT;
  v_last_name TEXT;
BEGIN
  -- Extract user_type (default to 'student')
  v_user_type := COALESCE(NEW.raw_user_meta_data->>'user_type', 'student');
  
  -- Extract names
  v_first_name := COALESCE(
    NEW.raw_user_meta_data->>'first_name',
    SPLIT_PART(COALESCE(NEW.raw_user_meta_data->>'full_name', ''), ' ', 1)
  );
  
  v_last_name := COALESCE(
    NEW.raw_user_meta_data->>'last_name',
    SUBSTRING(COALESCE(NEW.raw_user_meta_data->>'full_name', '') 
      FROM POSITION(' ' IN COALESCE(NEW.raw_user_meta_data->>'full_name', '')) + 1)
  );

  -- Insert into user_profiles
  INSERT INTO public.user_profiles (
    id, user_type, email, first_name, last_name, 
    avatar_url, email_verified, is_active, 
    onboarding_completed, created_at, updated_at
  ) VALUES (
    NEW.id, v_user_type, NEW.email,
    NULLIF(TRIM(v_first_name), ''),
    NULLIF(TRIM(v_last_name), ''),
    NEW.raw_user_meta_data->>'avatar_url',
    NEW.email_confirmed_at IS NOT NULL,
    true, false, NOW(), NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    email_verified = EXCLUDED.email_verified,
    updated_at = NOW();

  -- If student, create student record
  IF v_user_type = 'student' THEN
    INSERT INTO public.students (user_id, created_at, updated_at)
    VALUES (NEW.id, NOW(), NOW())
    ON CONFLICT (user_id) DO NOTHING;
  END IF;

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Failed to create user profile: %', SQLERRM;
    RETURN NEW;
END;
$function$
;

-- Function: handle_user_email_confirmed
-- Generated: 2025-10-25T15:36:11.678Z

CREATE OR REPLACE FUNCTION public.handle_user_email_confirmed()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  IF NEW.email_confirmed_at IS NOT NULL AND OLD.email_confirmed_at IS NULL THEN
    UPDATE public.user_profiles
    SET email_verified = true, updated_at = NOW()
    WHERE id = NEW.id;
  END IF;
  RETURN NEW;
END;
$function$
;

-- Function: insert_sample_categories
-- Generated: 2025-10-25T15:36:11.678Z

CREATE OR REPLACE FUNCTION public.insert_sample_categories()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
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
$function$
;

-- Function: insert_sample_notification_templates
-- Generated: 2025-10-25T15:36:11.679Z

CREATE OR REPLACE FUNCTION public.insert_sample_notification_templates()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
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
$function$
;

-- Function: insert_sample_payment_methods
-- Generated: 2025-10-25T15:36:11.679Z

CREATE OR REPLACE FUNCTION public.insert_sample_payment_methods()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
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
$function$
;

-- Function: is_admin
-- Generated: 2025-10-25T15:36:11.679Z

CREATE OR REPLACE FUNCTION public.is_admin()
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM user_profiles 
        WHERE id = auth.uid() AND user_type = 'admin'
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$function$
;

-- Function: refresh_course_statistics
-- Generated: 2025-10-25T15:36:11.680Z

CREATE OR REPLACE FUNCTION public.refresh_course_statistics()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

-- Function: set_chapter_sort_order
-- Generated: 2025-10-25T15:36:11.680Z

CREATE OR REPLACE FUNCTION public.set_chapter_sort_order()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Only assign if sort_order is not explicitly given or is 0
  IF NEW.sort_order IS NULL OR NEW.sort_order = 0 THEN
    SELECT COALESCE(MAX(sort_order), 0) + 1
      INTO NEW.sort_order
      FROM public.chapters
      WHERE course_id = NEW.course_id;
  END IF;
  RETURN NEW;
END;
$function$
;

-- Function: update_coaching_center_stats
-- Generated: 2025-10-25T15:36:11.680Z

CREATE OR REPLACE FUNCTION public.update_coaching_center_stats()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

-- Function: update_course_stats
-- Generated: 2025-10-25T15:36:11.681Z

CREATE OR REPLACE FUNCTION public.update_course_stats()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

-- Function: update_learning_streak
-- Generated: 2025-10-25T15:36:11.681Z

CREATE OR REPLACE FUNCTION public.update_learning_streak(p_student_id uuid, p_timezone character varying DEFAULT 'Asia/Kolkata'::character varying)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

-- Function: update_lesson_progress
-- Generated: 2025-10-25T15:36:11.682Z

CREATE OR REPLACE FUNCTION public.update_lesson_progress(p_student_id uuid, p_lesson_id uuid, p_watch_time_seconds integer DEFAULT 0, p_completion_percentage numeric DEFAULT NULL::numeric, p_is_completed boolean DEFAULT NULL::boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

-- Function: update_review_vote_counts
-- Generated: 2025-10-25T15:36:11.682Z

CREATE OR REPLACE FUNCTION public.update_review_vote_counts()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

-- Function: update_updated_at
-- Generated: 2025-10-25T15:36:11.682Z

CREATE OR REPLACE FUNCTION public.update_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$
;

