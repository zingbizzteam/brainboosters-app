// lib/screen/common/courses/courses_intro/course_intro_repository.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourseIntroRepository {
  static final SupabaseClient _client = Supabase.instance.client;
  static String? get currentUserId => _client.auth.currentUser?.id;
  static bool get isAuthenticated => _client.auth.currentUser != null;

  // ✅ FIXED: Filter unpublished lessons
  static Future<Map<String, dynamic>?> getCourseById(String courseId) async {
    try {
      final userId = currentUserId;

      final courseResponse = await _client
          .from('courses')
          .select('''
            id,
            title,
            slug,
            description,
            short_description,
            thumbnail_url,
            trailer_video_url,
            course_content_overview,
            what_you_learn,
            course_includes,
            target_audience,
            prerequisites,
            category_id,
            course_categories!left(id, name, slug),
            level,
            price,
            original_price,
            currency,
            duration_hours,
            total_lessons,
            learning_outcomes,
            tags,
            rating,
            total_reviews,
            enrollment_count,
            last_updated,
            created_at,
            updated_at,
            coaching_center_id,
            coaching_centers(id, user_id, center_name, logo_url),
            course_teachers!left(
              role,
              is_primary,
              teachers!inner(
                id,
                user_id,
                user_profiles!inner(first_name, last_name, avatar_url)
              )
            )
          ''')
          .eq('id', courseId)
          .eq('is_published', true)
          .maybeSingle();

      if (courseResponse == null) {
        debugPrint('Course not found with ID: $courseId');
        return null;
      }

      // Fetch chapters (show all chapters for now)
      final chapters = await _client
          .from('chapters')
          .select('''
            id,
            title,
            description,
            chapter_number,
            duration_minutes,
            total_lessons,
            is_published,
            is_free,
            sort_order
          ''')
          .eq('course_id', courseId)
          .eq('is_published', true) // ✅ Only show published chapters
          .order('sort_order', ascending: true);

      debugPrint('📚 Fetched ${chapters.length} published chapters for course $courseId');

      // ✅ FIXED: Only fetch PUBLISHED lessons
      for (var chapter in chapters) {
        final lessons = await _client
            .from('lessons')
            .select('''
              id,
              title,
              description,
              lesson_number,
              lesson_type,
              video_duration,
              content_url,
              is_published,
              is_free,
              sort_order
            ''')
            .eq('chapter_id', chapter['id'])
            .eq('is_published', true) // ✅ CRITICAL: Only show published lessons
            .order('sort_order', ascending: true);

        chapter['lessons'] = lessons;
        debugPrint('  📖 Chapter "${chapter['title']}": ${lessons.length} published lessons');
      }

      // Filter out chapters with no published lessons
      final chaptersWithLessons = chapters.where((chapter) {
        final lessons = chapter['lessons'] as List?;
        return lessons != null && lessons.isNotEmpty;
      }).toList();

      debugPrint('✅ ${chaptersWithLessons.length} chapters have published lessons');

      // Check enrollment status
      Map<String, dynamic>? enrollmentData;
      if (userId != null) {
        final studentResponse = await _client
            .from('students')
            .select('id')
            .eq('user_id', userId)
            .maybeSingle();

        if (studentResponse != null) {
          final studentId = studentResponse['id'];
          final enrollmentResponse = await _client
              .from('course_enrollments')
              .select('''
                progress_percentage,
                total_time_spent_minutes,
                lessons_completed,
                last_accessed_at,
                enrolled_at,
                completed_at,
                is_active
              ''')
              .eq('course_id', courseId)
              .eq('student_id', studentId)
              .eq('is_active', true)
              .maybeSingle();

          if (enrollmentResponse != null) {
            enrollmentData = enrollmentResponse;
          }
        }
      }

      final result = Map<String, dynamic>.from(courseResponse);
      result['chapters'] = chaptersWithLessons; // ✅ Use filtered chapters
      if (enrollmentData != null) {
        result['enrollment'] = enrollmentData;
      }

      debugPrint('✅ Course data prepared with ${chaptersWithLessons.length} chapters');
      return result;
    } catch (e) {
      debugPrint('❌ Error fetching course: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getCourseReviews(
    String courseId,
  ) async {
    try {
      final response = await _client
          .from('reviews')
          .select('''
            id,
            overall_rating,
            review_text,
            helpful_votes,
            created_at,
            updated_at,
            students!inner(
              id,
              user_profiles!inner(first_name, last_name, avatar_url)
            )
          ''')
          .eq('course_id', courseId)
          .eq('is_published', true)
          .order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      return [];
    }
  }

  static Future<bool> enrollInCourse(String courseId) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      final studentResponse = await _client
          .from('students')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (studentResponse == null) return false;

      final studentId = studentResponse['id'];

      final existingEnrollment = await _client
          .from('course_enrollments')
          .select('id')
          .eq('course_id', courseId)
          .eq('student_id', studentId)
          .maybeSingle();

      if (existingEnrollment != null) return false;

      await _client.from('course_enrollments').insert({
        'course_id': courseId,
        'student_id': studentId,
        'enrolled_at': DateTime.now().toIso8601String(),
        'progress_percentage': 0.0,
        'total_time_spent_minutes': 0,
        'lessons_completed': 0,
        'is_active': true,
      });

      return true;
    } catch (e) {
      debugPrint('Error enrolling in course: $e');
      return false;
    }
  }

  static Future<bool> isUserEnrolled(String courseId) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      final studentResponse = await _client
          .from('students')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (studentResponse == null) return false;

      final enrollmentResponse = await _client
          .from('course_enrollments')
          .select('id')
          .eq('course_id', courseId)
          .eq('student_id', studentResponse['id'])
          .eq('is_active', true)
          .maybeSingle();

      return enrollmentResponse != null;
    } catch (e) {
      debugPrint('Error checking enrollment: $e');
      return false;
    }
  }
}
