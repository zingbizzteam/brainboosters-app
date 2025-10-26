-- RLS Policies for: assignments
-- Generated: 2025-10-25T15:36:11.444Z

ALTER TABLE public.assignments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on assignments" ON public.assignments;
CREATE POLICY "admin policy on assignments"
  ON public.assignments
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.assignments;
CREATE POLICY "authenticated_user_policy"
  ON public.assignments
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

