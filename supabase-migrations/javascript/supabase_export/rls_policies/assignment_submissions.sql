-- RLS Policies for: assignment_submissions
-- Generated: 2025-10-25T15:36:11.444Z

ALTER TABLE public.assignment_submissions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on assignment_submissions" ON public.assignment_submissions;
CREATE POLICY "admin policy on assignment_submissions"
  ON public.assignment_submissions
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.assignment_submissions;
CREATE POLICY "authenticated_user_policy"
  ON public.assignment_submissions
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

