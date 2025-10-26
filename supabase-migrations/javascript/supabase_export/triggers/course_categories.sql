-- Triggers for: course_categories
-- Generated: 2025-10-25T15:36:11.520Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.course_categories FOR EACH ROW EXECUTE FUNCTION update_updated_at();

