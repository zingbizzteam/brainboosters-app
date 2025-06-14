// MainScreen (mainscreen.dart)
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:brainboosters_app/ui/navigation/student_routes/student_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/bottom_navbar.dart';
import 'widgets/sidebar.dart';

final _navItems = [
  _NavItem(
    route: StudentRoutes.home,
    label: 'Home',
    icon: Icons.home,
    color: Colors.blue,
  ),
  _NavItem(
    route: CommonRoutes.courses, // Remove the /student prefix
    label: 'Courses',
    icon: Icons.menu_book,
    color: const Color(0xFFA78DF0),
  ),
  _NavItem(
    route: CommonRoutes.liveClasses, // Remove the /student prefix
    label: 'Live',
    icon: Icons.live_tv,
    color: const Color(0xFFF76B6A),
  ),
  _NavItem(
    route: CommonRoutes.notifications, // Remove the /student prefix
    label: 'Notifications',
    icon: Icons.notifications,
    color: const Color(0xFFF9B857),
  ),
  _NavItem(
    route: StudentRoutes.settings,
    label: 'Settings',
    icon: Icons.settings,
    color: const Color(0xFF5873ff),
  ),
];

class StudentMainScreen extends StatelessWidget {
  final Widget child;
  const StudentMainScreen({super.key, required this.child});

  int _getSelectedIndex(BuildContext context) {
    final state = GoRouterState.of(context);
    final location = state.matchedLocation;

    print('Current location: $location'); // Debug log

    // Check exact matches first
    for (int i = 0; i < _navItems.length; i++) {
      if (location == _navItems[i].route) {
        return i;
      }
    }

    // Then check if location starts with any route (for nested paths)
    for (int i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].route) &&
          _navItems[i].route.length > 1) {
        // Avoid matching root "/"
        return i;
      }
    }

    return 0; // Default to first item
  }

  void _onNavTap(BuildContext context, int index) {
    if (index >= 0 && index < _navItems.length) {
      final targetRoute = _navItems[index].route;
      print('Navigating to: $targetRoute'); // Debug log

      try {
        // Use pushReplacement for better navigation within shell routes
        context.go(targetRoute);
      } catch (e) {
        print('Navigation error: $e');
        // Fallback navigation
        context.go(StudentRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final selectedIndex = _getSelectedIndex(
      context,
    ).clamp(0, _navItems.length - 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFD),
      body: Row(
        children: [
          if (isWide)
            DashboardSidebar(
              selectedIndex: selectedIndex,
              onItemSelected: (i) => _onNavTap(context, i),
              items: _navItems,
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : DashboardBottomNavBar(
              selectedIndex: selectedIndex,
              onItemSelected: (i) => _onNavTap(context, i),
              items: _navItems,
            ),
    );
  }
}

class _NavItem {
  final String route;
  final String label;
  final IconData icon;
  final Color color;
  const _NavItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.color,
  });
}
