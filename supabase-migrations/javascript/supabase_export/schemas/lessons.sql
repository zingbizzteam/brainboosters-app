-- Table: lessons
-- Generated: 2025-10-25T15:36:10.170Z

CREATE TABLE IF NOT EXISTS public.lessons (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  chapter_id uuid NOT NULL,
  course_id uuid NOT NULL,
  title character varying(300) NOT NULL,
  description text,
  lesson_number integer NOT NULL,
  lesson_type character varying(20) DEFAULT 'video'::character varying,
  content_url text,
  video_duration integer,
  transcript text,
  notes text,
  attachments jsonb DEFAULT '[]'::jsonb,
  resources jsonb DEFAULT '[]'::jsonb,
  is_published boolean DEFAULT false,
  is_free boolean DEFAULT false,
  is_downloadable boolean DEFAULT false,
  requires_completion boolean DEFAULT false,
  view_count integer DEFAULT 0,
  completion_count integer DEFAULT 0,
  completion_rate numeric DEFAULT 0.0,
  average_watch_time integer DEFAULT 0,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.lessons ADD CONSTRAINT lessons_chapter_id_fkey FOREIGN KEY (chapter_id) REFERENCES chapters(id);
ALTER TABLE public.lessons ADD CONSTRAINT lessons_chapter_id_lesson_number_key UNIQUE (chapter_id);
ALTER TABLE public.lessons ADD CONSTRAINT lessons_chapter_id_lesson_number_key UNIQUE (chapter_id);
ALTER TABLE public.lessons ADD CONSTRAINT lessons_chapter_id_lesson_number_key UNIQUE (lesson_number);
ALTER TABLE public.lessons ADD CONSTRAINT lessons_chapter_id_lesson_number_key UNIQUE (lesson_number);
ALTER TABLE public.lessons ADD CONSTRAINT lessons_chapter_id_sort_order_key UNIQUE (chapter_id);
ALTER TABLE public.lessons ADD CONSTRAINT lessons_chapter_id_sort_order_key UNIQUE (chapter_id);
ALTER TABLE public.lessons ADD CONSTRAINT lessons_chapter_id_sort_order_key UNIQUE (sort_order);
ALTER TABLE public.lessons ADD CONSTRAINT lessons_chapter_id_sort_order_key UNIQUE (sort_order);
ALTER TABLE public.lessons ADD CONSTRAINT lessons_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.lessons ADD CONSTRAINT lessons_pkey PRIMARY KEY (id);

