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

