-- Table: review_reports
-- Generated: 2025-10-25T15:36:10.733Z

CREATE TABLE IF NOT EXISTS public.review_reports (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  review_id uuid NOT NULL,
  reported_by uuid NOT NULL,
  reason character varying(50) NOT NULL,
  description text,
  status character varying(20) DEFAULT 'pending'::character varying,
  resolved_by uuid,
  resolved_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.review_reports ADD CONSTRAINT review_reports_pkey PRIMARY KEY (id);
ALTER TABLE public.review_reports ADD CONSTRAINT review_reports_reported_by_fkey FOREIGN KEY (reported_by) REFERENCES user_profiles(id);
ALTER TABLE public.review_reports ADD CONSTRAINT review_reports_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES user_profiles(id);
ALTER TABLE public.review_reports ADD CONSTRAINT review_reports_review_id_fkey FOREIGN KEY (review_id) REFERENCES reviews(id);
ALTER TABLE public.review_reports ADD CONSTRAINT review_reports_review_id_reported_by_key UNIQUE (review_id);
ALTER TABLE public.review_reports ADD CONSTRAINT review_reports_review_id_reported_by_key UNIQUE (review_id);
ALTER TABLE public.review_reports ADD CONSTRAINT review_reports_review_id_reported_by_key UNIQUE (reported_by);
ALTER TABLE public.review_reports ADD CONSTRAINT review_reports_review_id_reported_by_key UNIQUE (reported_by);

