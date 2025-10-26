-- View: course_progress_summary
-- Generated: 2025-10-25T15:36:11.741Z

CREATE OR REPLACE VIEW public.course_progress_summary AS
 SELECT ce.student_id,
    ce.course_id,
    c.title AS course_title,
    ce.progress_percentage,
    ce.lessons_completed,
    ce.total_lessons_in_course,
    ce.total_time_spent_minutes,
    ce.enrolled_at,
    ce.last_accessed_at,
    ce.completed_at,
    ( SELECT l.id
           FROM ((lessons l
             JOIN chapters ch ON ((l.chapter_id = ch.id)))
             LEFT JOIN lesson_progress lp ON (((l.id = lp.lesson_id) AND (lp.student_id = ce.student_id))))
          WHERE ((ch.course_id = ce.course_id) AND (l.is_published = true) AND ((lp.is_completed IS NULL) OR (lp.is_completed = false)))
          ORDER BY ch.sort_order, l.sort_order
         LIMIT 1) AS next_lesson_id,
        CASE
            WHEN (ce.progress_percentage >= (80)::numeric) THEN 'excellent'::text
            WHEN (ce.progress_percentage >= (60)::numeric) THEN 'good'::text
            WHEN (ce.progress_percentage >= (40)::numeric) THEN 'average'::text
            ELSE 'needs_attention'::text
        END AS progress_status
   FROM (course_enrollments ce
     JOIN courses c ON ((ce.course_id = c.id)))
  WHERE (ce.is_active = true);;

