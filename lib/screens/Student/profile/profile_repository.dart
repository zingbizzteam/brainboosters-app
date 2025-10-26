// lib/repositories/profile_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class ProfileRepository {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // FIXED: Return non-null default objects instead of null
  static Future<Map<String, dynamic>> getCurrentUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return _getDefaultUserProfile();
      }

      final response = await _supabase
          .from('user_profiles')
          .select('''
            *,
            students(
              id, student_id, grade_level, school_name,
              total_courses_enrolled, total_courses_completed,
              total_hours_learned, current_streak_days,
              longest_streak_days, total_points, level, badges
            )
          ''')
          .eq('id', user.id)
          .single();

      // Validate response and provide defaults for missing fields
      return _validateAndCleanUserProfile(response);
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return _getDefaultUserProfile();
    }
  }

  // FIXED: Always return valid data structure
  static Future<Map<String, dynamic>> generateAnalyticsReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final studentId = await _getStudentId();
      if (studentId == null) {
        return _getDefaultAnalyticsReport();
      }

      final results = await Future.wait([
        getLearningAnalytics(startDate: startDate, endDate: endDate),
        getCourseProgressAnalytics(),
        getTestPerformanceAnalytics(startDate: startDate, endDate: endDate),
      ]);

      final learningData = results[0];
      final courseData = results[1];
      final testData = results[2];

      // Calculate summary statistics with null safety
      final totalTimeSpent = learningData.fold<int>(
        0,
        (sum, item) => sum + ((item['time_spent_minutes'] as int?) ?? 0),
      );
      final totalLessonsCompleted = learningData.fold<int>(
        0,
        (sum, item) => sum + ((item['lessons_completed'] as int?) ?? 0),
      );
      final averageQuizScore = testData.isNotEmpty
          ? testData.fold<double>(
                  0,
                  (sum, item) => sum + ((item['percentage'] as double?) ?? 0),
                ) /
                testData.length
          : 0.0;
      final coursesInProgress = courseData
          .where(
            (course) => ((course['progress_percentage'] as double?) ?? 0) < 100,
          )
          .length;
      final coursesCompleted = courseData
          .where((course) => course['completed_at'] != null)
          .length;

      return {
        'summary': {
          'total_time_spent_minutes': totalTimeSpent,
          'total_lessons_completed': totalLessonsCompleted,
          'average_quiz_score': averageQuizScore,
          'courses_in_progress': coursesInProgress,
          'courses_completed': coursesCompleted,
          'total_courses_enrolled': courseData.length,
        },
        'learning_analytics': learningData,
        'course_progress': courseData,
        'test_performance': testData,
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error generating analytics report: $e');
      return _getDefaultAnalyticsReport();
    }
  }

  // FIXED: Safe data access methods
  static Future<List<Map<String, dynamic>>> getLearningAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? courseId,
  }) async {
    try {
      final studentId = await _getStudentId();
      if (studentId == null) return [];

      var query = _supabase
          .from('learning_analytics')
          .select('''
            *,
            courses(id, title, thumbnail_url)
          ''')
          .eq('student_id', studentId);

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String().split('T')[0]);
      }

      if (courseId != null) {
        query = query.eq('course_id', courseId);
      }

      final response = await query.order('date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching learning analytics: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getCourseProgressAnalytics() async {
    try {
      final studentId = await _getStudentId();
      if (studentId == null) return [];

      final response = await _supabase
          .from('course_enrollments')
          .select('''
            *,
            courses(
              id, title, thumbnail_url, category_id,
  course_categories(id, name, slug),
  total_lessons, duration_hours
            )
          ''')
          .eq('student_id', studentId)
          .eq('is_active', true)
          .order('enrolled_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching course progress: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getTestPerformanceAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final studentId = await _getStudentId();
      if (studentId == null) return [];

      var query = _supabase
          .from('test_results')
          .select('''
            *,
            tests(
              id, title, test_type, total_marks,
              courses(id, title)
            )
          ''')
          .eq('student_id', studentId);

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching test performance: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getCertificates() async {
    try {
      final studentId = await _getStudentId();
      if (studentId == null) return [];

      final enrollments = await _supabase
          .from('course_enrollments')
          .select('''
            completion_certificate_url,
            completed_at,
            course_id,
            courses!inner(id, title, thumbnail_url, teacher_id)
          ''')
          .eq('student_id', studentId)
          .not('completion_certificate_url', 'is', null)
          .not('completed_at', 'is', null)
          .order('completed_at', ascending: false);

      final certificates = <Map<String, dynamic>>[];
      for (final enrollment in enrollments) {
        final course = enrollment['courses'] as Map<String, dynamic>?;
        final teacherId = course?['teacher_id'];

        Map<String, dynamic>? teacherProfile;
        if (teacherId != null) {
          try {
            teacherProfile = await _supabase
                .from('user_profiles')
                .select('first_name, last_name')
                .eq('id', teacherId)
                .single();
          } catch (e) {
            debugPrint('Error fetching teacher profile: $e');
            teacherProfile = {'first_name': 'Unknown', 'last_name': 'Teacher'};
          }
        }

        certificates.add({
          ...enrollment,
          'teacher_profile':
              teacherProfile ??
              {'first_name': 'Unknown', 'last_name': 'Teacher'},
        });
      }

      return certificates;
    } catch (e) {
      debugPrint('Error fetching certificates: $e');
      return [];
    }
  }

  static Future<bool> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase
          .from('user_profiles')
          .update(profileData)
          .eq('id', user.id);

      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  static Future<String?> _getStudentId() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('students')
          .select('id')
          .eq('user_id', user.id)
          .single();

      return response['id'];
    } catch (e) {
      debugPrint('Error getting student ID: $e');
      return null;
    }
  }

  // FIXED: Default data providers to prevent null errors
  static Map<String, dynamic> _getDefaultUserProfile() {
    return {
      'id': '',
      'first_name': 'Guest',
      'last_name': 'User',
      'email': '',
      'phone': '',
      'gender': null,
      'avatar_url': null,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'students': {
        'id': '',
        'student_id': '',
        'grade_level': '1',
        'school_name': '',
        'total_courses_enrolled': 0,
        'total_courses_completed': 0,
        'total_hours_learned': 0,
        'current_streak_days': 0,
        'longest_streak_days': 0,
        'total_points': 0,
        'level': 1,
        'badges': [],
      },
    };
  }

  static Map<String, dynamic> _getDefaultAnalyticsReport() {
    return {
      'summary': {
        'total_time_spent_minutes': 0,
        'total_lessons_completed': 0,
        'average_quiz_score': 0.0,
        'courses_in_progress': 0,
        'courses_completed': 0,
        'total_courses_enrolled': 0,
      },
      'learning_analytics': <Map<String, dynamic>>[],
      'course_progress': <Map<String, dynamic>>[],
      'test_performance': <Map<String, dynamic>>[],
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> _validateAndCleanUserProfile(
    Map<String, dynamic> profile,
  ) {
    // Ensure all required fields exist with defaults
    final cleanProfile = Map<String, dynamic>.from(_getDefaultUserProfile());

    // Merge with actual data, keeping defaults for missing fields
    cleanProfile.addAll(profile);

    // Validate nested student data
    if (profile['students'] != null) {
      final studentDefaults =
          _getDefaultUserProfile()['students'] as Map<String, dynamic>;
      final studentData = Map<String, dynamic>.from(studentDefaults);
      studentData.addAll(profile['students'] as Map<String, dynamic>);
      cleanProfile['students'] = studentData;
    }

    return cleanProfile;
  }
}
