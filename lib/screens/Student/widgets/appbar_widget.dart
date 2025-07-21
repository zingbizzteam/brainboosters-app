// widgets/common/appbar_widget.dart - ENHANCED FOR WEB INTEGRATION
import 'package:brainboosters_app/screens/student/notifications/notifications_repository.dart';
import 'package:brainboosters_app/ui/navigation/app_router.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:brainboosters_app/ui/navigation/student_routes/student_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBarWidget extends StatefulWidget {
  final String? name;
  final String? avatarUrl;
  final bool showLogo;
  final bool showHamburger;
  final VoidCallback? onMenuTap;

  const AppBarWidget({
    super.key,
    this.name,
    this.avatarUrl,
    this.showLogo = true,
    this.showHamburger = false,
    this.onMenuTap,
  });

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  int _unreadCount = 0;
  bool get _isMobile => MediaQuery.of(context).size.width < 768;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await NotificationsRepository.getUnreadCount();
      if (mounted) {
        setState(() => _unreadCount = count);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _unreadCount = 0);
      }
    }
  }

  Widget _buildNotificationBadge() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: Color(0xFF4AA0E6),
          ),
          onPressed: () {
            context.go(StudentRoutes.notifications);
            Future.delayed(const Duration(milliseconds: 500), _loadUnreadCount);
          },
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
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

  String _getPageTitle() {
    final currentLocation = GoRouterState.of(context).uri.toString();
    if (currentLocation == '/' || currentLocation == '/home') return 'Dashboard';
    if (currentLocation.startsWith('/courses')) return 'Courses';
    if (currentLocation.startsWith('/live-class')) return 'Live Classes';
    if (currentLocation.startsWith('/coaching-center')) return 'Coaching Centers';
    if (currentLocation.startsWith('/profile')) return 'Profile';
    if (currentLocation.startsWith('/settings')) return 'Settings';
    if (currentLocation.startsWith('/notifications')) return 'Notifications';
    if (currentLocation.startsWith('/search')) return 'Search';
    return 'BrainBoosters';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _isMobile ? 60 : kToolbarHeight,
      padding: EdgeInsets.symmetric(horizontal: _isMobile ? 8 : 16),
      decoration: const BoxDecoration(color: Color(0xFFF9FBFD)),
      child: Row(
        children: [
          // Logo or hamburger + title
          if (widget.showLogo && !_isMobile)
            GestureDetector(
              onTap: () => context.go(AppRouter.home),
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
            )
          else if (_isMobile)
            Expanded(
              child: Text(
                _getPageTitle(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

          if (!_isMobile) const Spacer(),

          // Search button (desktop only)
          if (!_isMobile)
            IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF4AA0E6)),
              onPressed: () => context.go(CommonRoutes.searchRoute),
            ),

          // Notifications button with badge
          _buildNotificationBadge(),

          // Profile section (mobile only)
          if (_isMobile && widget.name != null) ...[
            const SizedBox(width: 8),
            if (widget.avatarUrl != null)
              CircleAvatar(
                backgroundImage: NetworkImage(widget.avatarUrl!),
                radius: 16,
              )
            else
              CircleAvatar(
                backgroundColor: const Color(0xFF4AA0E6),
                radius: 16,
                child: Text(
                  widget.name![0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
