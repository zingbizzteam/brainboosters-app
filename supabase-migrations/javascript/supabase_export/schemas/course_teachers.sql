-- Table: course_teachers
-- Generated: 2025-10-25T15:36:09.846Z

CREATE TABLE IF NOT EXISTS public.course_teachers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  course_id uuid NOT NULL,
  teacher_id uuid NOT NULL,
  role character varying(50) DEFAULT 'instructor'::character varying,
  is_primary boolean DEFAULT false,
  permissions jsonb DEFAULT '{}'::jsonb,
  joined_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.course_teachers ADD CONSTRAINT course_teachers_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.course_teachers ADD CONSTRAINT course_teachers_course_id_teacher_id_key UNIQUE (course_id);
ALTER TABLE public.course_teachers ADD CONSTRAINT course_teachers_course_id_teacher_id_key UNIQUE (course_id);
ALTER TABLE public.course_teachers ADD CONSTRAINT course_teachers_course_id_teacher_id_key UNIQUE (teacher_id);
ALTER TABLE public.course_teachers ADD CONSTRAINT course_teachers_course_id_teacher_id_key UNIQUE (teacher_id);
ALTER TABLE public.course_teachers ADD CONSTRAINT course_teachers_pkey PRIMARY KEY (id);
ALTER TABLE public.course_teachers ADD CONSTRAINT course_teachers_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES teachers(id);

