-- Function: insert_sample_notification_templates
-- Generated: 2025-10-25T15:36:11.679Z

CREATE OR REPLACE FUNCTION public.insert_sample_notification_templates()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO notification_templates (name, title_template, message_template, notification_type, channels) VALUES
    ('course_enrollment_success', 'Welcome to {{course_title}}!', 'You have successfully enrolled in {{course_title}}. Start learning now!', 'course_enrollment', '{"in_app","email"}'),
    ('lesson_completed', 'Lesson Completed! 🎉', 'Congratulations! You completed {{lesson_title}} in {{course_title}}', 'lesson_completed', '{"in_app"}'),
    ('assignment_due_reminder', 'Assignment Due Tomorrow', 'Your assignment "{{assignment_title}}" is due tomorrow. Submit before {{due_date}}', 'assignment_due', '{"in_app","email"}'),
    ('live_class_reminder', 'Live Class Starting Soon', 'Your live class "{{class_title}}" starts in {{time_until_start}}', 'live_class_reminder', '{"in_app","push"}'),
    ('certificate_issued', 'Certificate Ready! 🏆', 'Your certificate for {{course_title}} is ready. Download it now!', 'certificate_issued', '{"in_app","email"}'),
    ('payment_success', 'Payment Successful', 'Your payment of {{amount}} {{currency}} for {{item_name}} was successful', 'payment_success', '{"in_app","email"}'),
    ('streak_milestone', 'Learning Streak Milestone! 🔥', 'Amazing! You reached a {{streak_days}} day learning streak!', 'streak_milestone', '{"in_app"}');
    
    RAISE NOTICE 'Sample notification templates inserted successfully';
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Notification templates already exist, skipping insertion';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error inserting notification templates: %', SQLERRM;
END;
$function$
;

