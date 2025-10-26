-- RLS Policies for: course_categories
-- Generated: 2025-10-25T15:36:11.445Z

ALTER TABLE public.course_categories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on course_categories" ON public.course_categories;
CREATE POLICY "admin policy on course_categories"
  ON public.course_categories
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.course_categories;
CREATE POLICY "authenticated_user_policy"
  ON public.course_categories
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

