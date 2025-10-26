-- RLS Policies for: notification_templates
-- Generated: 2025-10-25T15:36:11.448Z

ALTER TABLE public.notification_templates ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on notification_templates" ON public.notification_templates;
CREATE POLICY "admin policy on notification_templates"
  ON public.notification_templates
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

