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

