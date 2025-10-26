-- Table: live_class_enrollments
-- Generated: 2025-10-25T15:36:10.250Z

CREATE TABLE IF NOT EXISTS public.live_class_enrollments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL,
  live_class_id uuid NOT NULL,
  enrolled_at timestamp with time zone DEFAULT now(),
  enrollment_source character varying(20) DEFAULT 'direct'::character varying,
  joined_at timestamp with time zone,
  left_at timestamp with time zone,
  attendance_duration_minutes integer DEFAULT 0,
  attended boolean DEFAULT false,
  attendance_percentage numeric DEFAULT 0.0,
  questions_asked integer DEFAULT 0,
  chat_messages_sent integer DEFAULT 0,
  polls_participated integer DEFAULT 0,
  engagement_score numeric DEFAULT 0.0,
  connection_quality character varying(10) DEFAULT 'good'::character varying,
  device_type character varying(20),
  browser_info text,
  session_rating integer,
  feedback_text text,
  feedback_submitted_at timestamp with time zone,
  status character varying(20) DEFAULT 'registered'::character varying,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.live_class_enrollments ADD CONSTRAINT live_class_enrollments_live_class_id_fkey FOREIGN KEY (live_class_id) REFERENCES live_classes(id);
ALTER TABLE public.live_class_enrollments ADD CONSTRAINT live_class_enrollments_pkey PRIMARY KEY (id);
ALTER TABLE public.live_class_enrollments ADD CONSTRAINT live_class_enrollments_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id);
ALTER TABLE public.live_class_enrollments ADD CONSTRAINT live_class_enrollments_student_id_live_class_id_key UNIQUE (student_id);
ALTER TABLE public.live_class_enrollments ADD CONSTRAINT live_class_enrollments_student_id_live_class_id_key UNIQUE (student_id);
ALTER TABLE public.live_class_enrollments ADD CONSTRAINT live_class_enrollments_student_id_live_class_id_key UNIQUE (live_class_id);
ALTER TABLE public.live_class_enrollments ADD CONSTRAINT live_class_enrollments_student_id_live_class_id_key UNIQUE (live_class_id);

