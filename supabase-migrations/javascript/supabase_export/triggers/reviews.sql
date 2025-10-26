-- Triggers for: reviews
-- Generated: 2025-10-25T15:36:11.524Z

CREATE TRIGGER trigger_update_course_stats_reviews AFTER INSERT OR DELETE OR UPDATE ON public.reviews FOR EACH ROW EXECUTE FUNCTION update_course_stats();

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.reviews FOR EACH ROW EXECUTE FUNCTION update_updated_at();

