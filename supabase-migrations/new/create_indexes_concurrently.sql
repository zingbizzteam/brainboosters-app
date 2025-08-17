-- =============================================
-- CONCURRENT INDEX CREATION FOR PRODUCTION LMS
-- Multi-Coaching Center Learning Management System
-- =============================================
-- 
-- This file should be run AFTER the main schema creation
-- Run each index creation separately or in small batches
-- Monitor system performance during index creation
-- =============================================

-- Core entity indexes
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_profiles_user_type 
    ON user_profiles(user_type) WHERE is_active = true;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_profiles_email 
    ON user_profiles(email);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_profiles_created_at 
    ON user_profiles(created_at);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_coaching_centers_approval 
    ON coaching_centers(approval_status, is_active);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_coaching_centers_code 
    ON coaching_centers(center_code);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_students_student_id 
    ON students(student_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_students_grade_level 
    ON students(grade_level) WHERE is_active = true;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_students_location 
    ON students(state, city);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_students_competitive_exams 
    ON students USING GIN(competitive_exams);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_teachers_center 
    ON teachers(coaching_center_id) WHERE status = 'active';

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_teachers_specializations 
    ON teachers USING GIN(specializations);

-- Course content indexes
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_courses_center 
    ON courses(coaching_center_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_courses_published 
    ON courses(is_published, is_featured);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_courses_category 
    ON courses(category_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_courses_rating 
    ON courses(rating DESC, total_reviews DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_courses_price 
    ON courses(price, currency);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_courses_enrollment_dates 
    ON courses(enrollment_start_date, enrollment_deadline);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_chapters_course_order 
    ON chapters(course_id, sort_order);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_lessons_chapter_order 
    ON lessons(chapter_id, sort_order);

-- Progress tracking indexes
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_course_enrollments_student 
    ON course_enrollments(student_id, is_active);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_course_enrollments_course 
    ON course_enrollments(course_id, is_active);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_course_enrollments_progress 
    ON course_enrollments(progress_percentage, completed_at);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_lesson_progress_student_course 
    ON lesson_progress(student_id, course_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_lesson_progress_completion 
    ON lesson_progress(is_completed, completed_at);

-- Assessment indexes
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tests_course 
    ON tests(course_id, is_published);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_test_results_student 
    ON test_results(student_id, completed_at);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_test_results_test 
    ON test_results(test_id, percentage DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_assignments_course_due 
    ON assignments(course_id, due_date, is_published);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_assignment_submissions_assignment 
    ON assignment_submissions(assignment_id, submitted_at);

-- Communication indexes
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_notifications_user_unread 
    ON notifications(user_id, is_read, created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_notifications_scheduled 
    ON notifications(scheduled_at) WHERE sent_at IS NULL;

-- Analytics indexes
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_analytics_events_user_date 
    ON analytics_events(user_id, server_timestamp);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_analytics_events_category 
    ON analytics_events(event_category, event_action, server_timestamp);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_learning_analytics_daily_student 
    ON learning_analytics_daily(student_id, date DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_learning_analytics_daily_course 
    ON learning_analytics_daily(course_id, date DESC);

-- Payment and commerce indexes
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_payments_student 
    ON payments(student_id, created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_payments_status 
    ON payments(status, created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_payments_course 
    ON payments(course_id) WHERE course_id IS NOT NULL;

-- Review indexes
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_reviews_course_published 
    ON reviews(course_id, is_published, created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_reviews_teacher 
    ON reviews(teacher_id, is_published);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_review_votes_review 
    ON review_votes(review_id);

-- Live class indexes
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_live_classes_scheduled 
    ON live_classes(scheduled_start, status);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_live_class_enrollments_student 
    ON live_class_enrollments(student_id, enrolled_at);

-- Unique partial indexes for reviews (replacing table constraints)
CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS idx_reviews_unique_student_course 
    ON reviews(student_id, course_id) WHERE course_id IS NOT NULL;

CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS idx_reviews_unique_student_teacher 
    ON reviews(student_id, teacher_id) WHERE teacher_id IS NOT NULL;

CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS idx_reviews_unique_student_live_class 
    ON reviews(student_id, live_class_id) WHERE live_class_id IS NOT NULL;

CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS idx_reviews_unique_student_center 
    ON reviews(student_id, coaching_center_id) WHERE coaching_center_id IS NOT NULL;

-- =============================================
-- Index Creation Complete
-- =============================================

