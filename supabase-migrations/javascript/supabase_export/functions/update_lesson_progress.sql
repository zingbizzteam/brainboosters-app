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

