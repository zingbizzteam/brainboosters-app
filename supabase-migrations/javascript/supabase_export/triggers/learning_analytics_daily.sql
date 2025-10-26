-- Triggers for: learning_analytics_daily
-- Generated: 2025-10-25T15:36:11.521Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.learning_analytics_daily FOR EACH ROW EXECUTE FUNCTION update_updated_at();

