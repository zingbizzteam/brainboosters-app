-- RLS Policies for: lesson_progress
-- Generated: 2025-10-25T15:36:11.447Z

ALTER TABLE public.lesson_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on lesson_progress" ON public.lesson_progress;
CREATE POLICY "admin policy on lesson_progress"
  ON public.lesson_progress
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.lesson_progress;
CREATE POLICY "authenticated_user_policy"
  ON public.lesson_progress
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

