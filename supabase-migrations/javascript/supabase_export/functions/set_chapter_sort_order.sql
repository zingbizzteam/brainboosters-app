-- Function: set_chapter_sort_order
-- Generated: 2025-10-25T15:36:11.680Z

CREATE OR REPLACE FUNCTION public.set_chapter_sort_order()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Only assign if sort_order is not explicitly given or is 0
  IF NEW.sort_order IS NULL OR NEW.sort_order = 0 THEN
    SELECT COALESCE(MAX(sort_order), 0) + 1
      INTO NEW.sort_order
      FROM public.chapters
      WHERE course_id = NEW.course_id;
  END IF;
  RETURN NEW;
END;
$function$
;

