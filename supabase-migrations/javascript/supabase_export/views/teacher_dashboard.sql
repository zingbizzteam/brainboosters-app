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

