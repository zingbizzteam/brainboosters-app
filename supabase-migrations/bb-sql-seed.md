```sql
-- =============================================
-- SAMPLE DATA FOR LMS STRESS TESTING
-- =============================================

-- Step 1: Insert users into auth.users and auth.identities
-- First, insert into auth.users with all required fields
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    recovery_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
) VALUES 
-- Admin User
(
    '00000000-0000-0000-0000-000000000000',
    '550e8400-e29b-41d4-a716-446655440001',
    'authenticated',
    'authenticated',
    'admin@edutech.com',
    crypt('123456', gen_salt('bf')),
    NOW(),
    NULL,
    NULL,
    '{"provider": "email", "providers": ["email"]}',
    '{"user_type": "admin", "first_name": "Sarah", "last_name": "Johnson"}',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
),
-- Coaching Center Users
(
    '00000000-0000-0000-0000-000000000000',
    '550e8400-e29b-41d4-a716-446655440002',
    'authenticated',
    'authenticated',
    'director@techacademy.com',
    crypt('123456', gen_salt('bf')),
    NOW(),
    NULL,
    NULL,
    '{"provider": "email", "providers": ["email"]}',
    '{"user_type": "coaching_center", "first_name": "Michael", "last_name": "Chen"}',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
),
(
    '00000000-0000-0000-0000-000000000000',
    '550e8400-e29b-41d4-a716-446655440003',
    'authenticated',
    'authenticated',
    'admin@skillhub.edu',
    crypt('123456', gen_salt('bf')),
    NOW(),
    NULL,
    NULL,
    '{"provider": "email", "providers": ["email"]}',
    '{"user_type": "coaching_center", "first_name": "Priya", "last_name": "Sharma"}',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
),
-- Teacher Users
(
    '00000000-0000-0000-0000-000000000000',
    '550e8400-e29b-41d4-a716-446655440004',
    'authenticated',
    'authenticated',
    'john.smith@techacademy.com',
    crypt('123456', gen_salt('bf')),
    NOW(),
    NULL,
    NULL,
    '{"provider": "email", "providers": ["email"]}',
    '{"user_type": "teacher", "first_name": "John", "last_name": "Smith"}',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
),
(
    '00000000-0000-0000-0000-000000000000',
    '550e8400-e29b-41d4-a716-446655440005',
    'authenticated',
    'authenticated',
    'emily.davis@skillhub.edu',
    crypt('123456', gen_salt('bf')),
    NOW(),
    NULL,
    NULL,
    '{"provider": "email", "providers": ["email"]}',
    '{"user_type": "teacher", "first_name": "Emily", "last_name": "Davis"}',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
),
(
    '00000000-0000-0000-0000-000000000000',
    '550e8400-e29b-41d4-a716-446655440006',
    'authenticated',
    'authenticated',
    'raj.patel@techacademy.com',
    crypt('123456', gen_salt('bf')),
    NOW(),
    NULL,
    NULL,
    '{"provider": "email", "providers": ["email"]}',
    '{"user_type": "teacher", "first_name": "Raj", "last_name": "Patel"}',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
),
-- Student Users
(
    '00000000-0000-0000-0000-000000000000',
    '550e8400-e29b-41d4-a716-446655440007',
    'authenticated',
    'authenticated',
    'alex.wilson@gmail.com',
    crypt('123456', gen_salt('bf')),
    NOW(),
    NULL,
    NULL,
    '{"provider": "email", "providers": ["email"]}',
    '{"user_type": "student", "first_name": "Alex", "last_name": "Wilson"}',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
),
(
    '00000000-0000-0000-0000-000000000000',
    '550e8400-e29b-41d4-a716-446655440008',
    'authenticated',
    'authenticated',
    'maria.garcia@gmail.com',
    crypt('123456', gen_salt('bf')),
    NOW(),
    NULL,
    NULL,
    '{"provider": "email", "providers": ["email"]}',
    '{"user_type": "student", "first_name": "Maria", "last_name": "Garcia"}',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
);

-- Then, insert corresponding records into auth.identities (REQUIRED for email/password auth)
INSERT INTO auth.identities (
    provider_id,
    user_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
) VALUES 
(
    '550e8400-e29b-41d4-a716-446655440001',
    '550e8400-e29b-41d4-a716-446655440001',
    '{"sub": "550e8400-e29b-41d4-a716-446655440001", "email": "admin@edutech.com", "email_verified": true, "phone_verified": false}',
    'email',
    NULL,
    NOW(),
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440002',
    '550e8400-e29b-41d4-a716-446655440002',
    '{"sub": "550e8400-e29b-41d4-a716-446655440002", "email": "director@techacademy.com", "email_verified": true, "phone_verified": false}',
    'email',
    NULL,
    NOW(),
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440003',
    '550e8400-e29b-41d4-a716-446655440003',
    '{"sub": "550e8400-e29b-41d4-a716-446655440003", "email": "admin@skillhub.edu", "email_verified": true, "phone_verified": false}',
    'email',
    NULL,
    NOW(),
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440004',
    '550e8400-e29b-41d4-a716-446655440004',
    '{"sub": "550e8400-e29b-41d4-a716-446655440004", "email": "john.smith@techacademy.com", "email_verified": true, "phone_verified": false}',
    'email',
    NULL,
    NOW(),
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440005',
    '550e8400-e29b-41d4-a716-446655440005',
    '{"sub": "550e8400-e29b-41d4-a716-446655440005", "email": "emily.davis@skillhub.edu", "email_verified": true, "phone_verified": false}',
    'email',
    NULL,
    NOW(),
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440006',
    '550e8400-e29b-41d4-a716-446655440006',
    '{"sub": "550e8400-e29b-41d4-a716-446655440006", "email": "raj.patel@techacademy.com", "email_verified": true, "phone_verified": false}',
    'email',
    NULL,
    NOW(),
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440007',
    '550e8400-e29b-41d4-a716-446655440007',
    '{"sub": "550e8400-e29b-41d4-a716-446655440007", "email": "alex.wilson@gmail.com", "email_verified": true, "phone_verified": false}',
    'email',
    NULL,
    NOW(),
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440008',
    '550e8400-e29b-41d4-a716-446655440008',
    '{"sub": "550e8400-e29b-41d4-a716-446655440008", "email": "maria.garcia@gmail.com", "email_verified": true, "phone_verified": false}',
    'email',
    NULL,
    NOW(),
    NOW()
);


-- Step 2: User Profiles (will be created automatically by trigger, but let's update them)
UPDATE user_profiles SET
    first_name = 'Sarah',
    last_name = 'Johnson',
    phone = '+1-555-0101',
    avatar_url = 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150',
    date_of_birth = '1985-03-15',
    gender = 'female',
    address = '{"street": "123 Admin St", "city": "San Francisco", "state": "CA", "zip": "94105", "country": "USA"}',
    is_active = true,
    email_verified = true,
    phone_verified = true,
    onboarding_completed = true,
    preferences = '{"theme": "light", "notifications": true, "language": "en"}'
WHERE id = '550e8400-e29b-41d4-a716-446655440001';

UPDATE user_profiles SET
    first_name = 'Michael',
    last_name = 'Chen',
    phone = '+1-555-0102',
    avatar_url = 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
    date_of_birth = '1978-07-22',
    gender = 'male',
    address = '{"street": "456 Tech Ave", "city": "Austin", "state": "TX", "zip": "73301", "country": "USA"}',
    is_active = true,
    email_verified = true,
    phone_verified = true,
    onboarding_completed = true,
    preferences = '{"theme": "dark", "notifications": true, "language": "en"}'
WHERE id = '550e8400-e29b-41d4-a716-446655440002';

UPDATE user_profiles SET
    first_name = 'Priya',
    last_name = 'Sharma',
    phone = '+91-9876543210',
    avatar_url = 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
    date_of_birth = '1982-11-08',
    gender = 'female',
    address = '{"street": "789 Education Blvd", "city": "Bangalore", "state": "Karnataka", "zip": "560001", "country": "India"}',
    is_active = true,
    email_verified = true,
    phone_verified = true,
    onboarding_completed = true,
    preferences = '{"theme": "light", "notifications": true, "language": "en"}'
WHERE id = '550e8400-e29b-41d4-a716-446655440003';

UPDATE user_profiles SET
    first_name = 'John',
    last_name = 'Smith',
    phone = '+1-555-0104',
    avatar_url = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    date_of_birth = '1990-05-12',
    gender = 'male',
    address = '{"street": "321 Teacher Lane", "city": "Austin", "state": "TX", "zip": "73302", "country": "USA"}',
    is_active = true,
    email_verified = true,
    phone_verified = true,
    onboarding_completed = true,
    preferences = '{"theme": "light", "notifications": true, "language": "en"}'
WHERE id = '550e8400-e29b-41d4-a716-446655440004';

UPDATE user_profiles SET
    first_name = 'Emily',
    last_name = 'Davis',
    phone = '+91-9876543211',
    avatar_url = 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
    date_of_birth = '1988-09-25',
    gender = 'female',
    address = '{"street": "654 Skill Street", "city": "Bangalore", "state": "Karnataka", "zip": "560002", "country": "India"}',
    is_active = true,
    email_verified = true,
    phone_verified = true,
    onboarding_completed = true,
    preferences = '{"theme": "dark", "notifications": true, "language": "en"}'
WHERE id = '550e8400-e29b-41d4-a716-446655440005';

UPDATE user_profiles SET
    first_name = 'Raj',
    last_name = 'Patel',
    phone = '+1-555-0106',
    avatar_url = 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    date_of_birth = '1985-12-03',
    gender = 'male',
    address = '{"street": "987 Code Blvd", "city": "Austin", "state": "TX", "zip": "73303", "country": "USA"}',
    is_active = true,
    email_verified = true,
    phone_verified = true,
    onboarding_completed = true,
    preferences = '{"theme": "light", "notifications": true, "language": "en"}'
WHERE id = '550e8400-e29b-41d4-a716-446655440006';

UPDATE user_profiles SET
    first_name = 'Alex',
    last_name = 'Wilson',
    phone = '+1-555-0107',
    avatar_url = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    date_of_birth = '2000-01-15',
    gender = 'male',
    address = '{"street": "147 Student Ave", "city": "Seattle", "state": "WA", "zip": "98101", "country": "USA"}',
    is_active = true,
    email_verified = true,
    phone_verified = true,
    onboarding_completed = true,
    preferences = '{"theme": "dark", "notifications": true, "language": "en"}'
WHERE id = '550e8400-e29b-41d4-a716-446655440007';

UPDATE user_profiles SET
    first_name = 'Maria',
    last_name = 'Garcia',
    phone = '+1-555-0108',
    avatar_url = 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
    date_of_birth = '1999-06-20',
    gender = 'female',
    address = '{"street": "258 Learning Lane", "city": "Miami", "state": "FL", "zip": "33101", "country": "USA"}',
    is_active = true,
    email_verified = true,
    phone_verified = true,
    onboarding_completed = true,
    preferences = '{"theme": "light", "notifications": true, "language": "en"}'
WHERE id = '550e8400-e29b-41d4-a716-446655440008';

-- Step 3: Coaching Centers
INSERT INTO coaching_centers (
    id, user_id, center_name, center_code, description, website_url, logo_url,
    contact_email, contact_phone, address, registration_number, tax_id,
    approval_status, approved_by, approved_at, subscription_plan,
    max_faculty_limit, max_courses_limit, is_active
) VALUES
('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002',
 'TechAcademy Pro', 'TECH001',
 'Leading technology education institute specializing in software development, data science, and AI/ML courses. We provide industry-relevant curriculum with hands-on projects.',
 'https://techacademy.com', 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=200',
 'director@techacademy.com', '+1-555-0102',
 '{"street": "456 Tech Ave", "city": "Austin", "state": "TX", "zip": "73301", "country": "USA", "landmark": "Near Tech Park"}',
 'REG-TECH-2023-001', 'TAX-TECH-001',
 'approved', '550e8400-e29b-41d4-a716-446655440001', NOW() - INTERVAL '30 days',
 'premium', 25, 100, true),

('660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440003',
 'SkillHub Education', 'SKILL001',
 'Comprehensive skill development center offering courses in programming, digital marketing, design, and business skills. Expert faculty with industry experience.',
 'https://skillhub.edu', 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=200',
 'admin@skillhub.edu', '+91-9876543210',
 '{"street": "789 Education Blvd", "city": "Bangalore", "state": "Karnataka", "zip": "560001", "country": "India", "landmark": "Opposite Metro Station"}',
 'REG-SKILL-2023-002', 'TAX-SKILL-002',
 'approved', '550e8400-e29b-41d4-a716-446655440001', NOW() - INTERVAL '45 days',
 'enterprise', 50, 200, true);

-- Step 4: Teachers
INSERT INTO teachers (
    id, user_id, coaching_center_id, employee_id, specializations, qualifications,
    experience_years, bio, hourly_rate, rating, total_reviews, is_verified,
    can_create_courses, can_conduct_live_classes, joined_at
) VALUES
('770e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440004',
 '660e8400-e29b-41d4-a716-446655440001', 'TECH-EMP-001',
 '{"Full Stack Development", "React", "Node.js", "JavaScript", "Python"}',
 '[{"degree": "M.S. Computer Science", "institution": "Stanford University", "year": 2015}, {"degree": "B.Tech Computer Engineering", "institution": "IIT Delhi", "year": 2013}]',
 8, 'Senior Full Stack Developer with 8+ years of experience in building scalable web applications. Passionate about teaching modern web technologies and mentoring aspiring developers.',
 75.00, 4.8, 156, true, true, true, NOW() - INTERVAL '2 years'),

('770e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440005',
 '660e8400-e29b-41d4-a716-446655440002', 'SKILL-EMP-001',
 '{"Data Science", "Machine Learning", "Python", "R", "Statistics"}',
 '[{"degree": "Ph.D. Data Science", "institution": "MIT", "year": 2018}, {"degree": "M.S. Statistics", "institution": "UC Berkeley", "year": 2015}]',
 6, 'Data Science expert with extensive experience in machine learning, statistical analysis, and big data technologies. Published researcher with 20+ papers in top-tier conferences.',
 85.00, 4.9, 203, true, true, true, NOW() - INTERVAL '18 months'),

('770e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440006',
 '660e8400-e29b-41d4-a716-446655440001', 'TECH-EMP-002',
 '{"Mobile Development", "React Native", "Flutter", "iOS", "Android"}',
 '[{"degree": "M.S. Software Engineering", "institution": "Carnegie Mellon", "year": 2016}, {"degree": "B.S. Computer Science", "institution": "University of Texas", "year": 2014}]',
 7, 'Mobile app development specialist with expertise in cross-platform and native mobile technologies. Built 50+ mobile apps with millions of downloads.',
 80.00, 4.7, 134, true, true, true, NOW() - INTERVAL '1 year');

-- Step 5: Students
INSERT INTO students (
    id, user_id, student_id, grade_level, school_name, parent_name, parent_phone,
    parent_email, learning_goals, preferred_learning_style, timezone,
    total_courses_enrolled, total_courses_completed, total_hours_learned,
    current_streak_days, longest_streak_days, total_points, level, badges
) VALUES
('880e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440007',
 'STU-2024-001', 'College Sophomore', 'University of Washington',
 'Robert Wilson', '+1-555-0207', 'robert.wilson@gmail.com',
 '{"Learn Full Stack Development", "Build Portfolio Projects", "Get Internship"}',
 'visual', 'America/Los_Angeles', 3, 1, 45.5, 7, 15, 2450, 3,
 '[{"name": "First Course Completed", "earned_at": "2024-01-15"}, {"name": "Week Streak", "earned_at": "2024-02-01"}]'),

('880e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440008',
 'STU-2024-002', 'College Junior', 'Florida International University',
 'Carlos Garcia', '+1-555-0208', 'carlos.garcia@gmail.com',
 '{"Master Data Science", "Learn Machine Learning", "Career Switch"}',
 'hands-on', 'America/New_York', 2, 0, 32.0, 12, 18, 3200, 4,
 '[{"name": "Data Explorer", "earned_at": "2024-01-20"}, {"name": "Two Week Streak", "earned_at": "2024-02-05"}]');

-- Step 6: Courses
INSERT INTO courses (
    id, coaching_center_id, teacher_id, title, slug, description, short_description,
    thumbnail_url, trailer_video_url, about, what_you_learn, course_includes,
    target_audience, course_requirements, category, subcategory, level, language,
    price, original_price, currency, duration_hours, total_lessons, max_enrollments,
    enrollment_deadline, total_chapters, prerequisites, learning_outcomes, tags,
    is_published, is_featured, enrollment_count, rating, total_reviews,
    completion_rate, published_at
) VALUES
('990e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001',
 '770e8400-e29b-41d4-a716-446655440001',
 'Complete Full Stack Web Development Bootcamp',
 'complete-full-stack-web-development-bootcamp',
 'Master modern web development with this comprehensive bootcamp covering HTML, CSS, JavaScript, React, Node.js, MongoDB, and deployment strategies. Build 10+ real-world projects and create a professional portfolio.',
 'Learn full stack web development from scratch with hands-on projects and industry best practices.',
 'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=400',
 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
 'This comprehensive course takes you from beginner to professional full stack developer. You will learn both frontend and backend technologies, work on real projects, and build a portfolio that will help you land your dream job.',
 '{"Build responsive websites with HTML, CSS, and JavaScript", "Create dynamic web applications with React", "Develop backend APIs with Node.js and Express", "Work with databases using MongoDB", "Deploy applications to production", "Version control with Git and GitHub"}',
 '["40+ hours of video content", "100+ coding exercises", "10 real-world projects", "Certificate of completion", "Lifetime access", "Community support"]',
 '{"Beginners with no programming experience", "Career changers", "Students", "Professionals upgrading skills"}',
 '{"Basic computer skills", "Willingness to learn", "Dedication to practice"}',
 'Technology', 'Web Development', 'beginner', 'en',
 199.99, 299.99, 'USD', 42.5, 25, 500, NOW() + INTERVAL '6 months',
 5, '{}',
 '{"Build production-ready web applications", "Understand modern development workflows", "Create responsive and interactive user interfaces", "Develop secure backend systems"}',
 '{"web development", "full stack", "javascript", "react", "node.js", "mongodb"}',
 true, true, 156, 4.7, 89, 78.5, NOW() - INTERVAL '3 months'),

('990e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440002',
 '770e8400-e29b-41d4-a716-446655440002',
 'Data Science and Machine Learning Masterclass',
 'data-science-machine-learning-masterclass',
 'Comprehensive data science course covering Python, statistics, machine learning algorithms, data visualization, and real-world projects. Perfect for beginners and professionals looking to enter the field.',
 'Master data science and machine learning with Python, statistics, and hands-on projects.',
 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400',
 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
 'Transform your career with this comprehensive data science masterclass. Learn from industry experts, work on real datasets, and build a portfolio of data science projects.',
 '{"Master Python for data science", "Understand statistical concepts", "Build machine learning models", "Create data visualizations", "Work with real datasets", "Deploy ML models"}',
 '["50+ hours of content", "Real datasets", "Jupyter notebooks", "Certificate", "Career guidance", "Project reviews"]',
 '{"Beginners interested in data science", "Professionals switching careers", "Students", "Analysts upgrading skills"}',
 '{"Basic mathematics knowledge", "Computer with internet", "Eagerness to learn"}',
 'Technology', 'Data Science', 'intermediate', 'en',
 249.99, 399.99, 'USD', 52.0, 25, 300, NOW() + INTERVAL '4 months',
 5, '{"Basic programming knowledge helpful"}',
 '{"Build end-to-end ML projects", "Analyze complex datasets", "Create predictive models", "Communicate insights effectively"}',
 '{"data science", "machine learning", "python", "statistics", "visualization"}',
 true, true, 89, 4.8, 67, 82.3, NOW() - INTERVAL '2 months'),

('990e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440001',
 '770e8400-e29b-41d4-a716-446655440003',
 'Mobile App Development with React Native',
 'mobile-app-development-react-native',
 'Build cross-platform mobile applications using React Native. Learn to create iOS and Android apps with a single codebase, integrate APIs, handle navigation, and publish to app stores.',
 'Create professional mobile apps for iOS and Android using React Native.',
 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400',
 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_3mb.mp4',
 'Master mobile app development with React Native and build apps that work on both iOS and Android platforms. Learn modern mobile development practices and create apps users love.',
 '{"Build cross-platform mobile apps", "Master React Native framework", "Integrate with APIs", "Handle device features", "Publish to app stores", "Optimize app performance"}',
 '["35+ hours of video", "5 complete apps", "Source code", "App store guidelines", "Certificate", "Mentor support"]',
 '{"Developers with React knowledge", "Mobile app enthusiasts", "Freelancers", "Entrepreneurs"}',
 '{"JavaScript fundamentals", "Basic React knowledge", "Mobile device for testing"}',
 'Technology', 'Mobile Development', 'intermediate', 'en',
 179.99, 249.99, 'USD', 38.0, 25, 200, NOW() + INTERVAL '5 months',
 5, '{"JavaScript", "React basics"}',
 '{"Develop professional mobile apps", "Understand mobile UX principles", "Integrate third-party services", "Deploy to production"}',
 '{"mobile development", "react native", "ios", "android", "cross-platform"}',
 true, false, 67, 4.6, 45, 75.8, NOW() - INTERVAL '1 month'),

('990e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440002',
 '770e8400-e29b-41d4-a716-446655440002',
 'Advanced Python Programming and Automation',
 'advanced-python-programming-automation',
 'Take your Python skills to the next level with advanced concepts, automation scripts, web scraping, API development, and performance optimization. Perfect for intermediate Python developers.',
 'Master advanced Python concepts and build powerful automation tools.',
 'https://images.unsplash.com/photo-1526379095098-d400fd0bf935?w=400',
 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_4mb.mp4',
 'Elevate your Python programming skills with advanced techniques, automation frameworks, and real-world applications. Build tools that save time and increase productivity.',
 '{"Master advanced Python concepts", "Build automation scripts", "Create web scrapers", "Develop APIs", "Optimize code performance", "Handle large datasets"}',
 '["30+ hours of content", "Automation projects", "Code templates", "Best practices guide", "Certificate", "Code reviews"]',
 '{"Intermediate Python developers", "Automation engineers", "Data professionals", "DevOps engineers"}',
 '{"Solid Python fundamentals", "Basic programming experience", "Understanding of OOP concepts"}',
 'Technology', 'Programming', 'advanced', 'en',
 159.99, 199.99, 'USD', 32.0, 25, 150, NOW() + INTERVAL '3 months',
 5, '{"Python fundamentals", "Object-oriented programming"}',
 '{"Write efficient Python code", "Automate repetitive tasks", "Build scalable applications", "Debug complex issues"}',
 '{"python", "automation", "scripting", "advanced programming", "optimization"}',
 true, false, 34, 4.5, 23, 68.2, NOW() - INTERVAL '2 weeks');

-- Step 7: Chapters for each course (5 chapters per course)
INSERT INTO chapters (
    id, course_id, title, description, chapter_number, duration_minutes, total_lessons, is_published, is_free
) VALUES
-- Course 1 Chapters
('aa0e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001',
 'Web Development Fundamentals', 'Learn the basics of HTML, CSS, and how the web works', 1, 480, 5, true, true),
('aa0e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440001',
 'JavaScript Essentials', 'Master JavaScript programming from basics to advanced concepts', 2, 540, 5, true, false),
('aa0e8400-e29b-41d4-a716-446655440003', '990e8400-e29b-41d4-a716-446655440001',
 'React Frontend Development', 'Build dynamic user interfaces with React', 3, 600, 5, true, false),
('aa0e8400-e29b-41d4-a716-446655440004', '990e8400-e29b-41d4-a716-446655440001',
 'Backend Development with Node.js', 'Create server-side applications and APIs', 4, 660, 5, true, false),
('aa0e8400-e29b-41d4-a716-446655440005', '990e8400-e29b-41d4-a716-446655440001',
 'Database and Deployment', 'Work with databases and deploy applications', 5, 570, 5, true, false),

-- Course 2 Chapters
('aa0e8400-e29b-41d4-a716-446655440006', '990e8400-e29b-41d4-a716-446655440002',
 'Python for Data Science', 'Master Python programming for data analysis', 1, 600, 5, true, true),
('aa0e8400-e29b-41d4-a716-446655440007', '990e8400-e29b-41d4-a716-446655440002',
 'Statistics and Data Analysis', 'Understand statistical concepts and data exploration', 2, 660, 5, true, false),
('aa0e8400-e29b-41d4-a716-446655440008', '990e8400-e29b-41d4-a716-446655440002',
 'Machine Learning Algorithms', 'Learn supervised and unsupervised learning', 3, 720, 5, true, false),
('aa0e8400-e29b-41d4-a716-446655440009', '990e8400-e29b-41d4-a716-446655440002',
 'Data Visualization', 'Create compelling visualizations and dashboards', 4, 540, 5, true, false),
('aa0e8400-e29b-41d4-a716-446655440010', '990e8400-e29b-41d4-a716-446655440002',
 'Advanced ML and Deployment', 'Deep learning and model deployment', 5, 600, 5, true, false),

-- Course 3 Chapters
('aa0e8400-e29b-41d4-a716-446655440011', '990e8400-e29b-41d4-a716-446655440003',
 'React Native Fundamentals', 'Introduction to React Native and mobile development', 1, 450, 5, true, true),
('aa0e8400-e29b-41d4-a716-446655440012', '990e8400-e29b-41d4-a716-446655440003',
 'Navigation and State Management', 'Handle navigation and manage app state', 2, 480, 5, true, false),
('aa0e8400-e29b-41d4-a716-446655440013', '990e8400-e29b-41d4-a716-446655440003',
 'Native Features and APIs', 'Access device features and integrate APIs', 3, 540, 5, true, false),
('aa0e8400-e29b-41d4-a716-446655440014', '990e8400-e29b-41d4-a716-446655440003',
 'Styling and Animations', 'Create beautiful UIs with animations', 4, 420, 5, true, false),
('aa0e8400-e29b-41d4-a716-446655440015', '990e8400-e29b-41d4-a716-446655440003',
 'Testing and Deployment', 'Test apps and publish to app stores', 5, 390, 5, true, false),

-- Course 4 Chapters
('aa0e8400-e29b-41d4-a716-446655440016', '990e8400-e29b-41d4-a716-446655440004',
 'Advanced Python Concepts', 'Decorators, generators, and advanced features', 1, 360, 5, true, true),
('aa0e8400-e29b-41d4-a716-446655440017', '990e8400-e29b-41d4-a716-446655440004',
 'Web Scraping and APIs', 'Extract data from websites and build APIs', 2, 420, 5, true, false),
('aa0e8400-e29b-41d4-a716-446655440018', '990e8400-e29b-41d4-a716-446655440004',
 'Automation and Scripting', 'Automate tasks and build useful scripts', 3, 480, 5, true, false),
('aa0e8400-e29b-41d4-a716-446655440019', '990e8400-e29b-41d4-a716-446655440004',
 'Performance Optimization', 'Write efficient and optimized Python code', 4, 360, 5, true, false),
('aa0e8400-e29b-41d4-a716-446655440020', '990e8400-e29b-41d4-a716-446655440004',
 'Advanced Projects', 'Build complex automation and data processing tools', 5, 300, 5, true, false);

-- Step 8: Lessons (5 lessons per chapter = 100 total lessons)
-- Course 1, Chapter 1 Lessons
INSERT INTO lessons (
    id, chapter_id, course_id, title, description, lesson_number, lesson_type,
    content_url, video_duration, transcript, attachments, is_published, is_free, view_count
) VALUES
('bb0e8400-e29b-41d4-a716-446655440001', 'aa0e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001',
 'Introduction to Web Development', 'Overview of web development and course structure', 1, 'video',
 'https://sample-videos.com/lesson1.mp4', 720, 'Welcome to the complete web development course...',
 '[{"name": "Course Outline.pdf", "url": "https://example.com/outline.pdf"}]', true, true, 1250),

('bb0e8400-e29b-41d4-a716-446655440002', 'aa0e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001',
 'HTML Fundamentals', 'Learn HTML structure, tags, and semantic markup', 2, 'video',
 'https://sample-videos.com/lesson2.mp4', 900, 'HTML is the foundation of web development...',
 '[{"name": "HTML Cheat Sheet.pdf", "url": "https://example.com/html-cheat.pdf"}]', true, true, 1180),

('bb0e8400-e29b-41d4-a716-446655440003', 'aa0e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001',
 'CSS Styling and Layout', 'Master CSS for styling and responsive layouts', 3, 'video',
 'https://sample-videos.com/lesson3.mp4', 1080, 'CSS allows us to style our HTML elements...',
 '[{"name": "CSS Examples.zip", "url": "https://example.com/css-examples.zip"}]', true, true, 1050),

('bb0e8400-e29b-41d4-a716-446655440004', 'aa0e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001',
 'Building Your First Website', 'Create a complete website using HTML and CSS', 4, 'video',
 'https://sample-videos.com/lesson4.mp4', 1200, 'Now lets put everything together...',
 '[{"name": "Project Files.zip", "url": "https://example.com/project1.zip"}]', true, false, 890),

('bb0e8400-e29b-41d4-a716-446655440005', 'aa0e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001',
 'Web Development Tools', 'Essential tools and browser developer tools', 5, 'video',
 'https://sample-videos.com/lesson5.mp4', 780, 'Professional developers use various tools...',
 '[{"name": "Tools List.pdf", "url": "https://example.com/tools.pdf"}]', true, false, 750);

-- Course 2, Chapter 1 Lessons
INSERT INTO lessons (
    id, chapter_id, course_id, title, description, lesson_number, lesson_type,
    content_url, video_duration, transcript, attachments, is_published, is_free, view_count
) VALUES
('bb0e8400-e29b-41d4-a716-446655440006', 'aa0e8400-e29b-41d4-a716-446655440006', '990e8400-e29b-41d4-a716-446655440002',
 'Python Installation and Setup', 'Set up Python environment for data science', 1, 'video',
 'https://sample-videos.com/ds-lesson1.mp4', 600, 'Welcome to data science with Python...',
 '[{"name": "Installation Guide.pdf", "url": "https://example.com/install.pdf"}]', true, true, 890),

('bb0e8400-e29b-41d4-a716-446655440007', 'aa0e8400-e29b-41d4-a716-446655440006', '990e8400-e29b-41d4-a716-446655440002',
 'Python Basics for Data Science', 'Essential Python concepts for data analysis', 2, 'video',
 'https://sample-videos.com/ds-lesson2.mp4', 840, 'Python is the most popular language for data science...',
 '[{"name": "Python Basics.ipynb", "url": "https://example.com/basics.ipynb"}]', true, true, 780),

('bb0e8400-e29b-41d4-a716-446655440008', 'aa0e8400-e29b-41d4-a716-446655440006', '990e8400-e29b-41d4-a716-446655440002',
 'NumPy for Numerical Computing', 'Master NumPy for efficient numerical operations', 3, 'video',
 'https://sample-videos.com/ds-lesson3.mp4', 960, 'NumPy is the foundation of data science in Python...',
 '[{"name": "NumPy Tutorial.ipynb", "url": "https://example.com/numpy.ipynb"}]', true, false, 650),

('bb0e8400-e29b-41d4-a716-446655440009', 'aa0e8400-e29b-41d4-a716-446655440006', '990e8400-e29b-41d4-a716-446655440002',
 'Pandas for Data Manipulation', 'Learn pandas for data cleaning and analysis', 4, 'video',
 'https://sample-videos.com/ds-lesson4.mp4', 1080, 'Pandas is essential for data manipulation...',
 '[{"name": "Pandas Examples.ipynb", "url": "https://example.com/pandas.ipynb"}]', true, false, 590),

('bb0e8400-e29b-41d4-a716-446655440010', 'aa0e8400-e29b-41d4-a716-446655440006', '990e8400-e29b-41d4-a716-446655440002',
 'Data Loading and Exploration', 'Load and explore real datasets', 5, 'video',
 'https://sample-videos.com/ds-lesson5.mp4', 720, 'Now lets work with real data...',
 '[{"name": "Sample Dataset.csv", "url": "https://example.com/dataset.csv"}]', true, false, 520);

-- Step 9: Course Enrollments
INSERT INTO course_enrollments (
    id, student_id, course_id, enrolled_at, progress_percentage, total_time_spent,
    last_accessed_at, lessons_completed, total_lessons_in_course, is_active
) VALUES
('cc0e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001',
 NOW() - INTERVAL '2 months', 68.0, 1620, NOW() - INTERVAL '1 day', 17, 25, true),

('cc0e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440003',
 NOW() - INTERVAL '1 month', 32.0, 720, NOW() - INTERVAL '3 days', 8, 25, true),

('cc0e8400-e29b-41d4-a716-446655440003', '880e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440002',
 NOW() - INTERVAL '3 weeks', 24.0, 600, NOW() - INTERVAL '2 days', 6, 25, true),

('cc0e8400-e29b-41d4-a716-446655440004', '880e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440002',
 NOW() - INTERVAL '6 weeks', 76.0, 1440, NOW() - INTERVAL '1 day', 19, 25, true),

('cc0e8400-e29b-41d4-a716-446655440005', '880e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440004',
 NOW() - INTERVAL '2 weeks', 45.0, 540, NOW() - INTERVAL '4 hours', 11, 25, true);

-- Step 10: Lesson Progress
INSERT INTO lesson_progress (
    id, student_id, lesson_id, course_id, started_at, completed_at, time_spent,
    progress_percentage, is_completed, watch_time_seconds, last_watched_at
) VALUES
-- Alex Wilson's progress
('dd0e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440001', 'bb0e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001',
 NOW() - INTERVAL '2 months', NOW() - INTERVAL '2 months', 720, 100.0, true, 720, NOW() - INTERVAL '2 months'),

('dd0e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440001', 'bb0e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440001',
 NOW() - INTERVAL '7 weeks', NOW() - INTERVAL '7 weeks', 900, 100.0, true, 900, NOW() - INTERVAL '7 weeks'),

('dd0e8400-e29b-41d4-a716-446655440003', '880e8400-e29b-41d4-a716-446655440001', 'bb0e8400-e29b-41d4-a716-446655440003', '990e8400-e29b-41d4-a716-446655440001',
 NOW() - INTERVAL '6 weeks', NOW() - INTERVAL '6 weeks', 1080, 100.0, true, 1080, NOW() - INTERVAL '6 weeks'),

-- Maria Garcia's progress
('dd0e8400-e29b-41d4-a716-446655440004', '880e8400-e29b-41d4-a716-446655440002', 'bb0e8400-e29b-41d4-a716-446655440006', '990e8400-e29b-41d4-a716-446655440002',
 NOW() - INTERVAL '6 weeks', NOW() - INTERVAL '6 weeks', 600, 100.0, true, 600, NOW() - INTERVAL '6 weeks'),

('dd0e8400-e29b-41d4-a716-446655440005', '880e8400-e29b-41d4-a716-446655440002', 'bb0e8400-e29b-41d4-a716-446655440007', '990e8400-e29b-41d4-a716-446655440002',
 NOW() - INTERVAL '5 weeks', NOW() - INTERVAL '5 weeks', 840, 100.0, true, 840, NOW() - INTERVAL '5 weeks');

-- Step 11: Live Classes
INSERT INTO live_classes (
    id, coaching_center_id, teacher_id, course_id, title, description, scheduled_at,
    duration_minutes, max_participants, current_participants, meeting_url, thumbnail_url,
    meeting_id, meeting_password, price, currency, is_free, status, chat_enabled, q_and_a_enabled
) VALUES
-- Course-related live classes
('ee0e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001',
 'Advanced React Patterns - Live Q&A', 'Deep dive into advanced React patterns with live coding and Q&A session',
 NOW() + INTERVAL '3 days', 90, 100, 45, 'https://zoom.us/j/123456789', 'https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=300',
 'REACT-LIVE-001', 'ReactPass123', 29.99, 'USD', false, 'scheduled', true, true),

('ee0e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440002', '770e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440002',
 'Machine Learning Model Deployment Workshop', 'Hands-on workshop on deploying ML models to production',
 NOW() + INTERVAL '1 week', 120, 50, 23, 'https://zoom.us/j/987654321', 'https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=300',
 'ML-DEPLOY-001', 'MLDeploy456', 49.99, 'USD', false, 'scheduled', true, true),

('ee0e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440003', '990e8400-e29b-41d4-a716-446655440003',
 'React Native Performance Optimization', 'Learn advanced techniques to optimize React Native app performance',
 NOW() + INTERVAL '5 days', 75, 75, 12, 'https://zoom.us/j/456789123', 'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=300',
 'RN-PERF-001', 'RNPerf789', 39.99, 'USD', false, 'scheduled', true, true),

-- Individual live class
('ee0e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440002', '770e8400-e29b-41d4-a716-446655440002', NULL,
 'Career Transition to Tech - AMA Session', 'Ask Me Anything session about transitioning to a tech career, resume tips, and interview preparation',
 NOW() + INTERVAL '2 weeks', 60, 200, 78, 'https://zoom.us/j/789123456', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
 'CAREER-AMA-001', 'CareerAMA321', 0.00, 'USD', true, 'scheduled', true, true);

-- Step 12: Live Class Enrollments
INSERT INTO live_class_enrollments (
    id, student_id, live_class_id, enrolled_at, attended, attendance_duration, rating, feedback
) VALUES
('ff0e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440001', 'ee0e8400-e29b-41d4-a716-446655440001',
 NOW() - INTERVAL '2 days', false, 0, NULL, NULL),

('ff0e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440002', 'ee0e8400-e29b-41d4-a716-446655440002',
 NOW() - INTERVAL '3 days', false, 0, NULL, NULL),

('ff0e8400-e29b-41d4-a716-446655440003', '880e8400-e29b-41d4-a716-446655440001', 'ee0e8400-e29b-41d4-a716-446655440004',
 NOW() - INTERVAL '1 day', false, 0, NULL, NULL),

('ff0e8400-e29b-41d4-a716-446655440004', '880e8400-e29b-41d4-a716-446655440002', 'ee0e8400-e29b-41d4-a716-446655440004',
 NOW() - INTERVAL '1 day', false, 0, NULL, NULL);

-- Step 13: Tests
INSERT INTO tests (
    id, course_id, chapter_id, coaching_center_id, teacher_id, title, description,
    test_type, total_questions, total_marks, passing_marks, time_limit_minutes,
    attempts_allowed, show_results_immediately, randomize_questions, is_published
) VALUES
('aa0e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001', 'aa0e8400-e29b-41d4-a716-446655440001',
 '660e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440001',
 'HTML & CSS Fundamentals Quiz', 'Test your knowledge of HTML and CSS basics', 'quiz',
 10, 20, 14, 15, 3, true, true, true),

('bb0e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440002', 'aa0e8400-e29b-41d4-a716-446655440006',
 '660e8400-e29b-41d4-a716-446655440002', '770e8400-e29b-41d4-a716-446655440002',
 'Python Basics Assessment', 'Evaluate your understanding of Python fundamentals', 'quiz',
 15, 30, 21, 20, 2, true, false, true);


-- Step 14.1: Test Questions
INSERT INTO test_questions (
    id, test_id, question_text, question_type, options, correct_answers, marks, explanation, question_order
) VALUES
('cc0e8400-e29b-41d4-a716-446655440001', 'aa0e8400-e29b-41d4-a716-446655440001',
 'What does HTML stand for?', 'mcq',
 '["HyperText Markup Language", "High Tech Modern Language", "Home Tool Markup Language", "Hyperlink and Text Markup Language"]',
 '["HyperText Markup Language"]', 2, 'HTML stands for HyperText Markup Language, which is the standard markup language for creating web pages.', 1),

('dd0e8400-e29b-41d4-a716-446655440002', 'aa0e8400-e29b-41d4-a716-446655440001',
 'Which CSS property is used to change the text color?', 'mcq',
 '["color", "text-color", "font-color", "text-style"]',
 '["color"]', 2, 'The color property in CSS is used to set the color of text.', 2),

('ee0e8400-e29b-41d4-a716-446655440003', 'bb0e8400-e29b-41d4-a716-446655440002',
 'What is the correct way to create a list in Python?', 'mcq',
 '["list = [1, 2, 3]", "list = (1, 2, 3)", "list = {1, 2, 3}", "list = <1, 2, 3>"]',
 '["list = [1, 2, 3]"]', 2, 'Lists in Python are created using square brackets [].', 1);

-- Step 14.2: Test Results
INSERT INTO test_results (
    id, test_id, student_id, started_at, completed_at, score, total_marks,
    time_taken_minutes, answers, is_submitted
) VALUES
-- Alex Wilson's test results
('aa0e8400-e29b-41d4-a716-446655440201', 'aa0e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440001',
 NOW() - INTERVAL '2 weeks', NOW() - INTERVAL '2 weeks' + INTERVAL '12 minutes', 18.0, 20.0,
 12, '{
    "cc0e8400-e29b-41d4-a716-446655440001": {"selected": "HyperText Markup Language", "correct": true, "time_spent": 45},
    "dd0e8400-e29b-41d4-a716-446655440002": {"selected": "color", "correct": true, "time_spent": 30}
 }', true),

-- Maria Garcia's test results
('bb0e8400-e29b-41d4-a716-446655440202', 'bb0e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440002',
 NOW() - INTERVAL '1 week', NOW() - INTERVAL '1 week' + INTERVAL '18 minutes', 26.0, 30.0,
 18, '{
    "ee0e8400-e29b-41d4-a716-446655440003": {"selected": "list = [1, 2, 3]", "correct": true, "time_spent": 60}
 }', true),

-- Alex Wilson attempting Python test
('cc0e8400-e29b-41d4-a716-446655440203', 'bb0e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440001',
 NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days' + INTERVAL '15 minutes', 24.0, 30.0,
 15, '{
    "ee0e8400-e29b-41d4-a716-446655440003": {"selected": "list = [1, 2, 3]", "correct": true, "time_spent": 45}
 }', true),

-- Maria Garcia attempting HTML/CSS test
('dd0e8400-e29b-41d4-a716-446655440204', 'aa0e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440002',
 NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days' + INTERVAL '10 minutes', 16.0, 20.0,
 10, '{
    "cc0e8400-e29b-41d4-a716-446655440001": {"selected": "HyperText Markup Language", "correct": true, "time_spent": 35},
    "dd0e8400-e29b-41d4-a716-446655440002": {"selected": "color", "correct": true, "time_spent": 25}
 }', true);


-- Step 15: Payments
INSERT INTO payments (
    id, student_id, course_id, live_class_id, payment_type, amount, currency,
    payment_method, payment_gateway, transaction_id, gateway_transaction_id,
    status, payment_date, metadata
) VALUES
('aa0e8400-e29b-41d4-a716-446655440011', '880e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001', NULL,
 'course', 199.99, 'USD', 'credit_card', 'stripe', 'TXN-COURSE-001', 'pi_1234567890',
 'completed', NOW() - INTERVAL '2 months',
 '{"card_last4": "4242", "card_brand": "visa", "receipt_url": "https://stripe.com/receipt/123"}'),

('bb0e8400-e29b-41d4-a716-446655440012', '880e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440003', NULL,
 'course', 179.99, 'USD', 'paypal', 'paypal', 'TXN-COURSE-002', 'PAYPAL-987654321',
 'completed', NOW() - INTERVAL '1 month',
 '{"paypal_email": "alex.wilson@gmail.com", "transaction_fee": 5.40}'),

('cc0e8400-e29b-41d4-a716-446655440013', '880e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440002', NULL,
 'course', 249.99, 'USD', 'credit_card', 'stripe', 'TXN-COURSE-003', 'pi_0987654321',
 'completed', NOW() - INTERVAL '6 weeks',
 '{"card_last4": "1234", "card_brand": "mastercard", "receipt_url": "https://stripe.com/receipt/456"}'),

('dd0e8400-e29b-41d4-a716-446655440014', '880e8400-e29b-41d4-a716-446655440001', NULL, 'ee0e8400-e29b-41d4-a716-446655440001',
 'live_class', 29.99, 'USD', 'credit_card', 'stripe', 'TXN-LIVE-001', 'pi_1122334455',
 'completed', NOW() - INTERVAL '2 days',
 '{"card_last4": "4242", "card_brand": "visa", "receipt_url": "https://stripe.com/receipt/789"}');

-- Step 16: Reviews
INSERT INTO reviews (
    id, student_id, course_id, teacher_id, rating, review_text, pros, cons,
    is_verified_purchase, is_published, helpful_votes_count, not_helpful_votes_count, created_at
) VALUES
('aa0e8400-e29b-41d4-a716-446655440021', '880e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440001',
 5, 'Excellent course! John explains complex concepts in a very clear and understandable way. The projects are practical and helped me build a solid portfolio.',
 'Clear explanations, practical projects, responsive instructor', 'Could use more advanced topics',
 true, true, 0, 0, NOW() - INTERVAL '1 month'),

('bb0e8400-e29b-41d4-a716-446655440022', '880e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440002', '770e8400-e29b-41d4-a716-446655440002',
 5, 'Amazing data science course! Emily is incredibly knowledgeable and the hands-on approach with real datasets makes learning so much more effective.',
 'Expert instructor, real datasets, comprehensive coverage', 'Fast-paced for beginners',
 true, true, 0, 0, NOW() - INTERVAL '3 weeks'),

('cc0e8400-e29b-41d4-a716-446655440023', '880e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440003', '770e8400-e29b-41d4-a716-446655440003',
 4, 'Great mobile development course! Raj covers both iOS and Android development well. The cross-platform approach saves a lot of time.',
 'Cross-platform focus, practical examples, good code quality', 'Could use more native-specific content',
 true, true, 0, 0, NOW() - INTERVAL '2 weeks');

-- Step 17: Sample review helpful votes
INSERT INTO review_helpful_votes (
    id, review_id, user_id, vote_type
) VALUES
('aa0e8400-e29b-41d4-a716-446655440051', 'aa0e8400-e29b-41d4-a716-446655440021', '550e8400-e29b-41d4-a716-446655440008', 'helpful'),
('bb0e8400-e29b-41d4-a716-446655440052', 'aa0e8400-e29b-41d4-a716-446655440021', '550e8400-e29b-41d4-a716-446655440004', 'helpful'),
('cc0e8400-e29b-41d4-a716-446655440053', 'bb0e8400-e29b-41d4-a716-446655440022', '550e8400-e29b-41d4-a716-446655440007', 'helpful'),
('dd0e8400-e29b-41d4-a716-446655440054', 'bb0e8400-e29b-41d4-a716-446655440022', '550e8400-e29b-41d4-a716-446655440004', 'helpful'),
('ee0e8400-e29b-41d4-a716-446655440055', 'cc0e8400-e29b-41d4-a716-446655440023', '550e8400-e29b-41d4-a716-446655440008', 'helpful'),
('ff0e8400-e29b-41d4-a716-446655440056', 'aa0e8400-e29b-41d4-a716-446655440021', '550e8400-e29b-41d4-a716-446655440006', 'not_helpful');


-- Step 18: Notifications
INSERT INTO notifications (
    id, user_id, title, message, notification_type, reference_id, reference_type,
    is_read, priority, scheduled_at, expires_at
) VALUES
('aa0e8400-e29b-41d4-a716-446655440031', '550e8400-e29b-41d4-a716-446655440007',
 'New Lesson Available', 'Chapter 3: React Frontend Development - New lesson "Component State Management" is now available',
 'course_update', '990e8400-e29b-41d4-a716-446655440001', 'course',
 false, 'medium', NOW() - INTERVAL '2 hours', NOW() + INTERVAL '7 days'),

('bb0e8400-e29b-41d4-a716-446655440032', '550e8400-e29b-41d4-a716-446655440008',
 'Live Class Reminder', 'Your live class "Machine Learning Model Deployment Workshop" starts in 24 hours',
 'live_class_reminder', 'ee0e8400-e29b-41d4-a716-446655440002', 'live_class',
 false, 'high', NOW() - INTERVAL '1 hour', NOW() + INTERVAL '2 days'),

('cc0e8400-e29b-41d4-a716-446655440033', '550e8400-e29b-41d4-a716-446655440007',
 'Assignment Due Soon', 'Your assignment for "HTML & CSS Fundamentals Quiz" is due in 3 days',
 'assignment_due', 'aa0e8400-e29b-41d4-a716-446655440001', 'test',
 true, 'medium', NOW() - INTERVAL '4 hours', NOW() + INTERVAL '3 days'),

('dd0e8400-e29b-41d4-a716-446655440034', '550e8400-e29b-41d4-a716-446655440004',
 'New Student Enrollment', 'Alex Wilson has enrolled in your course "Complete Full Stack Web Development Bootcamp"',
 'enrollment', '990e8400-e29b-41d4-a716-446655440001', 'course',
 false, 'low', NOW() - INTERVAL '2 months', NOW() + INTERVAL '30 days');

-- Step 19: Certificates
INSERT INTO certificates (
    id, student_id, course_id, coaching_center_id, teacher_id, certificate_number,
    certificate_name, issued_date, certificate_url, verification_code, is_verified,
    completion_percentage, grade, skills_acquired
) VALUES
('aa0e8400-e29b-41d4-a716-446655440041', '880e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001',
 '660e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440001',
 'CERT-TECH-2024-001', 'Complete Full Stack Web Development Bootcamp Certificate',
 NOW() - INTERVAL '2 weeks', 'https://certificates.techacademy.com/cert-001.pdf',
 'VERIFY-ABC123XYZ', true, 100.0, 'A+',
 ARRAY['HTML', 'CSS', 'JavaScript', 'React', 'Node.js', 'MongoDB']),

('bb0e8400-e29b-41d4-a716-446655440042', '880e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440002',
 '660e8400-e29b-41d4-a716-446655440002', '770e8400-e29b-41d4-a716-446655440002',
 'CERT-SKILL-2024-001', 'Data Science and Machine Learning Masterclass Certificate',
 NOW() - INTERVAL '1 week', 'https://certificates.skillhub.edu/cert-002.pdf',
 'VERIFY-XYZ789ABC', true, 100.0, 'A',
 ARRAY['Python', 'Statistics', 'Machine Learning', 'Data Visualization', 'Pandas', 'NumPy']);



-- Step 20: Assignments
INSERT INTO assignments (
    id, course_id, chapter_id, teacher_id, title, description, assignment_type,
    total_marks, due_date, submission_format, is_published, submission_count
) VALUES
('aa0e8400-e29b-41d4-a716-446655440101', '990e8400-e29b-41d4-a716-446655440001', 'aa0e8400-e29b-41d4-a716-446655440003',
 '770e8400-e29b-41d4-a716-446655440001', 'Build a React Todo Application',
 'Create a fully functional todo application using React. Include features like add, edit, delete, and mark as complete. Use hooks for state management and implement local storage.',
 'project', 50, NOW() + INTERVAL '1 week', 'github_link',
 true, 1),

('bb0e8400-e29b-41d4-a716-446655440102', '990e8400-e29b-41d4-a716-446655440002', 'aa0e8400-e29b-41d4-a716-446655440008',
 '770e8400-e29b-41d4-a716-446655440002', 'Data Analysis Project',
 'Analyze the provided sales dataset and create visualizations to identify trends, patterns, and insights. Submit a Jupyter notebook with your analysis and findings.',
 'project', 75, NOW() + INTERVAL '2 weeks', 'file_upload',
 true, 1),

('cc0e8400-e29b-41d4-a716-446655440103', '990e8400-e29b-41d4-a716-446655440003', 'aa0e8400-e29b-41d4-a716-446655440011',
 '770e8400-e29b-41d4-a716-446655440003', 'Mobile App UI Design',
 'Design a complete mobile app interface using Figma or similar tools. Include wireframes, mockups, and a design system.',
 'presentation', 40, NOW() + INTERVAL '10 days', 'url_submission',
 true, 0);

-- Step 21: Assignment Submissions
INSERT INTO assignment_submissions (
    id, assignment_id, student_id, submission_url, submission_text, submitted_at,
    grade, feedback, graded_at, graded_by, is_late
) VALUES
('aa0e8400-e29b-41d4-a716-446655440111', 'aa0e8400-e29b-41d4-a716-446655440101', '880e8400-e29b-41d4-a716-446655440001',
 'https://github.com/alexwilson/react-todo-app', 'I have implemented all the required features including local storage and responsive design. The app is fully functional and tested.',
 NOW() - INTERVAL '2 days', 45, 'Excellent work! Clean code structure and good use of React hooks. Minor suggestion: consider adding PropTypes for better type checking.',
 NOW() - INTERVAL '1 day', '770e8400-e29b-41d4-a716-446655440001', false),

('bb0e8400-e29b-41d4-a716-446655440112', 'bb0e8400-e29b-41d4-a716-446655440102', '880e8400-e29b-41d4-a716-446655440002',
 NULL, 'Please find attached my Jupyter notebook with comprehensive data analysis. I have identified key trends in sales data and created visualizations using matplotlib and seaborn.',
 NOW() - INTERVAL '3 days', 68, 'Good analysis and insights. The visualizations are clear and well-labeled. Consider adding more statistical tests for deeper analysis.',
 NOW() - INTERVAL '2 days', '770e8400-e29b-41d4-a716-446655440002', false);

-- Step 22: coupons
INSERT INTO coupons (
    id, coaching_center_id, code, description, discount_type, discount_value,
    minimum_amount, maximum_discount, valid_from, valid_until, usage_limit,
    used_count, is_active, applicable_courses
) VALUES
('aa0e8400-e29b-41d4-a716-446655440061', '660e8400-e29b-41d4-a716-446655440001',
 'WELCOME20', 'Welcome discount for new students', 'percentage', 20.00,
 50.00, 100.00, NOW() - INTERVAL '1 month', NOW() + INTERVAL '2 months',
 100, 23, true, ARRAY['990e8400-e29b-41d4-a716-446655440001'::UUID, '990e8400-e29b-41d4-a716-446655440003'::UUID]),

('bb0e8400-e29b-41d4-a716-446655440062', '660e8400-e29b-41d4-a716-446655440002',
 'EARLYBIRD50', 'Early bird discount for data science course', 'fixed', 50.00,
 100.00, 50.00, NOW() - INTERVAL '2 weeks', NOW() + INTERVAL '1 month',
 50, 12, true, ARRAY['990e8400-e29b-41d4-a716-446655440002'::UUID]),

('cc0e8400-e29b-41d4-a716-446655440063', '660e8400-e29b-41d4-a716-446655440001',
 'STUDENT15', 'Student discount for all courses', 'percentage', 15.00,
 0.00, 75.00, NOW(), NOW() + INTERVAL '6 months',
 NULL, 45, true, ARRAY[]::UUID[]); -- Empty UUID array

-- Step 23: Insert sample wishlists
INSERT INTO wishlists (
    id, student_id, course_id, added_at, priority, notes
) VALUES
('aa0e8400-e29b-41d4-a716-446655440071', '880e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440004', NOW() - INTERVAL '1 week', 3, 'Want to learn Python automation for my current job'),
('bb0e8400-e29b-41d4-a716-446655440072', '880e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440003', NOW() - INTERVAL '3 days', 2, 'Interested in mobile development after completing data science course');

-- Step 24: Insert sample learning paths (if you decide to keep them)
INSERT INTO learning_paths (
    id, coaching_center_id, title, description, difficulty_level, estimated_duration_hours,
    total_courses, thumbnail_url, is_published, enrollment_count, price, currency
) VALUES
('aa0e8400-e29b-41d4-a716-446655440081', '660e8400-e29b-41d4-a716-446655440001',
 'Complete Web Developer Path', 'Become a full-stack web developer with this comprehensive learning path covering frontend, backend, and deployment',
 'beginner', 120, 3, 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=400',
 true, 45, 499.99, 'INR'),

('bb0e8400-e29b-41d4-a716-446655440082', '660e8400-e29b-41d4-a716-446655440002',
 'Data Science Career Track', 'Master data science from basics to advanced machine learning and land your dream job',
 'intermediate', 180, 2, 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400',
 true, 28, 799.99, 'INR');

-- Step 25: Insert learning path courses
INSERT INTO learning_path_courses (
    id, learning_path_id, course_id, course_order, is_required
) VALUES
('aa0e8400-e29b-41d4-a716-446655440091', 'aa0e8400-e29b-41d4-a716-446655440081', '990e8400-e29b-41d4-a716-446655440001', 1, true),
('bb0e8400-e29b-41d4-a716-446655440092', 'aa0e8400-e29b-41d4-a716-446655440081', '990e8400-e29b-41d4-a716-446655440003', 2, true),
('cc0e8400-e29b-41d4-a716-446655440093', 'aa0e8400-e29b-41d4-a716-446655440081', '990e8400-e29b-41d4-a716-446655440004', 3, false),
('dd0e8400-e29b-41d4-a716-446655440094', 'bb0e8400-e29b-41d4-a716-446655440082', '990e8400-e29b-41d4-a716-446655440002', 1, true),
('ee0e8400-e29b-41d4-a716-446655440095', 'bb0e8400-e29b-41d4-a716-446655440082', '990e8400-e29b-41d4-a716-446655440004', 2, false);
-- Step 26: Analytics Events
INSERT INTO analytics_events (
    id, user_id, event_type, event_category, event_action, event_label,
    properties, session_id, ip_address, user_agent, created_at
) VALUES
('aa0e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440007',
 'lesson_started', 'learning', 'lesson_start', 'React Frontend Development - Lesson 1',
 '{"lesson_id": "bb0e8400-e29b-41d4-a716-446655440001", "course_id": "990e8400-e29b-41d4-a716-446655440001"}',
 'session_001', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
 NOW() - INTERVAL '2 hours'),

('bb0e8400-e29b-41d4-a716-446655440202', '550e8400-e29b-41d4-a716-446655440008',
 'course_enrolled', 'enrollment', 'course_enroll', 'Data Science and Machine Learning Masterclass',
 '{"course_id": "990e8400-e29b-41d4-a716-446655440002", "payment_amount": 249.99}',
 'session_002', '192.168.1.101', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
 NOW() - INTERVAL '6 weeks'),

('cc0e8400-e29b-41d4-a716-446655440203', '550e8400-e29b-41d4-a716-446655440007',
 'test_completed', 'assessment', 'test_complete', 'HTML & CSS Fundamentals Quiz',
 '{"test_id": "aa0e8400-e29b-41d4-a716-446655440001", "score": 18, "total": 20}',
 'session_003', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
 NOW() - INTERVAL '1 week'),

-- Additional analytics events for comprehensive data
('dd0e8400-e29b-41d4-a716-446655440204', '550e8400-e29b-41d4-a716-446655440008',
 'lesson_completed', 'learning', 'lesson_complete', 'Python Basics for Data Science',
 '{"lesson_id": "bb0e8400-e29b-41d4-a716-446655440006", "course_id": "990e8400-e29b-41d4-a716-446655440002", "completion_time": 1800}',
 'session_004', '192.168.1.101', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
 NOW() - INTERVAL '5 weeks'),

('ee0e8400-e29b-41d4-a716-446655440205', '550e8400-e29b-41d4-a716-446655440007',
 'video_watched', 'content', 'video_play', 'Introduction to Web Development',
 '{"lesson_id": "bb0e8400-e29b-41d4-a716-446655440001", "video_duration": 720, "watch_time": 680, "completion_rate": 94.4}',
 'session_005', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
 NOW() - INTERVAL '3 days'),

('ff0e8400-e29b-41d4-a716-446655440206', '550e8400-e29b-41d4-a716-446655440008',
 'assignment_submitted', 'assessment', 'assignment_submit', 'Data Analysis Project',
 '{"assignment_id": "bb0e8400-e29b-41d4-a716-446655440102", "submission_type": "file_upload", "file_size": 2048}',
 'session_006', '192.168.1.101', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
 NOW() - INTERVAL '4 days');


-- Step 28: app_config
INSERT INTO app_config (config_key, config_value, description, is_public) VALUES
('platform_info', '{
    "name": "EduTech Learning Platform",
    "tagline": "Empowering Minds, Transforming Futures",
    "logo_url": "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=200",
    "favicon_url": "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=32",
    "primary_color": "#3B82F6",
    "secondary_color": "#10B981"
}', 'Platform branding and visual identity', true),

('organization_details', '{
    "company_name": "EduTech Solutions Pvt Ltd",
    "registration_number": "U80904TN2023PTC123456",
    "address": {
        "street": "123 Tech Park Road",
        "city": "Chennai",
        "state": "Tamil Nadu",
        "postal_code": "600001",
        "country": "India"
    },
    "contact": {
        "email": "info@edutech.com",
        "phone": "+91-44-12345678",
        "support_email": "support@edutech.com"
    },
    "social_media": {
        "website": "https://edutech.com",
        "linkedin": "https://linkedin.com/company/edutech",
        "twitter": "https://twitter.com/edutech",
        "facebook": "https://facebook.com/edutech"
    }
}', 'Organization contact and legal information', true),

('developers_info', '{
    "development_team": "TechCraft Solutions",
    "lead_developer": "Rajesh Kumar",
    "team_members": [
        {"name": "Rajesh Kumar", "role": "Lead Full Stack Developer", "email": "rajesh@techcraft.com"},
        {"name": "Priya Sharma", "role": "Frontend Developer", "email": "priya@techcraft.com"},
        {"name": "Arjun Patel", "role": "Backend Developer", "email": "arjun@techcraft.com"},
        {"name": "Sneha Reddy", "role": "UI/UX Designer", "email": "sneha@techcraft.com"}
    ],
    "development_company": {
        "name": "TechCraft Solutions",
        "website": "https://techcraft.com",
        "email": "hello@techcraft.com",
        "phone": "+91-80-98765432"
    },
    "project_timeline": {
        "started": "2024-01-15",
        "version": "1.0.0",
        "last_updated": "2025-07-06"
    }
}', 'Development team and project information', false),

('course_categories', '{
    "categories": [
        {
            "id": "technology",
            "name": "Technology",
            "description": "Programming, web development, mobile apps, and emerging technologies",
            "icon": "💻",
            "color": "#3B82F6",
            "subcategories": [
                {"id": "web-development", "name": "Web Development", "description": "Frontend, backend, and full-stack development"},
                {"id": "mobile-development", "name": "Mobile Development", "description": "iOS, Android, and cross-platform apps"},
                {"id": "data-science", "name": "Data Science", "description": "Data analysis, ML, and AI"},
                {"id": "programming", "name": "Programming", "description": "Programming languages and concepts"}
            ]
        },
        {
            "id": "business",
            "name": "Business",
            "description": "Business skills, management, and entrepreneurship",
            "icon": "📊",
            "color": "#10B981",
            "subcategories": [
                {"id": "digital-marketing", "name": "Digital Marketing", "description": "SEO, social media, and online marketing"},
                {"id": "project-management", "name": "Project Management", "description": "Agile, Scrum, and project planning"},
                {"id": "finance", "name": "Finance", "description": "Accounting, investment, and financial planning"}
            ]
        },
        {
            "id": "design",
            "name": "Design",
            "description": "UI/UX design, graphic design, and creative skills",
            "icon": "🎨",
            "color": "#F59E0B",
            "subcategories": [
                {"id": "ui-ux", "name": "UI/UX Design", "description": "User interface and experience design"},
                {"id": "graphic-design", "name": "Graphic Design", "description": "Visual design and branding"},
                {"id": "web-design", "name": "Web Design", "description": "Website design and layout"}
            ]
        }
    ]
}', 'Course categories and subcategories configuration', true),

('system_settings', '{
    "max_file_upload_size": 50,
    "email_verification_required": true,
    "default_currency": "INR",
    "supported_currencies": ["INR", "USD", "EUR"],
    "timezone": "Asia/Kolkata",
    "date_format": "DD/MM/YYYY",
    "time_format": "24h",
    "pagination_limit": 20,
    "session_timeout": 3600,
    "password_policy": {
        "min_length": 8,
        "require_uppercase": true,
        "require_lowercase": true,
        "require_numbers": true,
        "require_special_chars": true
    }
}', 'System configuration and limits', false),

('payment_settings', '{
    "payment_gateways": {
        "razorpay": {
            "enabled": true,
            "supported_methods": ["card", "netbanking", "upi", "wallet"]
        },
        "stripe": {
            "enabled": true,
            "supported_methods": ["card", "paypal"]
        }
    },
    "default_gateway": "razorpay",
    "currency_settings": {
        "INR": {"symbol": "₹", "decimal_places": 2},
        "USD": {"symbol": "$", "decimal_places": 2}
    },
    "tax_settings": {
        "gst_rate": 18,
        "include_tax_in_price": true
    }
}', 'Payment gateway and currency configuration', false);

-- Step 27: Update statistics and counts
UPDATE courses SET
    enrollment_count = (SELECT COUNT(*) FROM course_enrollments WHERE course_id = courses.id),
    total_reviews = (SELECT COUNT(*) FROM reviews WHERE course_id = courses.id),
    rating = (SELECT AVG(rating) FROM reviews WHERE course_id = courses.id AND is_published = true)
WHERE id IN ('990e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440003', '990e8400-e29b-41d4-a716-446655440004');

UPDATE teachers SET
    total_reviews = (SELECT COUNT(*) FROM reviews WHERE teacher_id = teachers.id),
    rating = (SELECT AVG(rating) FROM reviews WHERE teacher_id = teachers.id AND is_published = true)
WHERE id IN ('770e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440002', '770e8400-e29b-41d4-a716-446655440003');

UPDATE coaching_centers SET
    total_courses = (SELECT COUNT(*) FROM courses WHERE coaching_center_id = coaching_centers.id AND is_published = true),
    total_students = (SELECT COUNT(DISTINCT student_id) FROM course_enrollments ce JOIN courses c ON ce.course_id = c.id WHERE c.coaching_center_id = coaching_centers.id)
WHERE id IN ('660e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440002');

-- Final verification queries
SELECT 'Users Created' as table_name, COUNT(*) as count FROM auth.users
UNION ALL
SELECT 'User Identities', COUNT(*) FROM auth.identities
UNION ALL
SELECT 'User Profiles', COUNT(*) FROM user_profiles
UNION ALL
SELECT 'Coaching Centers', COUNT(*) FROM coaching_centers
UNION ALL
SELECT 'Teachers', COUNT(*) FROM teachers
UNION ALL
SELECT 'Students', COUNT(*) FROM students
UNION ALL
SELECT 'Courses', COUNT(*) FROM courses
UNION ALL
SELECT 'Chapters', COUNT(*) FROM chapters
UNION ALL
SELECT 'Lessons', COUNT(*) FROM lessons
UNION ALL
SELECT 'Live Classes', COUNT(*) FROM live_classes
UNION ALL
SELECT 'Live Class Enrollments', COUNT(*) FROM live_class_enrollments
UNION ALL
SELECT 'Course Enrollments', COUNT(*) FROM course_enrollments
UNION ALL
SELECT 'Lesson Progress', COUNT(*) FROM lesson_progress
UNION ALL
SELECT 'Payments', COUNT(*) FROM payments
UNION ALL
SELECT 'Reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'Review Helpful Votes', COUNT(*) FROM review_helpful_votes
UNION ALL
SELECT 'Tests', COUNT(*) FROM tests
UNION ALL
SELECT 'Test Questions', COUNT(*) FROM test_questions
UNION ALL
SELECT 'Assignments', COUNT(*) FROM assignments
UNION ALL
SELECT 'Assignment Submissions', COUNT(*) FROM assignment_submissions
UNION ALL
SELECT 'Notifications', COUNT(*) FROM notifications
UNION ALL
SELECT 'Certificates', COUNT(*) FROM certificates
UNION ALL
SELECT 'Coupons', COUNT(*) FROM coupons
UNION ALL
SELECT 'Wishlists', COUNT(*) FROM wishlists
UNION ALL
SELECT 'Learning Paths', COUNT(*) FROM learning_paths
UNION ALL
SELECT 'Learning Path Courses', COUNT(*) FROM learning_path_courses
UNION ALL
SELECT 'Analytics Events', COUNT(*) FROM analytics_events
UNION ALL
SELECT 'App Config', COUNT(*) FROM app_config
ORDER BY table_name;

-- =============================================
-- SAMPLE DATA CREATION COMPLETED
-- =============================================

COMMIT;

```
