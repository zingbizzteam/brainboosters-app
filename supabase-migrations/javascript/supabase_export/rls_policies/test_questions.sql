-- RLS Policies for: test_questions
-- Generated: 2025-10-25T15:36:11.451Z

ALTER TABLE public.test_questions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on test_questions" ON public.test_questions;
CREATE POLICY "admin policy on test_questions"
  ON public.test_questions
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.test_questions;
CREATE POLICY "authenticated_user_policy"
  ON public.test_questions
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

