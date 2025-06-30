// student_mainscreen.dart
import 'package:brainboosters_app/screens/student/widgets/appbar_widget.dart';
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
    route: CommonRoutes.courses,
    label: 'Courses',
    icon: Icons.menu_book,
    color: const Color(0xFFA78DF0),
  ),
  _NavItem(
    route: CommonRoutes.liveClasses,
    label: 'Live',
    icon: Icons.live_tv,
    color: const Color(0xFFF76B6A),
  ),
  _NavItem(
    route: CommonRoutes.coachingCenters,
    label: 'Coaching',
    icon: Icons.school,
    color: const Color(0xFFF9B857),
  ),
  _NavItem(
    route: CommonRoutes.settings,
    label: 'Settings',
    icon: Icons.settings,
    color: const Color(0xFF5873ff),
  ),
];

class StudentMainScreen extends StatelessWidget {
  const StudentMainScreen({super.key, required this.shell});
  final StatefulNavigationShell shell;

  void _onNavTap(int index) {
    shell.goBranch(index);
  }

  bool _shouldShowAppBar(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    
    // Hide AppBar on nested routes (routes with more than one segment after the base)
    final pathSegments = currentLocation.split('/').where((s) => s.isNotEmpty).toList();
    
    // Show AppBar only on main tab routes
    return pathSegments.length <= 1 || 
           currentLocation == StudentRoutes.home ||
           currentLocation == CommonRoutes.courses ||
           currentLocation == CommonRoutes.liveClasses ||
           currentLocation == CommonRoutes.coachingCenters ||
           currentLocation == CommonRoutes.settings;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final selectedIndex = shell.currentIndex;
    final showAppBar = _shouldShowAppBar(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFD),
      body: SafeArea(
        child: Row(
          children: [
            if (isWide)
              DashboardSidebar(
                selectedIndex: selectedIndex,
                onItemSelected: _onNavTap,
                items: _navItems,
              ),
            Expanded(
              child: showAppBar 
                ? NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverAppBar(
                        backgroundColor: const Color(0xFFF9FBFD),
                        elevation: 0,
                        scrolledUnderElevation: 0,
                        floating: true,
                        snap: true,
                        pinned: false,
                        flexibleSpace: AppBarWidget(),
                        automaticallyImplyLeading: false,
                        toolbarHeight: kToolbarHeight,
                      ),
                    ],
                    body: shell,
                  )
                : shell,
            ),
          ],
        ),
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