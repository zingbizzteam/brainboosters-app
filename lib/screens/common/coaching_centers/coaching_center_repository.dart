import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CoachingCenterRepository {
  static final SupabaseClient _client = Supabase.instance.client;

  static String? get currentUserId => _client.auth.currentUser?.id;

  // Get courses by coaching center
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
            category,
            subcategory
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

  // Get coaching centers with pagination - FIXED
  static Future<List<Map<String, dynamic>>> getCoachingCenters({
    int limit = 20,
    int offset = 0,
    String? sortBy,
    String? location,
    bool? isVerified,
  }) async {
    try {
      // Start with base query and apply filters FIRST
      var query = _client
          .from('coaching_centers')
          .select()
          .eq('approval_status', 'approved')
          .eq('is_active', true);

      // Apply sorting BEFORE select
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
        case 'newest':
          orderBy = 'created_at';
          ascending = false;
          break;
        default:
          orderBy = 'center_name';
          ascending = true;
      }

      // Now apply select, order, and range
      final response = await query
          .select('''
            id,
            center_name,
            center_code,
            description,
            logo_url,
            contact_email,
            contact_phone,
            address,
            approval_status,
            is_active,
            total_courses,
            total_students,
            created_at,
            user_profiles!coaching_centers_user_id_fkey(
              first_name,
              last_name,
              avatar_url
            )
          ''')
          .order(orderBy, ascending: ascending)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching coaching centers: $e');
      return [];
    }
  }

  // Get coaching centers near user - FIXED
  static Future<List<Map<String, dynamic>>> getNearbyCoachingCenters({
    int limit = 5,
  }) async {
    try {
      final response = await _client
          .from('coaching_centers')
          .select('''
            id,
            center_name,
            center_code,
            description,
            logo_url,
            contact_email,
            contact_phone,
            address,
            total_courses,
            total_students,
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

  // Get top coaching centers by student count - FIXED
  static Future<List<Map<String, dynamic>>> getTopCoachingCenters({
    int limit = 5,
  }) async {
    try {
      final response = await _client
          .from('coaching_centers')
          .select('''
            id,
            center_name,
            center_code,
            description,
            logo_url,
            contact_email,
            contact_phone,
            address,
            total_courses,
            total_students,
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

  // Get most loved centers - FIXED
  static Future<List<Map<String, dynamic>>> getMostLovedCoachingCenters({
    int limit = 5,
  }) async {
    try {
      final response = await _client
          .from('coaching_centers')
          .select('''
            id,
            center_name,
            center_code,
            description,
            logo_url,
            contact_email,
            contact_phone,
            address,
            total_courses,
            total_students,
            user_profiles!coaching_centers_user_id_fkey(
              first_name,
              last_name,
              avatar_url
            )
          ''')
          .eq('approval_status', 'approved')
          .eq('is_active', true)
          .order('total_courses', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching most loved coaching centers: $e');
      return [];
    }
  }

  // Get single coaching center by ID
  static Future<Map<String, dynamic>?> getCoachingCenterById(
    String centerId,
  ) async {
    try {
      final response = await _client
          .from('coaching_centers')
          .select('''
            id,
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
            created_at,
            user_profiles!coaching_centers_user_id_fkey(
              first_name,
              last_name,
              avatar_url,
              phone
            )
          ''')
          .eq('id', centerId)
          .eq('approval_status', 'approved')
          .eq('is_active', true)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error fetching coaching center: $e');
      return null;
    }
  }

  // Get total count for pagination - FIXED
  static Future<int> getCoachingCentersCount() async {
    try {
      final response = await _client
          .from('coaching_centers')
          .select('id')
          .eq('approval_status', 'approved')
          .eq('is_active', true);

      // For count, we need to get the length of the response
      final List<dynamic> data = response;
      return data.length;
    } catch (e) {
      debugPrint('Error getting coaching centers count: $e');
      return 0;
    }
  }

  // Alternative count method using RPC if you have it set up
  static Future<int> getCoachingCentersCountRPC() async {
    try {
      final response = await _client.rpc('get_coaching_centers_count');
      return response ?? 0;
    } catch (e) {
      debugPrint('Error getting coaching centers count via RPC: $e');
      return 0;
    }
  }
}
