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

