-- Table: payment_methods
-- Generated: 2025-10-25T15:36:10.532Z

CREATE TABLE IF NOT EXISTS public.payment_methods (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying(50) NOT NULL,
  display_name character varying(100) NOT NULL,
  provider character varying(50) NOT NULL,
  is_active boolean DEFAULT true,
  supports_refunds boolean DEFAULT true,
  processing_fee_percentage numeric DEFAULT 0,
  min_amount numeric DEFAULT 0,
  max_amount numeric,
  supported_currencies ARRAY DEFAULT '{INR}'::text[],
  configuration jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.payment_methods ADD CONSTRAINT payment_methods_name_key UNIQUE (name);
ALTER TABLE public.payment_methods ADD CONSTRAINT payment_methods_pkey PRIMARY KEY (id);

