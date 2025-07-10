// notifications_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:brainboosters_app/screens/Student/notifications/notification_model.dart';

class NotificationsRepository {
  static final _client = Supabase.instance.client;

  /// Get paginated notifications grouped by date
  static Future<NotificationResults> getNotifications({
    int limit = 20,
    int offset = 0,
    List<String>? types,
    List<String>? priorities,
    bool? isRead,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      var query = _client
          .from('notifications')
          .select('*')
          .eq('user_id', user.id);

      // Apply filters
      if (types != null && types.isNotEmpty) {
        query = query.inFilter('notification_type', types);
      }
      if (priorities != null && priorities.isNotEmpty) {
        query = query.inFilter('priority', priorities);
      }
      if (isRead != null) {
        query = query.eq('is_read', isRead);
      }
      if (fromDate != null) {
        query = query.gte('created_at', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('created_at', toDate.toIso8601String());
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1)
          .timeout(const Duration(seconds: 10));

      final notifications = List<Map<String, dynamic>>.from(
        response,
      ).map((data) => NotificationModel.fromJson(data)).toList();

      // Group by date on client side
      final groupedNotifications = _groupNotificationsByDate(notifications);

      return NotificationResults(
        groupedNotifications: groupedNotifications,
        hasMore: notifications.length == limit,
        totalFetched: offset + notifications.length,
      );
    } catch (e) {
      throw NotificationException('Failed to fetch notifications: $e');
    }
  }

  /// Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({
            'is_read': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);
    } catch (e) {
      throw NotificationException('Failed to mark notification as read: $e');
    }
  }

  /// Mark notification as unread - NEW FUNCTION
  static Future<void> markAsUnread(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({
            'is_read': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);
    } catch (e) {
      throw NotificationException('Failed to mark notification as unread: $e');
    }
  }

  /// Mark all notifications as read
  static Future<void> markAllAsRead() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client
          .from('notifications')
          .update({
            'is_read': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', user.id)
          .eq('is_read', false);
    } catch (e) {
      throw NotificationException(
        'Failed to mark all notifications as read: $e',
      );
    }
  }

  /// Get unread count
  static Future<int> getUnreadCount() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return 0;

      final response = await _client
          .from('notifications')
          .select('id')
          .eq('user_id', user.id)
          .eq('is_read', false);

      return List<Map<String, dynamic>>.from(response).length;
    } catch (e) {
      return 0;
    }
  }

  /// Group notifications by date
  static Map<String, List<NotificationModel>> _groupNotificationsByDate(
    List<NotificationModel> notifications,
  ) {
    final grouped = <String, List<NotificationModel>>{};
    final now = DateTime.now();

    for (final notification in notifications) {
      final createdAt = notification.createdAt;
      String dateKey;

      if (_isSameDay(createdAt, now)) {
        dateKey = 'Today';
      } else if (_isSameDay(createdAt, now.subtract(const Duration(days: 1)))) {
        dateKey = 'Yesterday';
      } else if (now.difference(createdAt).inDays < 7) {
        dateKey = _getDayName(createdAt.weekday);
      } else {
        dateKey = '${createdAt.day}/${createdAt.month}/${createdAt.year}';
      }

      grouped.putIfAbsent(dateKey, () => []).add(notification);
    }

    return grouped;
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }
}
