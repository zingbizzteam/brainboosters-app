-- =============================================
-- PRODUCTION-READY PAYMENT SYSTEM
-- =============================================

-- Enhanced payments table with comprehensive tracking
CREATE TABLE payments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id UUID REFERENCES students(id) ON DELETE RESTRICT NOT NULL,
    
    -- Payment items (polymorphic relationship)
    item_type VARCHAR(30) NOT NULL CHECK (item_type IN (
        'course', 'live_class', 'subscription', 'assignment_help', 'one_on_one', 'bundle'
    )),
    item_id UUID NOT NULL, -- References course_id, live_class_id, etc.
    item_title VARCHAR(300), -- Denormalized for performance
    
    -- Financial details
    base_amount DECIMAL(12,2) NOT NULL CHECK (base_amount >= 0),
    discount_amount DECIMAL(12,2) DEFAULT 0.00 CHECK (discount_amount >= 0),
    tax_amount DECIMAL(12,2) DEFAULT 0.00 CHECK (tax_amount >= 0),
    processing_fee DECIMAL(12,2) DEFAULT 0.00 CHECK (processing_fee >= 0),
    final_amount DECIMAL(12,2) GENERATED ALWAYS AS (
        base_amount - discount_amount + tax_amount + processing_fee
    ) STORED,
    currency VARCHAR(3) DEFAULT 'INR',
    
    -- Discount tracking
    coupon_code VARCHAR(50),
    discount_type VARCHAR(20) CHECK (discount_type IN ('percentage', 'fixed', 'bogo', 'referral')),
    discount_value DECIMAL(10,2) DEFAULT 0.00,
    
    -- Payment processing
    payment_method VARCHAR(30) NOT NULL CHECK (payment_method IN (
        'credit_card', 'debit_card', 'upi', 'netbanking', 'wallet', 'emi', 'bank_transfer'
    )),
    payment_gateway VARCHAR(30) NOT NULL CHECK (payment_gateway IN (
        'razorpay', 'stripe', 'paypal', 'payu', 'cashfree', 'phonepe', 'gpay'
    )),
    
    -- Gateway transaction details
    gateway_order_id VARCHAR(200) UNIQUE NOT NULL,
    gateway_payment_id VARCHAR(200),
    gateway_signature VARCHAR(500),
    gateway_transaction_id VARCHAR(200),
    gateway_reference_id VARCHAR(200),
    
    -- Payment status and tracking
    status VARCHAR(20) DEFAULT 'initiated' CHECK (status IN (
        'initiated', 'pending', 'processing', 'completed', 'failed', 
        'cancelled', 'refunded', 'partially_refunded', 'disputed', 'chargeback'
    )),
    failure_reason TEXT,
    failure_code VARCHAR(50),
    
    -- Important timestamps
    initiated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE,
    failed_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '15 minutes'),
    
    -- Refund tracking
    refund_amount DECIMAL(12,2) DEFAULT 0.00 CHECK (refund_amount >= 0),
    refund_reason TEXT,
    refunded_at TIMESTAMP WITH TIME ZONE,
    refunded_by UUID REFERENCES user_profiles(id),
    refund_reference_id VARCHAR(200),
    
    -- Security and fraud detection
    risk_score INTEGER DEFAULT 0 CHECK (risk_score >= 0 AND risk_score <= 100),
    fraud_flags JSONB DEFAULT '[]',
    verification_required BOOLEAN DEFAULT false,
    
    -- Customer and session info
    customer_ip INET,
    customer_user_agent TEXT,
    device_fingerprint TEXT,
    session_id VARCHAR(100),
    
    -- Metadata and additional info
    metadata JSONB DEFAULT '{}',
    notes TEXT,
    
    -- Reconciliation
    reconciled BOOLEAN DEFAULT false,
    reconciled_at TIMESTAMP WITH TIME ZONE,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    CONSTRAINT payment_amount_valid CHECK (final_amount >= 0)
) WITH (fillfactor = 90); -- High update frequency

-- Payment attempts for retry logic
CREATE TABLE payment_attempts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    payment_id UUID REFERENCES payments(id) ON DELETE CASCADE NOT NULL,
    attempt_number INTEGER NOT NULL CHECK (attempt_number > 0),
    
    -- Attempt details
    payment_method VARCHAR(30) NOT NULL,
    payment_gateway VARCHAR(30) NOT NULL,
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    -- Gateway response
    gateway_response JSONB DEFAULT '{}',
    response_code VARCHAR(50),
    response_message TEXT,
    
    -- Result
    is_successful BOOLEAN DEFAULT false,
    error_code VARCHAR(50),
    error_message TEXT,
    processing_time_ms INTEGER,
    
    UNIQUE(payment_id, attempt_number)
);

-- Payment webhooks for gateway callbacks
CREATE TABLE payment_webhooks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    payment_id UUID REFERENCES payments(id) ON DELETE CASCADE,
    
    -- Webhook details
    gateway VARCHAR(30) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    webhook_id VARCHAR(200), -- Gateway's webhook ID
    
    -- Payload and verification
    raw_payload TEXT NOT NULL,
    parsed_payload JSONB DEFAULT '{}',
    signature VARCHAR(500),
    signature_verified BOOLEAN DEFAULT false,
    
    -- Processing
    processed BOOLEAN DEFAULT false,
    processed_at TIMESTAMP WITH TIME ZONE,
    processing_error TEXT,
    retry_count INTEGER DEFAULT 0,
    
    -- Metadata
    headers JSONB DEFAULT '{}',
    source_ip INET,
    
    received_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Coupons and discount codes
CREATE TABLE coupons (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    coaching_center_id UUID REFERENCES coaching_centers(id) ON DELETE CASCADE,
    
    -- Coupon details
    code VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    
    -- Discount configuration
    discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('percentage', 'fixed_amount', 'bogo')),
    discount_value DECIMAL(10,2) NOT NULL CHECK (discount_value > 0),
    max_discount_amount DECIMAL(10,2), -- For percentage discounts
    min_order_amount DECIMAL(10,2) DEFAULT 0.00,
    
    -- Usage limits
    usage_limit INTEGER, -- Total usage limit
    usage_limit_per_user INTEGER DEFAULT 1,
    used_count INTEGER DEFAULT 0,
    
    -- Validity period
    valid_from TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    valid_until TIMESTAMP WITH TIME ZONE NOT NULL,
    
    -- Applicable items
    applicable_items JSONB DEFAULT '{}', -- Courses, live classes, etc.
    applicable_user_types TEXT[] DEFAULT '{"student"}',
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    created_by UUID REFERENCES user_profiles(id) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Coupon usage tracking
CREATE TABLE coupon_usages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    coupon_id UUID REFERENCES coupons(id) ON DELETE CASCADE NOT NULL,
    payment_id UUID REFERENCES payments(id) ON DELETE CASCADE NOT NULL,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE NOT NULL,
    
    discount_amount DECIMAL(10,2) NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    UNIQUE(coupon_id, payment_id)
);

-- =============================================
-- PAYMENT INDEXES (PRODUCTION OPTIMIZED)
-- =============================================

CREATE INDEX CONCURRENTLY idx_payments_student ON payments(student_id) 
    WHERE status != 'failed';
CREATE INDEX CONCURRENTLY idx_payments_status ON payments(status);
CREATE INDEX CONCURRENTLY idx_payments_created_date ON payments(created_at::date);
CREATE INDEX CONCURRENTLY idx_payments_gateway_order ON payments(gateway_order_id) 
    WHERE gateway_order_id IS NOT NULL;
CREATE INDEX CONCURRENTLY idx_payments_gateway_payment ON payments(gateway_payment_id) 
    WHERE gateway_payment_id IS NOT NULL;
CREATE INDEX CONCURRENTLY idx_payments_item ON payments(item_type, item_id) 
    WHERE status = 'completed';
CREATE INDEX CONCURRENTLY idx_payments_reconciled ON payments(reconciled) 
    WHERE status = 'completed';
CREATE INDEX CONCURRENTLY idx_payments_expires ON payments(expires_at) 
    WHERE status IN ('initiated', 'pending');

CREATE INDEX CONCURRENTLY idx_payment_attempts_payment ON payment_attempts(payment_id);
CREATE INDEX CONCURRENTLY idx_payment_webhooks_payment ON payment_webhooks(payment_id);
CREATE INDEX CONCURRENTLY idx_payment_webhooks_processed ON payment_webhooks(processed, received_at);

CREATE INDEX CONCURRENTLY idx_coupons_code ON coupons(code) WHERE is_active = true;
CREATE INDEX CONCURRENTLY idx_coupons_validity ON coupons(valid_from, valid_until) WHERE is_active = true;
CREATE INDEX CONCURRENTLY idx_coupon_usages_coupon ON coupon_usages(coupon_id);

-- =============================================
-- PAYMENT STORED PROCEDURES
-- =============================================

-- Validate and apply coupon
CREATE OR REPLACE FUNCTION sp_validate_coupon(
    p_coupon_code VARCHAR,
    p_student_id UUID,
    p_item_type VARCHAR,
    p_item_id UUID,
    p_base_amount DECIMAL
) RETURNS JSONB AS $$
DECLARE
    v_coupon coupons%ROWTYPE;
    v_user_usage_count INTEGER;
    v_discount_amount DECIMAL(10,2);
    result JSONB;
BEGIN
    -- Get coupon details
    SELECT * INTO v_coupon 
    FROM coupons 
    WHERE code = p_coupon_code AND is_active = true;
    
    IF v_coupon.id IS NULL THEN
        RETURN jsonb_build_object('valid', false, 'message', 'Invalid coupon code');
    END IF;
    
    -- Check validity period
    IF NOW() < v_coupon.valid_from OR NOW() > v_coupon.valid_until THEN
        RETURN jsonb_build_object('valid', false, 'message', 'Coupon has expired');
    END IF;
    
    -- Check usage limits
    IF v_coupon.usage_limit IS NOT NULL AND v_coupon.used_count >= v_coupon.usage_limit THEN
        RETURN jsonb_build_object('valid', false, 'message', 'Coupon usage limit exceeded');
    END IF;
    
    -- Check per-user usage limit
    SELECT COUNT(*) INTO v_user_usage_count
    FROM coupon_usages cu
    JOIN payments p ON cu.payment_id = p.id
    WHERE cu.coupon_id = v_coupon.id 
    AND cu.student_id = p_student_id 
    AND p.status = 'completed';
    
    IF v_user_usage_count >= v_coupon.usage_limit_per_user THEN
        RETURN jsonb_build_object('valid', false, 'message', 'You have already used this coupon');
    END IF;
    
    -- Check minimum order amount
    IF p_base_amount < v_coupon.min_order_amount THEN
        RETURN jsonb_build_object(
            'valid', false, 
            'message', FORMAT('Minimum order amount is ₹%.2f', v_coupon.min_order_amount)
        );
    END IF;
    
    -- Calculate discount
    CASE v_coupon.discount_type
        WHEN 'percentage' THEN
            v_discount_amount := LEAST(
                (p_base_amount * v_coupon.discount_value / 100),
                COALESCE(v_coupon.max_discount_amount, p_base_amount)
            );
        WHEN 'fixed_amount' THEN
            v_discount_amount := LEAST(v_coupon.discount_value, p_base_amount);
        ELSE
            v_discount_amount := 0;
    END CASE;
    
    result := jsonb_build_object(
        'valid', true,
        'coupon_id', v_coupon.id,
        'discount_type', v_coupon.discount_type,
        'discount_value', v_coupon.discount_value,
        'discount_amount', v_discount_amount,
        'final_amount', p_base_amount - v_discount_amount,
        'title', v_coupon.title
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Initialize payment with comprehensive validation
CREATE OR REPLACE FUNCTION sp_initiate_payment(
    p_student_id UUID,
    p_item_type VARCHAR,
    p_item_id UUID,
    p_base_amount DECIMAL,
    p_payment_method VARCHAR,
    p_payment_gateway VARCHAR DEFAULT 'razorpay',
    p_coupon_code VARCHAR DEFAULT NULL,
    p_session_data JSONB DEFAULT '{}'
) RETURNS JSONB AS $$
DECLARE
    v_payment_id UUID;
    v_gateway_order_id VARCHAR(200);
    v_final_amount DECIMAL(12,2);
    v_discount_amount DECIMAL(12,2) := 0.00;
    v_tax_amount DECIMAL(12,2);
    v_processing_fee DECIMAL(12,2) := 0.00;
    v_coupon_validation JSONB;
    v_item_title VARCHAR(300);
    v_expires_at TIMESTAMP WITH TIME ZONE;
    result JSONB;
BEGIN
    -- Validate student exists and is active
    IF NOT EXISTS (SELECT 1 FROM students WHERE id = p_student_id AND is_active = true) THEN
        RETURN jsonb_build_object('success', false, 'message', 'Invalid student account');
    END IF;
    
    -- Get item title based on type
    CASE p_item_type
        WHEN 'course' THEN
            SELECT title INTO v_item_title FROM courses WHERE id = p_item_id AND status = 'published';
        WHEN 'live_class' THEN
            SELECT title INTO v_item_title FROM live_classes WHERE id = p_item_id AND status = 'scheduled';
        ELSE
            v_item_title := 'Unknown Item';
    END CASE;
    
    IF v_item_title IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Item not found or not available');
    END IF;
    
    -- Validate and apply coupon if provided
    IF p_coupon_code IS NOT NULL THEN
        v_coupon_validation := sp_validate_coupon(p_coupon_code, p_student_id, p_item_type, p_item_id, p_base_amount);
        
        IF NOT (v_coupon_validation->>'valid')::BOOLEAN THEN
            RETURN jsonb_build_object('success', false, 'message', v_coupon_validation->>'message');
        END IF;
        
        v_discount_amount := (v_coupon_validation->>'discount_amount')::DECIMAL;
    END IF;
    
    -- Calculate tax (18% GST for India)
    v_tax_amount := ROUND((p_base_amount - v_discount_amount) * 0.18, 2);
    
    -- Calculate processing fee based on payment method
    CASE p_payment_method
        WHEN 'credit_card', 'debit_card' THEN
            v_processing_fee := ROUND((p_base_amount - v_discount_amount) * 0.02, 2); -- 2%
        WHEN 'upi', 'netbanking' THEN
            v_processing_fee := ROUND((p_base_amount - v_discount_amount) * 0.01, 2); -- 1%
        ELSE
            v_processing_fee := 0.00;
    END CASE;
    
    v_final_amount := p_base_amount - v_discount_amount + v_tax_amount + v_processing_fee;
    
    -- Generate unique gateway order ID
    v_gateway_order_id := 'ORD_' || EXTRACT(EPOCH FROM NOW())::BIGINT || '_' || 
                         UPPER(SUBSTRING(gen_random_uuid()::TEXT FROM 1 FOR 8));
    
    -- Set expiration time (15 minutes for most payments, 24 hours for bank transfer)
    v_expires_at := CASE 
        WHEN p_payment_method = 'bank_transfer' THEN NOW() + INTERVAL '24 hours'
        ELSE NOW() + INTERVAL '15 minutes'
    END;
    
    -- Create payment record
    INSERT INTO payments (
        student_id, item_type, item_id, item_title,
        base_amount, discount_amount, tax_amount, processing_fee, currency,
        coupon_code, discount_type, discount_value,
        payment_method, payment_gateway,
        gateway_order_id, status, expires_at,
        customer_ip, customer_user_agent, session_id, metadata
    ) VALUES (
        p_student_id, p_item_type, p_item_id, v_item_title,
        p_base_amount, v_discount_amount, v_tax_amount, v_processing_fee, 'INR',
        p_coupon_code, 
        CASE WHEN p_coupon_code IS NOT NULL THEN v_coupon_validation->>'discount_type' ELSE NULL END,
        CASE WHEN p_coupon_code IS NOT NULL THEN (v_coupon_validation->>'discount_value')::DECIMAL ELSE NULL END,
        p_payment_method, p_payment_gateway,
        v_gateway_order_id, 'initiated', v_expires_at,
        COALESCE((p_session_data->>'ip_address')::INET, inet_client_addr()),
        p_session_data->>'user_agent',
        p_session_data->>'session_id',
        p_session_data
    ) RETURNING id INTO v_payment_id;
    
    -- Record first payment attempt
    INSERT INTO payment_attempts (
        payment_id, attempt_number, payment_method, payment_gateway
    ) VALUES (
        v_payment_id, 1, p_payment_method, p_payment_gateway
    );
    
    result := jsonb_build_object(
        'success', true,
        'payment_id', v_payment_id,
        'gateway_order_id', v_gateway_order_id,
        'item_title', v_item_title,
        'base_amount', p_base_amount,
        'discount_amount', v_discount_amount,
        'tax_amount', v_tax_amount,
        'processing_fee', v_processing_fee,
        'final_amount', v_final_amount,
        'expires_at', v_expires_at,
        'currency', 'INR'
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Complete payment and create enrollments
CREATE OR REPLACE FUNCTION sp_complete_payment(
    p_payment_id UUID,
    p_gateway_payment_id VARCHAR,
    p_gateway_signature VARCHAR DEFAULT NULL,
    p_gateway_response JSONB DEFAULT '{}'
) RETURNS JSONB AS $$
DECLARE
    v_payment payments%ROWTYPE;
    v_enrollment_result JSONB;
    v_coupon_id UUID;
    result JSONB;
BEGIN
    -- Get payment details with row lock
    SELECT * INTO v_payment 
    FROM payments 
    WHERE id = p_payment_id 
    FOR UPDATE;
    
    IF v_payment.id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Payment not found');
    END IF;
    
    -- Check if already processed
    IF v_payment.status NOT IN ('initiated', 'pending') THEN
        RETURN jsonb_build_object('success', false, 'message', 'Payment already processed');
    END IF;
    
    -- Check if payment has expired
    IF v_payment.expires_at < NOW() THEN
        UPDATE payments SET
