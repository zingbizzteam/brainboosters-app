-- RLS Policies for: reviews
-- Generated: 2025-10-25T15:36:11.450Z

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on reviews" ON public.reviews;
CREATE POLICY "admin policy on reviews"
  ON public.reviews
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.reviews;
CREATE POLICY "authenticated_user_policy"
  ON public.reviews
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

