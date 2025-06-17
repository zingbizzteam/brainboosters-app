// screens/common/notifications/notifications_page.dart
import 'package:brainboosters_app/screens/common/notifications/data/notification_dummy_data.dart';
import 'package:brainboosters_app/screens/common/notifications/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'widgets/notification_filter_bar.dart';
import 'widgets/notification_item.dart';
import 'widgets/notification_group_header.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationModel> _notifications = [];
  List<String> _selectedNotifications = [];
  bool _isSelectionMode = false;
  NotificationType? _filterType;
  bool _showOnlyUnread = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notifications = NotificationDummyData.getNotifications();
    });
  }

  List<NotificationModel> get _filteredNotifications {
    var filtered = _notifications;
    
    if (_filterType != null) {
      filtered = filtered.where((n) => n.type == _filterType).toList();
    }
    
    if (_showOnlyUnread) {
      filtered = filtered.where((n) => !n.isRead).toList();
    }
    
    return filtered;
  }

  Map<String, List<NotificationModel>> get _groupedNotifications {
    final Map<String, List<NotificationModel>> grouped = {};
    
    for (var notification in _filteredNotifications) {
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

  void _toggleSelection(String notificationId) {
    setState(() {
      if (_selectedNotifications.contains(notificationId)) {
        _selectedNotifications.remove(notificationId);
      } else {
        _selectedNotifications.add(notificationId);
      }
      
      if (_selectedNotifications.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _startSelectionMode(String notificationId) {
    setState(() {
      _isSelectionMode = true;
      _selectedNotifications = [notificationId];
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedNotifications.clear();
    });
  }

  void _selectAll() {
    setState(() {
      _selectedNotifications = _filteredNotifications.map((n) => n.id).toList();
    });
  }

  void _markAsRead(List<String> notificationIds) {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        if (notificationIds.contains(_notifications[i].id)) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
    });
    _exitSelectionMode();
  }

  void _markAsUnread(List<String> notificationIds) {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        if (notificationIds.contains(_notifications[i].id)) {
          _notifications[i] = _notifications[i].copyWith(isRead: false);
        }
      }
    });
    _exitSelectionMode();
  }

  void _deleteNotifications(List<String> notificationIds) {
    setState(() {
      _notifications.removeWhere((n) => notificationIds.contains(n.id));
    });
    _exitSelectionMode();
  }

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _isSelectionMode 
            ? '${_selectedNotifications.length} selected'
            : 'Notifications',
          style: const TextStyle(color: Colors.black),
        ),
        leading: _isSelectionMode
          ? IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: _exitSelectionMode,
            )
          : null,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.select_all, color: Colors.black),
              onPressed: _selectAll,
              tooltip: 'Select All',
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onSelected: (value) {
                switch (value) {
                  case 'mark_read':
                    _markAsRead(_selectedNotifications);
                    break;
                  case 'mark_unread':
                    _markAsUnread(_selectedNotifications);
                    break;
                  case 'delete':
                    _showDeleteConfirmation();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_read',
                  child: Row(
                    children: [
                      Icon(Icons.mark_email_read, size: 20),
                      SizedBox(width: 12),
                      Text('Mark as Read'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'mark_unread',
                  child: Row(
                    children: [
                      Icon(Icons.mark_email_unread, size: 20),
                      SizedBox(width: 12),
                      Text('Mark as Unread'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            if (unreadCount > 0)
              TextButton(
                onPressed: _markAllAsRead,
                child: const Text('Mark all read'),
              ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.black),
              onPressed: () => _showFilterOptions(),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          NotificationFilterBar(
            filterType: _filterType,
            showOnlyUnread: _showOnlyUnread,
            unreadCount: unreadCount,
            onFilterChanged: (type) {
              setState(() {
                _filterType = type;
              });
            },
            onUnreadToggled: (value) {
              setState(() {
                _showOnlyUnread = value;
              });
            },
          ),
          
          // Notifications List
          Expanded(
            child: _filteredNotifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 0 : 16,
                  ),
                  itemCount: _buildNotificationItems().length,
                  itemBuilder: (context, index) {
                    return _buildNotificationItems()[index];
                  },
                ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNotificationItems() {
    final List<Widget> items = [];
    final groupedNotifications = _groupedNotifications;
    
    // Define the order of groups
    const groupOrder = ['Today', 'Yesterday', 'This Week', 'This Month', 'Older'];
    
    for (String groupKey in groupOrder) {
      if (groupedNotifications.containsKey(groupKey)) {
        final notifications = groupedNotifications[groupKey]!;
        
        // Add group header
        items.add(NotificationGroupHeader(
          title: groupKey,
          count: notifications.length,
        ));
        
        // Add notifications in this group
        for (var notification in notifications) {
          items.add(NotificationItem(
            notification: notification,
            isSelected: _selectedNotifications.contains(notification.id),
            isSelectionMode: _isSelectionMode,
            onTap: () => _handleNotificationTap(notification),
            onLongPress: () => _startSelectionMode(notification.id),
            onSelectionChanged: (selected) => _toggleSelection(notification.id),
          ));
        }
      }
    }
    
    return items;
  }

  void _handleNotificationTap(NotificationModel notification) {
    if (_isSelectionMode) {
      _toggleSelection(notification.id);
    } else {
      // Mark as read if not already read
      if (!notification.isRead) {
        _markAsRead([notification.id]);
      }
      
      // Handle navigation if actionUrl exists
      if (notification.actionUrl != null) {
        // Navigate to the specified URL
        // context.push(notification.actionUrl!);
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _showOnlyUnread ? 'No unread notifications' : 'No notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showOnlyUnread 
              ? 'All caught up! You have no unread notifications.'
              : 'You\'ll see notifications here when you receive them.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Filter by type
              const Text(
                'Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _filterType == null,
                    onSelected: (selected) {
                      setState(() {
                        _filterType = null;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ...NotificationType.values.map((type) => FilterChip(
                    label: Text(_getTypeDisplayName(type)),
                    selected: _filterType == type,
                    onSelected: (selected) {
                      setState(() {
                        _filterType = selected ? type : null;
                      });
                      Navigator.pop(context);
                    },
                  )),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Show only unread toggle
              SwitchListTile(
                title: const Text('Show only unread'),
                value: _showOnlyUnread,
                onChanged: (value) {
                  setState(() {
                    _showOnlyUnread = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notifications'),
        content: Text(
          'Are you sure you want to delete ${_selectedNotifications.length} notification(s)? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNotifications(_selectedNotifications);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
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
