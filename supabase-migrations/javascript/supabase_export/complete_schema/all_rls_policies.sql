-- Complete RLS Policies
-- Generated: 2025-10-25T15:36:11.443Z

-- RLS Policies for: analytics_events
-- Generated: 2025-10-25T15:36:11.443Z

ALTER TABLE public.analytics_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on analytics_events" ON public.analytics_events;
CREATE POLICY "admin policy on analytics_events"
  ON public.analytics_events
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.analytics_events;
CREATE POLICY "authenticated_user_policy"
  ON public.analytics_events
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

-- RLS Policies for: assignment_submissions
-- Generated: 2025-10-25T15:36:11.444Z

ALTER TABLE public.assignment_submissions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on assignment_submissions" ON public.assignment_submissions;
CREATE POLICY "admin policy on assignment_submissions"
  ON public.assignment_submissions
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.assignment_submissions;
CREATE POLICY "authenticated_user_policy"
  ON public.assignment_submissions
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

-- RLS Policies for: assignments
-- Generated: 2025-10-25T15:36:11.444Z

ALTER TABLE public.assignments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on assignments" ON public.assignments;
CREATE POLICY "admin policy on assignments"
  ON public.assignments
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.assignments;
CREATE POLICY "authenticated_user_policy"
  ON public.assignments
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

-- RLS Policies for: chapters
-- Generated: 2025-10-25T15:36:11.445Z

ALTER TABLE public.chapters ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on chapters" ON public.chapters;
CREATE POLICY "admin policy on chapters"
  ON public.chapters
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.chapters;
CREATE POLICY "authenticated_user_policy"
  ON public.chapters
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

-- RLS Policies for: coaching_centers
-- Generated: 2025-10-25T15:36:11.445Z

ALTER TABLE public.coaching_centers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on coaching_centers" ON public.coaching_centers;
CREATE POLICY "admin policy on coaching_centers"
  ON public.coaching_centers
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.coaching_centers;
CREATE POLICY "authenticated_user_policy"
  ON public.coaching_centers
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

-- RLS Policies for: course_categories
-- Generated: 2025-10-25T15:36:11.445Z

ALTER TABLE public.course_categories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on course_categories" ON public.course_categories;
CREATE POLICY "admin policy on course_categories"
  ON public.course_categories
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.course_categories;
CREATE POLICY "authenticated_user_policy"
  ON public.course_categories
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

-- RLS Policies for: course_enrollments
-- Generated: 2025-10-25T15:36:11.446Z

ALTER TABLE public.course_enrollments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Coaching centers can read their enrollments" ON public.course_enrollments;
CREATE POLICY "Coaching centers can read their enrollments"
  ON public.course_enrollments
  AS PERMISSIVE
  FOR SELECT
  TO {authenticated}
  USING ((auth.uid() = coaching_center_id))
;

DROP POLICY IF EXISTS "admin policy" ON public.course_enrollments;
CREATE POLICY "admin policy"
  ON public.course_enrollments
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((auth.uid() = '47288471-af42-4c23-be20-96a16c0a37c7'::uuid))
  WITH CHECK ((auth.uid() = '47288471-af42-4c23-be20-96a16c0a37c7'::uuid))
;

DROP POLICY IF EXISTS "admin policy on course_enrollments" ON public.course_enrollments;
CREATE POLICY "admin policy on course_enrollments"
  ON public.course_enrollments
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.course_enrollments;
CREATE POLICY "authenticated_user_policy"
  ON public.course_enrollments
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

DROP POLICY IF EXISTS "teacher can view the enorollments for their course" ON public.course_enrollments;
CREATE POLICY "teacher can view the enorollments for their course"
  ON public.course_enrollments
  AS PERMISSIVE
  FOR SELECT
  TO {authenticated}
  USING ((auth.uid() = teacher_id))
;

-- RLS Policies for: course_teachers
-- Generated: 2025-10-25T15:36:11.446Z

ALTER TABLE public.course_teachers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on course_teachers" ON public.course_teachers;
CREATE POLICY "admin policy on course_teachers"
  ON public.course_teachers
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.course_teachers;
CREATE POLICY "authenticated_user_policy"
  ON public.course_teachers
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

-- RLS Policies for: courses
-- Generated: 2025-10-25T15:36:11.446Z

ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow teacher to manage their own courses" ON public.courses;
CREATE POLICY "Allow teacher to manage their own courses"
  ON public.courses
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.uid() = primary_teacher_id))
;

DROP POLICY IF EXISTS "Coaching centers can manage their courses" ON public.courses;
CREATE POLICY "Coaching centers can manage their courses"
  ON public.courses
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.uid() = coaching_center_id))
  WITH CHECK ((auth.uid() = coaching_center_id))
;

DROP POLICY IF EXISTS "admin policy" ON public.courses;
CREATE POLICY "admin policy"
  ON public.courses
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((auth.uid() = '47288471-af42-4c23-be20-96a16c0a37c7'::uuid))
  WITH CHECK ((auth.uid() = '47288471-af42-4c23-be20-96a16c0a37c7'::uuid))
;

DROP POLICY IF EXISTS "admin policy on courses" ON public.courses;
CREATE POLICY "admin policy on courses"
  ON public.courses
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

-- RLS Policies for: learning_analytics_daily
-- Generated: 2025-10-25T15:36:11.447Z

ALTER TABLE public.learning_analytics_daily ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on learning_analytics_daily" ON public.learning_analytics_daily;
CREATE POLICY "admin policy on learning_analytics_daily"
  ON public.learning_analytics_daily
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

-- RLS Policies for: lesson_progress
-- Generated: 2025-10-25T15:36:11.447Z

ALTER TABLE public.lesson_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on lesson_progress" ON public.lesson_progress;
CREATE POLICY "admin policy on lesson_progress"
  ON public.lesson_progress
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.lesson_progress;
CREATE POLICY "authenticated_user_policy"
  ON public.lesson_progress
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

-- RLS Policies for: lessons
-- Generated: 2025-10-25T15:36:11.447Z

ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on lessons" ON public.lessons;
CREATE POLICY "admin policy on lessons"
  ON public.lessons
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.lessons;
CREATE POLICY "authenticated_user_policy"
  ON public.lessons
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

-- RLS Policies for: live_class_enrollments
-- Generated: 2025-10-25T15:36:11.448Z

ALTER TABLE public.live_class_enrollments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on live_class_enrollments" ON public.live_class_enrollments;
CREATE POLICY "admin policy on live_class_enrollments"
  ON public.live_class_enrollments
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.live_class_enrollments;
CREATE POLICY "authenticated_user_policy"
  ON public.live_class_enrollments
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

-- RLS Policies for: live_classes
-- Generated: 2025-10-25T15:36:11.448Z

ALTER TABLE public.live_classes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Teachers can manage their own classes" ON public.live_classes;
CREATE POLICY "Teachers can manage their own classes"
  ON public.live_classes
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.uid() = primary_teacher_id))
  WITH CHECK (true)
;

DROP POLICY IF EXISTS "admin policy on live_classes" ON public.live_classes;
CREATE POLICY "admin policy on live_classes"
  ON public.live_classes
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.live_classes;
CREATE POLICY "authenticated_user_policy"
  ON public.live_classes
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

-- RLS Policies for: notification_templates
-- Generated: 2025-10-25T15:36:11.448Z

ALTER TABLE public.notification_templates ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on notification_templates" ON public.notification_templates;
CREATE POLICY "admin policy on notification_templates"
  ON public.notification_templates
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

-- RLS Policies for: notifications
-- Generated: 2025-10-25T15:36:11.448Z

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on notifications" ON public.notifications;
CREATE POLICY "admin policy on notifications"
  ON public.notifications
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.notifications;
CREATE POLICY "authenticated_user_policy"
  ON public.notifications
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

-- RLS Policies for: payment_methods
-- Generated: 2025-10-25T15:36:11.449Z

ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on payment_methods" ON public.payment_methods;
CREATE POLICY "admin policy on payment_methods"
  ON public.payment_methods
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

-- RLS Policies for: payments
-- Generated: 2025-10-25T15:36:11.449Z

ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on payments" ON public.payments;
CREATE POLICY "admin policy on payments"
  ON public.payments
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.payments;
CREATE POLICY "authenticated_user_policy"
  ON public.payments
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

-- RLS Policies for: registration
-- Generated: 2025-10-25T15:36:11.450Z

ALTER TABLE public.registration ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admin policy" ON public.registration;
CREATE POLICY "Admin policy"
  ON public.registration
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "Allow new user to create a row in this table" ON public.registration;
CREATE POLICY "Allow new user to create a row in this table"
  ON public.registration
  AS PERMISSIVE
  FOR INSERT
  TO {anon}
  WITH CHECK (true)
;

-- RLS Policies for: review_reports
-- Generated: 2025-10-25T15:36:11.450Z

ALTER TABLE public.review_reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on review_reports" ON public.review_reports;
CREATE POLICY "admin policy on review_reports"
  ON public.review_reports
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

-- RLS Policies for: review_votes
-- Generated: 2025-10-25T15:36:11.450Z

ALTER TABLE public.review_votes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on review_votes" ON public.review_votes;
CREATE POLICY "admin policy on review_votes"
  ON public.review_votes
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.review_votes;
CREATE POLICY "authenticated_user_policy"
  ON public.review_votes
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

-- RLS Policies for: reviews
-- Generated: 2025-10-25T15:36:11.450Z

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on reviews" ON public.reviews;
CREATE POLICY "admin policy on reviews"
  ON public.reviews
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.reviews;
CREATE POLICY "authenticated_user_policy"
  ON public.reviews
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

-- RLS Policies for: students
-- Generated: 2025-10-25T15:36:11.451Z

ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on students" ON public.students;
CREATE POLICY "admin policy on students"
  ON public.students
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "admin_manage_students" ON public.students;
CREATE POLICY "admin_manage_students"
  ON public.students
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "users_manage_own_student_profile" ON public.students;
CREATE POLICY "users_manage_own_student_profile"
  ON public.students
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.uid() = user_id))
  WITH CHECK ((auth.uid() = user_id))
;

-- RLS Policies for: teachers
-- Generated: 2025-10-25T15:36:11.451Z

ALTER TABLE public.teachers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Coaching centers can manage their teachers" ON public.teachers;
CREATE POLICY "Coaching centers can manage their teachers"
  ON public.teachers
  AS PERMISSIVE
  FOR SELECT
  TO {authenticated}
  USING ((auth.uid() = coaching_center_id))
;

DROP POLICY IF EXISTS "admin" ON public.teachers;
CREATE POLICY "admin"
  ON public.teachers
  AS PERMISSIVE
  FOR SELECT
  TO {public}
  USING ((auth.uid() = '47288471-af42-4c23-be20-96a16c0a37c7'::uuid))
;

DROP POLICY IF EXISTS "admin policy on teachers" ON public.teachers;
CREATE POLICY "admin policy on teachers"
  ON public.teachers
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.teachers;
CREATE POLICY "authenticated_user_policy"
  ON public.teachers
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

DROP POLICY IF EXISTS "teacher can manage their own data" ON public.teachers;
CREATE POLICY "teacher can manage their own data"
  ON public.teachers
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.uid() = user_id))
;

-- RLS Policies for: test_questions
-- Generated: 2025-10-25T15:36:11.451Z

ALTER TABLE public.test_questions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on test_questions" ON public.test_questions;
CREATE POLICY "admin policy on test_questions"
  ON public.test_questions
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.test_questions;
CREATE POLICY "authenticated_user_policy"
  ON public.test_questions
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

-- RLS Policies for: test_results
-- Generated: 2025-10-25T15:36:11.452Z

ALTER TABLE public.test_results ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on test_results" ON public.test_results;
CREATE POLICY "admin policy on test_results"
  ON public.test_results
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.test_results;
CREATE POLICY "authenticated_user_policy"
  ON public.test_results
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

-- RLS Policies for: tests
-- Generated: 2025-10-25T15:36:11.452Z

ALTER TABLE public.tests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin policy on tests" ON public.tests;
CREATE POLICY "admin policy on tests"
  ON public.tests
  AS PERMISSIVE
  FOR ALL
  TO {public}
  USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.user_type)::text = 'admin'::text)))))
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.tests;
CREATE POLICY "authenticated_user_policy"
  ON public.tests
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

-- RLS Policies for: user_profiles
-- Generated: 2025-10-25T15:36:11.452Z

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated users can view see all users profile " ON public.user_profiles;
CREATE POLICY "Authenticated users can view see all users profile "
  ON public.user_profiles
  AS PERMISSIVE
  FOR SELECT
  TO {authenticated}
  USING (true)
;

DROP POLICY IF EXISTS "User can manage their own details" ON public.user_profiles;
CREATE POLICY "User can manage their own details"
  ON public.user_profiles
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.uid() = id))
  WITH CHECK (true)
;

DROP POLICY IF EXISTS "authenticated_user_policy" ON public.user_profiles;
CREATE POLICY "authenticated_user_policy"
  ON public.user_profiles
  AS PERMISSIVE
  FOR ALL
  TO {authenticated}
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text))
;

