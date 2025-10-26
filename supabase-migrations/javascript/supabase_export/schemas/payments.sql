-- Table: payments
-- Generated: 2025-10-25T15:36:10.587Z

CREATE TABLE IF NOT EXISTS public.payments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL,
  course_id uuid,
  live_class_id uuid,
  items jsonb DEFAULT '[]'::jsonb,
  payment_type character varying(20) NOT NULL,
  subtotal numeric NOT NULL,
  discount_amount numeric DEFAULT 0,
  tax_amount numeric DEFAULT 0,
  processing_fee numeric DEFAULT 0,
  total_amount numeric NOT NULL,
  currency character varying(3) DEFAULT 'INR'::character varying,
  payment_method_id uuid,
  payment_gateway character varying(50) NOT NULL,
  gateway_transaction_id character varying(200),
  internal_transaction_id character varying(100) NOT NULL DEFAULT (gen_random_uuid())::text,
  status character varying(20) DEFAULT 'pending'::character varying,
  failure_reason text,
  initiated_at timestamp with time zone DEFAULT now(),
  processed_at timestamp with time zone,
  completed_at timestamp with time zone,
  refund_amount numeric DEFAULT 0.00,
  refund_reason text,
  refunded_at timestamp with time zone,
  refunded_by uuid,
  coupon_code character varying(50),
  discount_type character varying(20),
  discount_value numeric DEFAULT 0,
  invoice_number character varying(50),
  invoice_url text,
  customer_details jsonb DEFAULT '{}'::jsonb,
  gateway_response jsonb DEFAULT '{}'::jsonb,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.payments ADD CONSTRAINT payments_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.payments ADD CONSTRAINT payments_internal_transaction_id_key UNIQUE (internal_transaction_id);
ALTER TABLE public.payments ADD CONSTRAINT payments_invoice_number_key UNIQUE (invoice_number);
ALTER TABLE public.payments ADD CONSTRAINT payments_live_class_id_fkey FOREIGN KEY (live_class_id) REFERENCES live_classes(id);
ALTER TABLE public.payments ADD CONSTRAINT payments_payment_method_id_fkey FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id);
ALTER TABLE public.payments ADD CONSTRAINT payments_pkey PRIMARY KEY (id);
ALTER TABLE public.payments ADD CONSTRAINT payments_refunded_by_fkey FOREIGN KEY (refunded_by) REFERENCES user_profiles(id);
ALTER TABLE public.payments ADD CONSTRAINT payments_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id);

