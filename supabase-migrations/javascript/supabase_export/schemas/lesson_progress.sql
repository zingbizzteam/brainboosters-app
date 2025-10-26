-- Table: lesson_progress
-- Generated: 2025-10-25T15:36:10.096Z

CREATE TABLE IF NOT EXISTS public.lesson_progress (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL,
  lesson_id uuid NOT NULL,
  course_id uuid NOT NULL,
  started_at timestamp with time zone DEFAULT now(),
  completed_at timestamp with time zone,
  last_accessed_at timestamp with time zone DEFAULT now(),
  watch_time_seconds integer DEFAULT 0,
  total_video_duration_seconds integer DEFAULT 0,
  last_video_position_seconds integer DEFAULT 0,
  video_completion_percentage numeric DEFAULT 0.0,
  reading_progress_percentage numeric DEFAULT 0.0,
  reading_time_seconds integer DEFAULT 0,
  overall_progress_percentage numeric DEFAULT 0.0,
  is_completed boolean DEFAULT false,
  completion_criteria_met boolean DEFAULT false,
  total_visits integer DEFAULT 1,
  total_time_spent_seconds integer DEFAULT 0,
  engagement_score numeric DEFAULT 0.0,
  student_notes text,
  bookmarks jsonb DEFAULT '[]'::jsonb,
  is_bookmarked boolean DEFAULT false,
  focus_time_seconds integer DEFAULT 0,
  distraction_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.lesson_progress ADD CONSTRAINT lesson_progress_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.lesson_progress ADD CONSTRAINT lesson_progress_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES lessons(id);
ALTER TABLE public.lesson_progress ADD CONSTRAINT lesson_progress_pkey PRIMARY KEY (id);
ALTER TABLE public.lesson_progress ADD CONSTRAINT lesson_progress_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id);
ALTER TABLE public.lesson_progress ADD CONSTRAINT lesson_progress_student_id_lesson_id_key UNIQUE (student_id);
ALTER TABLE public.lesson_progress ADD CONSTRAINT lesson_progress_student_id_lesson_id_key UNIQUE (student_id);
ALTER TABLE public.lesson_progress ADD CONSTRAINT lesson_progress_student_id_lesson_id_key UNIQUE (lesson_id);
ALTER TABLE public.lesson_progress ADD CONSTRAINT lesson_progress_student_id_lesson_id_key UNIQUE (lesson_id);

