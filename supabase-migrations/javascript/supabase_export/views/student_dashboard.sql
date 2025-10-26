-- View: student_dashboard
-- Generated: 2025-10-25T15:36:11.742Z

CREATE OR REPLACE VIEW public.student_dashboard AS
 SELECT s.id AS student_id,
    s.student_id AS student_number,
    (((up.first_name)::text || ' '::text) || (up.last_name)::text) AS full_name,
    s.grade_level,
    s.current_streak_days,
    s.total_points,
    s.level,
    s.total_courses_enrolled,
    s.total_courses_completed,
    s.total_hours_learned,
    ( SELECT count(*) AS count
           FROM lesson_progress lp
          WHERE ((lp.student_id = s.id) AND (lp.last_accessed_at >= (now() - '7 days'::interval)))) AS lessons_this_week,
    ( SELECT count(*) AS count
           FROM course_enrollments ce
          WHERE ((ce.student_id = s.id) AND (ce.last_accessed_at >= (now() - '7 days'::interval)))) AS active_courses_this_week
   FROM (students s
     JOIN user_profiles up ON ((s.user_id = up.id)))
  WHERE (s.is_active = true);;

