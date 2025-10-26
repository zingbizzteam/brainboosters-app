-- Triggers for: lesson_progress
-- Generated: 2025-10-25T15:36:11.521Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.lesson_progress FOR EACH ROW EXECUTE FUNCTION update_updated_at();

