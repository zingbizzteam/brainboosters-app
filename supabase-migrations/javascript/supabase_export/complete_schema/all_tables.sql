-- Complete Database Schema
-- Generated: 2025-10-25T15:36:09.268Z
-- Database: db.ytiednidnujnyczorddc.supabase.co

-- Table: analytics_events
-- Generated: 2025-10-25T15:36:09.269Z

CREATE TABLE IF NOT EXISTS public.analytics_events (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  session_id character varying(100),
  anonymous_id character varying(100),
  event_name character varying(100) NOT NULL,
  event_category character varying(50) NOT NULL,
  event_action character varying(100) NOT NULL,
  event_label character varying(200),
  event_value numeric,
  entity_type character varying(50),
  entity_id uuid,
  properties jsonb DEFAULT '{}'::jsonb,
  user_properties jsonb DEFAULT '{}'::jsonb,
  user_agent text,
  ip_address inet,
  country character varying(2),
  region character varying(100),
  city character varying(100),
  device_type character varying(20),
  device_model character varying(100),
  browser character varying(50),
  browser_version character varying(20),
  os character varying(50),
  os_version character varying(20),
  screen_resolution character varying(20),
  page_url text,
  page_title character varying(200),
  referrer text,
  utm_source character varying(100),
  utm_medium character varying(100),
  utm_campaign character varying(100),
  utm_content character varying(100),
  utm_term character varying(100),
  client_timestamp timestamp with time zone,
  server_timestamp timestamp with time zone DEFAULT now(),
  processed boolean DEFAULT false,
  processed_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.analytics_events ADD CONSTRAINT analytics_events_pkey PRIMARY KEY (id);
ALTER TABLE public.analytics_events ADD CONSTRAINT analytics_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES user_profiles(id);

-- Table: assignment_submissions
-- Generated: 2025-10-25T15:36:09.362Z

CREATE TABLE IF NOT EXISTS public.assignment_submissions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  assignment_id uuid NOT NULL,
  student_id uuid NOT NULL,
  submission_text text,
  submission_files jsonb DEFAULT '[]'::jsonb,
  submission_urls jsonb DEFAULT '[]'::jsonb,
  attempt_number integer DEFAULT 1,
  submitted_at timestamp with time zone DEFAULT now(),
  is_late boolean DEFAULT false,
  grade numeric,
  feedback text,
  detailed_feedback jsonb DEFAULT '{}'::jsonb,
  graded_at timestamp with time zone,
  graded_by uuid,
  submission_status character varying(20) DEFAULT 'submitted'::character varying,
  plagiarism_score numeric,
  plagiarism_report jsonb DEFAULT '{}'::jsonb,
  word_count integer DEFAULT 0,
  total_file_size_mb numeric DEFAULT 0,
  file_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  metadata jsonb DEFAULT '{}'::jsonb
);

-- Constraints
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES assignments(id);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_assignment_id_student_id_attempt_num_key UNIQUE (assignment_id);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_assignment_id_student_id_attempt_num_key UNIQUE (assignment_id);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_assignment_id_student_id_attempt_num_key UNIQUE (assignment_id);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_assignment_id_student_id_attempt_num_key UNIQUE (student_id);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_assignment_id_student_id_attempt_num_key UNIQUE (student_id);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_assignment_id_student_id_attempt_num_key UNIQUE (student_id);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_assignment_id_student_id_attempt_num_key UNIQUE (attempt_number);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_assignment_id_student_id_attempt_num_key UNIQUE (attempt_number);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_assignment_id_student_id_attempt_num_key UNIQUE (attempt_number);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_graded_by_fkey FOREIGN KEY (graded_by) REFERENCES teachers(id);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_pkey PRIMARY KEY (id);
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id);

-- Table: assignments
-- Generated: 2025-10-25T15:36:09.438Z

CREATE TABLE IF NOT EXISTS public.assignments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  course_id uuid NOT NULL,
  chapter_id uuid,
  teacher_id uuid NOT NULL,
  title character varying(300) NOT NULL,
  description text NOT NULL,
  instructions text,
  assignment_type character varying(30) DEFAULT 'project'::character varying,
  submission_format character varying(30) NOT NULL,
  total_marks numeric NOT NULL DEFAULT 100,
  passing_marks numeric DEFAULT 40,
  grading_rubric jsonb DEFAULT '{}'::jsonb,
  assigned_date timestamp with time zone DEFAULT now(),
  due_date timestamp with time zone NOT NULL,
  late_submission_deadline timestamp with time zone,
  allow_late_submission boolean DEFAULT true,
  late_penalty_percentage numeric DEFAULT 10,
  is_group_assignment boolean DEFAULT false,
  max_group_size integer DEFAULT 1,
  allow_resubmission boolean DEFAULT false,
  max_file_size_mb integer DEFAULT 50,
  allowed_file_types ARRAY DEFAULT '{pdf,doc,docx,txt,zip,jpg,png}'::text[],
  resources jsonb DEFAULT '[]'::jsonb,
  reference_materials jsonb DEFAULT '[]'::jsonb,
  sample_submissions jsonb DEFAULT '[]'::jsonb,
  is_published boolean DEFAULT false,
  is_archived boolean DEFAULT false,
  submission_count integer DEFAULT 0,
  on_time_submissions integer DEFAULT 0,
  average_grade numeric DEFAULT 0,
  plagiarism_check_enabled boolean DEFAULT false,
  auto_grade_enabled boolean DEFAULT false,
  ai_feedback_enabled boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.assignments ADD CONSTRAINT assignments_chapter_id_fkey FOREIGN KEY (chapter_id) REFERENCES chapters(id);
ALTER TABLE public.assignments ADD CONSTRAINT assignments_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.assignments ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);
ALTER TABLE public.assignments ADD CONSTRAINT assignments_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES teachers(user_id);

-- Table: chapters
-- Generated: 2025-10-25T15:36:09.516Z

CREATE TABLE IF NOT EXISTS public.chapters (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  course_id uuid NOT NULL,
  title character varying(300) NOT NULL,
  description text,
  chapter_number integer NOT NULL,
  duration_minutes integer DEFAULT 0,
  total_lessons integer DEFAULT 0,
  learning_objectives ARRAY DEFAULT '{}'::text[],
  is_published boolean DEFAULT false,
  is_free boolean DEFAULT false,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.chapters ADD CONSTRAINT chapters_course_id_chapter_number_key UNIQUE (course_id);
ALTER TABLE public.chapters ADD CONSTRAINT chapters_course_id_chapter_number_key UNIQUE (course_id);
ALTER TABLE public.chapters ADD CONSTRAINT chapters_course_id_chapter_number_key UNIQUE (chapter_number);
ALTER TABLE public.chapters ADD CONSTRAINT chapters_course_id_chapter_number_key UNIQUE (chapter_number);
ALTER TABLE public.chapters ADD CONSTRAINT chapters_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.chapters ADD CONSTRAINT chapters_course_id_sort_order_key UNIQUE (course_id);
ALTER TABLE public.chapters ADD CONSTRAINT chapters_course_id_sort_order_key UNIQUE (course_id);
ALTER TABLE public.chapters ADD CONSTRAINT chapters_course_id_sort_order_key UNIQUE (sort_order);
ALTER TABLE public.chapters ADD CONSTRAINT chapters_course_id_sort_order_key UNIQUE (sort_order);
ALTER TABLE public.chapters ADD CONSTRAINT chapters_pkey PRIMARY KEY (id);

-- Table: coaching_centers
-- Generated: 2025-10-25T15:36:09.596Z

CREATE TABLE IF NOT EXISTS public.coaching_centers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  center_name character varying(200) NOT NULL,
  center_code character varying(20) NOT NULL,
  description text,
  website_url text,
  logo_url text,
  contact_email character varying(255) NOT NULL,
  contact_phone character varying(20) NOT NULL,
  address jsonb NOT NULL DEFAULT '{}'::jsonb,
  registration_number character varying(100),
  tax_id character varying(50),
  approval_status character varying(20) DEFAULT 'pending'::character varying,
  approved_by uuid,
  approved_at timestamp with time zone,
  rejection_reason text,
  subscription_plan character varying(50) DEFAULT 'basic'::character varying,
  max_faculty_limit integer DEFAULT 10,
  max_courses_limit integer DEFAULT 50,
  max_students_limit integer DEFAULT 1000,
  is_active boolean DEFAULT true,
  total_courses integer DEFAULT 0,
  total_students integer DEFAULT 0,
  total_teachers integer DEFAULT 0,
  rating numeric DEFAULT 0.0,
  total_reviews integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.coaching_centers ADD CONSTRAINT coaching_centers_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES user_profiles(id);
ALTER TABLE public.coaching_centers ADD CONSTRAINT coaching_centers_center_code_key UNIQUE (center_code);
ALTER TABLE public.coaching_centers ADD CONSTRAINT coaching_centers_pkey PRIMARY KEY (id);
ALTER TABLE public.coaching_centers ADD CONSTRAINT coaching_centers_user_id_fkey FOREIGN KEY (user_id) REFERENCES user_profiles(id);
ALTER TABLE public.coaching_centers ADD CONSTRAINT coaching_centers_user_id_key UNIQUE (user_id);

-- Table: course_categories
-- Generated: 2025-10-25T15:36:09.674Z

CREATE TABLE IF NOT EXISTS public.course_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying(100) NOT NULL,
  slug character varying(100) NOT NULL,
  description text,
  parent_id uuid,
  icon_url text,
  is_active boolean DEFAULT true,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.course_categories ADD CONSTRAINT course_categories_name_key UNIQUE (name);
ALTER TABLE public.course_categories ADD CONSTRAINT course_categories_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES course_categories(id);
ALTER TABLE public.course_categories ADD CONSTRAINT course_categories_pkey PRIMARY KEY (id);
ALTER TABLE public.course_categories ADD CONSTRAINT course_categories_slug_key UNIQUE (slug);

-- Table: course_enrollments
-- Generated: 2025-10-25T15:36:09.746Z

CREATE TABLE IF NOT EXISTS public.course_enrollments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL,
  course_id uuid NOT NULL,
  enrolled_at timestamp with time zone DEFAULT now(),
  enrollment_method character varying(20) DEFAULT 'direct'::character varying,
  payment_status character varying(20) DEFAULT 'pending'::character varying,
  progress_percentage numeric DEFAULT 0.0,
  lessons_completed integer DEFAULT 0,
  total_lessons_in_course integer DEFAULT 0,
  chapters_completed integer DEFAULT 0,
  total_chapters_in_course integer DEFAULT 0,
  total_time_spent_minutes integer DEFAULT 0,
  average_session_duration_minutes numeric DEFAULT 0,
  total_sessions integer DEFAULT 0,
  completed_at timestamp with time zone,
  completion_percentage_required numeric DEFAULT 80.0,
  last_accessed_at timestamp with time zone,
  access_expires_at timestamp with time zone,
  is_active boolean DEFAULT true,
  current_chapter_id uuid,
  current_lesson_id uuid,
  bookmarked_lessons ARRAY DEFAULT '{}'::uuid[],
  notes text,
  certificate_issued boolean DEFAULT false,
  certificate_issued_at timestamp with time zone,
  certificate_id uuid,
  course_rating integer,
  course_review text,
  reviewed_at timestamp with time zone,
  average_quiz_score numeric DEFAULT 0,
  assignments_submitted integer DEFAULT 0,
  assignments_graded integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  teacher_id uuid,
  coaching_center_id uuid
);

-- Constraints
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_coaching_center_id_fkey FOREIGN KEY (coaching_center_id) REFERENCES coaching_centers(user_id);
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_current_chapter_id_fkey FOREIGN KEY (current_chapter_id) REFERENCES chapters(id);
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_current_lesson_id_fkey FOREIGN KEY (current_lesson_id) REFERENCES lessons(id);
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_pkey PRIMARY KEY (id);
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_student_id_course_id_key UNIQUE (student_id);
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_student_id_course_id_key UNIQUE (student_id);
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_student_id_course_id_key UNIQUE (course_id);
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_student_id_course_id_key UNIQUE (course_id);
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id);
ALTER TABLE public.course_enrollments ADD CONSTRAINT course_enrollments_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES teachers(user_id);

-- Table: course_teachers
-- Generated: 2025-10-25T15:36:09.846Z

CREATE TABLE IF NOT EXISTS public.course_teachers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  course_id uuid NOT NULL,
  teacher_id uuid NOT NULL,
  role character varying(50) DEFAULT 'instructor'::character varying,
  is_primary boolean DEFAULT false,
  permissions jsonb DEFAULT '{}'::jsonb,
  joined_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.course_teachers ADD CONSTRAINT course_teachers_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.course_teachers ADD CONSTRAINT course_teachers_course_id_teacher_id_key UNIQUE (course_id);
ALTER TABLE public.course_teachers ADD CONSTRAINT course_teachers_course_id_teacher_id_key UNIQUE (course_id);
ALTER TABLE public.course_teachers ADD CONSTRAINT course_teachers_course_id_teacher_id_key UNIQUE (teacher_id);
ALTER TABLE public.course_teachers ADD CONSTRAINT course_teachers_course_id_teacher_id_key UNIQUE (teacher_id);
ALTER TABLE public.course_teachers ADD CONSTRAINT course_teachers_pkey PRIMARY KEY (id);
ALTER TABLE public.course_teachers ADD CONSTRAINT course_teachers_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES teachers(id);

-- Table: courses
-- Generated: 2025-10-25T15:36:09.926Z

CREATE TABLE IF NOT EXISTS public.courses (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  category_id uuid,
  title character varying(300) NOT NULL,
  slug character varying(300) NOT NULL,
  description text,
  short_description text,
  thumbnail_url text,
  trailer_video_url text,
  course_content_overview text,
  what_you_learn ARRAY DEFAULT '{}'::text[],
  course_includes jsonb DEFAULT '{}'::jsonb,
  target_audience ARRAY DEFAULT '{}'::text[],
  prerequisites ARRAY DEFAULT '{}'::text[],
  learning_outcomes ARRAY DEFAULT '{}'::text[],
  level character varying(20) DEFAULT 'beginner'::character varying,
  language character varying(10) DEFAULT 'en'::character varying,
  tags ARRAY DEFAULT '{}'::text[],
  price numeric DEFAULT 0.00,
  original_price numeric,
  currency character varying(3) DEFAULT 'INR'::character varying,
  is_free boolean,
  duration_hours numeric DEFAULT 0,
  total_lessons integer DEFAULT 0,
  total_chapters integer DEFAULT 0,
  total_assignments integer DEFAULT 0,
  total_quizzes integer DEFAULT 0,
  max_enrollments integer,
  enrollment_start_date timestamp with time zone,
  enrollment_deadline timestamp with time zone,
  course_start_date timestamp with time zone,
  course_end_date timestamp with time zone,
  is_published boolean DEFAULT false,
  is_featured boolean DEFAULT false,
  is_archived boolean DEFAULT false,
  publish_date timestamp with time zone,
  enrollment_count integer DEFAULT 0,
  completed_count integer DEFAULT 0,
  rating numeric DEFAULT 0.0,
  total_reviews integer DEFAULT 0,
  completion_rate numeric DEFAULT 0.0,
  view_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  last_updated timestamp with time zone DEFAULT now(),
  published_at timestamp with time zone,
  primary_teacher_id uuid,
  coaching_center_id uuid
);

-- Constraints
ALTER TABLE public.courses ADD CONSTRAINT courses_category_id_fkey FOREIGN KEY (category_id) REFERENCES course_categories(id);
ALTER TABLE public.courses ADD CONSTRAINT courses_coaching_center_id_fkey FOREIGN KEY (coaching_center_id) REFERENCES coaching_centers(user_id);
ALTER TABLE public.courses ADD CONSTRAINT courses_pkey PRIMARY KEY (id);
ALTER TABLE public.courses ADD CONSTRAINT courses_primary_teacher_id_fkey FOREIGN KEY (primary_teacher_id) REFERENCES user_profiles(id);
ALTER TABLE public.courses ADD CONSTRAINT courses_slug_key UNIQUE (slug);

-- Table: learning_analytics_daily
-- Generated: 2025-10-25T15:36:10.006Z

CREATE TABLE IF NOT EXISTS public.learning_analytics_daily (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  date date NOT NULL,
  student_id uuid,
  course_id uuid,
  coaching_center_id uuid,
  total_time_spent_minutes integer DEFAULT 0,
  lessons_started integer DEFAULT 0,
  lessons_completed integer DEFAULT 0,
  videos_watched integer DEFAULT 0,
  video_watch_time_minutes integer DEFAULT 0,
  quizzes_attempted integer DEFAULT 0,
  quizzes_passed integer DEFAULT 0,
  average_quiz_score numeric DEFAULT 0.0,
  assignments_submitted integer DEFAULT 0,
  login_count integer DEFAULT 0,
  page_views integer DEFAULT 0,
  session_count integer DEFAULT 0,
  average_session_duration_minutes numeric DEFAULT 0,
  progress_gained numeric DEFAULT 0.0,
  streak_days integer DEFAULT 0,
  points_earned integer DEFAULT 0,
  help_requests integer DEFAULT 0,
  forum_posts integer DEFAULT 0,
  peer_interactions integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_coaching_center_id_fkey FOREIGN KEY (coaching_center_id) REFERENCES coaching_centers(id);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_date_student_id_course_id_key UNIQUE (date);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_date_student_id_course_id_key UNIQUE (date);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_date_student_id_course_id_key UNIQUE (date);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_date_student_id_course_id_key UNIQUE (student_id);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_date_student_id_course_id_key UNIQUE (student_id);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_date_student_id_course_id_key UNIQUE (student_id);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_date_student_id_course_id_key UNIQUE (course_id);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_date_student_id_course_id_key UNIQUE (course_id);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_date_student_id_course_id_key UNIQUE (course_id);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_pkey PRIMARY KEY (id);
ALTER TABLE public.learning_analytics_daily ADD CONSTRAINT learning_analytics_daily_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id);

-- Table: lesson_progress
-- Generated: 2025-10-25T15:36:10.096Z

CREATE TABLE IF NOT EXISTS public.lesson_progress (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL,
  lesson_id uuid NOT NULL,
  course_id uuid NOT NULL,
  started_at timestamp with time zone DEFAULT now(),
  completed_at timestamp with time zone,
  last_accessed_at timestamp with time zone DEFAULT now(),
  watch_time_seconds integer DEFAULT 0,
  total_video_duration_seconds integer DEFAULT 0,
  last_video_position_seconds integer DEFAULT 0,
  video_completion_percentage numeric DEFAULT 0.0,
  reading_progress_percentage numeric DEFAULT 0.0,
  reading_time_seconds integer DEFAULT 0,
  overall_progress_percentage numeric DEFAULT 0.0,
  is_completed boolean DEFAULT false,
  completion_criteria_met boolean DEFAULT false,
  total_visits integer DEFAULT 1,
  total_time_spent_seconds integer DEFAULT 0,
  engagement_score numeric DEFAULT 0.0,
  student_notes text,
  bookmarks jsonb DEFAULT '[]'::jsonb,
  is_bookmarked boolean DEFAULT false,
  focus_time_seconds integer DEFAULT 0,
  distraction_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.lesson_progress ADD CONSTRAINT lesson_progress_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.lesson_progress ADD CONSTRAINT lesson_progress_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES lessons(id);
ALTER TABLE public.lesson_progress ADD CONSTRAINT lesson_progress_pkey PRIMARY KEY (id);
ALTER TABLE public.lesson_progress ADD CONSTRAINT lesson_progress_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id);
ALTER TABLE public.lesson_progress ADD CONSTRAINT lesson_progress_student_id_lesson_id_key UNIQUE (student_id);
ALTER TABLE public.lesson_progress ADD CONSTRAINT lesson_progress_student_id_lesson_id_key UNIQUE (student_id);
ALTER TABLE public.lesson_progress ADD CONSTRAINT lesson_progress_student_id_lesson_id_key UNIQUE (lesson_id);
ALTER TABLE public.lesson_progress ADD CONSTRAINT lesson_progress_student_id_lesson_id_key UNIQUE (lesson_id);

-- Table: lessons
-- Generated: 2025-10-25T15:36:10.170Z

CREATE TABLE IF NOT EXISTS public.lessons (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  chapter_id uuid NOT NULL,
  course_id uuid NOT NULL,
  title character varying(300) NOT NULL,
  description text,
  lesson_number integer NOT NULL,
  lesson_type character varying(20) DEFAULT 'video'::character varying,
  content_url text,
  video_duration integer,
  transcript text,
  notes text,
  attachments jsonb DEFAULT '[]'::jsonb,
  resources jsonb DEFAULT '[]'::jsonb,
  is_published boolean DEFAULT false,
  is_free boolean DEFAULT false,
  is_downloadable boolean DEFAULT false,
  requires_completion boolean DEFAULT false,
  view_count integer DEFAULT 0,
  completion_count integer DEFAULT 0,
  completion_rate numeric DEFAULT 0.0,
  average_watch_time integer DEFAULT 0,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.lessons ADD CONSTRAINT lessons_chapter_id_fkey FOREIGN KEY (chapter_id) REFERENCES chapters(id);
ALTER TABLE public.lessons ADD CONSTRAINT lessons_chapter_id_lesson_number_key UNIQUE (chapter_id);
ALTER TABLE public.lessons ADD CONSTRAINT lessons_chapter_id_lesson_number_key UNIQUE (chapter_id);
ALTER TABLE public.lessons ADD CONSTRAINT lessons_chapter_id_lesson_number_key UNIQUE (lesson_number);
ALTER TABLE public.lessons ADD CONSTRAINT lessons_chapter_id_lesson_number_key UNIQUE (lesson_number);
ALTER TABLE public.lessons ADD CONSTRAINT lessons_chapter_id_sort_order_key UNIQUE (chapter_id);
ALTER TABLE public.lessons ADD CONSTRAINT lessons_chapter_id_sort_order_key UNIQUE (chapter_id);
ALTER TABLE public.lessons ADD CONSTRAINT lessons_chapter_id_sort_order_key UNIQUE (sort_order);
ALTER TABLE public.lessons ADD CONSTRAINT lessons_chapter_id_sort_order_key UNIQUE (sort_order);
ALTER TABLE public.lessons ADD CONSTRAINT lessons_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.lessons ADD CONSTRAINT lessons_pkey PRIMARY KEY (id);

-- Table: live_class_enrollments
-- Generated: 2025-10-25T15:36:10.250Z

CREATE TABLE IF NOT EXISTS public.live_class_enrollments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL,
  live_class_id uuid NOT NULL,
  enrolled_at timestamp with time zone DEFAULT now(),
  enrollment_source character varying(20) DEFAULT 'direct'::character varying,
  joined_at timestamp with time zone,
  left_at timestamp with time zone,
  attendance_duration_minutes integer DEFAULT 0,
  attended boolean DEFAULT false,
  attendance_percentage numeric DEFAULT 0.0,
  questions_asked integer DEFAULT 0,
  chat_messages_sent integer DEFAULT 0,
  polls_participated integer DEFAULT 0,
  engagement_score numeric DEFAULT 0.0,
  connection_quality character varying(10) DEFAULT 'good'::character varying,
  device_type character varying(20),
  browser_info text,
  session_rating integer,
  feedback_text text,
  feedback_submitted_at timestamp with time zone,
  status character varying(20) DEFAULT 'registered'::character varying,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.live_class_enrollments ADD CONSTRAINT live_class_enrollments_live_class_id_fkey FOREIGN KEY (live_class_id) REFERENCES live_classes(id);
ALTER TABLE public.live_class_enrollments ADD CONSTRAINT live_class_enrollments_pkey PRIMARY KEY (id);
ALTER TABLE public.live_class_enrollments ADD CONSTRAINT live_class_enrollments_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id);
ALTER TABLE public.live_class_enrollments ADD CONSTRAINT live_class_enrollments_student_id_live_class_id_key UNIQUE (student_id);
ALTER TABLE public.live_class_enrollments ADD CONSTRAINT live_class_enrollments_student_id_live_class_id_key UNIQUE (student_id);
ALTER TABLE public.live_class_enrollments ADD CONSTRAINT live_class_enrollments_student_id_live_class_id_key UNIQUE (live_class_id);
ALTER TABLE public.live_class_enrollments ADD CONSTRAINT live_class_enrollments_student_id_live_class_id_key UNIQUE (live_class_id);

-- Table: live_classes
-- Generated: 2025-10-25T15:36:10.325Z

CREATE TABLE IF NOT EXISTS public.live_classes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  coaching_center_id uuid,
  course_id uuid,
  chapter_id uuid,
  primary_teacher_id uuid,
  title character varying(300) NOT NULL,
  description text,
  agenda text,
  learning_objectives ARRAY DEFAULT '{}'::text[],
  scheduled_start timestamp with time zone NOT NULL,
  scheduled_end timestamp with time zone,
  actual_start timestamp with time zone,
  actual_end timestamp with time zone,
  timezone character varying(50) DEFAULT 'Asia/Kolkata'::character varying,
  max_participants integer DEFAULT 100,
  current_participants integer DEFAULT 0,
  auto_record boolean DEFAULT false,
  allow_chat boolean DEFAULT true,
  allow_qa boolean DEFAULT true,
  allow_screen_sharing boolean DEFAULT false,
  require_approval boolean DEFAULT false,
  meeting_platform character varying(20) DEFAULT 'zoom'::character varying,
  meeting_url text,
  meeting_id character varying(100),
  meeting_password character varying(100),
  dial_in_numbers jsonb DEFAULT '[]'::jsonb,
  price numeric DEFAULT 0.00,
  currency character varying(3) DEFAULT 'INR'::character varying,
  is_free boolean,
  thumbnail_url text,
  presentation_url text,
  resources jsonb DEFAULT '[]'::jsonb,
  status character varying(20) DEFAULT 'scheduled'::character varying,
  cancellation_reason text,
  recording_url text,
  recording_duration_minutes integer,
  recording_size_mb numeric,
  recording_available_until timestamp with time zone,
  total_registered integer DEFAULT 0,
  total_attended integer DEFAULT 0,
  average_attendance_duration_minutes numeric DEFAULT 0,
  engagement_score numeric DEFAULT 0.0,
  average_rating numeric DEFAULT 0.0,
  total_feedback_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.live_classes ADD CONSTRAINT live_classes_chapter_id_fkey FOREIGN KEY (chapter_id) REFERENCES chapters(id);
ALTER TABLE public.live_classes ADD CONSTRAINT live_classes_coaching_center_id_fkey FOREIGN KEY (coaching_center_id) REFERENCES coaching_centers(user_id);
ALTER TABLE public.live_classes ADD CONSTRAINT live_classes_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.live_classes ADD CONSTRAINT live_classes_pkey PRIMARY KEY (id);
ALTER TABLE public.live_classes ADD CONSTRAINT live_classes_primary_teacher_id_fkey FOREIGN KEY (primary_teacher_id) REFERENCES teachers(user_id);

-- Table: notification_templates
-- Generated: 2025-10-25T15:36:10.397Z

CREATE TABLE IF NOT EXISTS public.notification_templates (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying(100) NOT NULL,
  title_template text NOT NULL,
  message_template text NOT NULL,
  notification_type character varying(50) NOT NULL,
  channels ARRAY DEFAULT '{in_app}'::text[],
  is_active boolean DEFAULT true,
  variables jsonb DEFAULT '[]'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.notification_templates ADD CONSTRAINT notification_templates_name_key UNIQUE (name);
ALTER TABLE public.notification_templates ADD CONSTRAINT notification_templates_pkey PRIMARY KEY (id);

-- Table: notifications
-- Generated: 2025-10-25T15:36:10.460Z

CREATE TABLE IF NOT EXISTS public.notifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  title character varying(255) NOT NULL,
  message text NOT NULL,
  notification_type character varying(50) NOT NULL,
  reference_id uuid,
  reference_type character varying(50),
  channels ARRAY DEFAULT '{in_app}'::text[],
  delivery_status jsonb DEFAULT '{}'::jsonb,
  priority character varying(10) DEFAULT 'medium'::character varying,
  is_read boolean DEFAULT false,
  read_at timestamp with time zone,
  scheduled_at timestamp with time zone DEFAULT now(),
  sent_at timestamp with time zone,
  expires_at timestamp with time zone,
  category character varying(50) DEFAULT 'general'::character varying,
  action_url text,
  action_label character varying(50),
  metadata jsonb DEFAULT '{}'::jsonb,
  template_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.notifications ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);
ALTER TABLE public.notifications ADD CONSTRAINT notifications_template_id_fkey FOREIGN KEY (template_id) REFERENCES notification_templates(id);
ALTER TABLE public.notifications ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES user_profiles(id);

-- Table: payment_methods
-- Generated: 2025-10-25T15:36:10.532Z

CREATE TABLE IF NOT EXISTS public.payment_methods (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying(50) NOT NULL,
  display_name character varying(100) NOT NULL,
  provider character varying(50) NOT NULL,
  is_active boolean DEFAULT true,
  supports_refunds boolean DEFAULT true,
  processing_fee_percentage numeric DEFAULT 0,
  min_amount numeric DEFAULT 0,
  max_amount numeric,
  supported_currencies ARRAY DEFAULT '{INR}'::text[],
  configuration jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.payment_methods ADD CONSTRAINT payment_methods_name_key UNIQUE (name);
ALTER TABLE public.payment_methods ADD CONSTRAINT payment_methods_pkey PRIMARY KEY (id);

-- Table: payments
-- Generated: 2025-10-25T15:36:10.587Z

CREATE TABLE IF NOT EXISTS public.payments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL,
  course_id uuid,
  live_class_id uuid,
  items jsonb DEFAULT '[]'::jsonb,
  payment_type character varying(20) NOT NULL,
  subtotal numeric NOT NULL,
  discount_amount numeric DEFAULT 0,
  tax_amount numeric DEFAULT 0,
  processing_fee numeric DEFAULT 0,
  total_amount numeric NOT NULL,
  currency character varying(3) DEFAULT 'INR'::character varying,
  payment_method_id uuid,
  payment_gateway character varying(50) NOT NULL,
  gateway_transaction_id character varying(200),
  internal_transaction_id character varying(100) NOT NULL DEFAULT (gen_random_uuid())::text,
  status character varying(20) DEFAULT 'pending'::character varying,
  failure_reason text,
  initiated_at timestamp with time zone DEFAULT now(),
  processed_at timestamp with time zone,
  completed_at timestamp with time zone,
  refund_amount numeric DEFAULT 0.00,
  refund_reason text,
  refunded_at timestamp with time zone,
  refunded_by uuid,
  coupon_code character varying(50),
  discount_type character varying(20),
  discount_value numeric DEFAULT 0,
  invoice_number character varying(50),
  invoice_url text,
  customer_details jsonb DEFAULT '{}'::jsonb,
  gateway_response jsonb DEFAULT '{}'::jsonb,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.payments ADD CONSTRAINT payments_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.payments ADD CONSTRAINT payments_internal_transaction_id_key UNIQUE (internal_transaction_id);
ALTER TABLE public.payments ADD CONSTRAINT payments_invoice_number_key UNIQUE (invoice_number);
ALTER TABLE public.payments ADD CONSTRAINT payments_live_class_id_fkey FOREIGN KEY (live_class_id) REFERENCES live_classes(id);
ALTER TABLE public.payments ADD CONSTRAINT payments_payment_method_id_fkey FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id);
ALTER TABLE public.payments ADD CONSTRAINT payments_pkey PRIMARY KEY (id);
ALTER TABLE public.payments ADD CONSTRAINT payments_refunded_by_fkey FOREIGN KEY (refunded_by) REFERENCES user_profiles(id);
ALTER TABLE public.payments ADD CONSTRAINT payments_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id);

-- Table: registration
-- Generated: 2025-10-25T15:36:10.670Z

CREATE TABLE IF NOT EXISTS public.registration (
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  first_name text NOT NULL,
  last_name text,
  email character varying NOT NULL,
  phone_number numeric NOT NULL,
  address json NOT NULL,
  password character varying NOT NULL,
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  center_name text NOT NULL,
  approval_status USER-DEFINED NOT NULL DEFAULT 'pending'::approval_status
);

-- Constraints
ALTER TABLE public.registration ADD CONSTRAINT registration_email_key UNIQUE (email);
ALTER TABLE public.registration ADD CONSTRAINT registration_pkey PRIMARY KEY (id);

-- Table: review_reports
-- Generated: 2025-10-25T15:36:10.733Z

CREATE TABLE IF NOT EXISTS public.review_reports (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  review_id uuid NOT NULL,
  reported_by uuid NOT NULL,
  reason character varying(50) NOT NULL,
  description text,
  status character varying(20) DEFAULT 'pending'::character varying,
  resolved_by uuid,
  resolved_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.review_reports ADD CONSTRAINT review_reports_pkey PRIMARY KEY (id);
ALTER TABLE public.review_reports ADD CONSTRAINT review_reports_reported_by_fkey FOREIGN KEY (reported_by) REFERENCES user_profiles(id);
ALTER TABLE public.review_reports ADD CONSTRAINT review_reports_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES user_profiles(id);
ALTER TABLE public.review_reports ADD CONSTRAINT review_reports_review_id_fkey FOREIGN KEY (review_id) REFERENCES reviews(id);
ALTER TABLE public.review_reports ADD CONSTRAINT review_reports_review_id_reported_by_key UNIQUE (review_id);
ALTER TABLE public.review_reports ADD CONSTRAINT review_reports_review_id_reported_by_key UNIQUE (review_id);
ALTER TABLE public.review_reports ADD CONSTRAINT review_reports_review_id_reported_by_key UNIQUE (reported_by);
ALTER TABLE public.review_reports ADD CONSTRAINT review_reports_review_id_reported_by_key UNIQUE (reported_by);

-- Table: review_votes
-- Generated: 2025-10-25T15:36:10.805Z

CREATE TABLE IF NOT EXISTS public.review_votes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  review_id uuid NOT NULL,
  user_id uuid NOT NULL,
  vote_type character varying(15) NOT NULL,
  created_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.review_votes ADD CONSTRAINT review_votes_pkey PRIMARY KEY (id);
ALTER TABLE public.review_votes ADD CONSTRAINT review_votes_review_id_fkey FOREIGN KEY (review_id) REFERENCES reviews(id);
ALTER TABLE public.review_votes ADD CONSTRAINT review_votes_review_id_user_id_key UNIQUE (review_id);
ALTER TABLE public.review_votes ADD CONSTRAINT review_votes_review_id_user_id_key UNIQUE (review_id);
ALTER TABLE public.review_votes ADD CONSTRAINT review_votes_review_id_user_id_key UNIQUE (user_id);
ALTER TABLE public.review_votes ADD CONSTRAINT review_votes_review_id_user_id_key UNIQUE (user_id);
ALTER TABLE public.review_votes ADD CONSTRAINT review_votes_user_id_fkey FOREIGN KEY (user_id) REFERENCES user_profiles(id);

-- Table: reviews
-- Generated: 2025-10-25T15:36:10.875Z

CREATE TABLE IF NOT EXISTS public.reviews (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL,
  course_id uuid,
  teacher_id uuid,
  live_class_id uuid,
  coaching_center_id uuid,
  review_type character varying(20) NOT NULL,
  overall_rating numeric NOT NULL,
  content_rating numeric,
  instructor_rating numeric,
  value_rating numeric,
  difficulty_rating numeric,
  title character varying(200),
  review_text text,
  pros text,
  cons text,
  is_verified_purchase boolean DEFAULT false,
  completed_percentage numeric DEFAULT 0,
  is_published boolean DEFAULT true,
  is_featured boolean DEFAULT false,
  moderation_status character varying(20) DEFAULT 'approved'::character varying,
  moderation_reason text,
  moderated_by uuid,
  moderated_at timestamp with time zone,
  helpful_votes integer DEFAULT 0,
  not_helpful_votes integer DEFAULT 0,
  total_votes integer,
  helpfulness_score numeric DEFAULT 0.0,
  report_count integer DEFAULT 0,
  last_reported_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.reviews ADD CONSTRAINT reviews_coaching_center_id_fkey FOREIGN KEY (coaching_center_id) REFERENCES coaching_centers(user_id);
ALTER TABLE public.reviews ADD CONSTRAINT reviews_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.reviews ADD CONSTRAINT reviews_live_class_id_fkey FOREIGN KEY (live_class_id) REFERENCES live_classes(id);
ALTER TABLE public.reviews ADD CONSTRAINT reviews_moderated_by_fkey FOREIGN KEY (moderated_by) REFERENCES user_profiles(id);
ALTER TABLE public.reviews ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);
ALTER TABLE public.reviews ADD CONSTRAINT reviews_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id);
ALTER TABLE public.reviews ADD CONSTRAINT reviews_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES teachers(user_id);

-- Table: students
-- Generated: 2025-10-25T15:36:10.957Z

CREATE TABLE IF NOT EXISTS public.students (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  student_id character varying(50) NOT NULL,
  grade_level character varying(50),
  education_board character varying(50),
  primary_interest character varying(100),
  secondary_interests ARRAY DEFAULT '{}'::text[],
  state character varying(100),
  city character varying(100),
  pincode character varying(10),
  preferred_language character varying(10) DEFAULT 'en'::character varying,
  other_languages ARRAY DEFAULT '{}'::text[],
  school_name character varying(200),
  institution_type character varying(50),
  parent_name character varying(200),
  parent_phone character varying(20),
  parent_email character varying(255),
  guardian_relationship character varying(50) DEFAULT 'parent'::character varying,
  learning_goals ARRAY DEFAULT '{}'::text[],
  preferred_learning_style character varying(50),
  competitive_exams ARRAY DEFAULT '{}'::text[],
  target_exam_year integer,
  timezone character varying(50) DEFAULT 'Asia/Kolkata'::character varying,
  total_courses_enrolled integer DEFAULT 0,
  total_courses_completed integer DEFAULT 0,
  total_hours_learned numeric DEFAULT 0.0,
  current_streak_days integer DEFAULT 0,
  longest_streak_days integer DEFAULT 0,
  total_points integer DEFAULT 0,
  level integer DEFAULT 1,
  badges jsonb DEFAULT '[]'::jsonb,
  achievements jsonb DEFAULT '{}'::jsonb,
  daily_study_goal_minutes integer DEFAULT 60,
  preferred_study_time character varying(20) DEFAULT 'evening'::character varying,
  is_active boolean DEFAULT true,
  is_verified boolean DEFAULT false,
  verification_method character varying(50),
  subscription_status character varying(20) DEFAULT 'free'::character varying,
  subscription_expires_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  last_login_date date,
  last_streak_update_date date,
  profile_completed_at timestamp with time zone
);

-- Constraints
ALTER TABLE public.students ADD CONSTRAINT students_pkey PRIMARY KEY (id);
ALTER TABLE public.students ADD CONSTRAINT students_student_id_key UNIQUE (student_id);
ALTER TABLE public.students ADD CONSTRAINT students_user_id_fkey FOREIGN KEY (user_id) REFERENCES user_profiles(id);
ALTER TABLE public.students ADD CONSTRAINT students_user_id_key UNIQUE (user_id);

-- Table: teachers
-- Generated: 2025-10-25T15:36:11.036Z

CREATE TABLE IF NOT EXISTS public.teachers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  coaching_center_id uuid NOT NULL,
  employee_id character varying(50),
  title character varying(100),
  specializations ARRAY DEFAULT '{}'::text[],
  qualifications ARRAY,
  experience_years integer DEFAULT 0,
  bio text,
  hourly_rate numeric,
  rating numeric DEFAULT 0.0,
  total_reviews integer DEFAULT 0,
  total_courses integer DEFAULT 0,
  total_students_taught integer DEFAULT 0,
  is_verified boolean DEFAULT false,
  can_create_courses boolean DEFAULT true,
  can_conduct_live_classes boolean DEFAULT true,
  can_grade_assignments boolean DEFAULT true,
  status character varying(20) DEFAULT 'active'::character varying,
  joined_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.teachers ADD CONSTRAINT teachers_coaching_center_id_fkey FOREIGN KEY (coaching_center_id) REFERENCES coaching_centers(user_id);
ALTER TABLE public.teachers ADD CONSTRAINT teachers_pkey PRIMARY KEY (id);
ALTER TABLE public.teachers ADD CONSTRAINT teachers_user_id_fkey FOREIGN KEY (user_id) REFERENCES user_profiles(id);
ALTER TABLE public.teachers ADD CONSTRAINT teachers_user_id_key UNIQUE (user_id);
ALTER TABLE public.teachers ADD CONSTRAINT unique_employee_per_center UNIQUE (coaching_center_id);
ALTER TABLE public.teachers ADD CONSTRAINT unique_employee_per_center UNIQUE (coaching_center_id);
ALTER TABLE public.teachers ADD CONSTRAINT unique_employee_per_center UNIQUE (employee_id);
ALTER TABLE public.teachers ADD CONSTRAINT unique_employee_per_center UNIQUE (employee_id);

-- Table: test_questions
-- Generated: 2025-10-25T15:36:11.106Z

CREATE TABLE IF NOT EXISTS public.test_questions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  test_id uuid NOT NULL,
  question_text text NOT NULL,
  question_type character varying(20) DEFAULT 'mcq'::character varying,
  options jsonb DEFAULT '[]'::jsonb,
  correct_answers jsonb NOT NULL,
  explanation text,
  hints ARRAY,
  marks numeric DEFAULT 1,
  negative_marks numeric DEFAULT 0,
  difficulty_level character varying(10) DEFAULT 'medium'::character varying,
  topic character varying(200),
  subtopic character varying(200),
  tags ARRAY DEFAULT '{}'::text[],
  question_order integer NOT NULL,
  time_limit_seconds integer,
  attempt_count integer DEFAULT 0,
  correct_count integer DEFAULT 0,
  difficulty_score numeric DEFAULT 0.5,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.test_questions ADD CONSTRAINT test_questions_pkey PRIMARY KEY (id);
ALTER TABLE public.test_questions ADD CONSTRAINT test_questions_test_id_fkey FOREIGN KEY (test_id) REFERENCES tests(id);
ALTER TABLE public.test_questions ADD CONSTRAINT test_questions_test_id_question_order_key UNIQUE (test_id);
ALTER TABLE public.test_questions ADD CONSTRAINT test_questions_test_id_question_order_key UNIQUE (test_id);
ALTER TABLE public.test_questions ADD CONSTRAINT test_questions_test_id_question_order_key UNIQUE (question_order);
ALTER TABLE public.test_questions ADD CONSTRAINT test_questions_test_id_question_order_key UNIQUE (question_order);

-- Table: test_results
-- Generated: 2025-10-25T15:36:11.170Z

CREATE TABLE IF NOT EXISTS public.test_results (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  test_id uuid NOT NULL,
  student_id uuid NOT NULL,
  attempt_number integer DEFAULT 1,
  started_at timestamp with time zone DEFAULT now(),
  completed_at timestamp with time zone,
  submitted_at timestamp with time zone,
  total_questions integer NOT NULL,
  questions_attempted integer DEFAULT 0,
  correct_answers integer DEFAULT 0,
  incorrect_answers integer DEFAULT 0,
  skipped_questions integer DEFAULT 0,
  score numeric NOT NULL DEFAULT 0,
  total_marks numeric NOT NULL,
  percentage numeric,
  passed boolean DEFAULT false,
  grade character varying(5),
  time_taken_minutes integer,
  time_limit_minutes integer,
  extra_time_used integer DEFAULT 0,
  answers jsonb DEFAULT '{}'::jsonb,
  question_wise_analysis jsonb DEFAULT '{}'::jsonb,
  is_submitted boolean DEFAULT false,
  is_flagged boolean DEFAULT false,
  flag_reason text,
  is_proctored boolean DEFAULT false,
  proctoring_data jsonb DEFAULT '{}'::jsonb,
  rank_in_test integer,
  percentile numeric,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.test_results ADD CONSTRAINT test_results_pkey PRIMARY KEY (id);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_test_id_fkey FOREIGN KEY (test_id) REFERENCES tests(id);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_test_id_student_id_attempt_number_key UNIQUE (test_id);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_test_id_student_id_attempt_number_key UNIQUE (test_id);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_test_id_student_id_attempt_number_key UNIQUE (test_id);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_test_id_student_id_attempt_number_key UNIQUE (student_id);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_test_id_student_id_attempt_number_key UNIQUE (student_id);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_test_id_student_id_attempt_number_key UNIQUE (student_id);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_test_id_student_id_attempt_number_key UNIQUE (attempt_number);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_test_id_student_id_attempt_number_key UNIQUE (attempt_number);
ALTER TABLE public.test_results ADD CONSTRAINT test_results_test_id_student_id_attempt_number_key UNIQUE (attempt_number);

-- Table: tests
-- Generated: 2025-10-25T15:36:11.246Z

CREATE TABLE IF NOT EXISTS public.tests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  course_id uuid NOT NULL,
  chapter_id uuid,
  lesson_id uuid,
  coaching_center_id uuid NOT NULL,
  teacher_id uuid,
  title character varying(300) NOT NULL,
  description text,
  instructions text,
  test_type character varying(20) DEFAULT 'quiz'::character varying,
  difficulty_level character varying(20) DEFAULT 'medium'::character varying,
  total_questions integer NOT NULL,
  total_marks numeric NOT NULL,
  passing_marks numeric NOT NULL,
  negative_marking boolean DEFAULT false,
  negative_marks_per_question numeric DEFAULT 0,
  time_limit_minutes integer,
  extra_time_minutes integer DEFAULT 0,
  attempts_allowed integer DEFAULT 1,
  time_between_attempts_hours integer DEFAULT 0,
  show_results_immediately boolean DEFAULT true,
  show_correct_answers boolean DEFAULT true,
  show_explanations boolean DEFAULT true,
  randomize_questions boolean DEFAULT false,
  randomize_options boolean DEFAULT false,
  available_from timestamp with time zone,
  available_until timestamp with time zone,
  is_published boolean DEFAULT false,
  is_proctored boolean DEFAULT false,
  attempt_count integer DEFAULT 0,
  average_score numeric DEFAULT 0,
  pass_rate numeric DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.tests ADD CONSTRAINT tests_chapter_id_fkey FOREIGN KEY (chapter_id) REFERENCES chapters(id);
ALTER TABLE public.tests ADD CONSTRAINT tests_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE public.tests ADD CONSTRAINT tests_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES lessons(id);
ALTER TABLE public.tests ADD CONSTRAINT tests_pkey PRIMARY KEY (id);
ALTER TABLE public.tests ADD CONSTRAINT tests_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES teachers(user_id);

-- Table: user_profiles
-- Generated: 2025-10-25T15:36:11.320Z

CREATE TABLE IF NOT EXISTS public.user_profiles (
  id uuid NOT NULL,
  user_type character varying(20) NOT NULL,
  first_name character varying(100) NOT NULL,
  last_name character varying(100) NOT NULL,
  email character varying(255) NOT NULL,
  phone character varying(20),
  avatar_url text,
  date_of_birth date,
  gender character varying(10),
  address jsonb DEFAULT '{}'::jsonb,
  is_active boolean DEFAULT true,
  email_verified boolean DEFAULT false,
  phone_verified boolean DEFAULT false,
  onboarding_completed boolean DEFAULT false,
  preferences jsonb DEFAULT '{}'::jsonb,
  last_seen timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Constraints
ALTER TABLE public.user_profiles ADD CONSTRAINT user_profiles_id_fkey FOREIGN KEY (id) REFERENCES null(null);
ALTER TABLE public.user_profiles ADD CONSTRAINT user_profiles_id_key UNIQUE (id);
ALTER TABLE public.user_profiles ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (id);

