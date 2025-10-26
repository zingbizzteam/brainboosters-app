-- RLS Policies for: teachers
-- Generated: 2025-10-25T15:36:11.451Z

ALTER TABLE public.teachers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Coaching centers can manage their teachers" ON public.teachers;
CREATE POLICY "Coaching centers can manage their teachers"
  ON public.teachers
  AS PERMISSIVE
  FOR SELECT
  TO {authenticated}
  USING ((auth.uid() = coaching_center_id))
;

DROP POLICY IF EXISTS "admin" ON public.teachers;
CREATE POLICY "admin"
  ON public.teachers
  AS PERMISSIVE
  FOR SELECT
  TO {public}
  USING ((auth.uid() = '47288471-af42-4c23-be20-96a16c0a37c7'::uuid))
;

DROP POLICY IF EXISTS "admin policy on teachers" ON public.teachers;
CREATE POLICY "admin policy on teachers"
  ON public.teachers
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.teachers;
CREATE POLICY "authenticated_user_policy"
  ON public.teachers
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

DROP POLICY IF EXISTS "teacher can manage their own data" ON public.teachers;
CREATE POLICY "teacher can manage their own data"
  ON public.teachers
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.uid() = user_id))
;

