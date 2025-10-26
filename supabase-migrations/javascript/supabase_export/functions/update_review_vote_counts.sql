-- Function: update_review_vote_counts
-- Generated: 2025-10-25T15:36:11.682Z

CREATE OR REPLACE FUNCTION public.update_review_vote_counts()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_review_id UUID := COALESCE(NEW.review_id, OLD.review_id);
    v_helpful_count INTEGER;
    v_not_helpful_count INTEGER;
BEGIN
    SELECT 
        COUNT(*) FILTER (WHERE vote_type = 'helpful'),
        COUNT(*) FILTER (WHERE vote_type = 'not_helpful')
    INTO v_helpful_count, v_not_helpful_count
    FROM review_votes
    WHERE review_id = v_review_id;
    
    UPDATE reviews
    SET 
        helpful_votes = v_helpful_count,
        not_helpful_votes = v_not_helpful_count,
        helpfulness_score = CASE 
            WHEN (v_helpful_count + v_not_helpful_count) > 0 
            THEN ROUND(v_helpful_count::DECIMAL / (v_helpful_count + v_not_helpful_count), 2)
            ELSE 0.0 
        END,
        updated_at = NOW()
    WHERE id = v_review_id;
    
    RETURN COALESCE(NEW, OLD);
END;
$function$
;

