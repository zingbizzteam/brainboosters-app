-- RLS Policies for: review_reports
-- Generated: 2025-10-25T15:36:11.450Z

ALTER TABLE public.review_reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on review_reports" ON public.review_reports;
CREATE POLICY "admin policy on review_reports"
  ON public.review_reports
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

