-- RLS Policies for: courses
-- Generated: 2025-10-25T15:36:11.446Z

ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow teacher to manage their own courses" ON public.courses;
CREATE POLICY "Allow teacher to manage their own courses"
  ON public.courses
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.uid() = primary_teacher_id))
;

DROP POLICY IF EXISTS "Coaching centers can manage their courses" ON public.courses;
CREATE POLICY "Coaching centers can manage their courses"
  ON public.courses
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.uid() = coaching_center_id))
  WITH CHECK ((auth.uid() = coaching_center_id))
;

DROP POLICY IF EXISTS "admin policy" ON public.courses;
CREATE POLICY "admin policy"
  ON public.courses
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((auth.uid() = '47288471-af42-4c23-be20-96a16c0a37c7'::uuid))
  WITH CHECK ((auth.uid() = '47288471-af42-4c23-be20-96a16c0a37c7'::uuid))
;

DROP POLICY IF EXISTS "admin policy on courses" ON public.courses;
CREATE POLICY "admin policy on courses"
  ON public.courses
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

