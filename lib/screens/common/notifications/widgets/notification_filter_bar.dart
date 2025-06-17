// screens/common/notifications/widgets/notification_filter_bar.dart
import 'package:brainboosters_app/screens/common/notifications/models/notification_model.dart';
import 'package:flutter/material.dart';

class NotificationFilterBar extends StatelessWidget {
  final NotificationType? filterType;
  final bool showOnlyUnread;
  final int unreadCount;
  final ValueChanged<NotificationType?> onFilterChanged;
  final ValueChanged<bool> onUnreadToggled;

  const NotificationFilterBar({
    super.key,
    required this.filterType,
    required this.showOnlyUnread,
    required this.unreadCount,
    required this.onFilterChanged,
    required this.onUnreadToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unread toggle and count
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Switch(
                      value: showOnlyUnread,
                      onChanged: onUnreadToggled,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Unread only',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unreadCount unread',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Type filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', filterType == null, () => onFilterChanged(null)),
                const SizedBox(width: 8),
                ...NotificationType.values.map((type) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(
                    _getTypeDisplayName(type),
                    filterType == type,
                    () => onFilterChanged(type),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _getTypeDisplayName(NotificationType type) {
    switch (type) {
      case NotificationType.course:
        return 'Courses';
      case NotificationType.liveClass:
        return 'Live Classes';
      case NotificationType.system:
        return 'System';
      case NotificationType.payment:
        return 'Payments';
      case NotificationType.reminder:
        return 'Reminders';
      case NotificationType.achievement:
        return 'Achievements';
    }
  }
}
