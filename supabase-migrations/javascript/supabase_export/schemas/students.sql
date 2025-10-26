-- Table: students
-- Generated: 2025-10-25T15:36:10.957Z

CREATE TABLE IF NOT EXISTS public.students (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  student_id character varying(50) NOT NULL,
  grade_level character varying(50),
  education_board character varying(50),
  primary_interest character varying(100),
  secondary_interests ARRAY DEFAULT '{}'::text[],
  state character varying(100),
  city character varying(100),
  pincode character varying(10),
  preferred_language character varying(10) DEFAULT 'en'::character varying,
  other_languages ARRAY DEFAULT '{}'::text[],
  school_name character varying(200),
  institution_type character varying(50),
  parent_name character varying(200),
  parent_phone character varying(20),
  parent_email character varying(255),
  guardian_relationship character varying(50) DEFAULT 'parent'::character varying,
  learning_goals ARRAY DEFAULT '{}'::text[],
  preferred_learning_style character varying(50),
  competitive_exams ARRAY DEFAULT '{}'::text[],
  target_exam_year integer,
  timezone character varying(50) DEFAULT 'Asia/Kolkata'::character varying,
  total_courses_enrolled integer DEFAULT 0,
  total_courses_completed integer DEFAULT 0,
  total_hours_learned numeric DEFAULT 0.0,
  current_streak_days integer DEFAULT 0,
  longest_streak_days integer DEFAULT 0,
  total_points integer DEFAULT 0,
  level integer DEFAULT 1,
  badges jsonb DEFAULT '[]'::jsonb,
  achievements jsonb DEFAULT '{}'::jsonb,
  daily_study_goal_minutes integer DEFAULT 60,
  preferred_study_time character varying(20) DEFAULT 'evening'::character varying,
  is_active boolean DEFAULT true,
  is_verified boolean DEFAULT false,
  verification_method character varying(50),
  subscription_status character varying(20) DEFAULT 'free'::character varying,
  subscription_expires_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  last_login_date date,
  last_streak_update_date date,
  profile_completed_at timestamp with time zone
);

-- Constraints
ALTER TABLE public.students ADD CONSTRAINT students_pkey PRIMARY KEY (id);
ALTER TABLE public.students ADD CONSTRAINT students_student_id_key UNIQUE (student_id);
ALTER TABLE public.students ADD CONSTRAINT students_user_id_fkey FOREIGN KEY (user_id) REFERENCES user_profiles(id);
ALTER TABLE public.students ADD CONSTRAINT students_user_id_key UNIQUE (user_id);

