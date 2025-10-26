-- Triggers for: teachers
-- Generated: 2025-10-25T15:36:11.525Z

CREATE TRIGGER trigger_coaching_center_stats_teachers AFTER INSERT OR DELETE OR UPDATE ON public.teachers FOR EACH ROW EXECUTE FUNCTION update_coaching_center_stats();

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.teachers FOR EACH ROW EXECUTE FUNCTION update_updated_at();

