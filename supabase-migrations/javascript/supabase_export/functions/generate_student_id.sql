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

