// lib/coaching_centers/teacher/teacher_repository.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeacherRepository {
  static final SupabaseClient _client = Supabase.instance.client;

  static String? get currentUserId => _client.auth.currentUser?.id;

  // Get teachers by coaching center
  static Future<List<Map<String, dynamic>>> getTeachersByCoachingCenter(
    String coachingCenterId,
  ) async {
    try {
      final response = await _client
          .from('teachers')
          .select('''
            id,
            employee_id,
            specializations,
            qualifications,
            experience_years,
            bio,
            hourly_rate,
            rating,
            total_reviews,
            is_verified,
            can_create_courses,
            can_conduct_live_classes,
            joined_at,
            user_profiles!teachers_user_id_fkey(
              first_name,
              last_name,
              avatar_url,
              phone,
              date_of_birth,
              address
            )
          ''')
          .eq('coaching_center_id', coachingCenterId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching teachers: $e');
      return [];
    }
  }

  // FIXED: Get single teacher by ID - removed email field
  static Future<Map<String, dynamic>?> getTeacherById(String teacherId) async {
    try {
      final response = await _client
          .from('teachers')
          .select('''
            id,
            employee_id,
            specializations,
            qualifications,
            experience_years,
            bio,
            hourly_rate,
            rating,
            total_reviews,
            is_verified,
            can_create_courses,
            can_conduct_live_classes,
            joined_at,
            coaching_center_id,
            user_profiles!teachers_user_id_fkey(
              first_name,
              last_name,
              avatar_url,
              phone,
              date_of_birth,
              address
            ),
            coaching_centers!teachers_coaching_center_id_fkey(
              center_name,
              logo_url,
              contact_email,
              contact_phone
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

  // Get courses taught by teacher
  static Future<List<Map<String, dynamic>>> getCoursesByTeacher(
    String teacherId, {
    int limit = 10,
  }) async {
    try {
      final response = await _client
          .from('courses')
          .select('''
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
            category,
            subcategory,
            is_published
          ''')
          .eq('teacher_id', teacherId)
          .eq('is_published', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching teacher courses: $e');
      return [];
    }
  }

  // Get teacher reviews
  static Future<List<Map<String, dynamic>>> getTeacherReviews(
    String teacherId, {
    int limit = 5,
  }) async {
    try {
      final response = await _client
          .from('reviews')
          .select('''
            id,
            rating,
            review_text,
            pros,
            cons,
            created_at,
            students!reviews_student_id_fkey(
              user_profiles!students_user_id_fkey(
                first_name,
                last_name,
                avatar_url
              )
            ),
            courses!reviews_course_id_fkey(
              title
            )
          ''')
          .eq('teacher_id', teacherId)
          .eq('is_published', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching teacher reviews: $e');
      return [];
    }
  }

  // Get featured teachers (top-rated teachers across all coaching centers)
  static Future<List<Map<String, dynamic>>> getFeaturedTeachers({
    int limit = 4,
  }) async {
    try {
      // Strategy 1: Try to get highly rated teachers with reviews
      var response = await _client
          .from('teachers')
          .select('''
          id,
          specializations,
          experience_years,
          rating,
          total_reviews,
          is_verified,
          coaching_center_id,
          user_profiles!teachers_user_id_fkey(
            first_name,
            last_name,
            avatar_url
          ),
          coaching_centers!teachers_coaching_center_id_fkey(
            center_name
          )
        ''')
          .eq('is_verified', true)
          .gte('rating', 4.0) // Lowered from 4.5
          .gte('total_reviews', 5) // Lowered from 10
          .order('rating', ascending: false)
          .order('total_reviews', ascending: false)
          .limit(limit);

      // If we got enough results, return them
      if (response.length >= limit) {
        return List<Map<String, dynamic>>.from(response);
      }

      // Strategy 2: If not enough results, try verified teachers with any rating
      if (response.length < limit) {
        final additionalResponse = await _client
            .from('teachers')
            .select('''
            id,
            specializations,
            experience_years,
            rating,
            total_reviews,
            is_verified,
            coaching_center_id,
            user_profiles!teachers_user_id_fkey(
              first_name,
              last_name,
              avatar_url
            ),
            coaching_centers!teachers_coaching_center_id_fkey(
              center_name
            )
          ''')
            .eq('is_verified', true)
            .not('rating', 'is', null) // Exclude NULL ratings
            .order('rating', ascending: false)
            .order('experience_years', ascending: false)
            .limit(limit);

        // Merge results and remove duplicates
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

      // Strategy 3: Last resort - get any teachers (for development/testing)
      final fallbackResponse = await _client
          .from('teachers')
          .select('''
          id,
          specializations,
          experience_years,
          rating,
          total_reviews,
          is_verified,
          coaching_center_id,
          user_profiles!teachers_user_id_fkey(
            first_name,
            last_name,
            avatar_url
          ),
          coaching_centers!teachers_coaching_center_id_fkey(
            center_name
          )
        ''')
          .order('created_at', ascending: false) // Get newest teachers
          .limit(limit);

      return List<Map<String, dynamic>>.from(fallbackResponse);
    } catch (e) {
      debugPrint('Error fetching featured teachers: $e');
      return [];
    }
  }

  // Search teachers
  static Future<List<Map<String, dynamic>>> searchTeachers(
    String query, {
    int limit = 20,
  }) async {
    try {
      final response = await _client
          .from('teachers')
          .select('''
            id,
            specializations,
            experience_years,
            rating,
            total_reviews,
            is_verified,
            user_profiles!teachers_user_id_fkey(
              first_name,
              last_name,
              avatar_url
            ),
            coaching_centers!teachers_coaching_center_id_fkey(
              center_name
            )
          ''')
          .or(
            'user_profiles.first_name.ilike.%$query%,user_profiles.last_name.ilike.%$query%,specializations.cs.{$query}',
          )
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error searching teachers: $e');
      return [];
    }
  }
}
