-- Triggers for: review_votes
-- Generated: 2025-10-25T15:36:11.524Z

CREATE TRIGGER trigger_update_review_votes AFTER INSERT OR DELETE OR UPDATE ON public.review_votes FOR EACH ROW EXECUTE FUNCTION update_review_vote_counts();

