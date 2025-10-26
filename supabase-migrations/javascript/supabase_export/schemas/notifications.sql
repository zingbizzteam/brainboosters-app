-- Table: notifications
-- Generated: 2025-10-25T15:36:10.460Z

CREATE TABLE IF NOT EXISTS public.notifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  title character varying(255) NOT NULL,
  message text NOT NULL,
  notification_type character varying(50) NOT NULL,
  reference_id uuid,
  reference_type character varying(50),
  channels ARRAY DEFAULT '{in_app}'::text[],
  delivery_status jsonb DEFAULT '{}'::jsonb,
  priority character varying(10) DEFAULT 'medium'::character varying,
  is_read boolean DEFAULT false,
  read_at timestamp with time zone,
  scheduled_at timestamp with time zone DEFAULT now(),
  sent_at timestamp with time zone,
  expires_at timestamp with time zone,
  category character varying(50) DEFAULT 'general'::character varying,
  action_url text,
  action_label character varying(50),
  metadata jsonb DEFAULT '{}'::jsonb,
  template_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.notifications ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);
ALTER TABLE public.notifications ADD CONSTRAINT notifications_template_id_fkey FOREIGN KEY (template_id) REFERENCES notification_templates(id);
ALTER TABLE public.notifications ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES user_profiles(id);

