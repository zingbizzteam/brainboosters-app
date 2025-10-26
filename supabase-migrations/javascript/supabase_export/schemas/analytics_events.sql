-- Table: analytics_events
-- Generated: 2025-10-25T15:36:09.269Z

CREATE TABLE IF NOT EXISTS public.analytics_events (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  session_id character varying(100),
  anonymous_id character varying(100),
  event_name character varying(100) NOT NULL,
  event_category character varying(50) NOT NULL,
  event_action character varying(100) NOT NULL,
  event_label character varying(200),
  event_value numeric,
  entity_type character varying(50),
  entity_id uuid,
  properties jsonb DEFAULT '{}'::jsonb,
  user_properties jsonb DEFAULT '{}'::jsonb,
  user_agent text,
  ip_address inet,
  country character varying(2),
  region character varying(100),
  city character varying(100),
  device_type character varying(20),
  device_model character varying(100),
  browser character varying(50),
  browser_version character varying(20),
  os character varying(50),
  os_version character varying(20),
  screen_resolution character varying(20),
  page_url text,
  page_title character varying(200),
  referrer text,
  utm_source character varying(100),
  utm_medium character varying(100),
  utm_campaign character varying(100),
  utm_content character varying(100),
  utm_term character varying(100),
  client_timestamp timestamp with time zone,
  server_timestamp timestamp with time zone DEFAULT now(),
  processed boolean DEFAULT false,
  processed_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.analytics_events ADD CONSTRAINT analytics_events_pkey PRIMARY KEY (id);
ALTER TABLE public.analytics_events ADD CONSTRAINT analytics_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES user_profiles(id);

