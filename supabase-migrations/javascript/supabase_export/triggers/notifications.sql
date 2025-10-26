-- Triggers for: notifications
-- Generated: 2025-10-25T15:36:11.523Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.notifications FOR EACH ROW EXECUTE FUNCTION update_updated_at();

