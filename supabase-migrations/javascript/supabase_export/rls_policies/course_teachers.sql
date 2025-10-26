-- RLS Policies for: course_teachers
-- Generated: 2025-10-25T15:36:11.446Z

ALTER TABLE public.course_teachers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on course_teachers" ON public.course_teachers;
CREATE POLICY "admin policy on course_teachers"
  ON public.course_teachers
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.course_teachers;
CREATE POLICY "authenticated_user_policy"
  ON public.course_teachers
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

