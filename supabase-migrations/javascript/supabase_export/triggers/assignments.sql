-- Triggers for: assignments
-- Generated: 2025-10-25T15:36:11.519Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.assignments FOR EACH ROW EXECUTE FUNCTION update_updated_at();

