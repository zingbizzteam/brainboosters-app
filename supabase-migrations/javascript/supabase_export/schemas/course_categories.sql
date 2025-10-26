-- Table: course_categories
-- Generated: 2025-10-25T15:36:09.674Z

CREATE TABLE IF NOT EXISTS public.course_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying(100) NOT NULL,
  slug character varying(100) NOT NULL,
  description text,
  parent_id uuid,
  icon_url text,
  is_active boolean DEFAULT true,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.course_categories ADD CONSTRAINT course_categories_name_key UNIQUE (name);
ALTER TABLE public.course_categories ADD CONSTRAINT course_categories_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES course_categories(id);
ALTER TABLE public.course_categories ADD CONSTRAINT course_categories_pkey PRIMARY KEY (id);
ALTER TABLE public.course_categories ADD CONSTRAINT course_categories_slug_key UNIQUE (slug);

