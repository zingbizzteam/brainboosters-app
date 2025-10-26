-- Table: notification_templates
-- Generated: 2025-10-25T15:36:10.397Z

CREATE TABLE IF NOT EXISTS public.notification_templates (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying(100) NOT NULL,
  title_template text NOT NULL,
  message_template text NOT NULL,
  notification_type character varying(50) NOT NULL,
  channels ARRAY DEFAULT '{in_app}'::text[],
  is_active boolean DEFAULT true,
  variables jsonb DEFAULT '[]'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.notification_templates ADD CONSTRAINT notification_templates_name_key UNIQUE (name);
ALTER TABLE public.notification_templates ADD CONSTRAINT notification_templates_pkey PRIMARY KEY (id);

