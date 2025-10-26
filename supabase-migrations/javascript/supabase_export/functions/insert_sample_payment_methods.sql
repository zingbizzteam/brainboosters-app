-- Function: insert_sample_payment_methods
-- Generated: 2025-10-25T15:36:11.679Z

CREATE OR REPLACE FUNCTION public.insert_sample_payment_methods()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO payment_methods (name, display_name, provider, is_active, processing_fee_percentage) VALUES
    ('razorpay_card', 'Credit/Debit Card', 'Razorpay', true, 2.5),
    ('razorpay_upi', 'UPI', 'Razorpay', true, 1.5),
    ('razorpay_netbanking', 'Net Banking', 'Razorpay', true, 2.0),
    ('razorpay_wallet', 'Digital Wallet', 'Razorpay', true, 2.0),
    ('stripe_card', 'International Card', 'Stripe', true, 2.9),
    ('paypal', 'PayPal', 'PayPal', true, 3.5),
    ('bank_transfer', 'Bank Transfer', 'Manual', true, 0.0);
    
    RAISE NOTICE 'Sample payment methods inserted successfully';
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Payment methods already exist, skipping insertion';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error inserting payment methods: %', SQLERRM;
END;
$function$
;

