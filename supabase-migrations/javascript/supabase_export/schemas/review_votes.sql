-- Table: review_votes
-- Generated: 2025-10-25T15:36:10.805Z

CREATE TABLE IF NOT EXISTS public.review_votes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  review_id uuid NOT NULL,
  user_id uuid NOT NULL,
  vote_type character varying(15) NOT NULL,
  created_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.review_votes ADD CONSTRAINT review_votes_pkey PRIMARY KEY (id);
ALTER TABLE public.review_votes ADD CONSTRAINT review_votes_review_id_fkey FOREIGN KEY (review_id) REFERENCES reviews(id);
ALTER TABLE public.review_votes ADD CONSTRAINT review_votes_review_id_user_id_key UNIQUE (review_id);
ALTER TABLE public.review_votes ADD CONSTRAINT review_votes_review_id_user_id_key UNIQUE (review_id);
ALTER TABLE public.review_votes ADD CONSTRAINT review_votes_review_id_user_id_key UNIQUE (user_id);
ALTER TABLE public.review_votes ADD CONSTRAINT review_votes_review_id_user_id_key UNIQUE (user_id);
ALTER TABLE public.review_votes ADD CONSTRAINT review_votes_user_id_fkey FOREIGN KEY (user_id) REFERENCES user_profiles(id);

