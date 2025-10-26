// screens/student/student_main_screen.dart - FIXED IMPORTS
import 'package:brainboosters_app/screens/student/widgets/appbar_widget.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:brainboosters_app/ui/navigation/student_routes/student_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/bottom_navbar.dart';
import 'widgets/sidebar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:brainboosters_app/screens/student/widgets/navigation_item.dart';
import 'dart:async'; // ADD THIS for StreamSubscription

final _navItems = [
  NavigationItem(
    route: StudentRoutes.home,
    label: 'Home',
    icon: Icons.home,
    color: Colors.blue,
  ),
  NavigationItem(
    route: CommonRoutes.coursesRoute,
    label: 'Courses',
    icon: Icons.menu_book,
    color: const Color(0xFFA78DF0),
  ),
  NavigationItem(
    route: CommonRoutes.liveClassesRoute,
    label: 'Live Classes',
    icon: Icons.live_tv,
    color: Colors.red,
  ),
  NavigationItem(
    route: CommonRoutes.coachingCentersRoute,
    label: 'Coaching',
    icon: Icons.apartment,
    color: const Color(0xFFF9B857),
  ),
  NavigationItem(
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

class _StudentMainScreenState extends State<StudentMainScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _sidebarExpanded = false;
  late AnimationController _sidebarAnimationController;
  late Animation<double> _sidebarAnimation;
  StreamSubscription<AuthState>? _authSubscription;

  bool get _isMobile => MediaQuery.of(context).size.width < 768;
  bool get _isWide => MediaQuery.of(context).size.width >= 900;

  void _setupAuthListener() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      event,
    ) {
      debugPrint('🔄 Auth state changed: ${event.event}');

      if (event.event == AuthChangeEvent.signedOut) {
        // Clear profile when signed out
        if (mounted) {
          setState(() {
            _profile = null;
            _loading = false;
          });
        }
      } else if (event.event == AuthChangeEvent.signedIn ||
          event.event == AuthChangeEvent.tokenRefreshed) {
        // Refresh profile when signed in or token refreshed
        _fetchProfile();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchProfile();
    _setupAuthListener(); // ADD THIS LINE
  }

  void _initializeAnimations() {
    _sidebarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _sidebarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sidebarAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isMobile && _sidebarExpanded) {
      setState(() => _sidebarExpanded = false);
      _sidebarAnimationController.reset();
    }
  }

  Future<void> _fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
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
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _onNavTap(int index) {
    widget.shell.goBranch(index);
    _closeMobileSidebar();
  }

  void _toggleSidebar() {
    setState(() {
      _sidebarExpanded = !_sidebarExpanded;
    });

    if (_sidebarExpanded) {
      _sidebarAnimationController.forward();
    } else {
      _sidebarAnimationController.reverse();
    }
  }

  void _closeMobileSidebar() {
    if (_isMobile && _sidebarExpanded) {
      _toggleSidebar();
    }
  }

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

  int _getSelectedIndex(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();

    for (int i = 0; i < _navItems.length; i++) {
      final item = _navItems[i];
      if (currentLocation == item.route ||
          (item.route != StudentRoutes.home &&
              currentLocation.startsWith(item.route))) {
        return i;
      }
    }

    return widget.shell.currentIndex.clamp(0, _navItems.length - 1);
  }

  @override
  void dispose() {
    _sidebarAnimationController.dispose();
    _authSubscription?.cancel(); // ADD THIS LINE
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);
    final showAppBar = _shouldShowAppBar(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFD),
      body: SafeArea(
        child: Row(
          children: [
            // Desktop sidebar or mobile animated sidebar
            if (_isWide)
              Container(
                width: 280,
                child: DashboardSidebar(
                  selectedIndex: selectedIndex,
                  onItemSelected: _onNavTap,
                  items:
                      _navItems, // FIXED: Now uses shared NavigationItem type
                  profile: _profile,
                  loading: _loading,
                ),
              )
            else if (_isMobile)
              AnimatedBuilder(
                animation: _sidebarAnimation,
                builder: (context, child) {
                  final maxSidebarWidth = screenWidth * 0.85;
                  final currentWidth = _sidebarExpanded
                      ? maxSidebarWidth * _sidebarAnimation.value
                      : 0.0;

                  return Stack(
                    children: [
                      Container(
                        width: currentWidth,
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(),
                        child: currentWidth > 0
                            ? _buildMobileSidebar(currentWidth, selectedIndex)
                            : const SizedBox.shrink(),
                      ),

                      if (_sidebarExpanded && _sidebarAnimation.value > 0.3)
                        Positioned.fill(
                          left: currentWidth,
                          child: GestureDetector(
                            onTap: _closeMobileSidebar,
                            child: Container(
                              color: Colors.black.withOpacity(
                                0.5 * _sidebarAnimation.value,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

            // Main content area
            Expanded(
              child: Column(
                children: [
                  if (showAppBar) _buildEnhancedAppBar(),
                  Expanded(child: widget.shell),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isWide
          ? null
          : DashboardBottomNavBar(
              selectedIndex:
                  selectedIndex >= 0 && selectedIndex < _navItems.length
                  ? selectedIndex
                  : 0,
              onItemSelected: _onNavTap,
              items: _navItems
                  .map(
                    (item) => _NavItem(
                      route: item.route,
                      label: item.label,
                      icon: item.icon,
                      color: item.color,
                    ),
                  )
                  .toList(),
              avatarUrl: _profile?['avatar_url'],
            ),
    );
  }

  Widget _buildMobileSidebar(double width, int selectedIndex) {
    return Container(
      width: width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMobileHeader(),
          Expanded(
            child: DashboardSidebar(
              selectedIndex: selectedIndex,
              onItemSelected: _onNavTap,
              items: _navItems, // FIXED: Now uses shared NavigationItem type
              profile: _profile,
              loading: _loading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF4AA0E6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'BrainBoosters',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4AA0E6),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: _closeMobileSidebar,
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[100],
              foregroundColor: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedAppBar() {
    return Container(
      height: _isMobile ? 60 : kToolbarHeight,
      decoration: const BoxDecoration(
        color: Color(0xFFF9FBFD),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          if (_isMobile) ...[
            IconButton(
              onPressed: _toggleSidebar,
              icon: AnimatedRotation(
                turns: _sidebarExpanded ? 0.125 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _sidebarExpanded ? Icons.close : Icons.menu,
                  color: const Color(0xFF4AA0E6),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          Expanded(
            child: AppBarWidget(
              name: _profile?['first_name'] != null
                  ? '${_profile?['first_name']} ${_profile?['last_name'] ?? ''}'
                  : null,
              avatarUrl: _profile?['avatar_url'],
              showLogo: !_isMobile,
              showHamburger: false,
            ),
          ),
        ],
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
