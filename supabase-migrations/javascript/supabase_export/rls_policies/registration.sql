-- RLS Policies for: registration
-- Generated: 2025-10-25T15:36:11.450Z

ALTER TABLE public.registration ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admin policy" ON public.registration;
CREATE POLICY "Admin policy"
  ON public.registration
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "Allow new user to create a row in this table" ON public.registration;
CREATE POLICY "Allow new user to create a row in this table"
  ON public.registration
  AS PERMISSIVE
  FOR INSERT
  TO {anon}
  WITH CHECK (true)
;

