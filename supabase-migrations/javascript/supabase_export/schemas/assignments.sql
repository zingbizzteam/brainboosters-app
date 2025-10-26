-- Table: assignments
-- Generated: 2025-10-25T15:36:09.438Z

CREATE TABLE IF NOT EXISTS public.assignments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  course_id uuid NOT NULL,
  chapter_id uuid,
  teacher_id uuid NOT NULL,
  title character varying(300) NOT NULL,
  description text NOT NULL,
  instructions text,
  assignment_type character varying(30) DEFAULT 'project'::character varying,
  submission_format character varying(30) NOT NULL,
  total_marks numeric NOT NULL DEFAULT 100,
  passing_marks numeric DEFAULT 40,
  grading_rubric jsonb DEFAULT '{}'::jsonb,
  assigned_date timestamp with time zone DEFAULT now(),
  due_date timestamp with time zone NOT NULL,
  late_submission_deadline timestamp with time zone,
  allow_late_submission boolean DEFAULT true,
  late_penalty_percentage numeric DEFAULT 10,
  is_group_assignment boolean DEFAULT false,
  max_group_size integer DEFAULT 1,
  allow_resubmission boolean DEFAULT false,
  max_file_size_mb integer DEFAULT 50,
  allowed_file_types ARRAY DEFAULT '{pdf,doc,docx,txt,zip,jpg,png}'::text[],
  resources jsonb DEFAULT '[]'::jsonb,
  reference_materials jsonb DEFAULT '[]'::jsonb,
  sample_submissions jsonb DEFAULT '[]'::jsonb,
  is_published boolean DEFAULT false,
  is_archived boolean DEFAULT false,
  submission_count integer DEFAULT 0,
  on_time_submissions integer DEFAULT 0,
  average_grade numeric DEFAULT 0,
  plagiarism_check_enabled boolean DEFAULT false,
  auto_grade_enabled boolean DEFAULT false,
  ai_feedback_enabled boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.assignments ADD CONSTRAINT assignments_chapter_id_fkey FOREIGN KEY (chapter_id) REFERENCES chapters(id);
ALTER TABLE public.assignments ADD CONSTRAINT assignments_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.assignments ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);
ALTER TABLE public.assignments ADD CONSTRAINT assignments_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES teachers(user_id);

