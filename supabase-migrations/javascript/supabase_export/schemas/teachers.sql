-- Table: teachers
-- Generated: 2025-10-25T15:36:11.036Z

CREATE TABLE IF NOT EXISTS public.teachers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  coaching_center_id uuid NOT NULL,
  employee_id character varying(50),
  title character varying(100),
  specializations ARRAY DEFAULT '{}'::text[],
  qualifications ARRAY,
  experience_years integer DEFAULT 0,
  bio text,
  hourly_rate numeric,
  rating numeric DEFAULT 0.0,
  total_reviews integer DEFAULT 0,
  total_courses integer DEFAULT 0,
  total_students_taught integer DEFAULT 0,
  is_verified boolean DEFAULT false,
  can_create_courses boolean DEFAULT true,
  can_conduct_live_classes boolean DEFAULT true,
  can_grade_assignments boolean DEFAULT true,
  status character varying(20) DEFAULT 'active'::character varying,
  joined_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.teachers ADD CONSTRAINT teachers_coaching_center_id_fkey FOREIGN KEY (coaching_center_id) REFERENCES coaching_centers(user_id);
ALTER TABLE public.teachers ADD CONSTRAINT teachers_pkey PRIMARY KEY (id);
ALTER TABLE public.teachers ADD CONSTRAINT teachers_user_id_fkey FOREIGN KEY (user_id) REFERENCES user_profiles(id);
ALTER TABLE public.teachers ADD CONSTRAINT teachers_user_id_key UNIQUE (user_id);
ALTER TABLE public.teachers ADD CONSTRAINT unique_employee_per_center UNIQUE (coaching_center_id);
ALTER TABLE public.teachers ADD CONSTRAINT unique_employee_per_center UNIQUE (coaching_center_id);
ALTER TABLE public.teachers ADD CONSTRAINT unique_employee_per_center UNIQUE (employee_id);
ALTER TABLE public.teachers ADD CONSTRAINT unique_employee_per_center UNIQUE (employee_id);

