// lib/screens/common/live_class/live_class_repository.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LiveClassRepository {
  static final SupabaseClient _client = Supabase.instance.client;
  static String? get currentUserId => _client.auth.currentUser?.id;

  // ✅ COMPLETELY FIXED: Get all live classes matching your actual schema
  static Future<List<Map<String, dynamic>>> getLiveClasses({
    String? status,
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      debugPrint('🔍 Fetching live classes with status: $status, limit: $limit');

      var query = _client.from('live_classes').select('''
        id,
        title,
        description,
        scheduled_start,
        scheduled_end,
        duration_minutes,
        max_participants,
        current_participants,
        meeting_url,
        meeting_id,
        meeting_password,
        meeting_platform,
        thumbnail_url,
        price,
        currency,
        is_free,
        status,
        course_id,
        primary_teacher_id,
        coaching_center_id,
        timezone,
        allow_chat,
        allow_qa,
        total_registered,
        coaching_centers!live_classes_coaching_center_id_fkey(
          id,
          user_id,
          center_name,
          logo_url
        ),
        teachers!live_classes_primary_teacher_id_fkey(
          id,
          user_id,
          user_profiles!teachers_user_id_fkey(
            first_name,
            last_name,
            avatar_url
          )
        ),
        courses(
          id,
          title,
          category_id,
          course_categories(id, name, slug)
        )
      ''');

      // Apply status filter
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      } else {
        // Default: Show scheduled and live classes
        query = query.inFilter('status', ['scheduled', 'live']);
      }

      // Apply ordering and pagination
      final response = await query
          .order('scheduled_start', ascending: true)
          .range(offset, offset + limit - 1);

      debugPrint('✅ Fetched ${response.length} live classes');

      final List<Map<String, dynamic>> liveClasses = 
          List<Map<String, dynamic>>.from(response);

      // If not authenticated, return all (public access logic can be added here)
      final userId = currentUserId;
      if (userId == null) {
        return liveClasses;
      }

      // Check enrollment for authenticated users
      try {
        final studentId = await _getStudentId(userId);
        
        // Get user's enrolled courses
        final enrolledCoursesResponse = await _client
            .from('course_enrollments')
            .select('course_id')
            .eq('student_id', studentId)
            .eq('is_active', true);

        final enrolledCourseIds = enrolledCoursesResponse
            .map((e) => e['course_id'] as String?)
            .where((id) => id != null)
            .cast<String>()
            .toSet();

        // Add enrollment status to each live class
        for (final liveClass in liveClasses) {
          final courseId = liveClass['course_id'] as String?;
          
          // Check if it's a free/public class or user is enrolled
          liveClass['can_access'] = 
              liveClass['is_free'] == true ||
              courseId == null ||
              enrolledCourseIds.contains(courseId);

          // Check if user is enrolled in this specific live class
          final liveClassEnrollment = await _client
              .from('live_class_enrollments')
              .select('id')
              .eq('student_id', studentId)
              .eq('live_class_id', liveClass['id'])
              .maybeSingle();

          liveClass['is_enrolled'] = liveClassEnrollment != null;
        }
      } catch (e) {
        debugPrint('⚠️ Could not check enrollment status: $e');
        // Continue without enrollment info
      }

      return liveClasses;
    } catch (e) {
      debugPrint('❌ Error fetching live classes: $e');
      return [];
    }
  }

  // ✅ FIXED: Get single live class by ID
  static Future<Map<String, dynamic>?> getLiveClassById(
    String liveClassId,
  ) async {
    try {
      final response = await _client
          .from('live_classes')
          .select('''
            id,
            title,
            description,
            scheduled_start,
            scheduled_end,
            duration_minutes,
            max_participants,
            current_participants,
            meeting_url,
            meeting_id,
            meeting_password,
            meeting_platform,
            thumbnail_url,
            price,
            currency,
            is_free,
            status,
            recording_url,
            allow_chat,
            allow_qa,
            allow_screen_sharing,
            course_id,
            primary_teacher_id,
            coaching_center_id,
            timezone,
            total_registered,
            total_attended,
            coaching_centers!live_classes_coaching_center_id_fkey(
              id,
              user_id,
              center_name,
              logo_url,
              contact_email,
              contact_phone
            ),
            teachers!live_classes_primary_teacher_id_fkey(
              id,
              user_id,
              specializations,
              bio,
              rating,
              total_reviews,
              user_profiles!teachers_user_id_fkey(
                first_name,
                last_name,
                avatar_url
              )
            ),
            courses(
              id,
              title,
              category_id,
              description,
              thumbnail_url,
              course_categories(id, name, slug)
            )
          ''')
          .eq('id', liveClassId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      // Check if user can access this live class
      final userId = currentUserId;
      if (userId != null) {
        try {
          final studentId = await _getStudentId(userId);
          final courseId = response['course_id'] as String?;

          // Check if user is enrolled in this specific live class
          final liveClassEnrollment = await _client
              .from('live_class_enrollments')
              .select('id, enrolled_at')
              .eq('student_id', studentId)
              .eq('live_class_id', liveClassId)
              .maybeSingle();

          response['is_enrolled'] = liveClassEnrollment != null;
          response['enrollment_date'] = liveClassEnrollment?['enrolled_at'];

          // Check course enrollment if live class is linked to a course
          if (courseId != null && courseId.isNotEmpty) {
            final enrollmentCheck = await _client
                .from('course_enrollments')
                .select('id')
                .eq('student_id', studentId)
                .eq('course_id', courseId)
                .eq('is_active', true)
                .maybeSingle();

            response['can_access'] = 
                response['is_free'] == true || enrollmentCheck != null;
          } else {
            response['can_access'] = true; // Public live class
          }
        } catch (e) {
          debugPrint('Could not check enrollment: $e');
          response['can_access'] = response['is_free'] == true;
        }
      }

      return response;
    } catch (e) {
      debugPrint('Error fetching live class: $e');
      return null;
    }
  }

  // Enroll in live class
  static Future<bool> enrollInLiveClass(String liveClassId) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      final studentId = await _getStudentId(userId);

      // Check if already enrolled
      final existingEnrollment = await _client
          .from('live_class_enrollments')
          .select('id')
          .eq('student_id', studentId)
          .eq('live_class_id', liveClassId)
          .maybeSingle();

      if (existingEnrollment != null) {
        debugPrint('Already enrolled in this live class');
        return true;
      }

      await _client.from('live_class_enrollments').insert({
        'student_id': studentId,
        'live_class_id': liveClassId,
        'enrolled_at': DateTime.now().toIso8601String(),
        'status': 'registered',
      });

      debugPrint('✅ Enrolled in live class successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error enrolling in live class: $e');
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
      return allLiveClasses.where((liveClass) {
        final course = liveClass['courses'];
        if (course != null) {
          final courseCategory = course['course_categories'];
          if (courseCategory != null) {
            return courseCategory['name']?.toString().toLowerCase() ==
                category.toLowerCase();
          }
        }
        return false;
      }).take(limit).toList();
    } catch (e) {
      debugPrint('Error fetching live classes by category: $e');
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
      debugPrint('Error fetching upcoming live classes: $e');
      return [];
    }
  }

  // Get enrolled live classes for current user
  static Future<List<Map<String, dynamic>>> getEnrolledLiveClasses() async {
    try {
      final userId = currentUserId;
      if (userId == null) return [];

      final studentId = await _getStudentId(userId);

      final enrollments = await _client
          .from('live_class_enrollments')
          .select('''
            live_class_id,
            enrolled_at,
            status,
            live_classes!inner(
              id,
              title,
              description,
              scheduled_start,
              scheduled_end,
              duration_minutes,
              meeting_url,
              thumbnail_url,
              status,
              coaching_centers(center_name, logo_url),
              teachers!live_classes_primary_teacher_id_fkey(
                user_profiles!teachers_user_id_fkey(first_name, last_name)
              )
            )
          ''')
          .eq('student_id', studentId)
          .order('enrolled_at', ascending: false);

      return List<Map<String, dynamic>>.from(enrollments)
          .map((e) => e['live_classes'] as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('Error fetching enrolled live classes: $e');
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
