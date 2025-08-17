# LMS Database Schema Documentation

## Overview
This is a comprehensive Learning Management System (LMS) database designed for multi-coaching center operations. It supports students, teachers, coaching centers, courses, assessments, live classes, payments, and analytics.

## Prerequisites

### Environment Setup
```bash
# Install dependencies for the seeder
pip install faker supabase python-dotenv

# Set environment variables
export SUPABASE_URL="your-supabase-project-url"
export SUPABASE_SERVICE_KEY="your-supabase-service-role-key"
```

### Running the Data Seeder
```bash
# Basic usage
python lms_seeder.py

# Custom configuration
python lms_seeder.py --coaching-centers 5 --teachers 25 --students 200 --courses 50

# Clear and reseed
python lms_seeder.py --clear
```

## Database Schema Structure

### Core Entities

#### 1. User Profiles (`user_profiles`)
Base table for all users in the system.

**Key Fields:**
- `id` - References auth.users(id)
- `user_type` - 'student', 'teacher', 'admin', 'coaching_center'
- `first_name`, `last_name`, `email`
- `is_active`, `email_verified`

#### 2. Coaching Centers (`coaching_centers`)
Institutes that offer courses.

**Key Fields:**
- `id` - Primary key
- `user_id` - References user_profiles(id)
- `center_name`, `center_code`
- `approval_status` - 'pending', 'approved', 'rejected'
- `subscription_plan` - 'basic', 'premium', 'enterprise'

#### 3. Students (`students`)
Student profiles with academic information.

**Key Fields:**
- `id` - Primary key
- `user_id` - References user_profiles(id)
- `student_id` - Unique student identifier
- `grade_level` - Academic level
- `competitive_exams` - Array of target exams
- `current_streak_days`, `total_points`, `level`

#### 4. Teachers (`teachers`)
Teacher profiles with qualifications.

**Key Fields:**
- `id` - Primary key
- `user_id` - References user_profiles(id)
- `coaching_center_id` - References coaching_centers(id)
- `specializations` - Array of subjects
- `qualifications` - JSONB of degrees
- `rating`, `total_reviews`

#### 5. Courses (`courses`)
Course catalog with detailed information.

**Key Fields:**
- `id` - Primary key
- `coaching_center_id` - Owner coaching center
- `primary_teacher_id` - Main instructor
- `title`, `slug`, `description`
- `price`, `currency`, `is_published`
- `rating`, `enrollment_count`

## Common Query Patterns

### Flutter/Dart Examples

#### 1. Authentication & User Profile

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // Sign up new user
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String userType,
    required String firstName,
    required String lastName,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'user_type': userType,
        'first_name': firstName,
        'last_name': lastName,
      },
    );
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final response = await supabase
        .from('user_profiles')
        .select()
        .eq('id', user.id)
        .single();
    
    return response;
  }

  // Get student profile with statistics
  Future<Map<String, dynamic>?> getStudentProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final response = await supabase
        .from('students')
        .select('''
          *,
          user_profiles!inner(first_name, last_name, email, avatar_url)
        ''')
        .eq('user_id', user.id)
        .single();
    
    return response;
  }
}
```

#### 2. Course Management

```dart
class CourseService {
  final supabase = Supabase.instance.client;

  // Get published courses with filters
  Future<List<Map<String, dynamic>>> getCourses({
    String? category,
    String? level,
    double? maxPrice,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = supabase
        .from('course_overview')
        .select()
        .eq('is_published', true)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    if (category != null) {
      query = query.eq('category_slug', category);
    }
    
    if (level != null) {
      query = query.eq('level', level);
    }
    
    if (maxPrice != null) {
      query = query.lte('price', maxPrice);
    }

    return await query;
  }

  // Get course details with chapters and lessons
  Future<Map<String, dynamic>?> getCourseDetails(String courseId) async {
    final response = await supabase
        .from('courses')
        .select('''
          *,
          coaching_centers!inner(center_name, logo_url),
          teachers!primary_teacher_id(
            *,
            user_profiles!inner(first_name, last_name)
          ),
          chapters!chapters_course_id_fkey(
            *,
            lessons!lessons_chapter_id_fkey(*)
          )
        ''')
        .eq('id', courseId)
        .eq('is_published', true)
        .single();
    
    return response;
  }

  // Check if student is enrolled
  Future<Map<String, dynamic>?> getEnrollmentStatus(String courseId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await supabase
          .from('course_enrollments')
          .select()
          .eq('course_id', courseId)
          .eq('student_id', user.id)
          .single();
      
      return response;
    } catch (e) {
      return null; // Not enrolled
    }
  }

  // Enroll in course
  Future<bool> enrollInCourse(String courseId) async {
    try {
      final response = await supabase.rpc('enroll_student_in_course', params: {
        'p_student_id': supabase.auth.currentUser!.id,
        'p_course_id': courseId,
        'p_payment_status': 'free', // or 'paid'
        'p_enrollment_method': 'direct',
      });
      
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
```

#### 3. Learning Progress

```dart
class ProgressService {
  final supabase = Supabase.instance.client;

  // Update lesson progress
  Future<bool> updateLessonProgress({
    required String lessonId,
    int watchTimeSeconds = 0,
    double? completionPercentage,
    bool? isCompleted,
  }) async {
    try {
      final response = await supabase.rpc('update_lesson_progress', params: {
        'p_student_id': supabase.auth.currentUser!.id,
        'p_lesson_id': lessonId,
        'p_watch_time_seconds': watchTimeSeconds,
        'p_completion_percentage': completionPercentage,
        'p_is_completed': isCompleted,
      });
      
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // Get course progress summary
  Future<List<Map<String, dynamic>>> getStudentProgress() async {
    final response = await supabase
        .from('course_progress_summary')
        .select()
        .eq('student_id', supabase.auth.currentUser!.id)
        .order('enrolled_at', ascending: false);
    
    return response;
  }

  // Get lesson progress for a course
  Future<List<Map<String, dynamic>>> getLessonProgress(String courseId) async {
    final response = await supabase
        .from('lesson_progress')
        .select('''
          *,
          lessons!inner(title, lesson_number, video_duration),
          chapters!inner(title, chapter_number)
        ''')
        .eq('student_id', supabase.auth.currentUser!.id)
        .eq('course_id', courseId)
        .order('lessons.chapter_id, lessons.sort_order');
    
    return response;
  }
}
```

#### 4. Dashboard Data

```dart
class DashboardService {
  final supabase = Supabase.instance.client;

  // Get student dashboard data
  Future<Map<String, dynamic>> getStudentDashboard() async {
    final studentData = await supabase
        .from('student_dashboard')
        .select()
        .eq('student_id', supabase.auth.currentUser!.id)
        .single();
    
    // Get recent enrollments
    final recentCourses = await supabase
        .from('course_progress_summary')
        .select('''
          *,
          courses!inner(title, thumbnail_url)
        ''')
        .eq('student_id', supabase.auth.currentUser!.id)
        .order('last_accessed_at', ascending: false)
        .limit(5);

    // Get upcoming assignments
    final upcomingAssignments = await supabase
        .from('assignments')
        .select('''
          *,
          courses!inner(title)
        ''')
        .gte('due_date', DateTime.now().toIso8601String())
        .eq('is_published', true)
        .order('due_date', ascending: true)
        .limit(5);

    return {
      'student': studentData,
      'recent_courses': recentCourses,
      'upcoming_assignments': upcomingAssignments,
    };
  }

  // Update learning streak
  Future<Map<String, dynamic>> updateLearningStreak() async {
    final response = await supabase.rpc('update_learning_streak', params: {
      'p_student_id': supabase.auth.currentUser!.id,
      'p_timezone': 'Asia/Kolkata',
    });
    
    return response;
  }
}
```

### Next.js/JavaScript Examples

#### 1. Server-side API Routes

```javascript
// pages/api/courses/index.js
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
)

export default async function handler(req, res) {
  if (req.method === 'GET') {
    try {
      const { category, level, page = 1, limit = 20 } = req.query
      const offset = (page - 1) * limit

      let query = supabase
        .from('course_overview')
        .select(`
          *,
          coaching_centers!inner(center_name, logo_url)
        `)
        .eq('is_published', true)
        .order('created_at', { ascending: false })
        .range(offset, offset + limit - 1)

      if (category) {
        query = query.eq('category_slug', category)
      }

      if (level) {
        query = query.eq('level', level)
      }

      const { data, error, count } = await query

      if (error) throw error

      res.status(200).json({
        courses: data,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: count
        }
      })
    } catch (error) {
      res.status(500).json({ error: error.message })
    }
  }
}
```

#### 2. Client-side Data Fetching

```javascript
// hooks/useCourses.js
import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

export function useCourses(filters = {}) {
  const [courses, setCourses] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchCourses()
  }, [filters])

  const fetchCourses = async () => {
    try {
      setLoading(true)
      
      let query = supabase
        .from('course_overview')
        .select('*')
        .eq('is_published', true)
        .order('created_at', { ascending: false })

      // Apply filters
      if (filters.category) {
        query = query.eq('category_slug', filters.category)
      }
      
      if (filters.level) {
        query = query.eq('level', filters.level)
      }
      
      if (filters.maxPrice) {
        query = query.lte('price', filters.maxPrice)
      }

      const { data, error } = await query

      if (error) throw error

      setCourses(data || [])
    } catch (error) {
      setError(error.message)
    } finally {
      setLoading(false)
    }
  }

  return { courses, loading, error, refetch: fetchCourses }
}
```

#### 3. Real-time Subscriptions

```javascript
// hooks/useRealtimeProgress.js
import { useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'

export function useRealtimeProgress(courseId) {
  const [progress, setProgress] = useState(null)
  const [user, setUser] = useState(null)

  useEffect(() => {
    // Get current user
    const getUser = async () => {
      const { data: { user } } = await supabase.auth.getUser()
      setUser(user)
    }
    getUser()
  }, [])

  useEffect(() => {
    if (!user || !courseId) return

    // Fetch initial progress
    const fetchProgress = async () => {
      const { data } = await supabase
        .from('course_progress_summary')
        .select('*')
        .eq('student_id', user.id)
        .eq('course_id', courseId)
        .single()
      
      setProgress(data)
    }
    fetchProgress()

    // Subscribe to progress changes
    const subscription = supabase
      .channel('progress_changes')
      .on(
        'postgres_changes',
        {
          event: 'UPDATE',
          schema: 'public',
          table: 'course_enrollments',
          filter: `student_id=eq.${user.id}`
        },
        (payload) => {
          if (payload.new.course_id === courseId) {
            setProgress(payload.new)
          }
        }
      )
      .subscribe()

    return () => {
      subscription.unsubscribe()
    }
  }, [user, courseId])

  return progress
}
```

## Advanced Queries

### 1. Course Analytics

```sql
-- Get detailed course analytics
SELECT 
  c.id,
  c.title,
  c.enrollment_count,
  c.rating,
  ce.completion_rate,
  AVG(lp.overall_progress_percentage) as avg_progress,
  COUNT(DISTINCT ce.student_id) as active_students,
  COUNT(DISTINCT r.id) as total_reviews
FROM courses c
LEFT JOIN course_enrollments ce ON c.id = ce.course_id
LEFT JOIN lesson_progress lp ON c.id = lp.course_id
LEFT JOIN reviews r ON c.id = r.course_id AND r.is_published = true
WHERE c.is_published = true
GROUP BY c.id, c.title, c.enrollment_count, c.rating, ce.completion_rate;
```

### 2. Student Performance Report

```sql
-- Get student performance across all courses
SELECT 
  s.student_id,
  up.first_name || ' ' || up.last_name as full_name,
  COUNT(ce.id) as total_enrollments,
  COUNT(ce.id) FILTER (WHERE ce.completed_at IS NOT NULL) as completed_courses,
  AVG(ce.progress_percentage) as avg_progress,
  SUM(ce.total_time_spent_minutes) as total_study_time,
  s.current_streak_days,
  s.total_points
FROM students s
JOIN user_profiles up ON s.user_id = up.id
LEFT JOIN course_enrollments ce ON s.id = ce.student_id
WHERE s.is_active = true
GROUP BY s.id, s.student_id, up.first_name, up.last_name, s.current_streak_days, s.total_points;
```

### 3. Teacher Dashboard Query

```sql
-- Get comprehensive teacher dashboard data
SELECT 
  t.id,
  up.first_name || ' ' || up.last_name as full_name,
  cc.center_name,
  COUNT(DISTINCT c.id) as total_courses,
  COUNT(DISTINCT ce.student_id) as total_students,
  AVG(c.rating) as avg_course_rating,
  COUNT(DISTINCT a.id) as total_assignments,
  COUNT(DISTINCT asub.id) FILTER (WHERE asub.grade IS NULL) as pending_grading
FROM teachers t
JOIN user_profiles up ON t.user_id = up.id
JOIN coaching_centers cc ON t.coaching_center_id = cc.id
LEFT JOIN courses c ON t.id = c.primary_teacher_id AND c.is_published = true
LEFT JOIN course_enrollments ce ON c.id = ce.course_id AND ce.is_active = true
LEFT JOIN assignments a ON t.id = a.teacher_id
LEFT JOIN assignment_submissions asub ON a.id = asub.assignment_id
WHERE t.status = 'active'
GROUP BY t.id, up.first_name, up.last_name, cc.center_name;
```

## Security Considerations

### Row Level Security (RLS) Policies

The database uses comprehensive RLS policies:

- **Students** can only access their own data and enrolled course content
- **Teachers** can access their own courses and enrolled students' progress
- **Coaching Centers** can manage their own teachers and courses
- **Admins** have full access to all data

### Best Practices

1. **Always use the service role key** for server-side operations
2. **Use the anon key** for client-side operations with RLS
3. **Validate user permissions** before allowing sensitive operations
4. **Use prepared statements** or parameterized queries to prevent SQL injection
5. **Implement rate limiting** for API endpoints

## Performance Optimization

### Indexes
The schema includes comprehensive indexes for:
- User lookups by type and status
- Course filtering and sorting
- Progress tracking queries
- Analytics and reporting

### Query Optimization Tips

1. **Use specific column selection** instead of `SELECT *`
2. **Leverage database views** for complex joins
3. **Implement pagination** for large result sets
4. **Use real-time subscriptions** judiciously to avoid overhead
5. **Cache frequently accessed data** on the client side

## Troubleshooting

### Common Issues

1. **RLS Policy Violations**
   - Ensure user is authenticated
   - Check if user has proper permissions
   - Verify RLS policies are correctly configured

2. **Foreign Key Constraints**
   - Ensure related records exist before creating dependencies
   - Use proper transaction handling for complex operations

3. **Performance Issues**
   - Check for missing indexes on frequently queried columns
   - Optimize complex joins and aggregations
   - Consider using database functions for complex operations

### Debugging Queries

```javascript
// Enable query logging in development
if (process.env.NODE_ENV === 'development') {
  supabase
    .from('your_table')
    .select('*')
    .then(console.log)
    .catch(console.error)
}
```

## Migration and Maintenance

### Regular Maintenance Tasks

1. **Clean up old analytics data** (run monthly):
```sql
SELECT cleanup_old_analytics_data(90); -- Keep 90 days
```

2. **Refresh course statistics** (run daily):
```sql
SELECT refresh_course_statistics();
```

3. **Update learning streaks** (run daily via cron):
```sql
-- This should be automated via application logic
SELECT update_learning_streak(student_id) FROM students WHERE is_active = true;
```

This documentation provides a comprehensive guide for using the LMS database schema with Flutter and Next.js applications. The examples demonstrate common patterns for authentication, data fetching, real-time updates, and complex queries.