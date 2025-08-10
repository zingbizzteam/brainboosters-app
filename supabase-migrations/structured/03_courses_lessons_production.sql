-- =============================================
-- PRODUCTION-READY COURSES AND LESSONS
-- =============================================

-- Enhanced courses table with production optimizations
CREATE TABLE courses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    coaching_center_id UUID REFERENCES coaching_centers(id) ON DELETE RESTRICT NOT NULL,
    primary_teacher_id UUID REFERENCES teachers(id) ON DELETE SET NULL,
    
    -- Core course information
    title VARCHAR(300) NOT NULL,
    slug VARCHAR(300) UNIQUE NOT NULL,
    description TEXT,
    short_description VARCHAR(500),
    thumbnail_url TEXT,
    trailer_video_url TEXT,
    
    -- Categorization and targeting
    category VARCHAR(100) NOT NULL,
    subcategory VARCHAR(100),
    tags TEXT[], -- For flexible tagging
    target_grade_levels TEXT[], -- Multiple grade levels supported
    difficulty_level VARCHAR(20) DEFAULT 'beginner' CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced', 'expert')),
    
    -- Language and accessibility
    language VARCHAR(5) DEFAULT 'en',
    subtitle_languages TEXT[] DEFAULT '{}',
    has_closed_captions BOOLEAN DEFAULT false,
    
    -- Pricing and business model
    price DECIMAL(10,2) DEFAULT 0.00 CHECK (price >= 0),
    original_price DECIMAL(10,2) CHECK (original_price >= price),
    currency VARCHAR(3) DEFAULT 'INR',
    pricing_type VARCHAR(20) DEFAULT 'one_time' CHECK (pricing_type IN ('free', 'one_time', 'subscription', 'pay_per_lesson')),
    
    -- Course structure and content
    total_lessons INTEGER DEFAULT 0 CHECK (total_lessons >= 0),
    total_duration_minutes INTEGER DEFAULT 0 CHECK (total_duration_minutes >= 0),
    estimated_completion_weeks INTEGER DEFAULT 4,
    
    -- Prerequisites and requirements
    prerequisites TEXT[],
    learning_objectives TEXT[],
    requirements TEXT[],
    
    -- Enrollment and capacity
    max_enrollments INTEGER,
    current_enrollments INTEGER DEFAULT 0,
    enrollment_starts_at TIMESTAMP WITH TIME ZONE,
    enrollment_ends_at TIMESTAMP WITH TIME ZONE,
    course_starts_at TIMESTAMP WITH TIME ZONE,
    course_ends_at TIMESTAMP WITH TIME ZONE,
    
    -- Performance metrics (updated by background jobs)
    view_count INTEGER DEFAULT 0,
    enrollment_count INTEGER DEFAULT 0,
    completion_count INTEGER DEFAULT 0,
    average_completion_time_days INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0.0 CHECK (average_rating >= 0 AND average_rating <= 5),
    total_reviews INTEGER DEFAULT 0,
    
    -- Revenue tracking
    total_revenue DECIMAL(15,2) DEFAULT 0.00,
    total_refunds DECIMAL(15,2) DEFAULT 0.00,
    
    -- Content flags and moderation
    content_warning BOOLEAN DEFAULT false,
    age_restriction INTEGER DEFAULT 0,
    moderation_status VARCHAR(20) DEFAULT 'pending' CHECK (moderation_status IN ('pending', 'approved', 'rejected', 'flagged')),
    
    -- SEO and marketing
    meta_title VARCHAR(200),
    meta_description VARCHAR(500),
    keywords TEXT[],
    
    -- Course settings and features
    allow_preview BOOLEAN DEFAULT true,
    has_certificate BOOLEAN DEFAULT false,
    certificate_template_id UUID,
    discussion_enabled BOOLEAN DEFAULT true,
    qa_enabled BOOLEAN DEFAULT true,
    downloadable_resources BOOLEAN DEFAULT false,
    
    -- Status and publication
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'review', 'published', 'archived', 'suspended')),
    is_featured BOOLEAN DEFAULT false,
    featured_until TIMESTAMP WITH TIME ZONE,
    
    -- System status
    is_active BOOLEAN DEFAULT true NOT NULL,
    is_deleted BOOLEAN DEFAULT false NOT NULL,
    
    -- Audit timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    published_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT valid_pricing CHECK (original_price IS NULL OR original_price >= price),
    CONSTRAINT valid_enrollment_period CHECK (enrollment_ends_at IS NULL OR enrollment_starts_at IS NULL OR enrollment_ends_at > enrollment_starts_at),
    CONSTRAINT valid_course_period CHECK (course_ends_at IS NULL OR course_starts_at IS NULL OR course_ends_at > course_starts_at)
) WITH (fillfactor = 85);

-- Production-optimized indexes for courses
CREATE INDEX CONCURRENTLY idx_courses_center_status ON courses(coaching_center_id, status) 
    WHERE is_deleted = false;
CREATE INDEX CONCURRENTLY idx_courses_category_level ON courses(category, difficulty_level) 
    WHERE status = 'published';
CREATE INDEX CONCURRENTLY idx_courses_featured ON courses(is_featured, featured_until) 
    WHERE status = 'published' AND is_featured = true;
CREATE INDEX CONCURRENTLY idx_courses_enrollment_period ON courses(enrollment_starts_at, enrollment_ends_at) 
    WHERE status = 'published';
CREATE INDEX CONCURRENTLY idx_courses_rating ON courses(average_rating DESC, total_reviews DESC) 
    WHERE status = 'published';
CREATE INDEX CONCURRENTLY idx_courses_price ON courses(price) WHERE status = 'published';
CREATE UNIQUE INDEX CONCURRENTLY idx_courses_slug ON courses(slug) WHERE is_deleted = false;
CREATE INDEX CONCURRENTLY idx_courses_tags_gin ON courses USING GIN(tags) WHERE status = 'published';
CREATE INDEX CONCURRENTLY idx_courses_grades_gin ON courses USING GIN(target_grade_levels) WHERE status = 'published';
CREATE INDEX CONCURRENTLY idx_courses_search ON courses USING GIN(
    to_tsvector('english', title || ' ' || COALESCE(description, ''))
) WHERE status = 'published';

-- =============================================
-- CHAPTERS (COURSE SECTIONS)
-- =============================================

CREATE TABLE chapters (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    
    title VARCHAR(255) NOT NULL,
    description TEXT,
    chapter_order INTEGER NOT NULL,
    
    -- Chapter content and structure
    total_lessons INTEGER DEFAULT 0,
    total_duration_minutes INTEGER DEFAULT 0,
    
    -- Chapter settings
    is_preview BOOLEAN DEFAULT false, -- Can be previewed without enrollment
    is_mandatory BOOLEAN DEFAULT true, -- Must complete to progress
    unlock_condition VARCHAR(50) DEFAULT 'sequential', -- sequential, score_based, date_based
    required_score INTEGER, -- For score_based unlock
    unlock_date TIMESTAMP WITH TIME ZONE, -- For date_based unlock
    
    -- Status
    is_published BOOLEAN DEFAULT false,
    is_deleted BOOLEAN DEFAULT false NOT NULL,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    UNIQUE(course_id, chapter_order),
    CONSTRAINT valid_unlock_score CHECK (unlock_condition != 'score_based' OR required_score IS NOT NULL)
);

CREATE INDEX CONCURRENTLY idx_chapters_course ON chapters(course_id, chapter_order) 
    WHERE is_deleted = false;
CREATE INDEX CONCURRENTLY idx_chapters_published ON chapters(course_id, is_published) 
    WHERE is_deleted = false;

-- =============================================
-- LESSONS (INDIVIDUAL LEARNING UNITS)
-- =============================================

CREATE TABLE lessons (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    chapter_id UUID REFERENCES chapters(id) ON DELETE CASCADE NOT NULL,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL, -- Denormalized for performance
    
    title VARCHAR(300) NOT NULL,
    description TEXT,
    lesson_order INTEGER NOT NULL,
    
    -- Content delivery
    lesson_type VARCHAR(30) DEFAULT 'video' CHECK (lesson_type IN (
        'video', 'text', 'quiz', 'assignment', 'live_session', 
        'interactive', 'document', 'audio', 'simulation'
    )),
    content_url TEXT,
    content_data JSONB DEFAULT '{}', -- Flexible content storage
    
    -- Video-specific fields
    video_duration_seconds INTEGER DEFAULT 0,
    video_thumbnail_url TEXT,
    video_quality_options JSONB DEFAULT '[]', -- Different quality options
    video_transcript TEXT,
    
    -- Interactive content
    interactive_elements JSONB DEFAULT '{}', -- Quizzes, polls, etc.
    
    -- Learning objectives and outcomes
    learning_objectives TEXT[],
    estimated_completion_minutes INTEGER DEFAULT 10,
    
    -- Access and prerequisites
    is_preview BOOLEAN DEFAULT false, -- Can be accessed without enrollment
    is_mandatory BOOLEAN DEFAULT true,
    prerequisite_lessons UUID[], -- Must complete these first
    
    -- Assessment and scoring
    has_assessment BOOLEAN DEFAULT false,
    assessment_data JSONB DEFAULT '{}',
    passing_score INTEGER, -- Required score to mark as complete
    max_attempts INTEGER DEFAULT 3,
    
    -- Content settings
    allow_download BOOLEAN DEFAULT false,
    allow_speed_control BOOLEAN DEFAULT true,
    auto_play_next BOOLEAN DEFAULT false,
    
    -- Analytics and tracking (updated by background jobs)
    view_count INTEGER DEFAULT 0,
    completion_count INTEGER DEFAULT 0,
    average_completion_time_minutes INTEGER DEFAULT 0,
    average_score DECIMAL(5,2) DEFAULT 0.0,
    
    -- Status
    is_published BOOLEAN DEFAULT false,
    is_deleted BOOLEAN DEFAULT false NOT NULL,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    UNIQUE(chapter_id, lesson_order),
    CONSTRAINT valid_assessment_score CHECK (has_assessment = false OR passing_score IS NOT NULL)
);

-- Production indexes for lessons
CREATE INDEX CONCURRENTLY idx_lessons_chapter ON lessons(chapter_id, lesson_order) 
    WHERE is_deleted = false;
CREATE INDEX CONCURRENTLY idx_lessons_course ON lessons(course_id) 
    WHERE is_published = true;
CREATE INDEX CONCURRENTLY idx_lessons_type ON lessons(lesson_type) 
    WHERE is_published = true;
CREATE INDEX CONCURRENTLY idx_lessons_prerequisites_gin ON lessons USING GIN(prerequisite_lessons) 
    WHERE is_published = true;

-- =============================================
-- COURSE-RELATED STORED PROCEDURES
-- =============================================

-- Get course with full details (optimized single query)
CREATE OR REPLACE FUNCTION sp_get_course_details(p_course_id UUID)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'course', jsonb_build_object(
            'id', c.id,
            'title', c.title,
            'description', c.description,
            'thumbnail_url', c.thumbnail_url,
            'price', c.price,
            'original_price', c.original_price,
            'rating', c.average_rating,
            'total_reviews', c.total_reviews,
            'total_lessons', c.total_lessons,
            'duration_minutes', c.total_duration_minutes,
            'enrollment_count', c.enrollment_count,
            'difficulty_level', c.difficulty_level,
            'language', c.language,
            'tags', c.tags,
            'learning_objectives', c.learning_objectives,
            'requirements', c.requirements
        ),
        'coaching_center', jsonb_build_object(
            'id', cc.id,
            'name', cc.center_name,
            'rating', cc.average_rating
        ),
        'teacher', jsonb_build_object(
            'id', t.id,
            'name', up.first_name || ' ' || up.last_name,
            'experience_years', t.experience_years,
            'rating', t.average_rating,
            'total_students', t.total_students
        ),
        'chapters', COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', ch.id,
                    'title', ch.title,
                    'description', ch.description,
                    'chapter_order', ch.chapter_order,
                    'total_lessons', ch.total_lessons,
                    'duration_minutes', ch.total_duration_minutes,
                    'is_preview', ch.is_preview,
                    'lessons', COALESCE((
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'id', l.id,
                                'title', l.title,
                                'lesson_type', l.lesson_type,
                                'duration_minutes', l.estimated_completion_minutes,
                                'is_preview', l.is_preview,
                                'has_assessment', l.has_assessment
                            )
                            ORDER BY l.lesson_order
                        )
                        FROM lessons l
                        WHERE l.chapter_id = ch.id AND l.is_published = true AND l.is_deleted = false
                    ), '[]'::jsonb)
                )
                ORDER BY ch.chapter_order
            )
            FROM chapters ch
            WHERE ch.course_id = c.id AND ch.is_published = true AND ch.is_deleted = false
        ), '[]'::jsonb)
    ) INTO result
    FROM courses c
    JOIN coaching_centers cc ON c.coaching_center_id = cc.id
    LEFT JOIN teachers t ON c.primary_teacher_id = t.id
    LEFT JOIN user_profiles up ON t.user_id = up.id
    WHERE c.id = p_course_id AND c.status = 'published' AND c.is_deleted = false;
    
    RETURN COALESCE(result, '{}'::jsonb);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Search courses with advanced filters
CREATE OR REPLACE FUNCTION sp_search_courses(
    p_query TEXT DEFAULT NULL,
    p_category VARCHAR DEFAULT NULL,
    p_difficulty VARCHAR DEFAULT NULL,
    p_min_price DECIMAL DEFAULT NULL,
    p_max_price DECIMAL DEFAULT NULL,
    p_min_rating DECIMAL DEFAULT NULL,
    p_grade_levels TEXT[] DEFAULT NULL,
    p_tags TEXT[] DEFAULT NULL,
    p_language VARCHAR DEFAULT NULL,
    p_sort_by VARCHAR DEFAULT 'relevance',
    p_limit INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0
) RETURNS TABLE(
    course_data JSONB,
    total_count INTEGER
) AS $$
DECLARE
    base_query TEXT;
    count_query TEXT;
    sort_clause TEXT;
    where_conditions TEXT[] := '{}';
    total_results INTEGER;
BEGIN
    -- Build WHERE conditions
    where_conditions := array_append(where_conditions, 'c.status = ''published'' AND c.is_deleted = false');
    
    IF p_query IS NOT NULL THEN
        where_conditions := array_append(where_conditions, 
            'to_tsvector(''english'', c.title || '' '' || COALESCE(c.description, '''')) @@ plainto_tsquery(''' || p_query || ''')');
    END IF;
    
    IF p_category IS NOT NULL THEN
        where_conditions := array_append(where_conditions, 'c.category = ''' || p_category || '''');
    END IF;
    
    IF p_difficulty IS NOT NULL THEN
        where_conditions := array_append(where_conditions, 'c.difficulty_level = ''' || p_difficulty || '''');
    END IF;
    
    IF p_min_price IS NOT NULL THEN
        where_conditions := array_append(where_conditions, 'c.price >= ' || p_min_price);
    END IF;
    
    IF p_max_price IS NOT NULL THEN
        where_conditions := array_append(where_conditions, 'c.price <= ' || p_max_price);
    END IF;
    
    IF p_min_rating IS NOT NULL THEN
        where_conditions := array_append(where_conditions, 'c.average_rating >= ' || p_min_rating);
    END IF;
    
    IF p_language IS NOT NULL THEN
        where_conditions := array_append(where_conditions, 'c.language = ''' || p_language || '''');
    END IF;
    
    IF p_grade_levels IS NOT NULL THEN
        where_conditions := array_append(where_conditions, 'c.target_grade_levels && ARRAY[''' || array_to_string(p_grade_levels, ''',''') || ''']');
    END IF;
    
    IF p_tags IS NOT NULL THEN
        where_conditions := array_append(where_conditions, 'c.tags && ARRAY[''' || array_to_string(p_tags, ''',''') || ''']');
    END IF;
    
    -- Build sort clause
    sort_clause := CASE p_sort_by
        WHEN 'price_low' THEN 'ORDER BY c.price ASC'
        WHEN 'price_high' THEN 'ORDER BY c.price DESC'
        WHEN 'rating' THEN 'ORDER BY c.average_rating DESC, c.total_reviews DESC'
        WHEN 'popular' THEN 'ORDER BY c.enrollment_count DESC'
        WHEN 'newest' THEN 'ORDER BY c.created_at DESC'
        ELSE 'ORDER BY c.is_featured DESC, c.average_rating DESC, c.enrollment_count DESC'
    END;
    
    -- Get total count
    count_query := 'SELECT COUNT(*) FROM courses c 
                   JOIN coaching_centers cc ON c.coaching_center_id = cc.id 
                   WHERE ' || array_to_string(where_conditions, ' AND ');
    
    EXECUTE count_query INTO total_results;
    
    -- Build main query
    base_query := '
        SELECT jsonb_build_object(
            ''id'', c.id,
            ''title'', c.title,
            ''short_description'', c.short_description,
            ''thumbnail_url'', c.thumbnail_url,
            ''price'', c.price,
            ''original_price'', c.original_price,
            ''rating'', c.average_rating,
            ''total_reviews'', c.total_reviews,
            ''enrollment_count'', c.enrollment_count,
            ''total_lessons'', c.total_lessons,
            ''duration_minutes'', c.total_duration_minutes,
            ''difficulty_level'', c.difficulty_level,
            ''category'', c.category,
            ''tags'', c.tags,
            ''coaching_center'', cc.center_name,
            ''is_featured'', c.is_featured
        ), ' || total_results || '
        FROM courses c
        JOIN coaching_centers cc ON c.coaching_center_id = cc.id
        WHERE ' || array_to_string(where_conditions, ' AND ') || '
        ' || sort_clause || '
        LIMIT ' || p_limit || ' OFFSET ' || p_offset;
    
    RETURN QUERY EXECUTE base_query;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update course statistics (background job function)
CREATE OR REPLACE FUNCTION sp_update_course_statistics(p_batch_size INTEGER DEFAULT 100)
RETURNS INTEGER AS $$
DECLARE
    updated_count INTEGER := 0;
    course_record RECORD;
BEGIN
    -- Update courses that haven't been updated in the last hour
    FOR course_record IN
        SELECT id FROM courses 
        WHERE status = 'published' 
        AND (updated_at < NOW() - INTERVAL '1 hour' OR total_lessons = 0)
        LIMIT p_batch_size
    LOOP
        UPDATE courses SET
            total_lessons = (
                SELECT COUNT(*) 
                FROM lessons l 
                WHERE l.course_id = course_record.id AND l.is_published = true AND l.is_deleted = false
            ),
            total_duration_minutes = (
                SELECT COALESCE(SUM(l.estimated_completion_minutes), 0)
                FROM lessons l 
                WHERE l.course_id = course_record.id AND l.is_published = true AND l.is_deleted = false
            ),
            enrollment_count = (
                SELECT COUNT(*) 
                FROM course_enrollments ce 
                WHERE ce.course_id = course_record.id AND ce.is_active = true
            ),
            completion_count = (
                SELECT COUNT(*) 
                FROM course_enrollments ce 
                WHERE ce.course_id = course_record.id AND ce.completed_at IS NOT NULL
            ),
            total_revenue = (
                SELECT COALESCE(SUM(p.final_amount), 0)
                FROM payments p 
                WHERE p.course_id = course_record.id AND p.status = 'completed'
            ),
            updated_at = NOW()
        WHERE id = course_record.id;
        
        updated_count := updated_count + 1;
    END LOOP;
    
    -- Update chapter statistics
    UPDATE chapters SET
        total_lessons = subq.lesson_count,
        total_duration_minutes = subq.total_duration,
        updated_at = NOW()
    FROM (
        SELECT 
            ch.id,
            COUNT(l.id) as lesson_count,
            COALESCE(SUM(l.estimated_completion_minutes), 0) as total_duration
        FROM chapters ch
        LEFT JOIN lessons l ON ch.id = l.chapter_id AND l.is_published = true AND l.is_deleted = false
        WHERE ch.updated_at < NOW() - INTERVAL '1 hour'
        GROUP BY ch.id
        LIMIT p_batch_size
    ) subq
    WHERE chapters.id = subq.id;
    
    RETURN updated_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply audit and update triggers
CREATE TRIGGER trg_audit_courses AFTER INSERT OR UPDATE OR DELETE ON courses 
    FOR EACH ROW EXECUTE FUNCTION audit.log_changes();
CREATE TRIGGER trg_audit_chapters AFTER INSERT OR UPDATE OR DELETE ON chapters 
    FOR EACH ROW EXECUTE FUNCTION audit.log_changes();
CREATE TRIGGER trg_audit_lessons AFTER INSERT OR UPDATE OR DELETE ON lessons 
    FOR EACH ROW EXECUTE FUNCTION audit.log_changes();

CREATE TRIGGER trg_updated_at_courses BEFORE UPDATE ON courses 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_updated_at_chapters BEFORE UPDATE ON chapters 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_updated_at_lessons BEFORE UPDATE ON lessons 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
