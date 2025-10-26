-- Triggers for: test_results
-- Generated: 2025-10-25T15:36:11.525Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.test_results FOR EACH ROW EXECUTE FUNCTION update_updated_at();

