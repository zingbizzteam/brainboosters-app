-- Triggers for: students
-- Generated: 2025-10-25T15:36:11.524Z

CREATE TRIGGER trigger_generate_student_id BEFORE INSERT ON public.students FOR EACH ROW WHEN ((new.student_id IS NULL)) EXECUTE FUNCTION generate_student_id();

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.students FOR EACH ROW EXECUTE FUNCTION update_updated_at();

