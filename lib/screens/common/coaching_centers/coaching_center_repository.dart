import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CoachingCenterRepository {
  static final SupabaseClient _client = Supabase.instance.client;
  static String? get currentUserId => _client.auth.currentUser?.id;

  // ✅ FIXED: Get courses by coaching center with proper schema
  static Future<List<Map<String, dynamic>>> getCoursesByCoachingCenter(
    String coachingCenterId, {
    int limit = 20,
    int offset = 0,
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
            category_id,
            course_categories(id, name, slug)
          ''')
          .eq('coaching_center_id', coachingCenterId)
          .eq('is_published', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching courses by coaching center: $e');
      return [];
    }
  }

  // ✅ FIXED: Get coaching centers with pagination
  static Future<List<Map<String, dynamic>>> getCoachingCenters({
    int limit = 20,
    int offset = 0,
    String? sortBy,
    String? location,
    bool? isVerified,
  }) async {
    try {
      var query = _client
          .from('coaching_centers')
          .select('''
            id,
            user_id,
            center_name,
            center_code,
            description,
            logo_url,
            contact_email,
            contact_phone,
            address,
            website_url,
            approval_status,
            is_active,
            total_courses,
            total_students,
            total_teachers,
            rating,
            total_reviews,
            created_at,
            user_profiles!coaching_centers_user_id_fkey(
              first_name,
              last_name,
              avatar_url
            )
          ''')
          .eq('approval_status', 'approved')
          .eq('is_active', true);

      // Apply sorting
      String orderBy;
      bool ascending;
      switch (sortBy) {
        case 'students':
          orderBy = 'total_students';
          ascending = false;
          break;
        case 'courses':
          orderBy = 'total_courses';
          ascending = false;
          break;
        case 'rating':
          orderBy = 'rating';
          ascending = false;
          break;
        case 'newest':
          orderBy = 'created_at';
          ascending = false;
          break;
        default:
          orderBy = 'center_name';
          ascending = true;
      }

      final response = await query
          .order(orderBy, ascending: ascending)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching coaching centers: $e');
      return [];
    }
  }

  // ✅ FIXED: Get nearby coaching centers
  static Future<List<Map<String, dynamic>>> getNearbyCoachingCenters({
    int limit = 5,
  }) async {
    try {
      final response = await _client
          .from('coaching_centers')
          .select('''
            id,
            user_id,
            center_name,
            center_code,
            description,
            logo_url,
            contact_email,
            contact_phone,
            address,
            website_url,
            total_courses,
            total_students,
            rating,
            total_reviews,
            user_profiles!coaching_centers_user_id_fkey(
              first_name,
              last_name,
              avatar_url
            )
          ''')
          .eq('approval_status', 'approved')
          .eq('is_active', true)
          .order('total_students', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching nearby coaching centers: $e');
      return [];
    }
  }

  // ✅ FIXED: Get top coaching centers by student count
  static Future<List<Map<String, dynamic>>> getTopCoachingCenters({
    int limit = 5,
  }) async {
    try {
      final response = await _client
          .from('coaching_centers')
          .select('''
            id,
            user_id,
            center_name,
            center_code,
            description,
            logo_url,
            contact_email,
            contact_phone,
            address,
            website_url,
            total_courses,
            total_students,
            rating,
            total_reviews,
            user_profiles!coaching_centers_user_id_fkey(
              first_name,
              last_name,
              avatar_url
            )
          ''')
          .eq('approval_status', 'approved')
          .eq('is_active', true)
          .order('total_students', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching top coaching centers: $e');
      return [];
    }
  }

  // ✅ FIXED: Get most loved centers (by rating and courses)
  static Future<List<Map<String, dynamic>>> getMostLovedCoachingCenters({
    int limit = 5,
  }) async {
    try {
      final response = await _client
          .from('coaching_centers')
          .select('''
            id,
            user_id,
            center_name,
            center_code,
            description,
            logo_url,
            contact_email,
            contact_phone,
            address,
            website_url,
            total_courses,
            total_students,
            rating,
            total_reviews,
            user_profiles!coaching_centers_user_id_fkey(
              first_name,
              last_name,
              avatar_url
            )
          ''')
          .eq('approval_status', 'approved')
          .eq('is_active', true)
          .order('rating', ascending: false)
          .order('total_reviews', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching most loved coaching centers: $e');
      return [];
    }
  }

  // ✅ FIXED: Get single coaching center by ID
  static Future<Map<String, dynamic>?> getCoachingCenterById(
    String centerId,
  ) async {
    try {
      final response = await _client
          .from('coaching_centers')
          .select('''
          id,
          user_id,
          center_name,
          center_code,
          description,
          website_url,
          logo_url,
          contact_email,
          contact_phone,
          address,
          registration_number,
          approval_status,
          subscription_plan,
          max_faculty_limit,
          max_courses_limit,
          is_active,
          total_courses,
          total_students,
          total_teachers,
          rating,
          total_reviews,
          created_at,
          user_profiles!coaching_centers_user_id_fkey(
            first_name,
            last_name,
            avatar_url,
            phone
          )
        ''')
          .eq('id', centerId) // Query by id
          .eq('approval_status', 'approved')
          .eq('is_active', true)
          .maybeSingle();

      debugPrint('🏢 Fetched center: ${response?['center_name']}');
      debugPrint('🏢 Center ID: ${response?['id']}');
      debugPrint('🏢 Center user_id: ${response?['user_id']}');

      return response;
    } catch (e) {
      debugPrint('Error fetching coaching center: $e');
      return null;
    }
  }

  // ✅ FIXED: Get coaching center by user_id
  static Future<Map<String, dynamic>?> getCoachingCenterByUserId(
    String userId,
  ) async {
    try {
      final response = await _client
          .from('coaching_centers')
          .select('''
            id,
            user_id,
            center_name,
            center_code,
            description,
            website_url,
            logo_url,
            contact_email,
            contact_phone,
            address,
            registration_number,
            approval_status,
            subscription_plan,
            max_faculty_limit,
            max_courses_limit,
            is_active,
            total_courses,
            total_students,
            total_teachers,
            rating,
            total_reviews,
            created_at
          ''')
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error fetching coaching center by user: $e');
      return null;
    }
  }

  // ✅ FIXED: Get total count for pagination (updated for new Supabase API)
  static Future<int> getCoachingCentersCount() async {
    try {
      // Use count with head: true to only get the count without data
      final response = await _client
          .from('coaching_centers')
          .select('id')
          .eq('approval_status', 'approved')
          .eq('is_active', true)
          .count(CountOption.exact);

      // The count is now returned directly as an integer
      return response.count;
    } catch (e) {
      debugPrint('Error getting coaching centers count: $e');
      return 0;
    }
  }

  // ✅ FIXED: Get coaching center statistics (updated API)
  static Future<Map<String, dynamic>?> getCoachingCenterStats(
    String centerId,
  ) async {
    try {
      // Get total enrollments count
      final enrollmentsResponse = await _client
          .from('course_enrollments')
          .select('id')
          .eq('coaching_center_id', centerId)
          .count(CountOption.exact);

      final totalEnrollments = enrollmentsResponse.count;

      // Get active courses count
      final coursesResponse = await _client
          .from('courses')
          .select('id')
          .eq('coaching_center_id', centerId)
          .eq('is_published', true)
          .count(CountOption.exact);

      final activeCourses = coursesResponse.count;

      return {
        'total_enrollments': totalEnrollments,
        'active_courses': activeCourses,
      };
    } catch (e) {
      debugPrint('Error fetching coaching center stats: $e');
      return null;
    }
  }
}
