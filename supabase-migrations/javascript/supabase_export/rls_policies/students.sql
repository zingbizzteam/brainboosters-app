-- RLS Policies for: students
-- Generated: 2025-10-25T15:36:11.451Z

ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on students" ON public.students;
CREATE POLICY "admin policy on students"
  ON public.students
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "admin_manage_students" ON public.students;
CREATE POLICY "admin_manage_students"
  ON public.students
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "users_manage_own_student_profile" ON public.students;
CREATE POLICY "users_manage_own_student_profile"
  ON public.students
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.uid() = user_id))
  WITH CHECK ((auth.uid() = user_id))
;

