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

