import os
import json
import uuid
import random
import argparse
import psycopg2
from datetime import datetime, timedelta
from decimal import Decimal
from faker import Faker
from dotenv import load_dotenv
import re
import time
import logging
import sys
import hashlib
import bcrypt

load_dotenv()

# Initialize Faker with Indian locale
fake = Faker('en_IN')

# Configuration
SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_SERVICE_KEY = os.getenv('SUPABASE_SERVICE_KEY')
DB_USER = os.getenv('DB_USER')
DB_PASSWORD = os.getenv('DB_PASSWORD')
DB_HOST = os.getenv('DB_HOST')
DB_PORT = os.getenv('DB_PORT')
DB_NAME = os.getenv('DB_NAME')

# Default data generation counts
DEFAULT_COUNTS = {
    'coaching_centers': 5,
    'teachers': 15,
    'students': 50,
    'courses': 20,
    'chapters_per_course': 6,
    'lessons_per_chapter': 4,
    'tests_per_course': 3,
    'assignments_per_course': 2,
    'live_classes': 10,
    'enrollments_percentage': 0.4,
    'reviews_percentage': 0.3,
}

class LMSDataSeeder:
    def __init__(self, db_params: dict):
        self.db_params = db_params
        self.db_connection = None
        self.current_year = datetime.now().year
        
        # Setup logging
        self.setup_logging()
        
        # Track created records with their relationships - FIXED STRUCTURE
        self.created_records = {
            'auth_users': {},
            'user_profiles': {},
            'coaching_centers': {},
            'teachers': {},
            'students': {},
            'courses': {},
            'course_categories': {},  
            'chapters': {},
            'lessons': {},
            'tests': {},
            'assignments': {},
            'live_classes': {},
            'course_enrollments': {},
            'payments': {},
        }
        
        self.generated_data = {
            'auth_users': [],
            'user_profiles': [],
            'coaching_centers': [],
            'teachers': [],
            'students': [],
            'courses': [],
            'chapters': [],
            'lessons': [],
            'tests': [],
            'course_categories': {},  
            'assignments': [],
            'live_classes': [],
            'course_enrollments': [],
            'reviews': [],
            'test_results': [],
            'assignment_submissions': [],
            'notifications': [],
            'payments': [],
            'lesson_progress': [],
            'live_class_enrollments': [],
            'course_teachers': [],
        }

    def setup_logging(self):
        """Setup comprehensive logging"""
        os.makedirs('logs', exist_ok=True)
        log_filename = f"logs/lms_seeder_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
        
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_filename, encoding='utf-8'),
                logging.StreamHandler(sys.stdout)
            ]
        )
        
        self.logger = logging.getLogger(__name__)
        self.logger.info("="*60)
        self.logger.info("LMS Database Seeder Started")
        self.logger.info("="*60)

    def log_and_print(self, message, level="info"):
        """Log message and print to console"""
        if level == "info":
            self.logger.info(message)
        elif level == "error":
            self.logger.error(message)
        elif level == "warning":
            self.logger.warning(message)
        elif level == "debug":
            self.logger.debug(message)

    def get_db_connection(self):
        """Get database connection"""
        if not self.db_connection or self.db_connection.closed:
            try:
                self.db_connection = psycopg2.connect(
                    user=self.db_params['user'],
                    password=self.db_params['password'],
                    host=self.db_params['host'],
                    port=int(self.db_params['port']),
                    database=self.db_params['database'],
                    connect_timeout=10
                )
                self.db_connection.autocommit = True
                self.log_and_print("✅ Connected to PostgreSQL database")
            except Exception as e:
                self.log_and_print(f"❌ Error connecting to database: {e}", "error")
                raise
        return self.db_connection

    def close_db_connection(self):
        """Close database connection"""
        if self.db_connection and not self.db_connection.closed:
            self.db_connection.close()
            self.log_and_print("🔐 Database connection closed")

    def execute_sql_file(self, file_path: str):
        """If 'concurrently' in filename, run each non-comment statement one by one; otherwise run as transaction batch."""
        if not os.path.exists(file_path):
            self.log_and_print(f"❌ SQL file not found: {file_path}", "error")
            return False

        self.log_and_print(f"📄 Executing SQL file: {file_path}")
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                sql_content = file.read()

            if 'concurrently' in file_path.lower():
                # Split lines, filter comments and blanks, aggregate statements ending with ;
                statements = []
                block = []
                for line in sql_content.splitlines():
                    stripped = line.strip()
                    if not stripped or stripped.startswith('--'):
                        continue  # skip comments and blank lines
                    block.append(line)
                    if stripped.endswith(';'):
                        statements.append('\n'.join(block))
                        block = []
                if block:  # handle any stray statement at end
                    statements.append('\n'.join(block))
                # Execute one by one with autocommit
                conn = self.get_db_connection()
                conn.autocommit = True
                cursor = conn.cursor()
                success_count = 0
                for i, stmt in enumerate(statements, 1):
                    try:
                        cursor.execute(stmt)
                        self.log_and_print(f"✅ Created index {i}/{len(statements)}")
                        success_count += 1
                    except Exception as e:
                        self.log_and_print(f"❌ Failed to create index {i}: {e}", "warning")
                cursor.close()
                return success_count > 0
            else:
                # Execute entire SQL content as a single transaction
                conn = self.get_db_connection()
                conn.autocommit = False
                cursor = conn.cursor()
                try:
                    cursor.execute(sql_content)
                    conn.commit()
                    self.log_and_print("✅ Successfully executed file as batch")
                    cursor.close()
                    return True
                except Exception as e:
                    conn.rollback()
                    self.log_and_print(f"❌ Error executing file: {e}", "error")
                    cursor.close()
                    return False
        except Exception as e:
            self.log_and_print(f"❌ Error reading {file_path}: {e}", "error")
            return False

    def setup_database_schema(self):
        """Setup database schema by executing SQL files"""
        self.log_and_print("🏗️ Setting up database schema...")
        
        sql_files = [
            'complete_sql_for_bb.sql',
            'create_indexes_concurrently.sql'
        ]
        
        for sql_file in sql_files:
            if not self.execute_sql_file(sql_file):
                self.log_and_print(f"❌ Failed to execute {sql_file}", "error")
                return False
        
        self.log_and_print("✅ Database schema setup completed")
        return True

    def generate_valid_phone(self):
        """Generate a valid Indian phone number"""
        first_digit = random.choice(['6', '7', '8', '9'])
        remaining_digits = ''.join([str(random.randint(0, 9)) for _ in range(9)])
        return f"+91{first_digit}{remaining_digits}"

    def format_postgres_array(self, python_list):
        """Convert Python list to PostgreSQL array format"""
        if not python_list:
            return '{}'
        
        escaped_items = []
        for item in python_list:
            if isinstance(item, str):
                escaped = item.replace('\\', '\\\\').replace('"', '\\"')
                escaped_items.append(f'"{escaped}"')
            else:
                escaped_items.append(str(item))
        
        return '{' + ','.join(escaped_items) + '}'

    def create_auth_user_record(self, user_id: str, email: str, first_name: str = "", last_name: str = "", user_type: str = "student"):
        """Create auth.users record with metadata to trigger profile creation"""
        return {
            'id': user_id,
            'email': email,
            'encrypted_password': '$2a$10$example.hash.for.testing.purposes.only', # bcrypt hash for '123456'
            'email_confirmed_at': datetime.now(),
            'created_at': datetime.now(),
            'updated_at': datetime.now(),
            'role': 'authenticated',
            'aud': 'authenticated',
            'raw_user_meta_data': json.dumps({
                'user_type': user_type,
                'first_name': first_name,
                'last_name': last_name
            })
        }


    def create_user_profile_record(self, user_id: str, user_type: str):
        """Create a comprehensive user profile record"""
        if user_id in self.created_records['user_profiles']:
            self.log_and_print(f"⚠️ User ID {user_id} already exists, skipping duplicate", "warning")
            return self.created_records['user_profiles'][user_id]

        phone = self.generate_valid_phone()
        email = fake.unique.email()
        first_name = fake.first_name()
        last_name = fake.last_name()

        # Create auth user with metadata - this will trigger basic profile creation
        auth_user = self.create_auth_user_record(user_id, email, first_name, last_name, user_type)
        self.generated_data['auth_users'].append(auth_user)
        self.created_records['auth_users'][user_id] = auth_user

        # Create the complete profile object that will UPDATE the trigger-created profile
        profile = {
            'id': user_id,
            'user_type': user_type,
            'first_name': first_name,
            'last_name': last_name,
            'email': email,
            'phone': phone,
            'avatar_url': f"https://api.dicebear.com/7.x/avataaars/svg?seed={user_id}",
            'date_of_birth': fake.date_of_birth(minimum_age=18, maximum_age=60),
            'gender': random.choice(['male', 'female', 'other']),
            'address': json.dumps({
                'street': fake.street_address(),
                'city': fake.city(),
                'state': fake.state(),
                'pincode': fake.postcode(),
                'country': 'India'
            }),
            'is_active': True,
            'email_verified': random.choice([True, False]),
            'phone_verified': random.choice([True, False]),
            'onboarding_completed': True,
            'preferences': json.dumps({
                'theme': random.choice(['light', 'dark', 'auto']),
                'notifications': {
                    'email': True,
                    'push': True,
                    'sms': random.choice([True, False])
                }
            }),
            'last_seen': fake.date_time_between(start_date='-7d', end_date='now'),
            'created_at': datetime.now(),
            'updated_at': datetime.now()
        }

        # ADD THIS LINE - This was missing!
        self.generated_data['user_profiles'].append(profile)
        self.created_records['user_profiles'][user_id] = profile
        return profile



    def generate_coaching_centers(self, count: int):
        """Generate comprehensive coaching centers"""
        centers = []
        self.log_and_print(f"🏢 Generating {count} coaching centers...")
        
        for i in range(count):
            user_id = str(uuid.uuid4())
            center_id = str(uuid.uuid4())
            
            user_profile = self.create_user_profile_record(user_id, 'coaching_center')
            
            center_code = f"CC{self.current_year}{i+1:03d}"
            
            center = {
                'id': center_id,
                'user_id': user_id,
                'center_name': f"{fake.company()} Coaching Center",
                'center_code': center_code,
                'description': fake.text(max_nb_chars=500),
                'website_url': fake.url(),
                'logo_url': f"https://api.dicebear.com/7.x/initials/svg?seed={center_code}",
                'contact_email': user_profile['email'],
                'contact_phone': user_profile['phone'],
                'address': user_profile['address'],
                'registration_number': f"REG-{self.current_year}-{i+1:04d}",
                'tax_id': f"GST{random.randint(10000000000, 99999999999)}",
                'approval_status': random.choice(['approved'] * 8 + ['pending', 'rejected']),
                'approved_by': None,
                'approved_at': fake.date_time_between(start_date='-90d', end_date='now') if random.choice([True, False]) else None,
                'rejection_reason': fake.text(max_nb_chars=100) if random.choice([True, False]) else None,
                'subscription_plan': random.choice(['basic'] * 5 + ['premium'] * 3 + ['enterprise'] * 2),
                'max_faculty_limit': random.choice([10, 25, 50, 100]),
                'max_courses_limit': random.choice([50, 100, 250, 500]),
                'max_students_limit': random.choice([1000, 2500, 5000, 10000]),
                'is_active': True,
                'total_courses': 0,
                'total_students': 0,
                'total_teachers': 0,
                'rating': round(random.uniform(3.5, 5.0), 2),
                'total_reviews': random.randint(5, 100),
                'created_at': datetime.now(),
                'updated_at': datetime.now()
            }
            
            # Store in memory for dependency tracking
            self.created_records['coaching_centers'][center_id] = center
            centers.append(center)
            
            self.log_and_print(f"  📝 Created center {i+1}: {center['center_name']}")
        
        return centers

    def generate_teachers(self, count: int):
        """Generate comprehensive teachers"""
        teachers = []
        specializations_pool = [
            'Mathematics', 'Physics', 'Chemistry', 'Biology', 'English', 'Hindi',
            'Computer Science', 'History', 'Geography', 'Economics', 'Accountancy',
            'Business Studies', 'Psychology', 'Sociology', 'Political Science'
        ]
        
        titles = ['Mr.', 'Ms.', 'Dr.', 'Prof.']
        
        self.log_and_print(f"👨🏫 Generating {count} teachers...")
        
        if not self.created_records['coaching_centers']:
            self.log_and_print("❌ No coaching centers available", "error")
            return teachers
        
        center_ids = list(self.created_records['coaching_centers'].keys())
        
        for i in range(count):
            user_id = str(uuid.uuid4())
            teacher_id = str(uuid.uuid4())
            
            user_profile = self.create_user_profile_record(user_id, 'teacher')
            
            # Select a center that exists
            center_id = random.choice(center_ids)
            
            teacher = {
                'id': teacher_id,
                'user_id': user_id,
                'coaching_center_id': center_id,
                'employee_id': f"EMP{self.current_year}{i+1:06d}",
                'title': random.choice(titles),
                'specializations': self.format_postgres_array(
                    random.sample(specializations_pool, random.randint(1, 3))
                ),
                'qualifications': json.dumps([{
                    'degree': random.choice(['B.Ed', 'M.Ed', 'B.Sc', 'M.Sc', 'B.A', 'M.A', 'PhD']),
                    'institution': fake.company() + ' University',
                    'year': random.randint(2000, 2020),
                    'grade': random.choice(['First Class', 'Second Class', 'Distinction'])
                } for _ in range(random.randint(1, 3))]),
                'experience_years': random.randint(2, 20),
                'bio': fake.text(max_nb_chars=500),
                'hourly_rate': round(random.uniform(500, 2000), 2),
                'rating': round(random.uniform(3.8, 5.0), 2),
                'total_reviews': random.randint(10, 50),
                'total_courses': random.randint(1, 10),
                'total_students_taught': random.randint(50, 500),
                'is_verified': random.choice([True] * 7 + [False] * 3),
                'can_create_courses': True,
                'can_conduct_live_classes': True,
                'can_grade_assignments': True,
                'status': 'active',
                'joined_at': fake.date_time_between(start_date='-2y', end_date='now'),
                'created_at': datetime.now(),
                'updated_at': datetime.now()
            }
            
            # Store in memory for dependency tracking
            self.created_records['teachers'][teacher_id] = teacher
            teachers.append(teacher)
            
            if (i + 1) % 5 == 0:
                self.log_and_print(f"  📝 Created {i+1} teachers...")
        
        return teachers

    def generate_students(self, count: int):
        """Generate comprehensive students"""
        students = []
        grade_levels = [
            'class_10', 'class_11_science', 'class_11_commerce', 'class_12_science',
            'class_12_commerce', 'ug_1st_year', 'ug_2nd_year', 'btech_1st_year',
            'btech_2nd_year', 'working_professional'
        ]
        
        competitive_exams = [
            'JEE Main', 'JEE Advanced', 'NEET', 'UPSC', 'SSC', 'Banking', 'CAT', 'GATE'
        ]
        
        self.log_and_print(f"👨🎓 Generating {count} students...")
        
        for i in range(count):
            user_id = str(uuid.uuid4())
            student_id = str(uuid.uuid4())
            
            user_profile = self.create_user_profile_record(user_id, 'student')
            
            address_data = json.loads(user_profile['address'])
            target_year = random.randint(self.current_year, self.current_year + 3)
            current_streak = random.randint(0, 30)
            
            student = {
                'id': student_id,
                'user_id': user_id,
                'student_id': f"STU{self.current_year}{i+1:06d}",
                'grade_level': random.choice(grade_levels),
                'education_board': random.choice(['cbse', 'icse', 'state_board', 'igcse', 'ib', 'nios', 'other']),
                'primary_interest': random.choice(['Science', 'Commerce', 'Arts', 'Technology', 'Medicine', 'Engineering']),
                'secondary_interests': self.format_postgres_array(
                    random.sample(['Sports', 'Music', 'Art', 'Reading', 'Gaming', 'Dancing', 'Photography'], 3)
                ),
                'state': address_data['state'],
                'city': address_data['city'],
                'pincode': address_data['pincode'],
                'preferred_language': random.choice(['en', 'hi', 'ta', 'te', 'bn']),
                'other_languages': self.format_postgres_array(
                    random.sample(['hi', 'ta', 'te', 'bn', 'mr', 'gu', 'kn', 'ml'], 2)
                ),
                'school_name': fake.company() + ' ' + random.choice(['School', 'High School', 'Senior Secondary School']),
                'institution_type': random.choice(['school', 'college', 'university', 'coaching_center', 'self_study']),
                'parent_name': fake.name(),
                'parent_phone': self.generate_valid_phone(),
                'parent_email': fake.email(),
                'guardian_relationship': random.choice(['parent', 'guardian', 'sibling', 'relative', 'self']),
                'learning_goals': self.format_postgres_array([
                    'Improve grades', 'Crack competitive exams', 'Build strong concepts',
                    'Career guidance', 'Skill development', 'Time management'
                ]),
                'preferred_learning_style': random.choice(['visual', 'auditory', 'kinesthetic', 'reading_writing', 'mixed']),
                'competitive_exams': self.format_postgres_array(
                    random.sample(competitive_exams, random.randint(1, 3))
                ),
                'target_exam_year': target_year,
                'timezone': 'Asia/Kolkata',
                'total_courses_enrolled': 0,
                'total_courses_completed': 0,
                'total_hours_learned': round(random.uniform(0, 500), 2),
                'current_streak_days': current_streak,
                'longest_streak_days': random.randint(current_streak, max(current_streak, 60)),
                'total_points': random.randint(0, 5000),
                'level': random.randint(1, 20),
                'badges': json.dumps([{
                    'name': random.choice(['Quick Learner', 'Consistent Student', 'High Scorer', 'Active Participant']),
                    'earned_at': fake.date_time_this_year().isoformat(),
                    'description': 'Achievement badge'
                } for _ in range(random.randint(1, 4))]),
                'achievements': json.dumps({
                    'streak_milestones': [7, 14, 30],
                    'course_completions': random.randint(0, 5),
                    'perfect_scores': random.randint(0, 3),
                    'certificates_earned': random.randint(0, 2)
                }),
                'daily_study_goal_minutes': random.choice([30, 60, 90, 120, 180]),
                'preferred_study_time': random.choice(['early_morning', 'morning', 'afternoon', 'evening', 'night', 'flexible']),
                'is_active': True,
                'is_verified': random.choice([True, False]),
                'verification_method': random.choice(['email', 'phone', 'document']) if random.choice([True, False]) else None,
                'subscription_status': random.choice(['free'] * 7 + ['premium'] * 3),
                'subscription_expires_at': fake.date_time_between(start_date='+30d', end_date='+365d') if random.choice([True, False]) else None,
                'created_at': datetime.now(),
                'updated_at': datetime.now(),
                'last_login_date': fake.date_between(start_date='-30d', end_date='today'),
                'last_streak_update_date': fake.date_between(start_date='-7d', end_date='today'),
                'profile_completed_at': fake.date_time_between(start_date='-90d', end_date='now')
            }
            
            # Store in memory for dependency tracking
            self.created_records['students'][student_id] = student
            students.append(student)
            
            if (i + 1) % 10 == 0:
                self.log_and_print(f"  📝 Created {i+1} students...")
        
        return students

    def generate_comprehensive_courses(self, count: int):
        """Generate comprehensive courses with working URLs and English descriptions"""
        courses = []
        levels = ['beginner', 'intermediate', 'advanced', 'expert']
        languages = ['en']
        
        self.log_and_print(f"📚 Generating {count} courses...")
        
        if not self.created_records['coaching_centers'] or not self.created_records['teachers']:
            self.log_and_print("❌ No coaching centers or teachers available", "error")
            return courses

        center_ids = list(self.created_records['coaching_centers'].keys())
        teacher_ids = list(self.created_records['teachers'].keys())

        # Working video URLs
        sample_trailers = [
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4"
        ]

        course_subjects = [
            "Advanced Mathematics", "Physics Fundamentals", "Chemistry Mastery", 
            "Biology Essentials", "Computer Science", "English Literature",
            "Data Science", "Machine Learning", "Web Development", "Digital Marketing"
        ]

        for i in range(count):
            course_id = str(uuid.uuid4())
            center_id = random.choice(center_ids)
            
            center_teachers = [tid for tid, teacher in self.created_records['teachers'].items()
                            if teacher['coaching_center_id'] == center_id]
            
            if center_teachers:
                teacher_id = random.choice(center_teachers)
            else:
                teacher_id = random.choice(teacher_ids)
                self.created_records['teachers'][teacher_id]['coaching_center_id'] = center_id

            subject = random.choice(course_subjects)
            course_title = f"{subject} - Complete Course"
            original_price = round(random.uniform(1999, 12999), 2)
            current_price = round(original_price * random.uniform(0.6, 0.9), 2) if random.choice([True, False]) else original_price

            course = {
                'id': course_id,
                'coaching_center_id': center_id,
                'category_id': random.choice(list(self.created_records['course_categories'].keys())) if self.created_records.get('course_categories') else None,
                'primary_teacher_id': teacher_id,
                'title': course_title,
                'slug': course_title.lower().replace(' ', '-').replace(',', '').replace('.', '') + f'-{i+1:03d}',
                'description': f"Comprehensive {subject.lower()} course designed to build strong fundamentals and advanced concepts. Perfect for students preparing for competitive exams and academic excellence.",
                'short_description': f"Master {subject.lower()} with expert guidance and practical examples.",
                'thumbnail_url': f"https://picsum.photos/400/300?random={random.randint(1, 1000)}",
                'trailer_video_url': random.choice(sample_trailers),
                'course_content_overview': f"This course covers all essential topics in {subject.lower()} with hands-on exercises and real-world applications.",
                'what_you_learn': self.format_postgres_array([
                    f"Core concepts of {subject.lower()}",
                    "Problem-solving techniques",
                    "Practical applications",
                    "Exam preparation strategies"
                ]),
                'course_includes': json.dumps({
                    'video_hours': random.randint(15, 80),
                    'articles': random.randint(10, 50),
                    'exercises': random.randint(20, 100),
                    'quizzes': random.randint(5, 20),
                    'assignments': random.randint(3, 15),
                    'certificate': True,
                    'lifetime_access': random.choice([True, False]),
                    'mobile_access': True,
                    'downloadable_resources': random.choice([True, False])
                }),
                'target_audience': self.format_postgres_array([
                    "Students preparing for competitive exams",
                    "Graduates seeking to strengthen their knowledge",
                    "Professionals looking to upgrade skills"
                ]),
                'prerequisites': self.format_postgres_array([
                    "Basic understanding of the subject",
                    "High school level mathematics"
                ]),
                'learning_outcomes': self.format_postgres_array([
                    f"Master fundamental concepts of {subject.lower()}",
                    "Solve complex problems with confidence",
                    "Apply knowledge to real-world scenarios"
                ]),
                'level': random.choice(levels),
                'language': 'en',
                'tags': self.format_postgres_array([
                    'comprehensive', 'hands-on', 'practical', 'exam-focused'
                ]),
                'price': current_price,
                'original_price': original_price if current_price != original_price else None,
                'currency': 'INR',
                'duration_hours': round(random.uniform(25, 120), 1),
                'total_lessons': 0,
                'total_chapters': 0,
                'total_assignments': 0,
                'total_quizzes': 0,
                'max_enrollments': random.choice([None, 50, 100, 200, 500]),
                'enrollment_start_date': fake.date_time_between(start_date='-30d', end_date='+30d'),
                'enrollment_deadline': fake.date_time_between(start_date='+31d', end_date='+120d'),
                'course_start_date': fake.date_time_between(start_date='+1d', end_date='+60d'),
                'course_end_date': fake.date_time_between(start_date='+180d', end_date='+365d') if random.choice([True, False]) else None,
                'is_published': random.choice([True] * 8 + [False] * 2),
                'is_featured': random.choice([True] * 3 + [False] * 7),
                'is_archived': False,
                'publish_date': fake.date_time_between(start_date='-60d', end_date='now') if random.choice([True, False]) else None,
                'enrollment_count': random.randint(10, 200),
                'completed_count': random.randint(5, 100),
                'rating': round(random.uniform(3.8, 5.0), 2),
                'total_reviews': random.randint(8, 80),
                'completion_rate': round(random.uniform(70, 95), 2),
                'view_count': random.randint(500, 10000),
                'created_at': datetime.now(),
                'updated_at': datetime.now(),
                'last_updated': datetime.now(),
                'published_at': fake.date_time_between(start_date='-45d', end_date='now') if random.choice([True, False]) else None
            }

            self.created_records['courses'][course_id] = course
            courses.append(course)
            
            if (i + 1) % 5 == 0:
                self.log_and_print(f" 📝 Created {i+1} courses...")

        return courses



    def generate_lesson_content_url(self, lesson_type, lesson_id):
        """Generate appropriate content URL based on lesson type with working URLs"""
        if lesson_type == 'video':
            video_urls = [
                "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
                "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
                "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
                "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
                "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
                "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
                "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
                "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
                "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
                "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4",
                "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4",
                "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4"
            ]
            return random.choice(video_urls)
        elif lesson_type == 'document':
            return "https://www.aeee.in/wp-content/uploads/2020/08/Sample-pdf.pdf"
        elif lesson_type == 'interactive':
            return f"https://interactive-content.com/lesson-{lesson_id}"
        else:
            return None


    def generate_comprehensive_chapters_and_lessons(self, chapters_per_course: int, lessons_per_chapter: int):
        """Generate comprehensive chapters and lessons"""
        chapters = []
        lessons = []

        if not self.created_records['courses']:
            self.log_and_print("❌ No courses available", "error")
            return chapters, lessons

        self.log_and_print(f"📖 Generating chapters and lessons...")

        lesson_types = ['video', 'text', 'quiz', 'assignment', 'interactive', 'document']

        for course_id in self.created_records['courses'].keys():
            for chapter_num in range(1, chapters_per_course + 1):
                chapter_id = str(uuid.uuid4())

                chapter = {
                    'id': chapter_id,
                    'course_id': course_id,
                    'title': f"Chapter {chapter_num}: {fake.catch_phrase()}",
                    'description': fake.text(max_nb_chars=300),
                    'chapter_number': chapter_num,
                    'duration_minutes': random.randint(180, 480),
                    'total_lessons': lessons_per_chapter,
                    'learning_objectives': self.format_postgres_array([
                        fake.sentence() for _ in range(random.randint(3, 5))
                    ]),
                    'is_published': True,
                    'is_free': chapter_num == 1,
                    'sort_order': chapter_num,
                    'created_at': datetime.now(),
                    'updated_at': datetime.now()
                }

                # Store in memory for dependency tracking
                self.created_records['chapters'][chapter_id] = chapter
                chapters.append(chapter)

                # Generate lessons for this chapter
                for lesson_num in range(1, lessons_per_chapter + 1):
                    lesson_id = str(uuid.uuid4())
                    lesson_type = random.choice(lesson_types)

                    # FIXED: Ensure video_duration is always an integer for video lessons
                    video_duration = None
                    if lesson_type == 'video':
                        video_duration = random.randint(300, 2400)  # 5-40 minutes

                    lesson = {
                        'id': lesson_id,
                        'chapter_id': chapter_id,
                        'course_id': course_id,
                        'title': f"Lesson {lesson_num}: {fake.catch_phrase()}",
                        'description': fake.text(max_nb_chars=250),
                        'lesson_number': lesson_num,
                        'lesson_type': lesson_type,
                        'content_url': self.generate_lesson_content_url(lesson_type, lesson_id),
                        'video_duration': video_duration,  # Will be None for non-video lessons
                        'transcript': fake.text(max_nb_chars=1000) if lesson_type == 'video' else None,
                        'notes': fake.text(max_nb_chars=500),
                        'attachments': json.dumps([{
                            'name': f'Resource_{lesson_num}.pdf',
                            'url': 'https://www.aeee.in/wp-content/uploads/2020/08/Sample-pdf.pdf',
                            'size': random.randint(100, 5000),
                            'type': 'pdf'
                        }]) if random.choice([True, False]) else json.dumps([]),
                        'resources': json.dumps([{
                            'title': 'Additional Reading',
                            'url': 'https://www.aeee.in/wp-content/uploads/2020/08/Sample-pdf.pdf',
                            'type': 'external_link'
                        }, {
                            'title': 'Practice Exercise',
                            'url': 'https://www.aeee.in/wp-content/uploads/2020/08/Sample-pdf.pdf',
                            'type': 'exercise'
                        }]) if random.choice([True, False]) else json.dumps([]),
                        'is_published': True,
                        'is_free': lesson_num <= 2 and chapter_num == 1,
                        'is_downloadable': random.choice([True, False]),
                        'requires_completion': random.choice([True, False]),
                        'view_count': random.randint(50, 1000),
                        'completion_count': random.randint(20, 500),
                        'completion_rate': round(random.uniform(75, 98), 2),
                        # FIXED: Handle average_watch_time properly
                        'average_watch_time': random.randint(180, min(1800, video_duration or 600)) if lesson_type == 'video' else 0,
                        'sort_order': lesson_num,
                        'created_at': datetime.now(),
                        'updated_at': datetime.now()
                    }

                    # Store in memory for dependency tracking
                    self.created_records['lessons'][lesson_id] = lesson
                    lessons.append(lesson)

        self.log_and_print(f"✅ Generated {len(chapters)} chapters and {len(lessons)} lessons")
        return chapters, lessons

    def generate_tests(self, tests_per_course: int):
        """Generate tests for courses"""
        tests = []
        test_questions = []

        self.log_and_print(f"📝 Generating tests...")

        if not self.created_records['courses'] or not self.created_records['teachers']:
            self.log_and_print("❌ No courses or teachers available", "error")
            return tests, test_questions

        question_types = ['mcq', 'multiple_select', 'short_answer', 'true_false']

        for course_id in self.created_records['courses'].keys():
            course = self.created_records['courses'][course_id]
            teacher_id = course['primary_teacher_id']

            for test_num in range(1, tests_per_course + 1):
                test_id = str(uuid.uuid4())
                total_questions = random.randint(10, 30)
                total_marks = total_questions * random.randint(1, 4)
                passing_marks = total_marks * random.uniform(0.4, 0.6)

                test = {
                    'id': test_id,
                    'course_id': course_id,
                    'chapter_id': None,
                    'lesson_id': None,
                    'coaching_center_id': course['coaching_center_id'],
                    'teacher_id': teacher_id,
                    'title': f"Test {test_num}: {fake.catch_phrase()}",
                    'description': fake.text(max_nb_chars=300),
                    'instructions': fake.text(max_nb_chars=500),
                    'test_type': random.choice(['quiz', 'assignment', 'exam', 'practice']),
                    'difficulty_level': random.choice(['easy', 'medium', 'hard']),
                    'total_questions': total_questions,
                    'total_marks': total_marks,
                    'passing_marks': passing_marks,
                    'negative_marking': random.choice([True, False]),
                    'negative_marks_per_question': round(random.uniform(0, 1), 2) if random.choice([True, False]) else 0,
                    'time_limit_minutes': random.randint(30, 180),
                    'extra_time_minutes': random.randint(0, 30),
                    'attempts_allowed': random.randint(1, 3),
                    'time_between_attempts_hours': random.randint(0, 24),
                    'show_results_immediately': random.choice([True, False]),
                    'show_correct_answers': random.choice([True, False]),
                    'show_explanations': random.choice([True, False]),
                    'randomize_questions': random.choice([True, False]),
                    'randomize_options': random.choice([True, False]),
                    'available_from': fake.date_time_between(start_date='-30d', end_date='+30d'),
                    'available_until': fake.date_time_between(start_date='+31d', end_date='+180d'),
                    'is_published': random.choice([True] * 8 + [False] * 2),
                    'is_proctored': random.choice([True, False]),
                    'attempt_count': random.randint(0, 100),
                    'average_score': round(random.uniform(60, 90), 2),
                    'pass_rate': round(random.uniform(70, 95), 2),
                    'created_at': datetime.now(),
                    'updated_at': datetime.now()
                }

                self.created_records['tests'][test_id] = test
                tests.append(test)

                # Generate questions for this test
                for q_num in range(1, total_questions + 1):
                    question_id = str(uuid.uuid4())
                    question_type = random.choice(question_types)

                    # Generate options based on question type
                    if question_type == 'mcq':
                        options = [fake.sentence() for _ in range(4)]
                        correct_answers = [random.choice(options)]
                    elif question_type == 'multiple_select':
                        options = [fake.sentence() for _ in range(5)]
                        correct_answers = random.sample(options, random.randint(2, 3))
                    elif question_type == 'true_false':
                        options = ['True', 'False']
                        correct_answers = [random.choice(options)]
                    else:  # short_answer
                        options = []
                        correct_answers = [fake.sentence()]

                    question = {
                        'id': question_id,
                        'test_id': test_id,
                        'question_text': fake.text(max_nb_chars=300) + "?",
                        'question_type': question_type,
                        'options': json.dumps(options),
                        'correct_answers': json.dumps(correct_answers),
                        'explanation': fake.text(max_nb_chars=200),
                        'hints': self.format_postgres_array([fake.sentence() for _ in range(2)]),
                        'marks': random.randint(1, 4),
                        'negative_marks': round(random.uniform(0, 1), 2) if random.choice([True, False]) else 0,
                        'difficulty_level': random.choice(['easy', 'medium', 'hard']),
                        'topic': fake.word(),
                        'subtopic': fake.word(),
                        'tags': self.format_postgres_array([fake.word() for _ in range(3)]),
                        'question_order': q_num,
                        'time_limit_seconds': random.randint(60, 300) if random.choice([True, False]) else None,
                        'attempt_count': random.randint(0, 50),
                        'correct_count': random.randint(0, 25),
                        'difficulty_score': round(random.uniform(0.1, 0.9), 2),
                        'created_at': datetime.now(),
                        'updated_at': datetime.now()
                    }

                    test_questions.append(question)

        self.log_and_print(f"✅ Generated {len(tests)} tests with {len(test_questions)} questions")
        return tests, test_questions

    def generate_assignments(self, assignments_per_course: int):
        """Generate assignments for courses"""
        assignments = []

        self.log_and_print(f"📋 Generating assignments...")

        if not self.created_records['courses'] or not self.created_records['teachers']:
            self.log_and_print("❌ No courses or teachers available", "error")
            return assignments

        assignment_types = ['project', 'essay', 'coding', 'presentation', 'research', 'case_study']
        submission_formats = ['file_upload', 'text_submission', 'url_submission', 'multiple_files']

        for course_id in self.created_records['courses'].keys():
            course = self.created_records['courses'][course_id]
            teacher_id = course['primary_teacher_id']

            for assign_num in range(1, assignments_per_course + 1):
                assignment_id = str(uuid.uuid4())

                total_marks = round(random.uniform(50, 100), 2)
                passing_marks = round(total_marks * random.uniform(0.4, 0.6), 2)

                assignment = {
                    'id': assignment_id,
                    'course_id': course_id,
                    'chapter_id': None,
                    'teacher_id': teacher_id,
                    'title': f"Assignment {assign_num}: {fake.catch_phrase()}",
                    'description': fake.text(max_nb_chars=800),
                    'instructions': fake.text(max_nb_chars=600),
                    'assignment_type': random.choice(assignment_types),
                    'submission_format': random.choice(submission_formats),
                    'total_marks': total_marks,
                    'passing_marks': passing_marks,
                    'grading_rubric': json.dumps({
                        'criteria': [
                            {'name': 'Content Quality', 'weight': 40},
                            {'name': 'Presentation', 'weight': 30},
                            {'name': 'Originality', 'weight': 20},
                            {'name': 'Timeliness', 'weight': 10}
                        ]
                    }),
                    'assigned_date': datetime.now(),
                    'due_date': fake.date_time_between(start_date='+7d', end_date='+30d'),
                    'late_submission_deadline': fake.date_time_between(start_date='+31d', end_date='+40d'),
                    'allow_late_submission': random.choice([True, False]),
                    'late_penalty_percentage': round(random.uniform(5, 20), 2),
                    'is_group_assignment': random.choice([True, False]),
                    'max_group_size': random.randint(2, 5) if random.choice([True, False]) else 1,
                    'allow_resubmission': random.choice([True, False]),
                    'max_file_size_mb': random.randint(10, 100),
                    'allowed_file_types': self.format_postgres_array(['pdf', 'doc', 'docx', 'txt', 'zip']),
                    'resources': json.dumps([{
                        'title': 'Reference Material',
                        'url': 'https://www.aeee.in/wp-content/uploads/2020/08/Sample-pdf.pdf',
                        'type': 'external_link'
                    }]),
                    'reference_materials': json.dumps([{
                        'title': 'Additional Reading',
                        'url': 'https://www.aeee.in/wp-content/uploads/2020/08/Sample-pdf.pdf'
                    }]),
                    'sample_submissions': json.dumps([]),
                    'is_published': random.choice([True] * 8 + [False] * 2),
                    'is_archived': False,
                    'submission_count': random.randint(0, 50),
                    'on_time_submissions': random.randint(0, 40),
                    'average_grade': round(random.uniform(70, 85), 2),
                    'plagiarism_check_enabled': random.choice([True, False]),
                    'auto_grade_enabled': random.choice([True, False]),
                    'ai_feedback_enabled': random.choice([True, False]),
                    'created_at': datetime.now(),
                    'updated_at': datetime.now()
                }

                self.created_records['assignments'][assignment_id] = assignment
                assignments.append(assignment)

        self.log_and_print(f"✅ Generated {len(assignments)} assignments")
        return assignments


    

    def generate_assignments(self, assignments_per_course: int):
        """Generate assignments for courses"""
        assignments = []
        
        self.log_and_print(f"📋 Generating assignments...")
        
        if not self.created_records['courses'] or not self.created_records['teachers']:
            self.log_and_print("❌ No courses or teachers available", "error")
            return assignments
        
        assignment_types = ['project', 'essay', 'coding', 'presentation', 'research', 'case_study']
        submission_formats = ['file_upload', 'text_submission', 'url_submission', 'multiple_files']
        
        for course_id in self.created_records['courses'].keys():
            course = self.created_records['courses'][course_id]
            teacher_id = course['primary_teacher_id']
            
            for assign_num in range(1, assignments_per_course + 1):
                assignment_id = str(uuid.uuid4())
                
                assignment = {
                    'id': assignment_id,
                    'course_id': course_id,
                    'chapter_id': None,
                    'teacher_id': teacher_id,
                    'title': f"Assignment {assign_num}: {fake.catch_phrase()}",
                    'description': fake.text(max_nb_chars=800),
                    'instructions': fake.text(max_nb_chars=600),
                    'assignment_type': random.choice(assignment_types),
                    'submission_format': random.choice(submission_formats),
                    'total_marks': round(random.uniform(50, 100), 2),
                    'passing_marks': round(random.uniform(30, 50), 2),
                    'grading_rubric': json.dumps({
                        'criteria': [
                            {'name': 'Content Quality', 'weight': 40},
                            {'name': 'Presentation', 'weight': 30},
                            {'name': 'Originality', 'weight': 20},
                            {'name': 'Timeliness', 'weight': 10}
                        ]
                    }),
                    'assigned_date': datetime.now(),
                    'due_date': fake.date_time_between(start_date='+7d', end_date='+30d'),
                    'late_submission_deadline': fake.date_time_between(start_date='+31d', end_date='+40d'),
                    'allow_late_submission': random.choice([True, False]),
                    'late_penalty_percentage': round(random.uniform(5, 20), 2),
                    'is_group_assignment': random.choice([True, False]),
                    'max_group_size': random.randint(2, 5) if random.choice([True, False]) else 1,
                    'allow_resubmission': random.choice([True, False]),
                    'max_file_size_mb': random.randint(10, 100),
                    'allowed_file_types': self.format_postgres_array(['pdf', 'doc', 'docx', 'txt', 'zip']),
                    'resources': json.dumps([{
                        'title': 'Reference Material',
                        'url': 'https://www.aeee.in/wp-content/uploads/2020/08/Sample-pdf.pdf',
                        'type': 'external_link'
                    }]),
                    'reference_materials': json.dumps([{
                        'title': 'Additional Reading',
                        'url': 'https://www.aeee.in/wp-content/uploads/2020/08/Sample-pdf.pdf'
                    }]),
                    'sample_submissions': json.dumps([]),
                    'is_published': random.choice([True] * 8 + [False] * 2),
                    'is_archived': False,
                    'submission_count': random.randint(0, 50),
                    'on_time_submissions': random.randint(0, 40),
                    'average_grade': round(random.uniform(70, 85), 2),
                    'plagiarism_check_enabled': random.choice([True, False]),
                    'auto_grade_enabled': random.choice([True, False]),
                    'ai_feedback_enabled': random.choice([True, False]),
                    'created_at': datetime.now(),
                    'updated_at': datetime.now()
                }
                
                self.created_records['assignments'][assignment_id] = assignment
                assignments.append(assignment)
        
        self.log_and_print(f"✅ Generated {len(assignments)} assignments")
        return assignments

    def generate_live_classes(self, count: int):
        """Generate live classes"""
        live_classes = []
        
        self.log_and_print(f"📹 Generating {count} live classes...")
        
        if not self.created_records['coaching_centers'] or not self.created_records['teachers']:
            self.log_and_print("❌ No coaching centers or teachers available", "error")
            return live_classes
        
        meeting_platforms = ['zoom', 'meet', 'teams', 'jitsi']
        
        for i in range(count):
            live_class_id = str(uuid.uuid4())
            
            # Select random coaching center and teacher
            center_id = random.choice(list(self.created_records['coaching_centers'].keys()))
            center_teachers = [tid for tid, teacher in self.created_records['teachers'].items() 
                             if teacher['coaching_center_id'] == center_id]
            
            if center_teachers:
                teacher_id = random.choice(center_teachers)
            else:
                teacher_id = random.choice(list(self.created_records['teachers'].keys()))
            
            course_id = None
            if self.created_records['courses']:
                center_courses = [cid for cid, course in self.created_records['courses'].items() 
                                if course['coaching_center_id'] == center_id]
                if center_courses:
                    course_id = random.choice(center_courses) if random.choice([True, False]) else None
            
            scheduled_start = fake.date_time_between(start_date='+1d', end_date='+30d')
            scheduled_end = scheduled_start + timedelta(hours=random.randint(1, 3))
            
            live_class = {
                'id': live_class_id,
                'coaching_center_id': center_id,
                'course_id': course_id,
                'chapter_id': None,
                'primary_teacher_id': teacher_id,
                'title': f"Live Class: {fake.catch_phrase()}",
                'description': fake.text(max_nb_chars=500),
                'agenda': fake.text(max_nb_chars=300),
                'learning_objectives': self.format_postgres_array([
                    fake.sentence() for _ in range(random.randint(3, 5))
                ]),
                'scheduled_start': scheduled_start,
                'scheduled_end': scheduled_end,
                'actual_start': None,
                'actual_end': None,
                'timezone': 'Asia/Kolkata',
                'max_participants': random.randint(50, 200),
                'current_participants': 0,
                'auto_record': random.choice([True, False]),
                'allow_chat': True,
                'allow_qa': True,
                'allow_screen_sharing': random.choice([True, False]),
                'require_approval': random.choice([True, False]),
                'meeting_platform': random.choice(meeting_platforms),
                'meeting_url': fake.url(),
                'meeting_id': str(random.randint(100000000, 999999999)),
                'meeting_password': str(random.randint(100000, 999999)),
                'dial_in_numbers': json.dumps(['+91-80-XXXX-XXXX', '+91-22-XXXX-XXXX']),
                'price': round(random.uniform(0, 500), 2),
                'currency': 'INR',
                'thumbnail_url': f"https://picsum.photos/400/300?random={i}",
                'presentation_url': "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"  if random.choice([True, False]) else None,
                'resources': json.dumps([{
                    'title': 'Class Notes',
                    'url': 'https://www.aeee.in/wp-content/uploads/2020/08/Sample-pdf.pdf',
                    'type': 'pdf'
                }]),
                'status': random.choice(['scheduled'] * 6 + ['completed'] * 3 + ['cancelled'] * 1),
                'cancellation_reason': fake.sentence() if random.choice([True, False]) else None,
                'recording_url': "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"  if random.choice([True, False]) else None,
                'recording_duration_minutes': random.randint(60, 180) if random.choice([True, False]) else None,
                'recording_size_mb': round(random.uniform(100, 1000), 2) if random.choice([True, False]) else None,
                'recording_available_until': fake.date_time_between(start_date='+60d', end_date='+365d') if random.choice([True, False]) else None,
                'total_registered': random.randint(20, 150),
                'total_attended': random.randint(15, 120),
                'average_attendance_duration_minutes': round(random.uniform(45, 120), 2),
                'engagement_score': round(random.uniform(0.6, 1.0), 2),
                'average_rating': round(random.uniform(4.0, 5.0), 2),
                'total_feedback_count': random.randint(5, 50),
                'created_at': datetime.now(),
                'updated_at': datetime.now()
            }
            
            self.created_records['live_classes'][live_class_id] = live_class
            live_classes.append(live_class)
        
        self.log_and_print(f"✅ Generated {len(live_classes)} live classes")
        return live_classes

    def generate_course_enrollments(self, enrollment_percentage: float):
        """Generate course enrollments"""
        enrollments = []
        
        self.log_and_print(f"📝 Generating course enrollments...")
        
        if not self.created_records['students'] or not self.created_records['courses']:
            self.log_and_print("❌ No students or courses available", "error")
            return enrollments
        
        student_ids = list(self.created_records['students'].keys())
        course_ids = list(self.created_records['courses'].keys())
        
        # Each student enrolls in a percentage of available courses
        for student_id in student_ids:
            num_enrollments = max(1, int(len(course_ids) * enrollment_percentage))
            enrolled_courses = random.sample(course_ids, min(num_enrollments, len(course_ids)))
            
            for course_id in enrolled_courses:
                enrollment_id = str(uuid.uuid4())
                
                enrolled_date = fake.date_time_between(start_date='-90d', end_date='now')
                progress = round(random.uniform(0, 100), 2)
                
                enrollment = {
                    'id': enrollment_id,
                    'student_id': student_id,
                    'course_id': course_id,
                    'enrolled_at': enrolled_date,
                    'enrollment_method': random.choice(['direct', 'invitation', 'api']),
                    'payment_status': random.choice(['paid', 'free', 'pending']),
                    'progress_percentage': progress,
                    'lessons_completed': random.randint(0, 20),
                    'total_lessons_in_course': random.randint(20, 50),
                    'chapters_completed': random.randint(0, 8),
                    'total_chapters_in_course': random.randint(8, 15),
                    'total_time_spent_minutes': random.randint(60, 1200),
                    'average_session_duration_minutes': round(random.uniform(15, 90), 2),
                    'total_sessions': random.randint(1, 50),
                    'completed_at': fake.date_time_between(start_date=enrolled_date, end_date='now') if progress >= 80 else None,
                    'completion_percentage_required': 80.0,
                    'last_accessed_at': fake.date_time_between(start_date='-7d', end_date='now'),
                    'access_expires_at': fake.date_time_between(start_date='+30d', end_date='+365d') if random.choice([True, False]) else None,
                    'is_active': True,
                    'current_chapter_id': None,
                    'current_lesson_id': None,
                    'bookmarked_lessons': self.format_postgres_array([]),
                    'notes': fake.text(max_nb_chars=300) if random.choice([True, False]) else None,
                    'certificate_issued': progress >= 80 and random.choice([True, False]),
                    'certificate_issued_at': fake.date_time_between(start_date=enrolled_date, end_date='now') if progress >= 80 and random.choice([True, False]) else None,
                    'certificate_id': str(uuid.uuid4()) if progress >= 80 and random.choice([True, False]) else None,
                    'course_rating': random.randint(1, 5) if random.choice([True, False]) else None,
                    'course_review': fake.text(max_nb_chars=200) if random.choice([True, False]) else None,
                    'reviewed_at': fake.date_time_between(start_date=enrolled_date, end_date='now') if random.choice([True, False]) else None,
                    'average_quiz_score': round(random.uniform(60, 95), 2),
                    'assignments_submitted': random.randint(0, 5),
                    'assignments_graded': random.randint(0, 5),
                    'created_at': enrolled_date,
                    'updated_at': datetime.now()
                }
                
                self.created_records['course_enrollments'][enrollment_id] = enrollment
                enrollments.append(enrollment)
        
        self.log_and_print(f"✅ Generated {len(enrollments)} course enrollments")
        return enrollments

    def generate_additional_data(self):
        """Generate additional data for all remaining tables"""
        additional_data = {}
        
        # Generate lesson progress
        lesson_progress = self.generate_lesson_progress()
        additional_data['lesson_progress'] = lesson_progress
        
        # Generate notifications
        notifications = self.generate_notifications()
        additional_data['notifications'] = notifications
        
        # Generate reviews
        reviews = self.generate_reviews()
        additional_data['reviews'] = reviews
        
        # Generate payments
        payments = self.generate_payments()
        additional_data['payments'] = payments
        
        # Generate test results
        test_results = self.generate_test_results()
        additional_data['test_results'] = test_results
        
        # Generate assignment submissions
        assignment_submissions = self.generate_assignment_submissions()
        additional_data['assignment_submissions'] = assignment_submissions
        
        # Generate live class enrollments
        live_class_enrollments = self.generate_live_class_enrollments()
        additional_data['live_class_enrollments'] = live_class_enrollments
        
        # Generate course teachers
        course_teachers = self.generate_course_teachers()
        additional_data['course_teachers'] = course_teachers
        
        return additional_data

    def generate_lesson_progress(self):
        """Generate lesson progress data"""
        lesson_progress = []

        if not self.created_records['course_enrollments'] or not self.created_records['lessons']:
            return lesson_progress

        for enrollment_id, enrollment in self.created_records['course_enrollments'].items():
            student_id = enrollment['student_id']
            course_id = enrollment['course_id']

            # Get lessons for this course
            course_lessons = [lesson_id for lesson_id, lesson in self.created_records['lessons'].items() 
                            if lesson['course_id'] == course_id]

            # Generate progress for some lessons
            num_lessons_with_progress = int(len(course_lessons) * random.uniform(0.3, 0.8))
            lessons_with_progress = random.sample(course_lessons, min(num_lessons_with_progress, len(course_lessons)))

            for lesson_id in lessons_with_progress:
                lesson = self.created_records['lessons'][lesson_id]
                progress_id = str(uuid.uuid4())

                # FIXED: Handle None video_duration properly
                lesson_video_duration = lesson.get('video_duration')
                if lesson_video_duration is None:
                    lesson_video_duration = 600  # Default 10 minutes

                # FIXED: Ensure watch_time doesn't exceed video duration
                max_watch_time = max(30, lesson_video_duration)
                watch_time = random.randint(30, max_watch_time)

                completion_percentage = round(random.uniform(0, 100), 2)

                progress = {
                    'id': progress_id,
                    'student_id': student_id,
                    'lesson_id': lesson_id,
                    'course_id': course_id,
                    'started_at': fake.date_time_between(start_date=enrollment['enrolled_at'], end_date='now'),
                    'completed_at': fake.date_time_between(start_date=enrollment['enrolled_at'], end_date='now') if completion_percentage >= 80 else None,
                    'last_accessed_at': fake.date_time_between(start_date='-7d', end_date='now'),
                    'watch_time_seconds': watch_time,
                    'total_video_duration_seconds': lesson_video_duration,
                    'last_video_position_seconds': random.randint(0, watch_time),
                    'video_completion_percentage': completion_percentage,
                    'reading_progress_percentage': completion_percentage,
                    'reading_time_seconds': random.randint(60, 1800),
                    'overall_progress_percentage': completion_percentage,
                    'is_completed': completion_percentage >= 80,
                    'completion_criteria_met': completion_percentage >= 80,
                    'total_visits': random.randint(1, 5),
                    'total_time_spent_seconds': watch_time + random.randint(60, 300),
                    'engagement_score': round(random.uniform(0.5, 1.0), 2),
                    'student_notes': fake.text(max_nb_chars=200) if random.choice([True, False]) else None,
                    'bookmarks': json.dumps([random.randint(30, 300) for _ in range(random.randint(0, 3))]),
                    'is_bookmarked': random.choice([True, False]),
                    'focus_time_seconds': random.randint(int(watch_time * 0.7), watch_time),
                    'distraction_count': random.randint(0, 5),
                    'created_at': datetime.now(),
                    'updated_at': datetime.now()
                }

                lesson_progress.append(progress)

        return lesson_progress


    def generate_notifications(self):
        """Generate notifications"""
        notifications = []
        
        if not self.created_records['user_profiles']:
            return notifications
        
        notification_types = [
            'course_enrollment', 'lesson_completed', 'assignment_due',
            'live_class_reminder', 'achievement_unlocked', 'payment_success'
        ]
        
        # Generate notifications for each user
        for user_id in self.created_records['user_profiles'].keys():
            num_notifications = random.randint(3, 10)
            
            for _ in range(num_notifications):
                notification_id = str(uuid.uuid4())
                
                notification = {
                    'id': notification_id,
                    'user_id': user_id,
                    'title': fake.catch_phrase(),
                    'message': fake.text(max_nb_chars=200),
                    'notification_type': random.choice(notification_types),
                    'reference_id': str(uuid.uuid4()) if random.choice([True, False]) else None,
                    'reference_type': random.choice(['course', 'lesson', 'assignment']) if random.choice([True, False]) else None,
                    'channels': self.format_postgres_array(['in_app', 'email']),
                    'delivery_status': json.dumps({'in_app': 'delivered', 'email': 'sent'}),
                    'priority': random.choice(['low', 'medium', 'high']),
                    'is_read': random.choice([True, False]),
                    'read_at': fake.date_time_between(start_date='-7d', end_date='now') if random.choice([True, False]) else None,
                    'scheduled_at': datetime.now(),
                    'sent_at': datetime.now(),
                    'expires_at': fake.date_time_between(start_date='+7d', end_date='+30d') if random.choice([True, False]) else None,
                    'category': random.choice(['academic', 'financial', 'technical', 'general']),
                    'action_url': fake.url() if random.choice([True, False]) else None,
                    'action_label': 'View Details' if random.choice([True, False]) else None,
                    'metadata': json.dumps({'source': 'system', 'batch_id': str(uuid.uuid4())}),
                    'template_id': None,
                    'created_at': datetime.now(),
                    'updated_at': datetime.now()
                }
                
                notifications.append(notification)
        
        return notifications

    def generate_reviews(self):
        """Generate reviews for courses and teachers"""
        reviews = []
        
        if not self.created_records['course_enrollments']:
            return reviews
        
        # Generate course reviews from enrolled students
        for enrollment_id, enrollment in self.created_records['course_enrollments'].items():
            if random.uniform(0, 1) < 0.3:  # 30% chance of review
                review_id = str(uuid.uuid4())
                
                overall_rating = round(random.uniform(3.5, 5.0), 1)
                
                review = {
                    'id': review_id,
                    'student_id': enrollment['student_id'],
                    'course_id': enrollment['course_id'],
                    'teacher_id': None,
                    'live_class_id': None,
                    'coaching_center_id': None,
                    'review_type': 'course',
                    'overall_rating': overall_rating,
                    'content_rating': round(random.uniform(3.0, 5.0), 1),
                    'instructor_rating': round(random.uniform(3.0, 5.0), 1),
                    'value_rating': round(random.uniform(3.0, 5.0), 1),
                    'difficulty_rating': round(random.uniform(2.0, 4.0), 1),
                    'title': fake.catch_phrase(),
                    'review_text': fake.text(max_nb_chars=400),
                    'pros': fake.text(max_nb_chars=200),
                    'cons': fake.text(max_nb_chars=200),
                    'is_verified_purchase': True,
                    'completed_percentage': enrollment['progress_percentage'],
                    'is_published': True,
                    'is_featured': random.choice([True, False]),
                    'moderation_status': 'approved',
                    'moderation_reason': None,
                    'moderated_by': None,
                    'moderated_at': None,
                    'helpful_votes': random.randint(0, 20),
                    'not_helpful_votes': random.randint(0, 5),
                    'helpfulness_score': round(random.uniform(0.7, 1.0), 2),
                    'report_count': 0,
                    'last_reported_at': None,
                    'created_at': fake.date_time_between(start_date=enrollment['enrolled_at'], end_date='now'),
                    'updated_at': datetime.now()
                }
                
                reviews.append(review)
        
        return reviews

    def generate_payments(self):
        """Generate payment records"""
        payments = []
        
        if not self.created_records['course_enrollments']:
            return payments
        
        # Generate payments for paid enrollments
        for enrollment_id, enrollment in self.created_records['course_enrollments'].items():
            if enrollment['payment_status'] == 'paid':
                payment_id = str(uuid.uuid4())
                
                course_id = enrollment['course_id']
                course = self.created_records['courses'][course_id]
                
                payment = {
                    'id': payment_id,
                    'student_id': enrollment['student_id'],
                    'course_id': course_id,
                    'live_class_id': None,
                    'items': json.dumps([{
                        'type': 'course',
                        'id': course_id,
                        'name': course['title'],
                        'price': course['price']
                    }]),
                    'payment_type': 'course',
                    'subtotal': course['price'],
                    'discount_amount': round(random.uniform(0, course['price'] * 0.2), 2),
                    'tax_amount': round(course['price'] * 0.18, 2),
                    'processing_fee': round(course['price'] * 0.025, 2),
                    'total_amount': course['price'],
                    'currency': 'INR',
                    'payment_method_id': None,
                    'payment_gateway': random.choice(['razorpay', 'stripe', 'paypal']),
                    'gateway_transaction_id': f"txn_{random.randint(1000000000, 9999999999)}",
                    'internal_transaction_id': f"int_{random.randint(1000000, 9999999)}",
                    'status': random.choice(['completed'] * 8 + ['failed'] * 1 + ['refunded'] * 1),
                    'failure_reason': fake.sentence() if random.choice([True, False]) else None,
                    'initiated_at': enrollment['enrolled_at'],
                    'processed_at': enrollment['enrolled_at'] + timedelta(minutes=random.randint(1, 10)),
                    'completed_at': enrollment['enrolled_at'] + timedelta(minutes=random.randint(2, 15)),
                    'refund_amount': 0.0,
                    'refund_reason': None,
                    'refunded_at': None,
                    'refunded_by': None,
                    'coupon_code': f"SAVE{random.randint(10, 50)}" if random.choice([True, False]) else None,
                    'discount_type': random.choice(['percentage', 'fixed']) if random.choice([True, False]) else None,
                    'discount_value': round(random.uniform(5, 25), 2) if random.choice([True, False]) else 0,
                    'invoice_number': f"INV-{self.current_year}-{random.randint(100000, 999999)}",
                    'invoice_url': 'https://www.aeee.in/wp-content/uploads/2020/08/Sample-pdf.pdf',
                    'customer_details': json.dumps({
                        'name': fake.name(),
                        'email': fake.email(),
                        'phone': self.generate_valid_phone()
                    }),
                    'gateway_response': json.dumps({
                        'transaction_id': f"gw_{random.randint(1000000000, 9999999999)}",
                        'status': 'success',
                        'message': 'Payment completed successfully'
                    }),
                    'metadata': json.dumps({
                        'device': random.choice(['mobile', 'desktop', 'tablet']),
                        'platform': random.choice(['web', 'android', 'ios'])
                    }),
                    'created_at': enrollment['enrolled_at'],
                    'updated_at': datetime.now()
                }
                
                payments.append(payment)
        
        return payments

    def generate_test_results(self):
        """Generate test results with correct constraint validation"""
        test_results = []

        if not self.created_records['tests'] or not self.created_records['course_enrollments']:
            return test_results

        for enrollment_id, enrollment in self.created_records['course_enrollments'].items():
            student_id = enrollment['student_id']
            course_id = enrollment['course_id']

            # Find tests for this course
            course_tests = [test_id for test_id, test in self.created_records['tests'].items()
                        if test['course_id'] == course_id]

            # Generate results for some tests
            for test_id in course_tests:
                if random.uniform(0, 1) < 0.6:  # 60% chance of taking test
                    test = self.created_records['tests'][test_id]
                    result_id = str(uuid.uuid4())
                    
                    total_questions = test['total_questions']
                    
                    # Fixed: To satisfy the constraint questions_attempted = correct + incorrect + skipped
                    # We need to set attempted = total_questions and skipped = 0
                    # OR calculate attempted properly based on the constraint
                    
                    # Option 1: Student attempts all questions (most realistic for DB constraint)
                    attempted = total_questions
                    skipped = 0
                    correct = random.randint(0, attempted)
                    incorrect = attempted - correct
                    
                    # Alternative Option 2: If you want some skipped questions, use this instead:
                    # skipped = random.randint(0, max(0, total_questions // 4))  # Skip up to 25%
                    # attempted = total_questions - skipped
                    # correct = random.randint(0, attempted)
                    # incorrect = attempted - correct

                    score = round(correct * (test['total_marks'] / total_questions), 2)
                    passing_threshold = test['passing_marks'] / test['total_marks'] if test['total_marks'] > 0 else 0
                    passed = (correct / total_questions) >= passing_threshold if total_questions > 0 else False

                    result = {
                        'id': result_id,
                        'test_id': test_id,
                        'student_id': student_id,
                        'attempt_number': random.randint(1, test['attempts_allowed']),
                        'started_at': fake.date_time_between(start_date=enrollment['enrolled_at'], end_date='now'),
                        'completed_at': fake.date_time_between(start_date=enrollment['enrolled_at'], end_date='now'),
                        'submitted_at': fake.date_time_between(start_date=enrollment['enrolled_at'], end_date='now'),
                        'total_questions': total_questions,
                        'questions_attempted': attempted,
                        'correct_answers': correct,
                        'incorrect_answers': incorrect,
                        'skipped_questions': skipped,
                        'score': score,
                        'total_marks': test['total_marks'],
                        'passed': passed,
                        'grade': random.choice(['A+', 'A', 'B+', 'B', 'C+', 'C', 'D']),
                        'time_taken_minutes': random.randint(30, test['time_limit_minutes'] if test['time_limit_minutes'] else 120),
                        'time_limit_minutes': test['time_limit_minutes'],
                        'extra_time_used': 0,
                        'answers': json.dumps({f"q_{i}": fake.word() for i in range(1, attempted + 1)}),
                        'question_wise_analysis': json.dumps({
                            f"q_{i}": {
                                'correct': random.choice([True, False]),
                                'time_taken': random.randint(30, 180),
                                'marked_for_review': random.choice([True, False])
                            } for i in range(1, total_questions + 1)
                        }),
                        'is_submitted': True,
                        'is_flagged': random.choice([True, False]) if random.uniform(0, 1) < 0.1 else False,
                        'flag_reason': fake.sentence() if random.choice([True, False]) else None,
                        'is_proctored': test['is_proctored'],
                        'proctoring_data': json.dumps({
                            'violations': random.randint(0, 2),
                            'screenshots': random.randint(5, 20)
                        }) if test['is_proctored'] else json.dumps({}),
                        'rank_in_test': None,
                        'percentile': round(random.uniform(50, 95), 2),
                        'created_at': datetime.now(),
                        'updated_at': datetime.now()
                    }

                    test_results.append(result)

        return test_results

    def generate_assignment_submissions(self):
        """Generate assignment submissions"""
        assignment_submissions = []
        
        if not self.created_records['assignments'] or not self.created_records['course_enrollments']:
            return assignment_submissions
        
        for enrollment_id, enrollment in self.created_records['course_enrollments'].items():
            student_id = enrollment['student_id']
            course_id = enrollment['course_id']
            
            # Find assignments for this course
            course_assignments = [assign_id for assign_id, assignment in self.created_records['assignments'].items()
                                if assignment['course_id'] == course_id]
            
            # Generate submissions for some assignments
            for assignment_id in course_assignments:
                if random.uniform(0, 1) < 0.7:  # 70% chance of submitting
                    assignment = self.created_records['assignments'][assignment_id]
                    submission_id = str(uuid.uuid4())
                    
                    submission = {
                        'id': submission_id,
                        'assignment_id': assignment_id,
                        'student_id': student_id,
                        'submission_text': fake.text(max_nb_chars=800) if assignment['submission_format'] == 'text_submission' else None,
                        'submission_files': json.dumps([{
                            'name': f"assignment_{random.randint(1, 100)}.pdf",
                            'url': 'https://www.aeee.in/wp-content/uploads/2020/08/Sample-pdf.pdf',
                            'size': random.randint(1000, 5000000),
                            'type': 'pdf'
                        }]) if assignment['submission_format'] == 'file_upload' else json.dumps([]),
                        'submission_urls': json.dumps([fake.url()]) if assignment['submission_format'] == 'url_submission' else json.dumps([]),
                        'attempt_number': random.randint(1, 2),
                        'submitted_at': fake.date_time_between(start_date=assignment['assigned_date'], end_date='now'),
                        'is_late': random.choice([True, False]),
                        'grade': round(random.uniform(60, 95), 2) if random.choice([True, False]) else None,
                        'feedback': fake.text(max_nb_chars=300) if random.choice([True, False]) else None,
                        'detailed_feedback': json.dumps({
                            'content_quality': 'Good analysis and understanding demonstrated',
                            'presentation': 'Well structured and clearly presented',
                            'originality': 'Shows original thinking and creativity',
                            'areas_for_improvement': 'Could include more examples'
                        }) if random.choice([True, False]) else json.dumps({}),
                        'graded_at': fake.date_time_between(start_date=assignment['assigned_date'], end_date='now') if random.choice([True, False]) else None,
                        'graded_by': assignment['teacher_id'] if random.choice([True, False]) else None,
                        'submission_status': random.choice(['submitted', 'under_review', 'graded']),
                        'plagiarism_score': round(random.uniform(0, 15), 2) if assignment['plagiarism_check_enabled'] else None,
                        'plagiarism_report': json.dumps({
                            'sources_found': random.randint(0, 3),
                            'similarity_percentage': round(random.uniform(0, 15), 2),
                            'status': 'clean'
                        }) if assignment['plagiarism_check_enabled'] else json.dumps({}),
                        'word_count': random.randint(500, 2000),
                        'total_file_size_mb': round(random.uniform(1, 10), 2),
                        'file_count': random.randint(1, 3),
                        'created_at': datetime.now(),
                        'updated_at': datetime.now(),
                        'metadata': json.dumps({
                            'device': random.choice(['mobile', 'desktop', 'tablet']),
                            'browser': random.choice(['Chrome', 'Firefox', 'Safari', 'Edge'])
                        })
                    }
                    
                    assignment_submissions.append(submission)
        
        return assignment_submissions

    def generate_live_class_enrollments(self):
        """Generate live class enrollments"""
        enrollments = []
        
        if not self.created_records['live_classes'] or not self.created_records['students']:
            return enrollments
        
        student_ids = list(self.created_records['students'].keys())
        
        for live_class_id, live_class in self.created_records['live_classes'].items():
            # Enroll random students
            num_enrollments = random.randint(10, min(50, len(student_ids)))
            enrolled_students = random.sample(student_ids, num_enrollments)
            
            for student_id in enrolled_students:
                enrollment_id = str(uuid.uuid4())
                
                attended = random.choice([True, False])
                
                enrollment = {
                    'id': enrollment_id,
                    'student_id': student_id,
                    'live_class_id': live_class_id,
                    'enrolled_at': fake.date_time_between(start_date='-30d', end_date='now'),
                    'enrollment_source': random.choice(['direct', 'course', 'invitation']),
                    'joined_at': live_class['scheduled_start'] + timedelta(minutes=random.randint(-5, 15)) if attended else None,
                    'left_at': live_class['scheduled_end'] - timedelta(minutes=random.randint(0, 30)) if attended else None,
                    'attendance_duration_minutes': random.randint(30, 120) if attended else 0,
                    'attended': attended,
                    'attendance_percentage': round(random.uniform(70, 100), 2) if attended else 0,
                    'questions_asked': random.randint(0, 5) if attended else 0,
                    'chat_messages_sent': random.randint(0, 10) if attended else 0,
                    'polls_participated': random.randint(0, 3) if attended else 0,
                    'engagement_score': round(random.uniform(0.6, 1.0), 2) if attended else 0,
                    'connection_quality': random.choice(['poor', 'fair', 'good', 'excellent']) if attended else None,
                    'device_type': random.choice(['desktop', 'mobile', 'tablet']) if attended else None,
                    'browser_info': random.choice(['Chrome 91', 'Firefox 89', 'Safari 14', 'Edge 91']) if attended else None,
                    'session_rating': random.randint(4, 5) if attended and random.choice([True, False]) else None,
                    'feedback_text': fake.text(max_nb_chars=200) if attended and random.choice([True, False]) else None,
                    'feedback_submitted_at': fake.date_time_between(start_date=live_class['scheduled_start'], end_date='now') if attended and random.choice([True, False]) else None,
                    'status': 'attended' if attended else random.choice(['missed', 'cancelled']),
                    'created_at': datetime.now(),
                    'updated_at': datetime.now()
                }
                
                enrollments.append(enrollment)
        
        return enrollments

    def generate_course_teachers(self):
        """Generate course-teacher associations"""
        course_teachers = []
        
        if not self.created_records['courses'] or not self.created_records['teachers']:
            return course_teachers
        
        for course_id, course in self.created_records['courses'].items():
            # Add primary teacher
            primary_teacher_id = course['primary_teacher_id']
            
            course_teacher = {
                'id': str(uuid.uuid4()),
                'course_id': course_id,
                'teacher_id': primary_teacher_id,
                'role': 'primary_instructor',
                'is_primary': True,
                'permissions': json.dumps({
                    'can_edit_content': True,
                    'can_grade': True,
                    'can_manage_students': True,
                    'can_conduct_live_classes': True
                }),
                'joined_at': course['created_at'],
                'created_at': course['created_at']
            }
            
            course_teachers.append(course_teacher)
            
            # Optionally add co-instructors
            if random.choice([True, False]):
                center_id = course['coaching_center_id']
                other_teachers = [tid for tid, teacher in self.created_records['teachers'].items()
                                if teacher['coaching_center_id'] == center_id and tid != primary_teacher_id]
                
                if other_teachers:
                    co_instructor_id = random.choice(other_teachers)
                    
                    co_instructor = {
                        'id': str(uuid.uuid4()),
                        'course_id': course_id,
                        'teacher_id': co_instructor_id,
                        'role': 'co_instructor',
                        'is_primary': False,
                        'permissions': json.dumps({
                            'can_edit_content': False,
                            'can_grade': True,
                            'can_manage_students': False,
                            'can_conduct_live_classes': True
                        }),
                        'joined_at': fake.date_time_between(start_date=course['created_at'], end_date='now'),
                        'created_at': datetime.now()
                    }
                    
                    course_teachers.append(co_instructor)
        
        return course_teachers

    def generate_course_categories(self):
        """Generate course categories"""
        categories = []
        # Initialize the dictionary first
        self.created_records['course_categories'] = {}
        
        category_data = [
            {'name': 'JEE Preparation', 'description': 'Joint Entrance Examination preparation courses'},
            {'name': 'NEET Preparation', 'description': 'Medical entrance exam preparation'},
            {'name': 'Class 10 CBSE', 'description': 'CBSE Class 10 board preparation'},
            {'name': 'Class 12 Science', 'description': 'Class 12 Science stream courses'},
            {'name': 'Competitive Exams', 'description': 'Various competitive exam preparations'},
            {'name': 'Skill Development', 'description': 'Professional skill development courses'},
            {'name': 'Language Learning', 'description': 'Language proficiency courses'}
        ]
        
        for cat_data in category_data:
            category_id = str(uuid.uuid4())
            category = {
                'id': category_id,
                'name': cat_data['name'],
                'description': cat_data['description'],
                'slug': cat_data['name'].lower().replace(' ', '-'),
                'is_active': True,
                'sort_order': len(categories) + 1,
                'created_at': datetime.now(),
                'updated_at': datetime.now()
            }
            categories.append(category)
            # Fix: Store each category properly
            self.created_records['course_categories'][category_id] = category
        
        return categories

    def clear_data(self):
        """Clear existing data from all tables"""
        tables_to_clear = [
            'analytics_events', 'notifications', 'review_votes', 'reviews',
            'assignment_submissions', 'assignments', 'test_results', 'test_questions',
            'tests', 'lesson_progress', 'live_class_enrollments', 'course_enrollments', 
            'live_classes', 'lessons', 'chapters', 'course_teachers', 'courses','course_categories',
            'students', 'teachers', 'coaching_centers', 'user_profiles', 'payments'
        ]
        
        self.log_and_print("🗑️ Clearing existing data...")
        
        try:
            conn = self.get_db_connection()
            cursor = conn.cursor()
            
            # Disable triggers temporarily
            cursor.execute("SET session_replication_role = replica;")
            
            # Clear main tables
            for table in tables_to_clear:
                try:
                    cursor.execute(f"TRUNCATE TABLE {table} CASCADE;")
                    self.log_and_print(f"✅ Cleared {table}")
                except psycopg2.Error as e:
                    if 'does not exist' in str(e).lower():
                        self.log_and_print(f"⚠️ Table {table} does not exist", "warning")
                    else:
                        self.log_and_print(f"⚠️ Error clearing {table}: {e}", "warning")
            
            # Also clear auth.users if accessible
            try:
                cursor.execute("TRUNCATE TABLE auth.users CASCADE;")
                self.log_and_print("✅ Cleared auth.users")
            except psycopg2.Error as e:
                self.log_and_print(f"⚠️ Could not clear auth.users: {e}", "warning")
            
            # Re-enable triggers
            cursor.execute("SET session_replication_role = DEFAULT;")
            
            cursor.close()
            self.log_and_print("✅ Data clearing completed")
            
        except Exception as e:
            self.log_and_print(f"❌ Error during data clearing: {e}", "error")

    def insert_or_update_user_profile(self, profile):
        """Insert or update user_profiles row based on trigger-created entry"""
        try:
            conn = self.get_db_connection()
            cursor = conn.cursor()

            # Check if profile exists
            cursor.execute("SELECT id FROM user_profiles WHERE id = %s", (profile['id'],))
            exists = cursor.fetchone() is not None

            columns = list(profile.keys())
            columns_str = ', '.join(f'"{col}"' for col in columns)
            placeholders = ', '.join(['%s'] * len(columns))

            if exists:
                # Prepare update statement (exclude id from update)
                update_cols = [col for col in columns if col != 'id']
                update_str = ', '.join(f'"{col}" = %s' for col in update_cols)
                update_values = [profile[col] for col in update_cols]
                update_values.append(profile['id'])
                update_query = f"UPDATE user_profiles SET {update_str} WHERE id = %s"
                cursor.execute(update_query, update_values)
                self.log_and_print(f"🔄 Updated user_profile: {profile['id']}")
            else:
                # Insert
                insert_query = f"INSERT INTO user_profiles ({columns_str}) VALUES ({placeholders})"
                values = [profile[col] for col in columns]
                cursor.execute(insert_query, values)
                self.log_and_print(f"➕ Inserted user_profile: {profile['id']}")
            cursor.close()
        except Exception as e:
            self.log_and_print(f"❌ Error inserting/updating user_profile {profile['id']}: {e}", "error")

    def insert_data_batch(self, table_name: str, data: list, batch_size: int = 50):
        """Enhanced batch insert with proper error handling"""
        if not data:
            self.log_and_print(f"⚠️ No data to insert for {table_name}", "warning")
            return

        # Special handling for user_profiles - update trigger-created profiles
        if table_name == 'user_profiles':
            self.log_and_print(f"📥 Inserting/Updating {len(data)} user profiles...")
            for profile in data:
                self.insert_or_update_user_profile(profile)
            self.log_and_print(f"✅ Completed user_profiles: {len(data)} processed")
            return

        self.log_and_print(f"📥 Inserting {len(data)} records into {table_name}...")
        try:
            conn = self.get_db_connection()
            cursor = conn.cursor()

            # Get columns from first record
            columns = list(data[0].keys())
            columns_str = ', '.join(f'"{col}"' for col in columns)  # Quote column names
            placeholders = ', '.join(['%s'] * len(columns))

            # Special handling for auth.users
            if table_name == 'auth_users':
                table_name = 'auth.users'

            insert_query = f"INSERT INTO {table_name} ({columns_str}) VALUES ({placeholders})"

            total_batches = (len(data) + batch_size - 1) // batch_size
            successful_inserts = 0

            for i in range(0, len(data), batch_size):
                batch = data[i:i + batch_size]
                batch_num = (i // batch_size) + 1

                try:
                    batch_values = []
                    for record in batch:
                        values = [record[col] for col in columns]
                        batch_values.append(values)
                    cursor.executemany(insert_query, batch_values)
                    successful_inserts += len(batch)
                    self.log_and_print(f"  ✅ Batch {batch_num}/{total_batches}: {len(batch)} records")
                except Exception as batch_error:
                    self.log_and_print(f"  ❌ Batch {batch_num} failed: {batch_error}", "error")

                    # Try individual records in failed batch
                    for j, record in enumerate(batch):
                        try:
                            values = [record[col] for col in columns]
                            cursor.execute(insert_query, values)
                            successful_inserts += 1
                        except Exception as record_error:
                            self.log_and_print(f"   ❌ Record {i+j+1} failed: {record_error}", "error")
                            continue

            cursor.close()
            self.log_and_print(f"✅ Completed {table_name}: {successful_inserts}/{len(data)} successful")

        except Exception as e:
            self.log_and_print(f"❌ Critical error inserting into {table_name}: {e}", "error")
            import traceback
            self.log_and_print(f"Stack trace: {traceback.format_exc()}", "error")

        

    def validate_connection(self):
        """Validate database connection"""
        self.log_and_print("🔍 Validating database connection...")
        try:
            conn = psycopg2.connect(
                user=self.db_params['user'],
                password=self.db_params['password'],
                host=self.db_params['host'],
                port=int(self.db_params['port']),
                database=self.db_params['database'],
                connect_timeout=10
            )
            
            cursor = conn.cursor()
            cursor.execute("SELECT version();")
            version = cursor.fetchone()
            cursor.close()
            conn.close()
            
            self.log_and_print(f"✅ Database connection successful")
            return True
        except Exception as e:
            self.log_and_print(f"❌ Database connection failed: {e}", "error")
            return False

    def seed_database(self, counts: dict = None, setup_schema: bool = True):
        """Main seeding method with proper dependency order"""
        if counts is None:
            counts = DEFAULT_COUNTS

        self.log_and_print("🌱 Starting Comprehensive LMS Database Seeding...")
        self.log_and_print(f"📊 Configuration: {counts}")

        start_time = time.time()

        # Validate connection
        if not self.validate_connection():
            return False

        try:
            # Setup schema if requested
            if setup_schema:
                if not self.setup_database_schema():
                    self.log_and_print("❌ Schema setup failed", "error")
                    return False

            self.log_and_print("\n" + "="*60)
            self.log_and_print("📊 GENERATING COMPREHENSIVE DATA")
            self.log_and_print("="*60)

            # Generate all data in dependency order
            centers = self.generate_coaching_centers(counts['coaching_centers'])
            self.generated_data['coaching_centers'] = centers

            teachers = self.generate_teachers(counts['teachers'])
            self.generated_data['teachers'] = teachers

            students = self.generate_students(counts['students'])
            self.generated_data['students'] = students

            categories = self.generate_course_categories()
            self.generated_data['course_categories'] = categories

            courses = self.generate_comprehensive_courses(counts['courses'])
            self.generated_data['courses'] = courses

            chapters, lessons = self.generate_comprehensive_chapters_and_lessons(
                counts['chapters_per_course'], counts['lessons_per_chapter']
            )
            self.generated_data['chapters'] = chapters
            self.generated_data['lessons'] = lessons

            # Generate tests and test questions
            tests, test_questions = self.generate_tests(counts['tests_per_course'])
            self.generated_data['tests'] = tests
            self.generated_data['test_questions'] = test_questions

            # Generate assignments
            assignments = self.generate_assignments(counts['assignments_per_course'])
            self.generated_data['assignments'] = assignments

            # Generate live classes
            live_classes = self.generate_live_classes(counts['live_classes'])
            self.generated_data['live_classes'] = live_classes

            # Generate course enrollments
            enrollments = self.generate_course_enrollments(counts['enrollments_percentage'])
            self.generated_data['course_enrollments'] = enrollments

            # Generate additional data
            additional_data = self.generate_additional_data()
            self.generated_data.update(additional_data)

            self.log_and_print("\n" + "="*60)
            self.log_and_print("💾 INSERTING DATA INTO DATABASE")
            self.log_and_print("="*60)

            # Insert data in correct dependency order
            insert_order = [
                ('auth_users', self.generated_data['auth_users']),
                ('user_profiles', self.generated_data['user_profiles']),  # ADD THIS LINE BACK
                ('course_categories', self.generated_data['course_categories']),
                ('coaching_centers', self.generated_data['coaching_centers']),
                ('teachers', self.generated_data['teachers']),
                ('students', self.generated_data['students']),
                ('courses', self.generated_data['courses']),
                ('chapters', self.generated_data['chapters']),
                ('lessons', self.generated_data['lessons']),
                ('tests', self.generated_data['tests']),
                ('test_questions', self.generated_data['test_questions']),
                ('assignments', self.generated_data['assignments']),
                ('live_classes', self.generated_data['live_classes']),
                ('course_teachers', self.generated_data['course_teachers']),
                ('course_enrollments', self.generated_data['course_enrollments']),
                ('lesson_progress', self.generated_data['lesson_progress']),
                ('live_class_enrollments', self.generated_data['live_class_enrollments']),
                ('reviews', self.generated_data['reviews']),
                ('payments', self.generated_data['payments']),
                ('test_results', self.generated_data['test_results']),
                ('assignment_submissions', self.generated_data['assignment_submissions']),
                ('notifications', self.generated_data['notifications']),
            ]

            # Insert each table's data
            for table_name, data in insert_order:
                if data:  # Only insert if data exists
                    self.insert_data_batch(table_name, data)
                else:
                    self.log_and_print(f"⚠️ No data generated for {table_name}", "warning")

            end_time = time.time()
            duration = end_time - start_time

            self.log_and_print("\n" + "="*60)
            self.log_and_print("🎉 COMPREHENSIVE DATABASE SEEDING COMPLETED!")
            self.log_and_print("="*60)
            self.log_and_print(f"⏱️ Total time: {duration:.2f} seconds")

            # Summary
            total_records = sum(len(data) if isinstance(data, list) else 0
                            for data in self.generated_data.values())
            self.log_and_print(f"📈 Total records created: {total_records}")

            for table_name, data in insert_order:
                if data:
                    self.log_and_print(f"  • {table_name}: {len(data)} records")

            return True

        except Exception as e:
            self.log_and_print(f"❌ Error during comprehensive seeding: {e}", "error")
            import traceback
            self.log_and_print(f"Stack trace: {traceback.format_exc()}", "error")
            return False

    def create_comprehensive_sample_users_json(self):
        """Create comprehensive sample users for manual auth setup"""
        self.log_and_print("\n🔑 Creating comprehensive sample users...")
        
        sample_users = []

        # Admin user
        sample_users.append({
            'email': 'admin@lms.com',
            'password': '123456',
            'user_type': 'admin',
            'first_name': 'System',
            'last_name': 'Administrator',
            'role': 'Admin'
        })

        # Coaching center users
        for center_id, center in list(self.created_records['coaching_centers'].items())[:3]:
            # Find the user profile for this center
            center_user_id = center['user_id']
            if center_user_id in self.created_records['user_profiles']:
                profile = self.created_records['user_profiles'][center_user_id]
                sample_users.append({
                    'email': profile['email'],
                    'password': '123456',
                    'user_type': 'coaching_center',
                    'first_name': profile['first_name'],
                    'last_name': profile['last_name'],
                    'center_name': center['center_name'],
                    'role': 'Coaching Center'
                })

        # Teacher users
        for teacher_id, teacher in list(self.created_records['teachers'].items())[:5]:
            teacher_user_id = teacher['user_id']
            if teacher_user_id in self.created_records['user_profiles']:
                profile = self.created_records['user_profiles'][teacher_user_id]
                sample_users.append({
                    'email': profile['email'],
                    'password': '123456',
                    'user_type': 'teacher',
                    'first_name': profile['first_name'],
                    'last_name': profile['last_name'],
                    'title': teacher['title'],
                    'role': 'Teacher'
                })

        # Student users
        for student_id, student in list(self.created_records['students'].items())[:10]:
            student_user_id = student['user_id']
            if student_user_id in self.created_records['user_profiles']:
                profile = self.created_records['user_profiles'][student_user_id]
                sample_users.append({
                    'email': profile['email'],
                    'password': '123456',
                    'user_type': 'student',
                    'first_name': profile['first_name'],
                    'last_name': profile['last_name'],
                    'student_id': student['student_id'],
                    'grade_level': student['grade_level'],
                    'role': 'Student'
                })

        # Save to file with timestamp
        filename = f'sample_users_{datetime.now().strftime("%Y%m%d_%H%M%S")}.json'
        with open(filename, 'w') as f:
            json.dump(sample_users, f, indent=2, default=str)

        self.log_and_print(f"✅ Comprehensive sample users saved to '{filename}'")
        self.log_and_print(f"📝 Created {len(sample_users)} sample user accounts")
        
        return sample_users

    def __del__(self):
        """Cleanup when object is destroyed"""
        self.close_db_connection()


def main():
    """Enhanced main function"""
    parser = argparse.ArgumentParser(description='Comprehensive LMS Database Seeder')
    
    # Database connection arguments
    parser.add_argument('--db-user', default=DB_USER, help='Database user')
    parser.add_argument('--db-password', default=DB_PASSWORD, help='Database password')
    parser.add_argument('--db-host', default=DB_HOST, help='Database host')
    parser.add_argument('--db-port', default=DB_PORT, help='Database port')
    parser.add_argument('--db-name', default=DB_NAME, help='Database name')
    
    # Operation arguments
    parser.add_argument('--clear', action='store_true', help='Clear existing data before seeding')
    parser.add_argument('--skip-schema', action='store_true', help='Skip database schema setup')
    
    # Data generation arguments
    parser.add_argument('--coaching-centers', type=int, default=3, help='Number of coaching centers')
    parser.add_argument('--teachers', type=int, default=10, help='Number of teachers')
    parser.add_argument('--students', type=int, default=30, help='Number of students')
    parser.add_argument('--courses', type=int, default=15, help='Number of courses')
    parser.add_argument('--chapters-per-course', type=int, default=4, help='Chapters per course')
    parser.add_argument('--lessons-per-chapter', type=int, default=3, help='Lessons per chapter')

    args = parser.parse_args()

    # Validate database parameters
    required_params = ['db_user', 'db_password', 'db_host', 'db_port', 'db_name']
    missing_params = [param for param in required_params 
                     if not getattr(args, param.replace('-', '_'))]
    
    if missing_params:
        print(f"❌ Missing database parameters: {missing_params}")
        print("Set environment variables in .env file or use command line arguments")
        return

    # Create database parameters
    db_params = {
        'user': args.db_user,
        'password': args.db_password,
        'host': args.db_host,
        'port': args.db_port,
        'database': args.db_name
    }

    # Create counts dictionary
    counts = {
        'coaching_centers': args.coaching_centers,
        'teachers': args.teachers,
        'students': args.students,
        'courses': args.courses,
        'chapters_per_course': args.chapters_per_course,
        'lessons_per_chapter': args.lessons_per_chapter,
        'tests_per_course': DEFAULT_COUNTS['tests_per_course'],
        'assignments_per_course': DEFAULT_COUNTS['assignments_per_course'],
        'live_classes': DEFAULT_COUNTS['live_classes'],
        'enrollments_percentage': DEFAULT_COUNTS['enrollments_percentage'],
        'reviews_percentage': DEFAULT_COUNTS['reviews_percentage'],
    }

    # Initialize seeder
    seeder = LMSDataSeeder(db_params)

    try:
        # Clear data if requested
        if args.clear:
            seeder.clear_data()

        # Seed database
        success = seeder.seed_database(counts=counts, setup_schema=not args.skip_schema)

        if success:
            # Create comprehensive sample users file
            seeder.create_comprehensive_sample_users_json()
            
            print("\n🎯 Next Steps:")
            print("1. Check the generated sample_users_*.json file for test accounts")
            print("2. Create users in Supabase Auth using the provided data")
            print("3. All users have password: 123456")
            print("4. Check logs/ directory for detailed execution logs")
            print("5. Your comprehensive database is ready for testing!")

    except Exception as e:
        if 'seeder' in locals():
            seeder.log_and_print(f"❌ Error during comprehensive seeding: {e}", "error")
        else:
            print(f"❌ Error: {e}")
        raise

    finally:
        if 'seeder' in locals():
            seeder.close_db_connection()


if __name__ == "__main__":
    main()
