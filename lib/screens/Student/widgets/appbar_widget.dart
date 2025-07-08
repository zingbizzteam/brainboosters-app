import 'package:brainboosters_app/screens/common/comming_soon_dialog.dart';
import 'package:brainboosters_app/screens/Student/notifications/notifications_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBarWidget extends StatefulWidget {
  final String? name;
  final String? avatarUrl;

  const AppBarWidget({super.key, this.name, this.avatarUrl});

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  /// Function to load and display notification count
  Future<void> _loadUnreadCount() async {
    try {
      final count = await NotificationsRepository.getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      // Handle error silently for app bar
      if (mounted) {
        setState(() {
          _unreadCount = 0;
        });
      }
    }
  }

  /// Widget to build notification badge
  Widget _buildNotificationBadge() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: Color(0xFF4AA0E6),
          ),
          onPressed: () {
            context.go('/notifications');
            // Refresh count after navigation
            Future.delayed(const Duration(milliseconds: 500), () {
              _loadUnreadCount();
            });
          },
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(color: Color(0xFFF9FBFD)),
      child: Row(
        children: [
          // Logo on the left
          GestureDetector(
            onTap: () => context.go('/'),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/images/bb-icon.png',
                fit: BoxFit.cover,
                height: 32,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF4AA0E6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          const Spacer(), // Pushes buttons to the right
          // Search button
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF4AA0E6)),
            onPressed: () {
              context.go('/search');
            },
          ),

          // Notifications button with badge
          _buildNotificationBadge(),

          // Avatar/profile button
          GestureDetector(
            onTap: () {
              // Navigate to profile page (coming soon for now)
              showComingSoonDialog('View Profile', context);
            },
            child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                ? CircleAvatar(
                    backgroundImage: NetworkImage(widget.avatarUrl!),
                    radius: 18,
                    onBackgroundImageError: (exception, stackTrace) {},
                  )
                : CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    radius: 18,
                    child: widget.name != null && widget.name!.trim().isNotEmpty
                        ? Text(
                            widget.name!
                                .trim()
                                .split(' ')
                                .map((e) => e[0])
                                .take(2)
                                .join()
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF4AA0E6),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          )
                        : const Icon(Icons.person, color: Color(0xFF4AA0E6)),
                  ),
          ),
        ],
      ),
    );
  }
}
