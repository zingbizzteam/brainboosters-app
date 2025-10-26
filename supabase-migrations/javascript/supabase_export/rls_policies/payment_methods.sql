-- RLS Policies for: payment_methods
-- Generated: 2025-10-25T15:36:11.449Z

ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on payment_methods" ON public.payment_methods;
CREATE POLICY "admin policy on payment_methods"
  ON public.payment_methods
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

