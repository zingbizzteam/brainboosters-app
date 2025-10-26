-- Triggers for: courses
-- Generated: 2025-10-25T15:36:11.521Z

CREATE TRIGGER trigger_coaching_center_stats_courses AFTER INSERT OR DELETE OR UPDATE ON public.courses FOR EACH ROW EXECUTE FUNCTION update_coaching_center_stats();

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.courses FOR EACH ROW EXECUTE FUNCTION update_updated_at();

