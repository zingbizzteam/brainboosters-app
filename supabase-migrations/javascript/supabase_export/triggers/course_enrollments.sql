-- Triggers for: course_enrollments
-- Generated: 2025-10-25T15:36:11.520Z

CREATE TRIGGER trigger_update_course_stats_enrollments AFTER INSERT OR DELETE OR UPDATE ON public.course_enrollments FOR EACH ROW EXECUTE FUNCTION update_course_stats();

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.course_enrollments FOR EACH ROW EXECUTE FUNCTION update_updated_at();

