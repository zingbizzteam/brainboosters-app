-- Function: update_learning_streak
-- Generated: 2025-10-25T15:36:11.681Z

CREATE OR REPLACE FUNCTION public.update_learning_streak(p_student_id uuid, p_timezone character varying DEFAULT 'Asia/Kolkata'::character varying)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_student RECORD;
    v_today DATE;
    v_yesterday DATE;
    v_new_streak INTEGER := 1;
    v_longest_streak INTEGER;
BEGIN
    -- Get student data
    SELECT 
        current_streak_days, 
        longest_streak_days, 
        last_login_date,
        last_streak_update_date
    INTO v_student
    FROM students
    WHERE id = p_student_id;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('error', 'Student not found');
    END IF;
    
    -- Get dates in user timezone
    v_today := (NOW() AT TIME ZONE p_timezone)::DATE;
    v_yesterday := v_today - INTERVAL '1 day';
    
    -- Skip if already updated today
    IF v_student.last_streak_update_date = v_today THEN
        RETURN jsonb_build_object(
            'success', true,
            'message', 'Streak already updated today',
            'current_streak', v_student.current_streak_days
        );
    END IF;
    
    -- Calculate new streak
    IF v_student.last_login_date = v_yesterday THEN
        -- Consecutive day - increment streak
        v_new_streak := v_student.current_streak_days + 1;
    ELSIF v_student.last_login_date = v_today THEN
        -- Same day - keep current streak
        v_new_streak := v_student.current_streak_days;
    ELSE
        -- Gap in learning - reset to 1
        v_new_streak := 1;
    END IF;
    
    v_longest_streak := GREATEST(v_student.longest_streak_days, v_new_streak);
    
    -- Update student record
    UPDATE students
    SET 
        current_streak_days = v_new_streak,
        longest_streak_days = v_longest_streak,
        last_login_date = v_today,
        last_streak_update_date = v_today,
        updated_at = NOW()
    WHERE id = p_student_id;
    
    RETURN jsonb_build_object(
        'success', true,
        'current_streak', v_new_streak,
        'longest_streak', v_longest_streak,
        'is_new_record', v_new_streak = v_longest_streak AND v_new_streak > v_student.longest_streak_days
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$function$
;

