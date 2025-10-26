// screens/student/dashboard/dashboard_repository.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:brainboosters_app/screens/student/dashboard/widgets/quick_stats_grid.dart';

class DashboardRepository {
  // ==================== STUDENT STATS ====================

  static Future<StudentStats> fetchStudentStats(String studentId) async {
    try {
      debugPrint('📊 Fetching stats for student: $studentId');

      // Fetch all stats in parallel for better performance
      final results = await Future.wait([
        _getEnrolledCoursesCount(studentId),
        _getCompletedLessonsStats(studentId),
        _getStudyHours(studentId),
        _getAchievementPoints(studentId),
        _getStreakDays(studentId),
      ]);

      final stats = StudentStats(
        enrolledCourses: results as int,
        completedLessons: (results as Map)['completed'] as int,
        totalLessons: (results as Map)['total'] as int,
        studyHours: results as double,
        achievementPoints: results as int,
        streakDays: results as int,
      );

      debugPrint('✅ Stats fetched successfully');
      return stats;
    } catch (e) {
      debugPrint('❌ Error fetching student stats: $e');
      return StudentStats.empty();
    }
  }

  // Private helper methods

  static Future<int> _getEnrolledCoursesCount(String studentId) async {
    try {
      final response = await Supabase.instance.client
          .from('course_enrollments')
          .select('id')
          .eq('student_id', studentId)
          .eq('is_active', true);

      return (response as List).length;
    } catch (e) {
      debugPrint('Error getting enrolled courses: $e');
      return 0;
    }
  }

  static Future<Map<String, int>> _getCompletedLessonsStats(
    String studentId,
  ) async {
    try {
      // Get total lessons from enrolled courses
      final enrolledCourses = await Supabase.instance.client
          .from('course_enrollments')
          .select('course_id')
          .eq('student_id', studentId)
          .eq('is_active', true);

      if (enrolledCourses.isEmpty) {
        return {'completed': 0, 'total': 0};
      }

      final courseIds = (enrolledCourses as List)
          .map((e) => e['course_id'])
          .toList();

      // Get total lessons count
      final totalLessons = await Supabase.instance.client
          .from('lessons')
          .select('id')
          .inFilter('course_id', courseIds)
          .eq('is_published', true);

      // Get completed lessons count
      final completedLessons = await Supabase.instance.client
          .from('lesson_progress')
          .select('id')
          .eq('student_id', studentId)
          .eq('is_completed', true);

      return {
        'completed': (completedLessons as List).length,
        'total': (totalLessons as List).length,
      };
    } catch (e) {
      debugPrint('Error getting lesson stats: $e');
      return {'completed': 0, 'total': 0};
    }
  }

  static Future<double> _getStudyHours(String studentId) async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      final response = await Supabase.instance.client
          .from('lesson_progress')
          .select('total_time_spent_seconds')
          .eq('student_id', studentId)
          .gte('updated_at', sevenDaysAgo.toIso8601String());

      if (response.isEmpty) return 0.0;

      final totalSeconds = (response as List).fold<int>(
        0,
        (sum, item) => sum + ((item['total_time_spent_seconds'] ?? 0) as int),
      );

      return totalSeconds / 3600.0; // Convert to hours
    } catch (e) {
      debugPrint('Error getting study hours: $e');
      return 0.0;
    }
  }

  static Future<int> _getAchievementPoints(String studentId) async {
    try {
      final response = await Supabase.instance.client
          .from('students')
          .select('total_points')
          .eq('user_id', studentId)
          .single();

      return response['total_points'] ?? 0;
    } catch (e) {
      debugPrint('Error getting achievement points: $e');
      return 0;
    }
  }

  static Future<int> _getStreakDays(String studentId) async {
    try {
      final response = await Supabase.instance.client
          .from('students')
          .select('current_streak_days')
          .eq('user_id', studentId)
          .single();

      return response['current_streak_days'] ?? 0;
    } catch (e) {
      debugPrint('Error getting streak: $e');
      return 0;
    }
  }

  // ==================== POPULAR COURSES ====================

  static Future<List<Map<String, dynamic>>> getPopularCourses() async {
    try {
      final response = await Supabase.instance.client
          .from('courses')
          .select('''
          id,
          title,
          thumbnail_url,
          category_id,
          course_categories(id, name, slug),
          level,
          price,
          original_price,
          is_published,
          rating,
          total_lessons,
          duration_hours,
          enrollment_count,
          total_reviews,
          coaching_centers(center_name)
        ''')
          .eq('is_published', true)
          .eq('is_archived', false)
          .gte('rating', 4.0)
          .order('enrollment_count', ascending: false)
          .limit(8);

      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (e) {
      throw Exception('Failed to fetch popular courses: $e');
    }
  }

  // ==================== POPULAR LIVE CLASSES ====================

  static Future<List<Map<String, dynamic>>> getPopularLiveClasses() async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await Supabase.instance.client
          .from('live_classes')
          .select('''
            id,
            title,
            description,
            scheduled_start,
            scheduled_end,
            status,
            price,
            is_free,
            thumbnail_url,
            max_participants,
            current_participants,
            meeting_platform,
            primary_teacher_id,
            teachers!live_classes_primary_teacher_id_fkey(user_id,user_profiles(first_name, last_name, avatar_url)),
            coaching_centers(id, center_name, logo_url)
          ''')
          .inFilter('status', ['scheduled', 'live'])
          .gte('scheduled_start', now)
          .order('scheduled_start', ascending: true)
          .limit(8);

      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (e) {
      debugPrint('❌ Error fetching popular live classes: $e');
      throw Exception('Failed to fetch popular live classes: $e');
    }
  }

  // ==================== ENROLLED COURSES ====================

  static Future<List<Map<String, dynamic>>> getEnrolledCourses(
    String studentId,
  ) async {
    try {
      final response = await Supabase.instance.client
          .from('course_enrollments')
          .select('''
            id,
            progress_percentage,
            lessons_completed,
            total_lessons_in_course,
            last_accessed_at,
            courses(
              id,
              title,
              slug,
              thumbnail_url,
              short_description,
              level,
              duration_hours,
              total_lessons,
              coaching_centers(center_name)
            )
          ''')
          .eq('student_id', studentId)
          .eq('is_active', true)
          .order('last_accessed_at', ascending: false)
          .limit(6);

      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (e) {
      debugPrint('❌ Error fetching enrolled courses: $e');
      return [];
    }
  }

  // ==================== ENROLLED LIVE CLASSES ====================

  static Future<List<Map<String, dynamic>>> getEnrolledLiveClasses(
    String studentId,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await Supabase.instance.client
          .from('live_class_enrollments')
          .select('''
            id,
            status,
            enrolled_at,
            live_classes(
              id,
              title,
              description,
              scheduled_start,
              scheduled_end,
              status,
              thumbnail_url,
              meeting_platform,
              meeting_url,
              user_profiles!live_classes_primary_teacher_id_fkey(first_name, last_name),
              coaching_centers(center_name)
            )
          ''')
          .eq('student_id', studentId)
          .gte('live_classes.scheduled_start', now)
          .inFilter('live_classes.status', ['scheduled', 'live'])
          .order('live_classes.scheduled_start', ascending: true)
          .limit(5);

      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (e) {
      debugPrint('❌ Error fetching enrolled live classes: $e');
      return [];
    }
  }
}
