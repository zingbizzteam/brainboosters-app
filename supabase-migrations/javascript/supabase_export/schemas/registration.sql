-- Table: registration
-- Generated: 2025-10-25T15:36:10.670Z

CREATE TABLE IF NOT EXISTS public.registration (
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  first_name text NOT NULL,
  last_name text,
  email character varying NOT NULL,
  phone_number numeric NOT NULL,
  address json NOT NULL,
  password character varying NOT NULL,
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  center_name text NOT NULL,
  approval_status USER-DEFINED NOT NULL DEFAULT 'pending'::approval_status
);

-- Constraints
ALTER TABLE public.registration ADD CONSTRAINT registration_email_key UNIQUE (email);
ALTER TABLE public.registration ADD CONSTRAINT registration_pkey PRIMARY KEY (id);

