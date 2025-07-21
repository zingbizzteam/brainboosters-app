// notification_card.dart
import 'package:flutter/material.dart';
import 'package:brainboosters_app/screens/student/notifications/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;
  final VoidCallback onMarkAsUnread;
  final VoidCallback? onDismiss; // NEW: Add dismiss callback

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onMarkAsRead,
    required this.onMarkAsUnread,
    this.onDismiss, // NEW: Optional dismiss callback
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: notification.isRead
            ? Colors.orange.shade100
            : Colors.green.shade100,
        child: Icon(
          notification.isRead ? Icons.mark_email_unread : Icons.mark_email_read,
          color: notification.isRead ? Colors.orange : Colors.green,
          size: 24,
        ),
      ),
      confirmDismiss: (direction) async {
        // NEW: Add confirmation and handle the action immediately
        if (notification.isRead) {
          onMarkAsUnread();
        } else {
          onMarkAsRead();
        }

        // Return false to prevent actual dismissal from the tree
        // since we're just marking as read/unread, not removing the notification
        return false;
      },
      onDismissed: (direction) {
        // This should only be called if we actually want to remove the item
        // Since we return false in confirmDismiss, this won't be called
        onDismiss?.call();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        color: notification.isRead ? Colors.white : Colors.blue.shade50,
        child: InkWell(
          onTap: () {
            onTap();
            if (!notification.isRead) {
              onMarkAsRead();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 4),
                      _buildMessage(),
                      const SizedBox(height: 8),
                      _buildFooter(),
                    ],
                  ),
                ),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.courseUpdate:
        icon = Icons.school;
        color = Colors.blue;
        break;
      case NotificationType.liveClassReminder:
        icon = Icons.live_tv;
        color = Colors.red;
        break;
      case NotificationType.assignmentDue:
        icon = Icons.assignment;
        color = Colors.orange;
        break;
      case NotificationType.enrollment:
        icon = Icons.person_add;
        color = Colors.green;
        break;
      case NotificationType.paymentSuccess:
        icon = Icons.payment;
        color = Colors.green;
        break;
      case NotificationType.certificateIssued:
        icon = Icons.card_membership;
        color = Colors.purple;
        break;
      case NotificationType.reviewReceived:
        icon = Icons.star;
        color = Colors.amber;
        break;
      case NotificationType.systemUpdate:
        icon = Icons.system_update;
        color = Colors.grey;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            notification.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: notification.isRead
                  ? FontWeight.w500
                  : FontWeight.w600,
              color: Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!notification.isRead)
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF4AA0E6),
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  Widget _buildMessage() {
    return Text(
      notification.message,
      style: TextStyle(
        fontSize: 14,
        color: notification.isRead
            ? Colors.grey.shade600
            : Colors.grey.shade700,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getTypeColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            notification.type.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getTypeColor(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (notification.priority == NotificationPriority.high)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'High Priority',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ),
        const Spacer(),
        Text(
          _formatTime(notification.createdAt),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return PopupMenuButton(
      onSelected: (value) {
        switch (value) {
          case 'mark_read':
            onMarkAsRead();
            break;
          case 'mark_unread':
            onMarkAsUnread();
            break;
        }
      },
      itemBuilder: (context) => [
        if (!notification.isRead)
          const PopupMenuItem(
            value: 'mark_read',
            child: Row(
              children: [
                Icon(Icons.mark_email_read, size: 18, color: Colors.green),
                SizedBox(width: 8),
                Text('Mark as read'),
              ],
            ),
          ),
        if (notification.isRead)
          const PopupMenuItem(
            value: 'mark_unread',
            child: Row(
              children: [
                Icon(Icons.mark_email_unread, size: 18, color: Colors.orange),
                SizedBox(width: 8),
                Text('Mark as unread'),
              ],
            ),
          ),
      ],
      child: Icon(Icons.more_vert, color: Colors.grey.shade400, size: 20),
    );
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case NotificationType.courseUpdate:
        return Colors.blue;
      case NotificationType.liveClassReminder:
        return Colors.red;
      case NotificationType.assignmentDue:
        return Colors.orange;
      case NotificationType.enrollment:
        return Colors.green;
      case NotificationType.paymentSuccess:
        return Colors.green;
      case NotificationType.certificateIssued:
        return Colors.purple;
      case NotificationType.reviewReceived:
        return Colors.amber;
      case NotificationType.systemUpdate:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365 && dateTime.year == now.year) {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dateTime.month - 1]} ${dateTime.day}';
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    }
  }
}
