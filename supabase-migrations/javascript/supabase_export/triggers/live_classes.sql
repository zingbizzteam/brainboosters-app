-- Triggers for: live_classes
-- Generated: 2025-10-25T15:36:11.522Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.live_classes FOR EACH ROW EXECUTE FUNCTION update_updated_at();

