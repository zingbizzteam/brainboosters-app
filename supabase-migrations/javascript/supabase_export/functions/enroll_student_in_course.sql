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

