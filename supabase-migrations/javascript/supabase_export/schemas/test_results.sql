-- Table: test_results
-- Generated: 2025-10-25T15:36:11.170Z

CREATE TABLE IF NOT EXISTS public.test_results (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  test_id uuid NOT NULL,
  student_id uuid NOT NULL,
  attempt_number integer DEFAULT 1,
  started_at timestamp with time zone DEFAULT now(),
  completed_at timestamp with time zone,
  submitted_at timestamp with time zone,
  total_questions integer NOT NULL,
  questions_attempted integer DEFAULT 0,
  correct_answers integer DEFAULT 0,
  incorrect_answers integer DEFAULT 0,
  skipped_questions integer DEFAULT 0,
  score numeric NOT NULL DEFAULT 0,
  total_marks numeric NOT NULL,
  percentage numeric,
  passed boolean DEFAULT false,
  grade character varying(5),
  time_taken_minutes integer,
  time_limit_minutes integer,
  extra_time_used integer DEFAULT 0,
  answers jsonb DEFAULT '{}'::jsonb,
  question_wise_analysis jsonb DEFAULT '{}'::jsonb,
  is_submitted boolean DEFAULT false,
  is_flagged boolean DEFAULT false,
  flag_reason text,
  is_proctored boolean DEFAULT false,
  proctoring_data jsonb DEFAULT '{}'::jsonb,
  rank_in_test integer,
  percentile numeric,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.test_results ADD CONSTRAINT test_results_pkey PRIMARY KEY (id);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_test_id_fkey FOREIGN KEY (test_id) REFERENCES tests(id);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_test_id_student_id_attempt_number_key UNIQUE (test_id);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_test_id_student_id_attempt_number_key UNIQUE (test_id);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_test_id_student_id_attempt_number_key UNIQUE (test_id);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_test_id_student_id_attempt_number_key UNIQUE (student_id);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_test_id_student_id_attempt_number_key UNIQUE (student_id);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_test_id_student_id_attempt_number_key UNIQUE (student_id);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_test_id_student_id_attempt_number_key UNIQUE (attempt_number);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_test_id_student_id_attempt_number_key UNIQUE (attempt_number);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_test_id_student_id_attempt_number_key UNIQUE (attempt_number);

