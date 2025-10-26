-- Table: tests
-- Generated: 2025-10-25T15:36:11.246Z

CREATE TABLE IF NOT EXISTS public.tests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  course_id uuid NOT NULL,
  chapter_id uuid,
  lesson_id uuid,
  coaching_center_id uuid NOT NULL,
  teacher_id uuid,
  title character varying(300) NOT NULL,
  description text,
  instructions text,
  test_type character varying(20) DEFAULT 'quiz'::character varying,
  difficulty_level character varying(20) DEFAULT 'medium'::character varying,
  total_questions integer NOT NULL,
  total_marks numeric NOT NULL,
  passing_marks numeric NOT NULL,
  negative_marking boolean DEFAULT false,
  negative_marks_per_question numeric DEFAULT 0,
  time_limit_minutes integer,
  extra_time_minutes integer DEFAULT 0,
  attempts_allowed integer DEFAULT 1,
  time_between_attempts_hours integer DEFAULT 0,
  show_results_immediately boolean DEFAULT true,
  show_correct_answers boolean DEFAULT true,
  show_explanations boolean DEFAULT true,
  randomize_questions boolean DEFAULT false,
  randomize_options boolean DEFAULT false,
  available_from timestamp with time zone,
  available_until timestamp with time zone,
  is_published boolean DEFAULT false,
  is_proctored boolean DEFAULT false,
  attempt_count integer DEFAULT 0,
  average_score numeric DEFAULT 0,
  pass_rate numeric DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.tests ADD CONSTRAINT tests_chapter_id_fkey FOREIGN KEY (chapter_id) REFERENCES chapters(id);
ALTER TABLE public.tests ADD CONSTRAINT tests_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.tests ADD CONSTRAINT tests_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES lessons(id);
ALTER TABLE public.tests ADD CONSTRAINT tests_pkey PRIMARY KEY (id);
ALTER TABLE public.tests ADD CONSTRAINT tests_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES teachers(user_id);

