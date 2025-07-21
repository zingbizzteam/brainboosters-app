// screens/student/dashboard/dashboard_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardRepository {
  static Future<List<Map<String, dynamic>>> getPopularCourses() async {
    try {
      final response = await Supabase.instance.client
          .from('courses')
          .select('''
            id,
            title,
            thumbnail_url,
            category,
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
          .gte('rating', 4.0)
          .order('enrollment_count', ascending: false)
          .limit(8);

      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (e) {
      throw Exception('Failed to fetch popular courses: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getPopularLiveClasses() async {
    try {
      final response = await Supabase.instance.client
          .from('live_classes')
          .select('''
            id,
            title,
            description,
            scheduled_at,
            status,
            price,
            is_free,
            thumbnail_url,
            duration_minutes,
            max_participants,
            current_participants,
            teachers(
              user_id,
              user_profiles(first_name, last_name)
            ),
            coaching_centers(center_name)
          ''')
          .inFilter('status', ['scheduled', 'live'])
          .order('scheduled_at', ascending: true)
          .limit(8);

      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (e) {
      throw Exception('Failed to fetch popular live classes: $e');
    }
  }
}
