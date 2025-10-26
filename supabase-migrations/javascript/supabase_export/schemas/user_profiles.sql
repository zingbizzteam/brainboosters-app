-- Table: user_profiles
-- Generated: 2025-10-25T15:36:11.320Z

CREATE TABLE IF NOT EXISTS public.user_profiles (
  id uuid NOT NULL,
  user_type character varying(20) NOT NULL,
  first_name character varying(100) NOT NULL,
  last_name character varying(100) NOT NULL,
  email character varying(255) NOT NULL,
  phone character varying(20),
  avatar_url text,
  date_of_birth date,
  gender character varying(10),
  address jsonb DEFAULT '{}'::jsonb,
  is_active boolean DEFAULT true,
  email_verified boolean DEFAULT false,
  phone_verified boolean DEFAULT false,
  onboarding_completed boolean DEFAULT false,
  preferences jsonb DEFAULT '{}'::jsonb,
  last_seen timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.user_profiles ADD CONSTRAINT user_profiles_id_fkey FOREIGN KEY (id) REFERENCES null(null);
ALTER TABLE public.user_profiles ADD CONSTRAINT user_profiles_id_key UNIQUE (id);
ALTER TABLE public.user_profiles ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (id);

