-- Function: handle_new_user
-- Generated: 2025-10-25T15:36:11.678Z

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_user_type TEXT;
  v_first_name TEXT;
  v_last_name TEXT;
BEGIN
  -- Extract user_type (default to 'student')
  v_user_type := COALESCE(NEW.raw_user_meta_data->>'user_type', 'student');
  
  -- Extract names
  v_first_name := COALESCE(
    NEW.raw_user_meta_data->>'first_name',
    SPLIT_PART(COALESCE(NEW.raw_user_meta_data->>'full_name', ''), ' ', 1)
  );
  
  v_last_name := COALESCE(
    NEW.raw_user_meta_data->>'last_name',
    SUBSTRING(COALESCE(NEW.raw_user_meta_data->>'full_name', '') 
      FROM POSITION(' ' IN COALESCE(NEW.raw_user_meta_data->>'full_name', '')) + 1)
  );

  -- Insert into user_profiles
  INSERT INTO public.user_profiles (
    id, user_type, email, first_name, last_name, 
    avatar_url, email_verified, is_active, 
    onboarding_completed, created_at, updated_at
  ) VALUES (
    NEW.id, v_user_type, NEW.email,
    NULLIF(TRIM(v_first_name), ''),
    NULLIF(TRIM(v_last_name), ''),
    NEW.raw_user_meta_data->>'avatar_url',
    NEW.email_confirmed_at IS NOT NULL,
    true, false, NOW(), NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    email_verified = EXCLUDED.email_verified,
    updated_at = NOW();

  -- If student, create student record
  IF v_user_type = 'student' THEN
    INSERT INTO public.students (user_id, created_at, updated_at)
    VALUES (NEW.id, NOW(), NOW())
    ON CONFLICT (user_id) DO NOTHING;
  END IF;

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Failed to create user profile: %', SQLERRM;
    RETURN NEW;
END;
$function$
;

