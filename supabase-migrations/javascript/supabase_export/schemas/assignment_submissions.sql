-- Table: assignment_submissions
-- Generated: 2025-10-25T15:36:09.362Z

CREATE TABLE IF NOT EXISTS public.assignment_submissions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  assignment_id uuid NOT NULL,
  student_id uuid NOT NULL,
  submission_text text,
  submission_files jsonb DEFAULT '[]'::jsonb,
  submission_urls jsonb DEFAULT '[]'::jsonb,
  attempt_number integer DEFAULT 1,
  submitted_at timestamp with time zone DEFAULT now(),
  is_late boolean DEFAULT false,
  grade numeric,
  feedback text,
  detailed_feedback jsonb DEFAULT '{}'::jsonb,
  graded_at timestamp with time zone,
  graded_by uuid,
  submission_status character varying(20) DEFAULT 'submitted'::character varying,
  plagiarism_score numeric,
  plagiarism_report jsonb DEFAULT '{}'::jsonb,
  word_count integer DEFAULT 0,
  total_file_size_mb numeric DEFAULT 0,
  file_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  metadata jsonb DEFAULT '{}'::jsonb
);

-- Constraints
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES assignments(id);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_assignment_id_student_id_attempt_num_key UNIQUE (assignment_id);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_assignment_id_student_id_attempt_num_key UNIQUE (assignment_id);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_assignment_id_student_id_attempt_num_key UNIQUE (assignment_id);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_assignment_id_student_id_attempt_num_key UNIQUE (student_id);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_assignment_id_student_id_attempt_num_key UNIQUE (student_id);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_assignment_id_student_id_attempt_num_key UNIQUE (student_id);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_assignment_id_student_id_attempt_num_key UNIQUE (attempt_number);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_assignment_id_student_id_attempt_num_key UNIQUE (attempt_number);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_assignment_id_student_id_attempt_num_key UNIQUE (attempt_number);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_graded_by_fkey FOREIGN KEY (graded_by) REFERENCES teachers(id);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_pkey PRIMARY KEY (id);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id);

