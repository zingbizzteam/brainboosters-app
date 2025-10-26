-- Triggers for: coaching_centers
-- Generated: 2025-10-25T15:36:11.520Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.coaching_centers FOR EACH ROW EXECUTE FUNCTION update_updated_at();

