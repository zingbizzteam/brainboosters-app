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

