// lib/coaching_centers/teacher/teacher_repository.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeacherRepository {
  static final SupabaseClient _client = Supabase.instance.client;

  static String? get currentUserId => _client.auth.currentUser?.id;

  // ✅ FIXED: Get teachers by coaching center
  static Future<List<Map<String, dynamic>>> getTeachersByCoachingCenter(
    String coachingCenterId,
  ) async {
    try {
      final response = await _client
          .from('teachers')
          .select('''
            id,
            user_id,
            employee_id,
            title,
            specializations,
            qualifications,
            experience_years,
            bio,
            hourly_rate,
            rating,
            total_reviews,
            total_courses,
            total_students_taught,
            is_verified,
            can_create_courses,
            can_conduct_live_classes,
            status,
            joined_at,
            user_profiles!teachers_user_id_fkey(
              first_name,
              last_name,
              avatar_url,
              phone,
              email,
              date_of_birth,
              address
            )
          ''')
          .eq('coaching_center_id', coachingCenterId)
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching teachers: $e');
      return [];
    }
  }

  // ✅ FIXED: Get single teacher by ID
  static Future<Map<String, dynamic>?> getTeacherById(String teacherId) async {
    try {
      final response = await _client
          .from('teachers')
          .select('''
            id,
            user_id,
            employee_id,
            title,
            specializations,
            qualifications,
            experience_years,
            bio,
            hourly_rate,
            rating,
            total_reviews,
            total_courses,
            total_students_taught,
            is_verified,
            can_create_courses,
            can_conduct_live_classes,
            can_grade_assignments,
            status,
            joined_at,
            coaching_center_id,
            user_profiles!teachers_user_id_fkey(
              first_name,
              last_name,
              avatar_url,
              phone,
              email,
              date_of_birth,
              address
            ),
            coaching_centers!teachers_coaching_center_id_fkey(
              center_name,
              logo_url,
              contact_email,
              contact_phone,
              address
            )
          ''')
          .eq('id', teacherId)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error fetching teacher: $e');
      return null;
    }
  }

  // ✅ FIXED: Get courses taught by teacher (via course_teachers junction table)
  static Future<List<Map<String, dynamic>>> getCoursesByTeacher(
    String teacherId, {
    int limit = 10,
  }) async {
    try {
      // First get courses through the course_teachers relationship
      final response = await _client
          .from('course_teachers')
          .select('''
            role,
            is_primary,
            courses!inner(
              id,
              title,
              slug,
              description,
              short_description,
              thumbnail_url,
              price,
              original_price,
              currency,
              duration_hours,
              total_lessons,
              enrollment_count,
              rating,
              total_reviews,
              level,
              is_published,
              category_id,
              course_categories(id, name, slug)
            )
          ''')
          .eq('teacher_id', teacherId)
          .eq('courses.is_published', true)
          .order('created_at', ascending: false)
          .limit(limit);

      // Extract courses from the junction table response
      final courses = response.map((item) {
        final course = Map<String, dynamic>.from(item['courses'] as Map);
        course['teacher_role'] = item['role'];
        course['is_primary_teacher'] = item['is_primary'];
        return course;
      }).toList();

      return courses;
    } catch (e) {
      debugPrint('Error fetching teacher courses: $e');
      return [];
    }
  }

  // ✅ FIXED: Get teacher reviews (reviews table has teacher_id referencing teachers.user_id)
  static Future<List<Map<String, dynamic>>> getTeacherReviews(
    String teacherId, {
    int limit = 5,
  }) async {
    try {
      // First get the user_id from the teacher
      final teacherData = await _client
          .from('teachers')
          .select('user_id')
          .eq('id', teacherId)
          .maybeSingle();

      if (teacherData == null) {
        debugPrint('Teacher not found');
        return [];
      }

      final teacherUserId = teacherData['user_id'];

      final response = await _client
          .from('reviews')
          .select('''
            id,
            overall_rating,
            content_rating,
            instructor_rating,
            title,
            review_text,
            pros,
            cons,
            is_verified_purchase,
            completed_percentage,
            helpful_votes,
            created_at,
            students!reviews_student_id_fkey(
              user_profiles!students_user_id_fkey(
                first_name,
                last_name,
                avatar_url
              )
            ),
            courses!reviews_course_id_fkey(
              title,
              thumbnail_url
            )
          ''')
          .eq('teacher_id', teacherUserId)
          .eq('is_published', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching teacher reviews: $e');
      return [];
    }
  }

  // ✅ FIXED: Get featured teachers
  static Future<List<Map<String, dynamic>>> getFeaturedTeachers({
    int limit = 4,
  }) async {
    try {
      // Strategy 1: Try to get highly rated teachers with reviews
      var response = await _client
          .from('teachers')
          .select('''
            id,
            user_id,
            title,
            specializations,
            experience_years,
            rating,
            total_reviews,
            total_courses,
            total_students_taught,
            is_verified,
            coaching_center_id,
            user_profiles!teachers_user_id_fkey(
              first_name,
              last_name,
              avatar_url
            ),
            coaching_centers!teachers_coaching_center_id_fkey(
              center_name,
              logo_url
            )
          ''')
          .eq('is_verified', true)
          .eq('status', 'active')
          .gte('rating', 4.0)
          .gte('total_reviews', 5)
          .order('rating', ascending: false)
          .order('total_reviews', ascending: false)
          .limit(limit);

      if (response.length >= limit) {
        return List<Map<String, dynamic>>.from(response);
      }

      // Strategy 2: If not enough results, try verified teachers with any rating
      if (response.length < limit) {
        final additionalResponse = await _client
            .from('teachers')
            .select('''
              id,
              user_id,
              title,
              specializations,
              experience_years,
              rating,
              total_reviews,
              total_courses,
              total_students_taught,
              is_verified,
              coaching_center_id,
              user_profiles!teachers_user_id_fkey(
                first_name,
                last_name,
                avatar_url
              ),
              coaching_centers!teachers_coaching_center_id_fkey(
                center_name,
                logo_url
              )
            ''')
            .eq('is_verified', true)
            .eq('status', 'active')
            .not('rating', 'is', null)
            .order('rating', ascending: false)
            .order('experience_years', ascending: false)
            .limit(limit);

        final allResults = [...response, ...additionalResponse];
        final uniqueResults = <Map<String, dynamic>>[];
        final seenIds = <String>{};

        for (final teacher in allResults) {
          final id = teacher['id']?.toString();
          if (id != null && !seenIds.contains(id)) {
            seenIds.add(id);
            uniqueResults.add(teacher);
            if (uniqueResults.length >= limit) break;
          }
        }

        if (uniqueResults.isNotEmpty) {
          return uniqueResults;
        }
      }

      // Strategy 3: Last resort - get any active teachers
      final fallbackResponse = await _client
          .from('teachers')
          .select('''
            id,
            user_id,
            title,
            specializations,
            experience_years,
            rating,
            total_reviews,
            total_courses,
            total_students_taught,
            is_verified,
            coaching_center_id,
            user_profiles!teachers_user_id_fkey(
              first_name,
              last_name,
              avatar_url
            ),
            coaching_centers!teachers_coaching_center_id_fkey(
              center_name,
              logo_url
            )
          ''')
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(fallbackResponse);
    } catch (e) {
      debugPrint('Error fetching featured teachers: $e');
      return [];
    }
  }

  // ✅ FIXED: Search teachers
  static Future<List<Map<String, dynamic>>> searchTeachers(
    String query, {
    int limit = 20,
  }) async {
    try {
      final response = await _client
          .from('teachers')
          .select('''
            id,
            user_id,
            title,
            specializations,
            experience_years,
            rating,
            total_reviews,
            total_courses,
            is_verified,
            user_profiles!teachers_user_id_fkey(
              first_name,
              last_name,
              avatar_url
            ),
            coaching_centers!teachers_coaching_center_id_fkey(
              center_name,
              logo_url
            )
          ''')
          .eq('status', 'active')
          .or(
            'user_profiles.first_name.ilike.%$query%,user_profiles.last_name.ilike.%$query%,title.ilike.%$query%',
          )
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error searching teachers: $e');
      return [];
    }
  }
}
