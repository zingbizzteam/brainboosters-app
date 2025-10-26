-- Triggers for: user_profiles
-- Generated: 2025-10-25T15:36:11.526Z

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();

