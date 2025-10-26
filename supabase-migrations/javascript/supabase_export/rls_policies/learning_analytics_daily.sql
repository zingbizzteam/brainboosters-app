-- RLS Policies for: learning_analytics_daily
-- Generated: 2025-10-25T15:36:11.447Z

ALTER TABLE public.learning_analytics_daily ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on learning_analytics_daily" ON public.learning_analytics_daily;
CREATE POLICY "admin policy on learning_analytics_daily"
  ON public.learning_analytics_daily
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

