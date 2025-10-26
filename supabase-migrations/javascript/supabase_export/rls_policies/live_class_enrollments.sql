-- RLS Policies for: live_class_enrollments
-- Generated: 2025-10-25T15:36:11.448Z

ALTER TABLE public.live_class_enrollments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on live_class_enrollments" ON public.live_class_enrollments;
CREATE POLICY "admin policy on live_class_enrollments"
  ON public.live_class_enrollments
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.live_class_enrollments;
CREATE POLICY "authenticated_user_policy"
  ON public.live_class_enrollments
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

