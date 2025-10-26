-- Table: learning_analytics_daily
-- Generated: 2025-10-25T15:36:10.006Z

CREATE TABLE IF NOT EXISTS public.learning_analytics_daily (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  date date NOT NULL,
  student_id uuid,
  course_id uuid,
  coaching_center_id uuid,
  total_time_spent_minutes integer DEFAULT 0,
  lessons_started integer DEFAULT 0,
  lessons_completed integer DEFAULT 0,
  videos_watched integer DEFAULT 0,
  video_watch_time_minutes integer DEFAULT 0,
  quizzes_attempted integer DEFAULT 0,
  quizzes_passed integer DEFAULT 0,
  average_quiz_score numeric DEFAULT 0.0,
  assignments_submitted integer DEFAULT 0,
  login_count integer DEFAULT 0,
  page_views integer DEFAULT 0,
  session_count integer DEFAULT 0,
  average_session_duration_minutes numeric DEFAULT 0,
  progress_gained numeric DEFAULT 0.0,
  streak_days integer DEFAULT 0,
  points_earned integer DEFAULT 0,
  help_requests integer DEFAULT 0,
  forum_posts integer DEFAULT 0,
  peer_interactions integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_coaching_center_id_fkey FOREIGN KEY (coaching_center_id) REFERENCES coaching_centers(id);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_date_student_id_course_id_key UNIQUE (date);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_date_student_id_course_id_key UNIQUE (date);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_date_student_id_course_id_key UNIQUE (date);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_date_student_id_course_id_key UNIQUE (student_id);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_date_student_id_course_id_key UNIQUE (student_id);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_date_student_id_course_id_key UNIQUE (student_id);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_date_student_id_course_id_key UNIQUE (course_id);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_date_student_id_course_id_key UNIQUE (course_id);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_date_student_id_course_id_key UNIQUE (course_id);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_pkey PRIMARY KEY (id);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id);

