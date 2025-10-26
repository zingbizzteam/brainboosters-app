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

