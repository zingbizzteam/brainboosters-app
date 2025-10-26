-- Table: reviews
-- Generated: 2025-10-25T15:36:10.875Z

CREATE TABLE IF NOT EXISTS public.reviews (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL,
  course_id uuid,
  teacher_id uuid,
  live_class_id uuid,
  coaching_center_id uuid,
  review_type character varying(20) NOT NULL,
  overall_rating numeric NOT NULL,
  content_rating numeric,
  instructor_rating numeric,
  value_rating numeric,
  difficulty_rating numeric,
  title character varying(200),
  review_text text,
  pros text,
  cons text,
  is_verified_purchase boolean DEFAULT false,
  completed_percentage numeric DEFAULT 0,
  is_published boolean DEFAULT true,
  is_featured boolean DEFAULT false,
  moderation_status character varying(20) DEFAULT 'approved'::character varying,
  moderation_reason text,
  moderated_by uuid,
  moderated_at timestamp with time zone,
  helpful_votes integer DEFAULT 0,
  not_helpful_votes integer DEFAULT 0,
  total_votes integer,
  helpfulness_score numeric DEFAULT 0.0,
  report_count integer DEFAULT 0,
  last_reported_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.reviews ADD CONSTRAINT reviews_coaching_center_id_fkey FOREIGN KEY (coaching_center_id) REFERENCES coaching_centers(user_id);
ALTER TABLE public.reviews ADD CONSTRAINT reviews_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.reviews ADD CONSTRAINT reviews_live_class_id_fkey FOREIGN KEY (live_class_id) REFERENCES live_classes(id);
ALTER TABLE public.reviews ADD CONSTRAINT reviews_moderated_by_fkey FOREIGN KEY (moderated_by) REFERENCES user_profiles(id);
ALTER TABLE public.reviews ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);
ALTER TABLE public.reviews ADD CONSTRAINT reviews_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id);
ALTER TABLE public.reviews ADD CONSTRAINT reviews_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES teachers(user_id);

