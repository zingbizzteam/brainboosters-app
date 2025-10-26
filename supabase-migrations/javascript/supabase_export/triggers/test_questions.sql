-- Triggers for: test_questions
-- Generated: 2025-10-25T15:36:11.525Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.test_questions FOR EACH ROW EXECUTE FUNCTION update_updated_at();

