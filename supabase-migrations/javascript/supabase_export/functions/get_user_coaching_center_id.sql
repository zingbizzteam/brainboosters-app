-- Function: get_user_coaching_center_id
-- Generated: 2025-10-25T15:36:11.677Z

CREATE OR REPLACE FUNCTION public.get_user_coaching_center_id()
 RETURNS uuid
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
AS $function$
BEGIN
    RETURN (
        SELECT CASE
            WHEN up.user_type = 'coaching_center' THEN cc.id
            WHEN up.user_type = 'teacher' THEN t.coaching_center_id
            ELSE NULL
        END
        FROM user_profiles up
        LEFT JOIN coaching_centers cc ON cc.user_id = up.id
        LEFT JOIN teachers t ON t.user_id = up.id
        WHERE up.id = auth.uid()
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$function$
;

