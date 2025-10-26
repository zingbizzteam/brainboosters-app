-- Triggers for: tests
-- Generated: 2025-10-25T15:36:11.526Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.tests FOR EACH ROW EXECUTE FUNCTION update_updated_at();

