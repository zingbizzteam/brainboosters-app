import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CoursePlayerRepository {
  static final _supabase = Supabase.instance.client;

  static Future<Map<String, dynamic>?> getCourseWithChapters(
    String courseId,
  ) async {
    try {
      final response = await _supabase
          .from('courses')
          .select('''
            *,
            chapters (
              *,
              lessons (
                id,
                title,
                lesson_number,
                lesson_type,
                video_duration,
                is_published,
                is_free,
                description,
                content_url
              )
            )
          ''')
          .eq('id', courseId)
          .eq('is_published', true)
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to load course: $e');
    }
  }

  static Future<Map<String, dynamic>> checkCourseAccess(String courseId) async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        return {'hasAccess': false, 'isEnrolled': false};
      }

      // Check if user is enrolled
      final enrollment = await _supabase
          .from('course_enrollments')
          .select('id, is_active')
          .eq('course_id', courseId)
          .eq('student_id', await _getStudentId())
          .eq('is_active', true)
          .maybeSingle();

      final isEnrolled = enrollment != null;

      return {'hasAccess': isEnrolled, 'isEnrolled': isEnrolled};
    } catch (e) {
      return {'hasAccess': false, 'isEnrolled': false};
    }
  }

  static Future<Map<String, dynamic>?> getLessonById(String lessonId) async {
    try {
      final response = await _supabase
          .from('lessons')
          .select('''
            *,
            chapters (
              id,
              title,
              course_id
            )
          ''')
          .eq('id', lessonId)
          .eq('is_published', true)
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to load lesson: $e');
    }
  }

  static Future<String?> getSecureVideoUrl(String lessonId) async {
    try {
      final lesson = await _supabase
          .from('lessons')
          .select('content_url, lesson_type, title')
          .eq('id', lessonId)
          .eq('is_published', true)
          .single();

      if (lesson['lesson_type'] != 'video') {
        debugPrint('Lesson is not a video type: ${lesson['lesson_type']}');
        return null;
      }

      final rawUrl = lesson['content_url'] as String?;
      if (rawUrl == null || rawUrl.isEmpty) {
        debugPrint('No content URL found for lesson: ${lesson['title']}');
        return null;
      }

      // Convert HTTP to HTTPS for better security and compatibility
      String secureUrl = rawUrl;
      if (secureUrl.startsWith('http://')) {
        secureUrl = secureUrl.replaceFirst('http://', 'https://');
        debugPrint('Converted HTTP to HTTPS: $secureUrl');
      }

      debugPrint('Validated video URL: $secureUrl');
      return secureUrl;
    } catch (e) {
      debugPrint('Failed to get video URL: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getLessonProgress(
    String lessonId,
  ) async {
    try {
      final studentId = await _getStudentId();

      final response = await _supabase
          .from('lesson_progress')
          .select('*')
          .eq('lesson_id', lessonId)
          .eq('student_id', studentId)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateLessonProgress(
    String lessonId,
    int positionSeconds,
    int durationSeconds,
  ) async {
    try {
      final studentId = await _getStudentId();
      final progressPercentage = durationSeconds > 0
          ? (positionSeconds / durationSeconds * 100).clamp(0, 100)
          : 0.0;

      await _supabase.rpc(
        'calculate_lesson_progress',
        params: {
          'p_student_id': studentId,
          'p_lesson_id': lessonId,
          'p_watch_time_seconds': positionSeconds,
          'p_is_completed': progressPercentage >= 90,
        },
      );
    } catch (e) {
      // Don't throw - progress tracking should be non-blocking
      debugPrint('Failed to update lesson progress: $e');
    }
  }

  static Future<void> markLessonCompleted(String lessonId) async {
    try {
      final studentId = await _getStudentId();

      await _supabase.rpc(
        'calculate_lesson_progress',
        params: {
          'p_student_id': studentId,
          'p_lesson_id': lessonId,
          'p_watch_time_seconds': 0,
          'p_is_completed': true,
        },
      );
    } catch (e) {
      debugPrint('Failed to mark lesson completed: $e');
    }
  }

  static Future<String> _getStudentId() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final student = await _supabase
        .from('students')
        .select('id')
        .eq('user_id', user.id)
        .single();

    return student['id'];
  }
}
