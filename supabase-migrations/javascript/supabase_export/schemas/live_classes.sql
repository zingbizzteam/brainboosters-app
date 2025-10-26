-- Table: live_classes
-- Generated: 2025-10-25T15:36:10.325Z

CREATE TABLE IF NOT EXISTS public.live_classes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  coaching_center_id uuid,
  course_id uuid,
  chapter_id uuid,
  primary_teacher_id uuid,
  title character varying(300) NOT NULL,
  description text,
  agenda text,
  learning_objectives ARRAY DEFAULT '{}'::text[],
  scheduled_start timestamp with time zone NOT NULL,
  scheduled_end timestamp with time zone,
  actual_start timestamp with time zone,
  actual_end timestamp with time zone,
  timezone character varying(50) DEFAULT 'Asia/Kolkata'::character varying,
  max_participants integer DEFAULT 100,
  current_participants integer DEFAULT 0,
  auto_record boolean DEFAULT false,
  allow_chat boolean DEFAULT true,
  allow_qa boolean DEFAULT true,
  allow_screen_sharing boolean DEFAULT false,
  require_approval boolean DEFAULT false,
  meeting_platform character varying(20) DEFAULT 'zoom'::character varying,
  meeting_url text,
  meeting_id character varying(100),
  meeting_password character varying(100),
  dial_in_numbers jsonb DEFAULT '[]'::jsonb,
  price numeric DEFAULT 0.00,
  currency character varying(3) DEFAULT 'INR'::character varying,
  is_free boolean,
  thumbnail_url text,
  presentation_url text,
  resources jsonb DEFAULT '[]'::jsonb,
  status character varying(20) DEFAULT 'scheduled'::character varying,
  cancellation_reason text,
  recording_url text,
  recording_duration_minutes integer,
  recording_size_mb numeric,
  recording_available_until timestamp with time zone,
  total_registered integer DEFAULT 0,
  total_attended integer DEFAULT 0,
  average_attendance_duration_minutes numeric DEFAULT 0,
  engagement_score numeric DEFAULT 0.0,
  average_rating numeric DEFAULT 0.0,
  total_feedback_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.live_classes ADD CONSTRAINT live_classes_chapter_id_fkey FOREIGN KEY (chapter_id) REFERENCES chapters(id);
ALTER TABLE public.live_classes ADD CONSTRAINT live_classes_coaching_center_id_fkey FOREIGN KEY (coaching_center_id) REFERENCES coaching_centers(user_id);
ALTER TABLE public.live_classes ADD CONSTRAINT live_classes_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.live_classes ADD CONSTRAINT live_classes_pkey PRIMARY KEY (id);
ALTER TABLE public.live_classes ADD CONSTRAINT live_classes_primary_teacher_id_fkey FOREIGN KEY (primary_teacher_id) REFERENCES teachers(user_id);

