-- Table: coaching_centers
-- Generated: 2025-10-25T15:36:09.596Z

CREATE TABLE IF NOT EXISTS public.coaching_centers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  center_name character varying(200) NOT NULL,
  center_code character varying(20) NOT NULL,
  description text,
  website_url text,
  logo_url text,
  contact_email character varying(255) NOT NULL,
  contact_phone character varying(20) NOT NULL,
  address jsonb NOT NULL DEFAULT '{}'::jsonb,
  registration_number character varying(100),
  tax_id character varying(50),
  approval_status character varying(20) DEFAULT 'pending'::character varying,
  approved_by uuid,
  approved_at timestamp with time zone,
  rejection_reason text,
  subscription_plan character varying(50) DEFAULT 'basic'::character varying,
  max_faculty_limit integer DEFAULT 10,
  max_courses_limit integer DEFAULT 50,
  max_students_limit integer DEFAULT 1000,
  is_active boolean DEFAULT true,
  total_courses integer DEFAULT 0,
  total_students integer DEFAULT 0,
  total_teachers integer DEFAULT 0,
  rating numeric DEFAULT 0.0,
  total_reviews integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.coaching_centers ADD CONSTRAINT coaching_centers_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES user_profiles(id);
ALTER TABLE public.coaching_centers ADD CONSTRAINT coaching_centers_center_code_key UNIQUE (center_code);
ALTER TABLE public.coaching_centers ADD CONSTRAINT coaching_centers_pkey PRIMARY KEY (id);
ALTER TABLE public.coaching_centers ADD CONSTRAINT coaching_centers_user_id_fkey FOREIGN KEY (user_id) REFERENCES user_profiles(id);
ALTER TABLE public.coaching_centers ADD CONSTRAINT coaching_centers_user_id_key UNIQUE (user_id);

