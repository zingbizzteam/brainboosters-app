// data/notification_dummy_data.dart
import '../models/notification_model.dart';

class NotificationDummyData {
  static final List<NotificationModel> notifications = [
    // Today's notifications
    NotificationModel(
      id: 'n001',
      title: 'New Course Available',
      message: 'The Complete Python Course: From Zero to Hero is now available for enrollment!',
      type: NotificationType.course,
      priority: NotificationPriority.medium,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
      actionUrl: '/courses/c001',
      imageUrl: 'https://picsum.photos/100/100?random=201',
    ),
    NotificationModel(
      id: 'n002',
      title: 'Live Class Starting Soon',
      message: 'Your Python Bootcamp live class starts in 15 minutes. Join now!',
      type: NotificationType.liveClass,
      priority: NotificationPriority.high,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      actionUrl: '/live-classes/lc001',
      imageUrl: 'https://picsum.photos/100/100?random=202',
    ),
    NotificationModel(
      id: 'n003',
      title: 'Payment Successful',
      message: 'Your payment of ₹2999 for "Data Science Course" has been processed successfully.',
      type: NotificationType.payment,
      priority: NotificationPriority.medium,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
      imageUrl: 'https://picsum.photos/100/100?random=203',
    ),
    NotificationModel(
      id: 'n004',
      title: 'Achievement Unlocked!',
      message: 'Congratulations! You\'ve completed 5 courses. Keep up the great work!',
      type: NotificationType.achievement,
      priority: NotificationPriority.low,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
      imageUrl: 'https://picsum.photos/100/100?random=204',
    ),

    // Yesterday's notifications
    NotificationModel(
      id: 'n005',
      title: 'Course Reminder',
      message: 'Don\'t forget to complete Module 3 of your AI course. You\'re almost there!',
      type: NotificationType.reminder,
      priority: NotificationPriority.medium,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isRead: true,
      actionUrl: '/courses/c002',
      imageUrl: 'https://picsum.photos/100/100?random=205',
    ),
    NotificationModel(
      id: 'n006',
      title: 'System Maintenance',
      message: 'Scheduled maintenance will occur tonight from 2 AM to 4 AM IST.',
      type: NotificationType.system,
      priority: NotificationPriority.high,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      isRead: true,
      imageUrl: 'https://picsum.photos/100/100?random=206',
    ),

    // This week's notifications
    NotificationModel(
      id: 'n007',
      title: 'New Instructor Joined',
      message: 'Dr. Sarah Johnson, AI expert, has joined our platform. Check out her courses!',
      type: NotificationType.system,
      priority: NotificationPriority.low,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isRead: false,
      imageUrl: 'https://picsum.photos/100/100?random=207',
    ),
    NotificationModel(
      id: 'n008',
      title: 'Course Completion',
      message: 'You\'ve successfully completed "Web Development Fundamentals". Download your certificate!',
      type: NotificationType.achievement,
      priority: NotificationPriority.medium,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      isRead: true,
      actionUrl: '/certificates/cert001',
      imageUrl: 'https://picsum.photos/100/100?random=208',
    ),
    NotificationModel(
      id: 'n009',
      title: 'Live Class Recorded',
      message: 'The recording of yesterday\'s Python session is now available in your dashboard.',
      type: NotificationType.liveClass,
      priority: NotificationPriority.low,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      isRead: false,
      actionUrl: '/recordings/rec001',
      imageUrl: 'https://picsum.photos/100/100?random=209',
    ),

    // This month's notifications
    NotificationModel(
      id: 'n010',
      title: 'Special Discount',
      message: 'Get 50% off on all courses this weekend! Limited time offer.',
      type: NotificationType.system,
      priority: NotificationPriority.urgent,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      isRead: true,
      imageUrl: 'https://picsum.photos/100/100?random=210',
    ),
    NotificationModel(
      id: 'n011',
      title: 'Profile Updated',
      message: 'Your profile information has been successfully updated.',
      type: NotificationType.system,
      priority: NotificationPriority.low,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      isRead: true,
      imageUrl: 'https://picsum.photos/100/100?random=211',
    ),

    // Older notifications
    NotificationModel(
      id: 'n012',
      title: 'Welcome to Brain Boosters!',
      message: 'Thank you for joining Brain Boosters. Start your learning journey today!',
      type: NotificationType.system,
      priority: NotificationPriority.medium,
      createdAt: DateTime.now().subtract(const Duration(days: 35)),
      isRead: true,
      imageUrl: 'https://picsum.photos/100/100?random=212',
    ),
  ];

  static List<NotificationModel> getNotifications() {
    return List.from(notifications);
  }

  static List<NotificationModel> getUnreadNotifications() {
    return notifications.where((n) => !n.isRead).toList();
  }

  static List<NotificationModel> getNotificationsByType(NotificationType type) {
    return notifications.where((n) => n.type == type).toList();
  }

  static Map<String, List<NotificationModel>> getGroupedNotifications() {
    final Map<String, List<NotificationModel>> grouped = {};
    
    for (var notification in notifications) {
      final key = notification.groupKey;
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(notification);
    }
    
    // Sort each group by creation time (newest first)
    grouped.forEach((key, value) {
      value.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
    
    return grouped;
  }
}
