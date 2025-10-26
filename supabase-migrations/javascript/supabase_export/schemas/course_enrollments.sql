-- Table: course_enrollments
-- Generated: 2025-10-25T15:36:09.746Z

CREATE TABLE IF NOT EXISTS public.course_enrollments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL,
  course_id uuid NOT NULL,
  enrolled_at timestamp with time zone DEFAULT now(),
  enrollment_method character varying(20) DEFAULT 'direct'::character varying,
  payment_status character varying(20) DEFAULT 'pending'::character varying,
  progress_percentage numeric DEFAULT 0.0,
  lessons_completed integer DEFAULT 0,
  total_lessons_in_course integer DEFAULT 0,
  chapters_completed integer DEFAULT 0,
  total_chapters_in_course integer DEFAULT 0,
  total_time_spent_minutes integer DEFAULT 0,
  average_session_duration_minutes numeric DEFAULT 0,
  total_sessions integer DEFAULT 0,
  completed_at timestamp with time zone,
  completion_percentage_required numeric DEFAULT 80.0,
  last_accessed_at timestamp with time zone,
  access_expires_at timestamp with time zone,
  is_active boolean DEFAULT true,
  current_chapter_id uuid,
  current_lesson_id uuid,
  bookmarked_lessons ARRAY DEFAULT '{}'::uuid[],
  notes text,
  certificate_issued boolean DEFAULT false,
  certificate_issued_at timestamp with time zone,
  certificate_id uuid,
  course_rating integer,
  course_review text,
  reviewed_at timestamp with time zone,
  average_quiz_score numeric DEFAULT 0,
  assignments_submitted integer DEFAULT 0,
  assignments_graded integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  teacher_id uuid,
  coaching_center_id uuid
);

-- Constraints
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_coaching_center_id_fkey FOREIGN KEY (coaching_center_id) REFERENCES coaching_centers(user_id);
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_current_chapter_id_fkey FOREIGN KEY (current_chapter_id) REFERENCES chapters(id);
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_current_lesson_id_fkey FOREIGN KEY (current_lesson_id) REFERENCES lessons(id);
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_pkey PRIMARY KEY (id);
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_student_id_course_id_key UNIQUE (student_id);
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_student_id_course_id_key UNIQUE (student_id);
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_student_id_course_id_key UNIQUE (course_id);
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_student_id_course_id_key UNIQUE (course_id);
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id);
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES teachers(user_id);

