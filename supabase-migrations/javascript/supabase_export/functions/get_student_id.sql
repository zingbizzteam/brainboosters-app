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

