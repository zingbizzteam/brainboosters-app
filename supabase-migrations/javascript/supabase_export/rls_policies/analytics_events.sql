-- RLS Policies for: analytics_events
-- Generated: 2025-10-25T15:36:11.443Z

ALTER TABLE public.analytics_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on analytics_events" ON public.analytics_events;
CREATE POLICY "admin policy on analytics_events"
  ON public.analytics_events
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.analytics_events;
CREATE POLICY "authenticated_user_policy"
  ON public.analytics_events
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

