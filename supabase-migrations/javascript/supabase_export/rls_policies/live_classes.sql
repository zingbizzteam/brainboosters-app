-- RLS Policies for: live_classes
-- Generated: 2025-10-25T15:36:11.448Z

ALTER TABLE public.live_classes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Teachers can manage their own classes" ON public.live_classes;
CREATE POLICY "Teachers can manage their own classes"
  ON public.live_classes
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.uid() = primary_teacher_id))
  WITH CHECK (true)
;

DROP POLICY IF EXISTS "admin policy on live_classes" ON public.live_classes;
CREATE POLICY "admin policy on live_classes"
  ON public.live_classes
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.live_classes;
CREATE POLICY "authenticated_user_policy"
  ON public.live_classes
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

