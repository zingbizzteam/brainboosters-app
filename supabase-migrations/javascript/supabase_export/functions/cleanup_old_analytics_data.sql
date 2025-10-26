-- Function: cleanup_old_analytics_data
-- Generated: 2025-10-25T15:36:11.675Z

CREATE OR REPLACE FUNCTION public.cleanup_old_analytics_data(days_to_keep integer DEFAULT 90)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_deleted_count INTEGER;
    v_cutoff_date TIMESTAMP WITH TIME ZONE;
BEGIN
    v_cutoff_date := NOW() - (days_to_keep || ' days')::INTERVAL;
    
    DELETE FROM analytics_events 
    WHERE server_timestamp < v_cutoff_date;
    
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
    
    RETURN jsonb_build_object(
        'success', true,
        'deleted_records', v_deleted_count,
        'cutoff_date', v_cutoff_date
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$function$
;

