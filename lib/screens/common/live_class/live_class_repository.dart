// lib/screens/common/live_class/live_class_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class LiveClassRepository {
  static final SupabaseClient _client = Supabase.instance.client;

  static String? get currentUserId => _client.auth.currentUser?.id;

  // Get all live classes with enrollment filtering
  static Future<List<Map<String, dynamic>>> getLiveClasses({
    String? status,
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final userId = currentUserId;

      var query = _client.from('live_classes').select('''
            id,
            title,
            description,
            scheduled_at,
            duration_minutes,
            max_participants,
            current_participants,
            meeting_url,
            thumbnail_url,
            price,
            currency,
            is_free,
            status,
            course_id,
            coaching_centers(
              id,
              center_name,
              logo_url
            ),
            teachers(
              id,
              user_profiles(
                first_name,
                last_name,
                avatar_url
              )
            ),
            courses(
              id,
              title,
              category,
              subcategory
            )
          ''');

      // Apply status filter
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      // Apply ordering and pagination after filtering
      final response = await query
          .order('scheduled_at', ascending: false)
          .range(offset, offset + limit - 1);

      if (userId == null) {
        // Not authenticated - only show public live classes
        return response
            .where(
              (liveClass) =>
                  liveClass['course_id'] == null ||
                  liveClass['is_free'] == true,
            )
            .toList();
      }

      // Get user's enrolled courses
      final enrolledCoursesResponse = await _client
          .from('course_enrollments')
          .select('course_id')
          .eq('student_id', await _getStudentId(userId))
          .eq('is_active', true);

      final enrolledCourseIds = enrolledCoursesResponse
          .map((e) => e['course_id'] as String)
          .toSet();

      // Filter live classes based on enrollment
      final filteredLiveClasses = response.where((liveClass) {
        final courseId = liveClass['course_id'] as String?;

        // Public live classes (no course_id or null)
        if (courseId == null || courseId.isEmpty) {
          return true;
        }

        // Course-linked live classes - only if user is enrolled
        return enrolledCourseIds.contains(courseId);
      }).toList();

      return filteredLiveClasses;
    } catch (e) {
      print('Error fetching live classes: $e');
      return [];
    }
  }

  // Get single live class by ID
  static Future<Map<String, dynamic>?> getLiveClassById(
    String liveClassId,
  ) async {
    try {
      final userId = currentUserId;

      final response = await _client
          .from('live_classes')
          .select('''
            id,
            title,
            description,
            scheduled_at,
            duration_minutes,
            max_participants,
            current_participants,
            meeting_url,
            meeting_id,
            meeting_password,
            thumbnail_url,
            price,
            currency,
            is_free,
            status,
            recording_url,
            chat_enabled,
            q_and_a_enabled,
            course_id,
            coaching_centers(
              id,
              center_name,
              logo_url,
              contact_email,
              contact_phone
            ),
            teachers(
              id,
              specializations,
              bio,
              rating,
              total_reviews,
              user_profiles(
                first_name,
                last_name,
                avatar_url
              )
            ),
            courses(
              id,
              title,
              category,
              subcategory,
              description,
              thumbnail_url
            )
          ''')
          .eq('id', liveClassId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      // Check if user can access this live class
      final courseId = response['course_id'] as String?;

      if (courseId != null && courseId.isNotEmpty && userId != null) {
        // Check if user is enrolled in the course
        final studentId = await _getStudentId(userId);
        final enrollmentCheck = await _client
            .from('course_enrollments')
            .select('id')
            .eq('student_id', studentId)
            .eq('course_id', courseId)
            .eq('is_active', true)
            .maybeSingle();

        if (enrollmentCheck == null) {
          return null; // User not enrolled, can't access
        }
      }

      // Check if user is already enrolled in this live class
      if (userId != null) {
        final studentId = await _getStudentId(userId);
        final liveClassEnrollment = await _client
            .from('live_class_enrollments')
            .select('id, enrolled_at')
            .eq('student_id', studentId)
            .eq('live_class_id', liveClassId)
            .maybeSingle();

        response['is_enrolled'] = liveClassEnrollment != null;
        response['enrollment_date'] = liveClassEnrollment?['enrolled_at'];
      }

      return response;
    } catch (e) {
      print('Error fetching live class: $e');
      return null;
    }
  }

  // Enroll in live class
  static Future<bool> enrollInLiveClass(String liveClassId) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      final studentId = await _getStudentId(userId);

      await _client.from('live_class_enrollments').insert({
        'student_id': studentId,
        'live_class_id': liveClassId,
        'enrolled_at': DateTime.now().toIso8601String(),
      });

      // Update current participants count
      await _client.rpc(
        'increment_live_class_participants',
        params: {'live_class_id': liveClassId},
      );

      return true;
    } catch (e) {
      print('Error enrolling in live class: $e');
      return false;
    }
  }

  // Get live classes by category
  static Future<List<Map<String, dynamic>>> getLiveClassesByCategory(
    String category, {
    int limit = 8,
  }) async {
    try {
      final allLiveClasses = await getLiveClasses(limit: limit * 2);

      return allLiveClasses
          .where((liveClass) {
            final course = liveClass['courses'];
            if (course != null) {
              return course['category']?.toString().toLowerCase() ==
                  category.toLowerCase();
            }
            return false;
          })
          .take(limit)
          .toList();
    } catch (e) {
      print('Error fetching live classes by category: $e');
      return [];
    }
  }

  // Get upcoming live classes
  static Future<List<Map<String, dynamic>>> getUpcomingLiveClasses({
    int limit = 8,
  }) async {
    try {
      return await getLiveClasses(status: 'scheduled', limit: limit);
    } catch (e) {
      print('Error fetching upcoming live classes: $e');
      return [];
    }
  }

  // Helper method to get student ID
  static Future<String> _getStudentId(String userId) async {
    final response = await _client
        .from('students')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) {
      throw Exception('Student record not found');
    }

    return response['id'];
  }
}
