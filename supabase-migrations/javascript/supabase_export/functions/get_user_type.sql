-- Function: get_user_type
-- Generated: 2025-10-25T15:36:11.677Z

CREATE OR REPLACE FUNCTION public.get_user_type()
 RETURNS text
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
AS $function$
BEGIN
    RETURN COALESCE((
        SELECT user_type
        FROM user_profiles
        WHERE id = auth.uid()
    ), 'anonymous');
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'anonymous';
END;
$function$
;

