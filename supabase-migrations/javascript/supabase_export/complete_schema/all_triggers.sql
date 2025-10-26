-- Complete Triggers
-- Generated: 2025-10-25T15:36:11.518Z

-- Triggers for: assignment_submissions
-- Generated: 2025-10-25T15:36:11.518Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.assignment_submissions FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: assignments
-- Generated: 2025-10-25T15:36:11.519Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.assignments FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: chapters
-- Generated: 2025-10-25T15:36:11.519Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.chapters FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: coaching_centers
-- Generated: 2025-10-25T15:36:11.520Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.coaching_centers FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: course_categories
-- Generated: 2025-10-25T15:36:11.520Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.course_categories FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: course_enrollments
-- Generated: 2025-10-25T15:36:11.520Z

CREATE TRIGGER trigger_update_course_stats_enrollments AFTER INSERT OR DELETE OR UPDATE ON public.course_enrollments FOR EACH ROW EXECUTE FUNCTION update_course_stats();

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.course_enrollments FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: courses
-- Generated: 2025-10-25T15:36:11.521Z

CREATE TRIGGER trigger_coaching_center_stats_courses AFTER INSERT OR DELETE OR UPDATE ON public.courses FOR EACH ROW EXECUTE FUNCTION update_coaching_center_stats();

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.courses FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: learning_analytics_daily
-- Generated: 2025-10-25T15:36:11.521Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.learning_analytics_daily FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: lesson_progress
-- Generated: 2025-10-25T15:36:11.521Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.lesson_progress FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: lessons
-- Generated: 2025-10-25T15:36:11.521Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.lessons FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: live_class_enrollments
-- Generated: 2025-10-25T15:36:11.522Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.live_class_enrollments FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: live_classes
-- Generated: 2025-10-25T15:36:11.522Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.live_classes FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: notification_templates
-- Generated: 2025-10-25T15:36:11.522Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.notification_templates FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: notifications
-- Generated: 2025-10-25T15:36:11.523Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.notifications FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: payment_methods
-- Generated: 2025-10-25T15:36:11.523Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.payment_methods FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: payments
-- Generated: 2025-10-25T15:36:11.523Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: review_votes
-- Generated: 2025-10-25T15:36:11.524Z

CREATE TRIGGER trigger_update_review_votes AFTER INSERT OR DELETE OR UPDATE ON public.review_votes FOR EACH ROW EXECUTE FUNCTION update_review_vote_counts();

-- Triggers for: reviews
-- Generated: 2025-10-25T15:36:11.524Z

CREATE TRIGGER trigger_update_course_stats_reviews AFTER INSERT OR DELETE OR UPDATE ON public.reviews FOR EACH ROW EXECUTE FUNCTION update_course_stats();

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.reviews FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: students
-- Generated: 2025-10-25T15:36:11.524Z

CREATE TRIGGER trigger_generate_student_id BEFORE INSERT ON public.students FOR EACH ROW WHEN ((new.student_id IS NULL)) EXECUTE FUNCTION generate_student_id();

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.students FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: teachers
-- Generated: 2025-10-25T15:36:11.525Z

CREATE TRIGGER trigger_coaching_center_stats_teachers AFTER INSERT OR DELETE OR UPDATE ON public.teachers FOR EACH ROW EXECUTE FUNCTION update_coaching_center_stats();

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.teachers FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: test_questions
-- Generated: 2025-10-25T15:36:11.525Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.test_questions FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: test_results
-- Generated: 2025-10-25T15:36:11.525Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.test_results FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: tests
-- Generated: 2025-10-25T15:36:11.526Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.tests FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Triggers for: user_profiles
-- Generated: 2025-10-25T15:36:11.526Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();

