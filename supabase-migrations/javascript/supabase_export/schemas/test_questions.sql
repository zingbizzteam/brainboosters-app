-- Table: test_questions
-- Generated: 2025-10-25T15:36:11.106Z

CREATE TABLE IF NOT EXISTS public.test_questions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  test_id uuid NOT NULL,
  question_text text NOT NULL,
  question_type character varying(20) DEFAULT 'mcq'::character varying,
  options jsonb DEFAULT '[]'::jsonb,
  correct_answers jsonb NOT NULL,
  explanation text,
  hints ARRAY,
  marks numeric DEFAULT 1,
  negative_marks numeric DEFAULT 0,
  difficulty_level character varying(10) DEFAULT 'medium'::character varying,
  topic character varying(200),
  subtopic character varying(200),
  tags ARRAY DEFAULT '{}'::text[],
  question_order integer NOT NULL,
  time_limit_seconds integer,
  attempt_count integer DEFAULT 0,
  correct_count integer DEFAULT 0,
  difficulty_score numeric DEFAULT 0.5,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.test_questions ADD CONSTRAINT test_questions_pkey PRIMARY KEY (id);
ALTER TABLE public.test_questions ADD CONSTRAINT test_questions_test_id_fkey FOREIGN KEY (test_id) REFERENCES tests(id);
ALTER TABLE public.test_questions ADD CONSTRAINT test_questions_test_id_question_order_key UNIQUE (test_id);
ALTER TABLE public.test_questions ADD CONSTRAINT test_questions_test_id_question_order_key UNIQUE (test_id);
ALTER TABLE public.test_questions ADD CONSTRAINT test_questions_test_id_question_order_key UNIQUE (question_order);
ALTER TABLE public.test_questions ADD CONSTRAINT test_questions_test_id_question_order_key UNIQUE (question_order);

