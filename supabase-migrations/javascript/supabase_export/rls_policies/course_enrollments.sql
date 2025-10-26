-- RLS Policies for: course_enrollments
-- Generated: 2025-10-25T15:36:11.446Z

ALTER TABLE public.course_enrollments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Coaching centers can read their enrollments" ON public.course_enrollments;
CREATE POLICY "Coaching centers can read their enrollments"
  ON public.course_enrollments
  AS PERMISSIVE
  FOR SELECT
  TO {authenticated}
  USING ((auth.uid() = coaching_center_id))
;

DROP POLICY IF EXISTS "admin policy" ON public.course_enrollments;
CREATE POLICY "admin policy"
  ON public.course_enrollments
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((auth.uid() = '47288471-af42-4c23-be20-96a16c0a37c7'::uuid))
  WITH CHECK ((auth.uid() = '47288471-af42-4c23-be20-96a16c0a37c7'::uuid))
;

DROP POLICY IF EXISTS "admin policy on course_enrollments" ON public.course_enrollments;
CREATE POLICY "admin policy on course_enrollments"
  ON public.course_enrollments
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.course_enrollments;
CREATE POLICY "authenticated_user_policy"
  ON public.course_enrollments
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

DROP POLICY IF EXISTS "teacher can view the enorollments for their course" ON public.course_enrollments;
CREATE POLICY "teacher can view the enorollments for their course"
  ON public.course_enrollments
  AS PERMISSIVE
  FOR SELECT
  TO {authenticated}
  USING ((auth.uid() = teacher_id))
;

