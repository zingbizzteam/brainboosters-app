-- Function: insert_sample_categories
-- Generated: 2025-10-25T15:36:11.678Z

CREATE OR REPLACE FUNCTION public.insert_sample_categories()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO course_categories (name, slug, description, is_active) VALUES
    ('Mathematics', 'mathematics', 'Mathematical subjects including algebra, calculus, geometry', true),
    ('Science', 'science', 'Physics, Chemistry, Biology and other scientific subjects', true),
    ('Computer Science', 'computer-science', 'Programming, algorithms, data structures, and technology', true),
    ('Language Arts', 'language-arts', 'English, Hindi, literature and communication skills', true),
    ('Social Studies', 'social-studies', 'History, geography, civics and social sciences', true),
    ('Competitive Exams', 'competitive-exams', 'JEE, NEET, UPSC and other competitive exam preparation', true),
    ('Professional Skills', 'professional-skills', 'Soft skills, leadership, and career development', true),
    ('Arts & Music', 'arts-music', 'Fine arts, music, dance and creative subjects', true);
    
    RAISE NOTICE 'Sample categories inserted successfully';
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Categories already exist, skipping insertion';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error inserting categories: %', SQLERRM;
END;
$function$
;

