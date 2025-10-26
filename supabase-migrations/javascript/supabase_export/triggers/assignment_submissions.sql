-- Triggers for: assignment_submissions
-- Generated: 2025-10-25T15:36:11.518Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.assignment_submissions FOR EACH ROW EXECUTE FUNCTION update_updated_at();

