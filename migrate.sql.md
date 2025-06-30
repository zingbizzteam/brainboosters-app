-- Base user profiles table
create table if not exists user_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique not null,
  phone text unique,
  name text not null,
  avatar_url text,
  user_type text not null check (user_type in ('student', 'faculty', 'coaching_center', 'admin')),
  is_active boolean default true,
  is_verified boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Students table
create table if not exists students (
  id uuid primary key references user_profiles(id) on delete cascade,
  student_id text unique not null,
  date_of_birth date,
  gender text check (gender in ('male', 'female', 'other')),
  address text,
  city text,
  state text,
  pincode text,
  parent_name text,
  parent_phone text,
  parent_email text,
  education_level text,
  preferred_language text default 'english',
  learning_goals text[],
  interests text[],
  onboarding_completed boolean default false,
  total_courses_enrolled integer default 0,
  total_courses_completed integer default 0,
  total_study_hours integer default 0,
  current_streak integer default 0,
  max_streak integer default 0,
  points_earned integer default 0,
  badges_earned text[],
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Faculties table
create table if not exists faculties (
  id uuid primary key references user_profiles(id) on delete cascade,
  faculty_id text unique not null,
  coaching_center_id uuid references coaching_centers(id),
  title text,
  qualification text[],
  specialization text[],
  experience_years integer,
  bio text,
  expertise_subjects text[],
  languages_spoken text[],
  rating decimal(3,2) default 0.00,
  total_reviews integer default 0,
  total_students_taught integer default 0,
  total_courses_created integer default 0,
  total_courses_enrolled integer default 0,
  total_live_sessions integer default 0,
  hourly_rate decimal(10,2),
  availability_schedule jsonb,
  is_verified_educator boolean default false,
  verification_documents text[],
  bank_account_number text,
  ifsc_code text,
  pan_number text,
  aadhar_number text,
  resume_url text,
  certificates text[],
  social_links jsonb,
  teaching_mode text[] default array['online'],
  preferred_batch_size integer,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Coaching Centers table (UPDATED with new verification statuses)
create table if not exists coaching_centers (
  id uuid primary key references user_profiles(id) on delete cascade,
  center_id text unique not null,
  slug text unique not null,
  center_name text not null,
  description text,
  location text,
  address text not null,
  city text not null,
  state text not null,
  pincode text not null,
  establishment_year integer,
  established_date date,
  contact_person text,
  contact_designation text,
  contact_email text,
  contact_phone text,
  website_url text,
  social_media_links jsonb,
  registration_number text,
  license_number text,
  gst_number text,
  pan_number text,
  license_documents text[],
  certifications text[],
  awards text[],
  founders_name text,
  facilities text[],
  courses_offered text[],
  subjects_taught text[],
  specializations text[],
  teaching_modes text[] default array['offline'],
  languages text[] default array['English'],
  teaching_methods text[],
  category text,
  exams_prepared text[],
  batch_timings text[],
  batch_capacity integer,
  has_online_classes boolean default false,
  has_offline_classes boolean default true,
  has_hybrid_classes boolean default false,
  has_library boolean default false,
  has_lab_facility boolean default false,
  has_hostel_facility boolean default false,
  has_cafeteria boolean default false,
  has_transport_facility boolean default false,
  admission_process text,
  fee_structure jsonb,
  fees decimal(10,2),
  scholarship_options text[],
  refund_policy text,
  success_rate decimal(5,2) default 0.00,
  toppers_list jsonb,
  total_faculties integer default 0,
  faculty_count integer default 0,
  total_students integer default 0,
  students_enrolled integer default 0,
  total_courses_created integer default 0,
  total_courses_enrolled integer default 0,
  average_class_size decimal(5,2) default 0.00,
  rating decimal(3,2) default 0.00,
  total_reviews integer default 0,
  reviews integer default 0,
  image_url text,
  image_gallery text[],
  gallery_images text[],
  is_verified boolean default false,
  -- UPDATED: Added 'email_pending' and 'suspended' to verification_status check constraint
  verification_status text default 'email_pending' check (verification_status in ('email_pending', 'pending', 'approved', 'rejected', 'suspended')),
  verification_documents text[],
  bank_details jsonb,
  operating_hours jsonb,
  achievements text[],
  metadata jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Admin Users table (NEW - for admin management)
create table if not exists admin_users (
  id uuid primary key references user_profiles(id) on delete cascade,
  role text default 'admin' check (role in ('admin', 'super_admin')),
  permissions text[] default array['manage_users', 'manage_centers', 'manage_content'],
  is_active boolean default true,
  last_login_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Coaching Center Registrations table (NEW - for pending registrations workflow)
create table if not exists coaching_center_registrations (
  id uuid primary key default gen_random_uuid(),
  center_id text unique not null,
  slug text unique not null,
  center_name text not null,
  description text,
  contact_person text not null,
  contact_designation text,
  contact_email text not null,
  contact_phone text not null,
  address text not null,
  city text not null,
  state text not null,
  pincode text not null,
  website_url text,
  establishment_year integer,
  registration_number text,
  license_number text,
  gst_number text,
  pan_number text,
  founders_name text,
  facilities text[],
  specializations text[],
  teaching_modes text[] default array['offline'],
  languages text[] default array['English'],
  teaching_methods text[],
  category text,
  exams_prepared text[],
  batch_timings text[],
  has_online_classes boolean default false,
  has_offline_classes boolean default true,
  has_hybrid_classes boolean default false,
  has_library boolean default false,
  has_lab_facility boolean default false,
  has_hostel_facility boolean default false,
  has_cafeteria boolean default false,
  has_transport_facility boolean default false,
  admission_process text,
  fees decimal(10,2) default 0,
  password_hash text not null,
  status text default 'pending' check (status in ('pending', 'approved', 'rejected')),
  submitted_at timestamptz default now(),
  approved_at timestamptz,
  rejected_at timestamptz,
  admin_notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Coaching Center Analytics (separate table for your analytics model)
create table if not exists coaching_center_analytics (
  id uuid primary key default gen_random_uuid(),
  coaching_center_id uuid references coaching_centers(id) on delete cascade,
  total_enquiries integer default 0,
  admissions_this_month integer default 0,
  active_students integer default 0,
  average_attendance decimal(5,2) default 0.00,
  successful_placements integer default 0,
  student_satisfaction_score decimal(5,2) default 0.00,
  monthly_enrollments jsonb,
  subject_wise_performance jsonb,
  website_visits integer default 0,
  brochure_downloads integer default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Coaching Center Reviews
create table if not exists coaching_center_reviews (
  id uuid primary key default gen_random_uuid(),
  coaching_center_id uuid references coaching_centers(id) on delete cascade,
  student_id uuid references students(id),
  student_name text not null,
  student_avatar_url text,
  rating decimal(3,2) not null,
  comment text,
  course text,
  is_verified boolean default false,
  review_date timestamptz default now(),
  created_at timestamptz default now()
);

-- Coaching Center Batches
create table if not exists coaching_center_batches (
  id uuid primary key default gen_random_uuid(),
  coaching_center_id uuid references coaching_centers(id) on delete cascade,
  name text not null,
  course text not null,
  timing text not null,
  max_capacity integer not null,
  current_students integer default 0,
  start_date date not null,
  end_date date not null,
  instructor text,
  fees decimal(10,2) not null,
  mode text default 'Offline' check (mode in ('Online', 'Offline', 'Hybrid')),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Coaching Center Faculty
create table if not exists coaching_center_faculty (
  id uuid primary key default gen_random_uuid(),
  coaching_center_id uuid references coaching_centers(id) on delete cascade,
  faculty_id uuid references faculties(id),
  name text not null,
  designation text,
  qualification text,
  experience_years integer default 0,
  subjects text[],
  image_url text,
  bio text,
  rating decimal(3,2) default 0.00,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- UPDATED: Courses table (removed thumbnail_url, renamed image_url to course_image_url, added intro_video_url)
create table if not exists courses (
  id uuid primary key default gen_random_uuid(),
  course_id text unique not null,
  slug text unique not null,
  title text not null,
  description text,
  course_image_url text,
  intro_video_url text,
  academy text,
  instructors text[],
  category text,
  subcategory text,
  subject text,
  level text check (level in ('beginner', 'intermediate', 'advanced', 'expert')),
  difficulty text check (difficulty in ('Beginner', 'Easy', 'Medium', 'Hard', 'Expert')),
  language text default 'english',
  duration integer, -- in hours
  duration_hours integer,
  total_lessons integer default 0,
  price decimal(10,2) not null default 0,
  original_price decimal(10,2),
  is_free boolean default false,
  max_enrollments integer,
  current_enrollments integer default 0,
  instructor_id uuid references user_profiles(id),
  instructor_type text check (instructor_type in ('faculty', 'coaching_center')),
  syllabus text[],
  learning_outcomes text[],
  what_you_will_learn text[],
  prerequisites text[],
  requirements text[],
  tags text[],
  course_content_titles text[],
  is_certified boolean default false,
  is_published boolean default false,
  published_at timestamptz,
  rating decimal(3,2) default 0.00,
  total_ratings integer default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Course Analytics
create table if not exists course_analytics (
  id uuid primary key default gen_random_uuid(),
  course_id uuid references courses(id) on delete cascade,
  enrolled_count integer default 0,
  completed_count integer default 0,
  view_count integer default 0,
  likes integer default 0,
  shares integer default 0,
  questions_asked integer default 0,
  discussions integer default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- What's Included (course features)
create table if not exists course_features (
  id uuid primary key default gen_random_uuid(),
  course_id uuid references courses(id) on delete cascade,
  certificate boolean default false,
  quizzes boolean default false,
  assignments boolean default false,
  downloadable_resources boolean default false,
  lifetime_access boolean default false,
  access_on_mobile boolean default false,
  instructor_qna boolean default false,
  community_access boolean default false,
  created_at timestamptz default now()
);

-- Chapters
create table if not exists chapters (
  id uuid primary key default gen_random_uuid(),
  course_id uuid references courses(id) on delete cascade,
  title text not null,
  description text,
  order_index integer not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Lessons
create table if not exists lessons (
  id uuid primary key default gen_random_uuid(),
  chapter_id uuid references chapters(id) on delete cascade,
  title text not null,
  video_url text,
  content text,
  duration integer, -- in minutes
  is_preview boolean default false,
  is_completed boolean default false,
  order_index integer not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Live Classes table (matching your live class model)
create table if not exists live_classes (
  id uuid primary key default gen_random_uuid(),
  class_id text unique not null,
  slug text unique not null,
  title text not null,
  description text,
  image_url text,
  thumbnail_url text,
  start_time timestamptz not null,
  end_time timestamptz not null,
  scheduled_at timestamptz not null,
  academy text,
  teachers text[],
  instructor text,
  instructor_id uuid references user_profiles(id),
  instructor_type text check (instructor_type in ('faculty', 'coaching_center')),
  category text,
  subject text,
  duration integer not null, -- in minutes
  duration_minutes integer not null,
  is_live boolean default false,
  is_recorded boolean default false,
  is_free boolean default false,
  max_participants integer,
  current_participants integer default 0,
  price decimal(10,2) not null,
  difficulty text check (difficulty in ('Beginner', 'Intermediate', 'Advanced')),
  level text check (level in ('beginner', 'intermediate', 'advanced')),
  tags text[],
  meeting_url text,
  meeting_link text,
  meeting_id text,
  meeting_password text,
  status text default 'scheduled' check (status in ('scheduled', 'upcoming', 'live', 'completed', 'cancelled')),
  is_published boolean default false,
  recording_url text,
  is_recording_available boolean default false,
  language text default 'English',
  prerequisites text[],
  metadata jsonb,
  rating decimal(3,2) default 0.00,
  total_ratings integer default 0,
  -- Analytics fields
  view_count integer default 0,
  chat_message_count integer default 0,
  reaction_count integer default 0,
  average_engagement_score decimal(5,2) default 0.00,
  engagement_scores jsonb,
  questions_asked integer default 0,
  resource_downloads integer default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Live Class Comments
create table if not exists live_class_comments (
  id uuid primary key default gen_random_uuid(),
  live_class_id uuid references live_classes(id) on delete cascade,
  user_id uuid references user_profiles(id) on delete cascade,
  user_name text not null,
  user_avatar_url text,
  text text not null,
  timestamp timestamptz default now(),
  likes integer default 0,
  sentiment text default 'neutral' check (sentiment in ('positive', 'negative', 'neutral', 'confused')),
  parent_comment_id uuid references live_class_comments(id),
  created_at timestamptz default now()
);

-- Reviews table (for courses and live classes)
create table if not exists reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references user_profiles(id) on delete cascade,
  user_name text not null,
  user_avatar_url text,
  course_id uuid references courses(id) on delete cascade,
  live_class_id uuid references live_classes(id) on delete cascade,
  rating decimal(3,2) not null,
  comment text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  
  -- Ensure review is for either course or live class, not both
  constraint check_review_target check (
    (course_id is not null and live_class_id is null) or
    (live_class_id is not null and course_id is null)
  )
);

-- Universal Enrollments table
create table if not exists enrollments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references user_profiles(id) on delete cascade,
  user_type text not null check (user_type in ('student', 'faculty', 'coaching_center')),
  enrollment_type text not null check (enrollment_type in ('course', 'live_class')),
  course_id uuid references courses(id) on delete cascade,
  live_class_id uuid references live_classes(id) on delete cascade,
  enrollment_date timestamptz default now(),
  completion_date timestamptz,
  progress decimal(5,2) default 0.00,
  progress_percentage decimal(5,2) default 0.00,
  status text default 'active' check (status in ('active', 'completed', 'dropped', 'paused')),
  payment_status text default 'pending' check (payment_status in ('pending', 'paid', 'refunded')),
  amount_paid decimal(10,2),
  payment_method text,
  payment_reference text,
  last_accessed_at timestamptz,
  time_spent_minutes integer default 0,
  is_enrolled boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  
  constraint check_enrollment_type check (
    (enrollment_type = 'course' and course_id is not null and live_class_id is null) or
    (enrollment_type = 'live_class' and live_class_id is not null and course_id is null)
  )
);

-- Course Progress Tracking
create table if not exists course_progress (
  id uuid primary key default gen_random_uuid(),
  enrollment_id uuid references enrollments(id) on delete cascade,
  user_id uuid references user_profiles(id) on delete cascade,
  course_id uuid references courses(id) on delete cascade,
  chapter_id uuid references chapters(id),
  lesson_id uuid references lessons(id),
  module_id text,
  completed boolean default false,
  completion_date timestamptz,
  time_spent_minutes integer default 0,
  quiz_score decimal(5,2),
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Live Class Attendance
create table if not exists live_class_attendance (
  id uuid primary key default gen_random_uuid(),
  enrollment_id uuid references enrollments(id) on delete cascade,
  user_id uuid references user_profiles(id) on delete cascade,
  live_class_id uuid references live_classes(id) on delete cascade,
  joined_at timestamptz,
  left_at timestamptz,
  attendance_duration_minutes integer default 0,
  attendance_percentage decimal(5,2) default 0.00,
  was_present boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Enable Row Level Security (RLS) on all tables
alter table user_profiles enable row level security;
alter table students enable row level security;
alter table faculties enable row level security;
alter table coaching_centers enable row level security;
alter table admin_users enable row level security;
alter table coaching_center_registrations enable row level security;
alter table coaching_center_analytics enable row level security;
alter table courses enable row level security;
alter table live_classes enable row level security;
alter table enrollments enable row level security;

-- RLS Policies for coaching_center_registrations
create policy "Anyone can submit registration" on coaching_center_registrations
  for insert with check (true);

create policy "Only admins can view registrations" on coaching_center_registrations
  for select using (
    exists (
      select 1 from user_profiles 
      where id = auth.uid() 
      and user_type = 'admin'
    )
  );

create policy "Only admins can update registrations" on coaching_center_registrations
  for update using (
    exists (
      select 1 from user_profiles 
      where id = auth.uid() 
      and user_type = 'admin'
    )
  );

-- RLS Policies for admin_users
create policy "Only admins can view admin users" on admin_users
  for select using (
    exists (
      select 1 from user_profiles 
      where id = auth.uid() 
      and user_type = 'admin'
    )
  );

-- Add indexes for better performance
create index if not exists idx_user_profiles_user_type on user_profiles(user_type);
create index if not exists idx_user_profiles_email on user_profiles(email);
create index if not exists idx_coaching_centers_slug on coaching_centers(slug);
create index if not exists idx_coaching_centers_city on coaching_centers(city);
create index if not exists idx_coaching_centers_verification_status on coaching_centers(verification_status);
create index if not exists idx_coaching_center_registrations_status on coaching_center_registrations(status);
create index if not exists idx_courses_slug on courses(slug);
create index if not exists idx_courses_instructor on courses(instructor_id, instructor_type);
create index if not exists idx_live_classes_slug on live_classes(slug);
create index if not exists idx_live_classes_instructor on live_classes(instructor_id, instructor_type);
create index if not exists idx_enrollments_user on enrollments(user_id, user_type);
create index if not exists idx_enrollments_course on enrollments(course_id);
create index if not exists idx_enrollments_live_class on enrollments(live_class_id);
create index if not exists idx_course_progress_user_course on course_progress(user_id, course_id);
create index if not exists idx_live_class_attendance_user on live_class_attendance(user_id, live_class_id);
create index if not exists idx_chapters_course on chapters(course_id, order_index);
create index if not exists idx_lessons_chapter on lessons(chapter_id, order_index);
create index if not exists idx_faculties_coaching_center on faculties(coaching_center_id);

-- Update triggers for updated_at timestamps
create or replace function update_updated_at_column()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language 'plpgsql';

create trigger update_user_profiles_updated_at before update on user_profiles for each row execute procedure update_updated_at_column();
create trigger update_students_updated_at before update on students for each row execute procedure update_updated_at_column();
create trigger update_faculties_updated_at before update on faculties for each row execute procedure update_updated_at_column();
create trigger update_coaching_centers_updated_at before update on coaching_centers for each row execute procedure update_updated_at_column();
create trigger update_admin_users_updated_at before update on admin_users for each row execute procedure update_updated_at_column();
create trigger update_coaching_center_registrations_updated_at before update on coaching_center_registrations for each row execute procedure update_updated_at_column();
create trigger update_courses_updated_at before update on courses for each row execute procedure update_updated_at_column();
create trigger update_live_classes_updated_at before update on live_classes for each row execute procedure update_updated_at_column();
create trigger update_enrollments_updated_at before update on enrollments for each row execute procedure update_updated_at_column();

-- Create the storage bucket for course media
INSERT INTO storage.buckets (id, name, public) VALUES ('course-media', 'course-media', true)
ON CONFLICT (id) DO NOTHING;

-- Set up RLS policies for the bucket
CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'course-media');
CREATE POLICY "Authenticated users can upload" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'course-media' AND auth.role() = 'authenticated');
CREATE POLICY "Users can update own files" ON storage.objects FOR UPDATE USING (bucket_id = 'course-media' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can delete own files" ON storage.objects FOR DELETE USING (bucket_id = 'course-media' AND auth.uid()::text = (storage.foldername(name))[1]);

-- ALTER commands for existing databases (if needed)
-- Remove thumbnail_url column if it exists
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'courses' AND column_name = 'thumbnail_url') THEN
        ALTER TABLE courses DROP COLUMN thumbnail_url;
    END IF;
END $$;

-- Rename image_url to course_image_url if needed
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'courses' AND column_name = 'image_url') THEN
        ALTER TABLE courses RENAME COLUMN image_url TO course_image_url;
    END IF;
END $$;

-- Add intro_video_url column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'courses' AND column_name = 'intro_video_url') THEN
        ALTER TABLE courses ADD COLUMN intro_video_url TEXT;
    END IF;
END $$;

-- Update level constraint to include 'expert'
ALTER TABLE courses DROP CONSTRAINT IF EXISTS courses_level_check;
ALTER TABLE courses ADD CONSTRAINT courses_level_check CHECK (level IN ('beginner', 'intermediate', 'advanced', 'expert'));

-- Update difficulty constraint to include more options
ALTER TABLE courses DROP CONSTRAINT IF EXISTS courses_difficulty_check;
ALTER TABLE courses ADD CONSTRAINT courses_difficulty_check CHECK (difficulty IN ('Beginner', 'Easy', 'Medium', 'Hard', 'Expert'));

-- Set default value for price column
ALTER TABLE courses ALTER COLUMN price SET DEFAULT 0;
