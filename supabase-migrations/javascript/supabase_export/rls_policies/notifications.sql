-- RLS Policies for: notifications
-- Generated: 2025-10-25T15:36:11.448Z

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on notifications" ON public.notifications;
CREATE POLICY "admin policy on notifications"
  ON public.notifications
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.notifications;
CREATE POLICY "authenticated_user_policy"
  ON public.notifications
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

