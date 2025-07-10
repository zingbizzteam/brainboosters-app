// notification_model.dart
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final String? referenceId;
  final String? referenceType;
  final bool isRead;
  final NotificationPriority priority;
  final DateTime scheduledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.referenceId,
    this.referenceType,
    required this.isRead,
    required this.priority,
    required this.scheduledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.fromString(json['notification_type']),
      referenceId: json['reference_id'],
      referenceType: json['reference_type'],
      isRead: json['is_read'] ?? false,
      priority: NotificationPriority.fromString(json['priority']),
      scheduledAt: DateTime.parse(json['scheduled_at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

}

enum NotificationType {
  courseUpdate,
  liveClassReminder,
  assignmentDue,
  enrollment,
  paymentSuccess,
  certificateIssued,
  reviewReceived,
  systemUpdate;

  static NotificationType fromString(String value) {
    switch (value) {
      case 'course_update':
        return NotificationType.courseUpdate;
      case 'live_class_reminder':
        return NotificationType.liveClassReminder;
      case 'assignment_due':
        return NotificationType.assignmentDue;
      case 'enrollment':
        return NotificationType.enrollment;
      case 'payment_success':
        return NotificationType.paymentSuccess;
      case 'certificate_issued':
        return NotificationType.certificateIssued;
      case 'review_received':
        return NotificationType.reviewReceived;
      case 'system_update':
        return NotificationType.systemUpdate;
      default:
        return NotificationType.systemUpdate;
    }
  }

  String get displayName {
    switch (this) {
      case NotificationType.courseUpdate:
        return 'Course Update';
      case NotificationType.liveClassReminder:
        return 'Live Class';
      case NotificationType.assignmentDue:
        return 'Assignment';
      case NotificationType.enrollment:
        return 'Enrollment';
      case NotificationType.paymentSuccess:
        return 'Payment';
      case NotificationType.certificateIssued:
        return 'Certificate';
      case NotificationType.reviewReceived:
        return 'Review';
      case NotificationType.systemUpdate:
        return 'System';
    }
  }

  String get dbValue {
    switch (this) {
      case NotificationType.courseUpdate:
        return 'course_update';
      case NotificationType.liveClassReminder:
        return 'live_class_reminder';
      case NotificationType.assignmentDue:
        return 'assignment_due';
      case NotificationType.enrollment:
        return 'enrollment';
      case NotificationType.paymentSuccess:
        return 'payment_success';
      case NotificationType.certificateIssued:
        return 'certificate_issued';
      case NotificationType.reviewReceived:
        return 'review_received';
      case NotificationType.systemUpdate:
        return 'system_update';
    }
  }
}

enum NotificationPriority {
  low,
  medium,
  high;

  static NotificationPriority fromString(String value) {
    switch (value) {
      case 'low':
        return NotificationPriority.low;
      case 'medium':
        return NotificationPriority.medium;
      case 'high':
        return NotificationPriority.high;
      default:
        return NotificationPriority.medium;
    }
  }

  String get displayName {
    switch (this) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.medium:
        return 'Medium';
      case NotificationPriority.high:
        return 'High';
    }
  }
}

class NotificationResults {
  final Map<String, List<NotificationModel>> groupedNotifications;
  final bool hasMore;
  final int totalFetched;

  NotificationResults({
    required this.groupedNotifications,
    required this.hasMore,
    required this.totalFetched,
  });
}

class NotificationFilters {
  final List<NotificationType> types;
  final List<NotificationPriority> priorities;
  final bool? isRead;
  final DateTime? fromDate;
  final DateTime? toDate;

  NotificationFilters({
    this.types = const [],
    this.priorities = const [],
    this.isRead,
    this.fromDate,
    this.toDate,
  });

  NotificationFilters copyWith({
    List<NotificationType>? types,
    List<NotificationPriority>? priorities,
    bool? isRead,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return NotificationFilters(
      types: types ?? this.types,
      priorities: priorities ?? this.priorities,
      isRead: isRead ?? this.isRead,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
}

class NotificationException implements Exception {
  final String message;
  NotificationException(this.message);
  
  @override
  String toString() => 'NotificationException: $message';
}
