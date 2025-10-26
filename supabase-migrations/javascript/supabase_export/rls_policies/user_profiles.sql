-- RLS Policies for: user_profiles
-- Generated: 2025-10-25T15:36:11.452Z

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated users can view see all users profile " ON public.user_profiles;
CREATE POLICY "Authenticated users can view see all users profile "
  ON public.user_profiles
  AS PERMISSIVE
  FOR SELECT
  TO {authenticated}
  USING (true)
;

DROP POLICY IF EXISTS "User can manage their own details" ON public.user_profiles;
CREATE POLICY "User can manage their own details"
  ON public.user_profiles
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.uid() = id))
  WITH CHECK (true)
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.user_profiles;
CREATE POLICY "authenticated_user_policy"
  ON public.user_profiles
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

