-- Table: chapters
-- Generated: 2025-10-25T15:36:09.516Z

CREATE TABLE IF NOT EXISTS public.chapters (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  course_id uuid NOT NULL,
  title character varying(300) NOT NULL,
  description text,
  chapter_number integer NOT NULL,
  duration_minutes integer DEFAULT 0,
  total_lessons integer DEFAULT 0,
  learning_objectives ARRAY DEFAULT '{}'::text[],
  is_published boolean DEFAULT false,
  is_free boolean DEFAULT false,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.chapters ADD CONSTRAINT chapters_course_id_chapter_number_key UNIQUE (course_id);
ALTER TABLE public.chapters ADD CONSTRAINT chapters_course_id_chapter_number_key UNIQUE (course_id);
ALTER TABLE public.chapters ADD CONSTRAINT chapters_course_id_chapter_number_key UNIQUE (chapter_number);
ALTER TABLE public.chapters ADD CONSTRAINT chapters_course_id_chapter_number_key UNIQUE (chapter_number);
ALTER TABLE public.chapters ADD CONSTRAINT chapters_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.chapters ADD CONSTRAINT chapters_course_id_sort_order_key UNIQUE (course_id);
ALTER TABLE public.chapters ADD CONSTRAINT chapters_course_id_sort_order_key UNIQUE (course_id);
ALTER TABLE public.chapters ADD CONSTRAINT chapters_course_id_sort_order_key UNIQUE (sort_order);
ALTER TABLE public.chapters ADD CONSTRAINT chapters_course_id_sort_order_key UNIQUE (sort_order);
ALTER TABLE public.chapters ADD CONSTRAINT chapters_pkey PRIMARY KEY (id);

