// screens/common/notifications/widgets/notification_item.dart
import 'package:brainboosters_app/screens/common/notifications/models/notification_model.dart';
import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<bool> onSelectionChanged;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
              ? Colors.blue 
              : notification.isRead 
                ? Colors.grey[200]! 
                : Colors.blue.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selection checkbox or type icon
            if (isSelectionMode)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    if (value != null) {
                      onSelectionChanged(value);
                    }
                  },
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getTypeColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(),
                    color: _getTypeColor(),
                    size: 20,
                  ),
                ),
              ),
            
            // Notification content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        notification.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getTypeColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getTypeDisplayName(),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getTypeColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (notification.priority == NotificationPriority.high ||
                          notification.priority == NotificationPriority.urgent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: notification.priority == NotificationPriority.urgent
                              ? Colors.red
                              : Colors.orange,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            notification.priority == NotificationPriority.urgent
                              ? 'URGENT'
                              : 'HIGH',
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case NotificationType.course:
        return Colors.blue;
      case NotificationType.liveClass:
        return Colors.red;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.reminder:
        return Colors.orange;
      case NotificationType.achievement:
        return Colors.purple;
    }
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case NotificationType.course:
        return Icons.book;
      case NotificationType.liveClass:
        return Icons.live_tv;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.achievement:
        return Icons.emoji_events;
    }
  }

  String _getTypeDisplayName() {
    switch (notification.type) {
      case NotificationType.course:
        return 'Course';
      case NotificationType.liveClass:
        return 'Live Class';
      case NotificationType.system:
        return 'System';
      case NotificationType.payment:
        return 'Payment';
      case NotificationType.reminder:
        return 'Reminder';
      case NotificationType.achievement:
        return 'Achievement';
    }
  }
}
