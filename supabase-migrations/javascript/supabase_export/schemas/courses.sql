-- Table: courses
-- Generated: 2025-10-25T15:36:09.926Z

CREATE TABLE IF NOT EXISTS public.courses (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  category_id uuid,
  title character varying(300) NOT NULL,
  slug character varying(300) NOT NULL,
  description text,
  short_description text,
  thumbnail_url text,
  trailer_video_url text,
  course_content_overview text,
  what_you_learn ARRAY DEFAULT '{}'::text[],
  course_includes jsonb DEFAULT '{}'::jsonb,
  target_audience ARRAY DEFAULT '{}'::text[],
  prerequisites ARRAY DEFAULT '{}'::text[],
  learning_outcomes ARRAY DEFAULT '{}'::text[],
  level character varying(20) DEFAULT 'beginner'::character varying,
  language character varying(10) DEFAULT 'en'::character varying,
  tags ARRAY DEFAULT '{}'::text[],
  price numeric DEFAULT 0.00,
  original_price numeric,
  currency character varying(3) DEFAULT 'INR'::character varying,
  is_free boolean,
  duration_hours numeric DEFAULT 0,
  total_lessons integer DEFAULT 0,
  total_chapters integer DEFAULT 0,
  total_assignments integer DEFAULT 0,
  total_quizzes integer DEFAULT 0,
  max_enrollments integer,
  enrollment_start_date timestamp with time zone,
  enrollment_deadline timestamp with time zone,
  course_start_date timestamp with time zone,
  course_end_date timestamp with time zone,
  is_published boolean DEFAULT false,
  is_featured boolean DEFAULT false,
  is_archived boolean DEFAULT false,
  publish_date timestamp with time zone,
  enrollment_count integer DEFAULT 0,
  completed_count integer DEFAULT 0,
  rating numeric DEFAULT 0.0,
  total_reviews integer DEFAULT 0,
  completion_rate numeric DEFAULT 0.0,
  view_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  last_updated timestamp with time zone DEFAULT now(),
  published_at timestamp with time zone,
  primary_teacher_id uuid,
  coaching_center_id uuid
);

-- Constraints
ALTER TABLE public.courses ADD CONSTRAINT courses_category_id_fkey FOREIGN KEY (category_id) REFERENCES course_categories(id);
ALTER TABLE public.courses ADD CONSTRAINT courses_coaching_center_id_fkey FOREIGN KEY (coaching_center_id) REFERENCES coaching_centers(user_id);
ALTER TABLE public.courses ADD CONSTRAINT courses_pkey PRIMARY KEY (id);
ALTER TABLE public.courses ADD CONSTRAINT courses_primary_teacher_id_fkey FOREIGN KEY (primary_teacher_id) REFERENCES user_profiles(id);
ALTER TABLE public.courses ADD CONSTRAINT courses_slug_key UNIQUE (slug);

