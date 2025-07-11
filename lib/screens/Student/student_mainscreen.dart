import 'package:brainboosters_app/screens/student/widgets/appbar_widget.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:brainboosters_app/ui/navigation/student_routes/student_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/bottom_navbar.dart';
import 'widgets/sidebar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _navItems = [
  _NavItem(
    route: StudentRoutes.home,
    label: 'Home',
    icon: Icons.home,
    color: Colors.blue,
  ),
  _NavItem(
    route: CommonRoutes.coursesRoute,
    label: 'Courses',
    icon: Icons.menu_book,
    color: const Color(0xFFA78DF0),
  ),
  _NavItem(
    route: CommonRoutes.liveClassesRoute,
    label: 'Live',
    icon: Icons.live_tv,
    color: Colors.red,
  ),
  _NavItem(
    route: CommonRoutes.coachingCentersRoute,
    label: 'Coaching',
    icon: Icons.apartment,
    color: const Color(0xFFF9B857),
  ),
  _NavItem(
    route: StudentRoutes.profile,
    label: 'Profile',
    icon: Icons.person,
    color: Colors.blueGrey,
  ),
];

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final profile = await Supabase.instance.client
        .from('user_profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (mounted) {
      setState(() {
        _profile = profile;
        _loading = false;
      });
    }
  }

  void _onNavTap(int index) => widget.shell.goBranch(index);

  bool _shouldShowAppBar(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    final pathSegments = currentLocation
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList();

    return pathSegments.length <= 1 ||
        currentLocation == StudentRoutes.home ||
        currentLocation == CommonRoutes.coursesRoute ||
        currentLocation == CommonRoutes.coachingCentersRoute ||
        currentLocation == StudentRoutes.settings ||
        currentLocation == StudentRoutes.profile ||
        currentLocation == CommonRoutes.liveClassesRoute ||
        currentLocation.startsWith('/live-class/');
  }

  // ADD THIS: Method to determine correct navigation index for live classes
  int _getSelectedIndex(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();

    // If on live classes, don't highlight any bottom nav item
    if (currentLocation == CommonRoutes.liveClassesRoute ||
        currentLocation.startsWith('/live-class/')) {
      return -1; // No selection
    }

    // Otherwise use the shell's current index
    return widget.shell.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final selectedIndex = _getSelectedIndex(context); // Use custom method
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
                profile: _profile,
                loading: _loading,
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
                          flexibleSpace: AppBarWidget(
                            name: _profile?['first_name'] != null
                                ? '${_profile?['first_name']} ${_profile?['last_name'] ?? ''}'
                                : null,
                            avatarUrl: _profile?['avatar_url'],
                          ),
                          automaticallyImplyLeading: false,
                          toolbarHeight: kToolbarHeight,
                        ),
                      ],
                      body: widget.shell,
                    )
                  : widget.shell,
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
              avatarUrl: _profile?['avatar_url'],
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
