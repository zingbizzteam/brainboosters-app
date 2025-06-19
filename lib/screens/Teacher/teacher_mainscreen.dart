// student_mainscreen.dart
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:brainboosters_app/ui/navigation/teacher_routes/teacher_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/bottom_navbar.dart';
import 'widgets/sidebar.dart';

final _navItems = [
  _NavItem(
    route: TeacherRoutes.home,
    label: 'Home',
    icon: Icons.home,
    color: Colors.blue,
  ),
  _NavItem(
    route: CommonRoutes.courses, // Branch 1
    label: 'Courses',
    icon: Icons.menu_book,
    color: const Color(0xFFA78DF0),
  ),
  _NavItem(
    route: CommonRoutes.liveClasses, // Branch 2
    label: 'Live',
    icon: Icons.live_tv,
    color: const Color(0xFFF76B6A),
  ),
  _NavItem(
    route: CommonRoutes.notifications, // Branch 3
    label: 'Notifications',
    icon: Icons.notifications,
    color: const Color(0xFFF9B857),
  ),
  _NavItem(
    route: CommonRoutes.settings, // Branch 4
    label: 'Settings',
    icon: Icons.settings,
    color: const Color(0xFF5873ff),
  ),
];

class TeacherMainScreen extends StatelessWidget {
  const TeacherMainScreen({super.key, required this.shell});
  final StatefulNavigationShell shell;

  void _onNavTap(int index) {
    print('Navigation tapped: $index, Current branch: ${shell.currentIndex}');
    shell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final selectedIndex = shell.currentIndex;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFD),
      body: Row(
        children: [
          if (isWide)
            DashboardSidebar(
              selectedIndex: selectedIndex,
              onItemSelected: _onNavTap,
              items: _navItems,
            ),
          Expanded(child: shell),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : DashboardBottomNavBar(
              selectedIndex: selectedIndex,
              onItemSelected: _onNavTap,
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
