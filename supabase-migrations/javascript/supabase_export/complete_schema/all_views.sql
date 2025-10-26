-- Complete Views
-- Generated: 2025-10-25T15:36:11.741Z

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

-- View: teacher_dashboard
-- Generated: 2025-10-25T15:36:11.742Z

CREATE OR REPLACE VIEW public.teacher_dashboard AS
 SELECT t.id AS teacher_id,
    (((up.first_name)::text || ' '::text) || (up.last_name)::text) AS full_name,
    t.title,
    t.rating,
    t.total_reviews,
    t.total_courses,
    t.total_students_taught,
    cc.center_name,
    ( SELECT count(*) AS count
           FROM (course_teachers ct
             JOIN courses c ON ((ct.course_id = c.id)))
          WHERE ((ct.teacher_id = t.id) AND (c.is_published = true))) AS active_courses,
    ( SELECT count(*) AS count
           FROM (assignment_submissions asub
             JOIN assignments a ON ((asub.assignment_id = a.id)))
          WHERE ((a.teacher_id = t.id) AND ((asub.submission_status)::text = 'submitted'::text) AND (asub.grade IS NULL))) AS pending_grading,
    ( SELECT count(*) AS count
           FROM live_classes lc
          WHERE ((lc.primary_teacher_id = t.id) AND (lc.scheduled_start > now()) AND (lc.scheduled_start <= (now() + '7 days'::interval)) AND ((lc.status)::text = 'scheduled'::text))) AS upcoming_classes
   FROM ((teachers t
     JOIN user_profiles up ON ((t.user_id = up.id)))
     JOIN coaching_centers cc ON ((t.coaching_center_id = cc.id)))
  WHERE ((t.status)::text = 'active'::text);;

