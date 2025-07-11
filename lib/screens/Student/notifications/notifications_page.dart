// notifications_page.dart
import 'package:brainboosters_app/screens/student/notifications/notifications_repository.dart';
import 'package:brainboosters_app/screens/student/notifications/widgets/notification_card.dart';
import 'package:brainboosters_app/screens/student/notifications/widgets/notification_filters_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:brainboosters_app/screens/student/notifications/notification_model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();

  Map<String, List<NotificationModel>> _groupedNotifications = {};
  NotificationFilters _filters = NotificationFilters();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 0;

  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNotifications();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreNotifications();
    }
  }

  Future<void> _loadNotifications({bool isRefresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
      if (isRefresh) {
        _currentPage = 0;
        _groupedNotifications.clear();
        _hasMore = true;
      }
    });

    try {
      final results = await NotificationsRepository.getNotifications(
        limit: _pageSize,
        offset: _currentPage * _pageSize,
        types: _filters.types.map((e) => e.dbValue).toList(),
        priorities: _filters.priorities.map((e) => e.name).toList(),
        isRead: _filters.isRead,
        fromDate: _filters.fromDate,
        toDate: _filters.toDate,
      );

      setState(() {
        if (isRefresh) {
          _groupedNotifications = results.groupedNotifications;
        } else {
          _mergeGroupedNotifications(results.groupedNotifications);
        }
        _hasMore = results.hasMore;
        _currentPage++;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (!_hasMore || _isLoadingMore || _isLoading) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final results = await NotificationsRepository.getNotifications(
        limit: _pageSize,
        offset: _currentPage * _pageSize,
        types: _filters.types.map((e) => e.dbValue).toList(),
        priorities: _filters.priorities.map((e) => e.name).toList(),
        isRead: _filters.isRead,
        fromDate: _filters.fromDate,
        toDate: _filters.toDate,
      );

      setState(() {
        _mergeGroupedNotifications(results.groupedNotifications);
        _hasMore = results.hasMore;
        _currentPage++;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load more notifications: $e');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _mergeGroupedNotifications(
    Map<String, List<NotificationModel>> newNotifications,
  ) {
    for (final entry in newNotifications.entries) {
      if (_groupedNotifications.containsKey(entry.key)) {
        _groupedNotifications[entry.key]!.addAll(entry.value);
      } else {
        _groupedNotifications[entry.key] = entry.value;
      }
    }
  }

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationFiltersBottomSheet(
        filters: _filters,
        onFiltersChanged: (newFilters) {
          setState(() {
            _filters = newFilters;
          });
          _loadNotifications(isRefresh: true);
        },
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    try {
      await NotificationsRepository.markAllAsRead();
      _loadNotifications(isRefresh: true);
      _showSuccessSnackBar('All notifications marked as read');
    } catch (e) {
      _showErrorSnackBar('Failed to mark all as read: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () => _loadNotifications(isRefresh: true),
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
      ),
      title: const Text(
        'Notifications',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Color(0xFF4AA0E6)),
          onPressed: _showFiltersBottomSheet,
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'mark_all_read') {
              _markAllAsRead();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'mark_all_read',
              child: Row(
                children: [
                  Icon(Icons.done_all, size: 20),
                  SizedBox(width: 8),
                  Text('Mark all as read'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading && _groupedNotifications.isEmpty) {
      return _buildSkeletonLoader();
    }

    if (_error != null && _groupedNotifications.isEmpty) {
      return _buildErrorState();
    }

    if (_groupedNotifications.isEmpty) {
      return _buildEmptyState();
    }

    return _buildNotificationsList();
  }

  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) => _buildSkeletonItem(),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 200, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 14, width: double.infinity, color: Colors.white),
          const SizedBox(height: 4),
          Container(height: 14, width: 250, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Failed to load notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error occurred',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _loadNotifications(isRefresh: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4AA0E6),
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    final sortedKeys = _groupedNotifications.keys.toList()
      ..sort((a, b) => _sortDateKeys(a, b));

    return ListView.builder(
      controller: _scrollController,
      itemCount: sortedKeys.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == sortedKeys.length) {
          return _buildLoadingMoreIndicator();
        }

        final dateKey = sortedKeys[index];
        final notifications = _groupedNotifications[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(dateKey),
            const SizedBox(height: 8),
            ...notifications.map(
              (notification) => NotificationCard(
                notification: notification,
                onTap: () => _handleNotificationTap(notification),
                onMarkAsRead: () => _markAsRead(notification),
                onMarkAsUnread: () => _markAsUnread(notification),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(String dateKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        dateKey,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4AA0E6)),
      ),
    );
  }

  int _sortDateKeys(String a, String b) {
    const order = ['Today', 'Yesterday'];
    final aIndex = order.indexOf(a);
    final bIndex = order.indexOf(b);

    if (aIndex != -1 && bIndex != -1) {
      return aIndex.compareTo(bIndex);
    } else if (aIndex != -1) {
      return -1;
    } else if (bIndex != -1) {
      return 1;
    } else {
      return b.compareTo(a);
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Navigate based on notification type and reference
    if (notification.referenceId != null) {
      switch (notification.referenceType) {
        case 'course':
          context.push('/course/${notification.referenceId}');
          break;
        case 'live_class':
          context.push('/live-class/${notification.referenceId}');
          break;
      }
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      await NotificationsRepository.markAsRead(notification.id);
      setState(() {
        _updateNotificationInGroups(notification, true);
      });
    } catch (e) {
      _showErrorSnackBar('Failed to mark as read: $e');
    }
  }

  Future<void> _markAsUnread(NotificationModel notification) async {
    if (!notification.isRead) return;

    try {
      await NotificationsRepository.markAsUnread(notification.id);
      setState(() {
        _updateNotificationInGroups(notification, false);
      });
    } catch (e) {
      _showErrorSnackBar('Failed to mark as unread: $e');
    }
  }

  void _updateNotificationInGroups(
    NotificationModel notification,
    bool isRead,
  ) {
    for (final group in _groupedNotifications.values) {
      final index = group.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        group[index] = NotificationModel(
          id: notification.id,
          userId: notification.userId,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          referenceId: notification.referenceId,
          referenceType: notification.referenceType,
          isRead: isRead,
          priority: notification.priority,
          scheduledAt: notification.scheduledAt,
          createdAt: notification.createdAt,
          updatedAt: DateTime.now(),
        );
        break;
      }
    }
  }
}
