// screens/web/web_main_screen.dart
import 'package:brainboosters_app/screens/student/widgets/appbar_widget.dart';
import 'package:brainboosters_app/screens/student/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:brainboosters_app/screens/student/widgets/navigation_item.dart';
import 'dart:async'; // Add this for StreamSubscription

class WebMainScreen extends StatefulWidget {
  final Widget child;

  const WebMainScreen({super.key, required this.child});

  @override
  State<WebMainScreen> createState() => _WebMainScreenState();
}

class _WebMainScreenState extends State<WebMainScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _sidebarExpanded = true;
  late AnimationController _sidebarAnimationController;
  late Animation<double> _sidebarAnimation;
  int _selectedIndex = 0;
  StreamSubscription<AuthState>? _authSubscription;

  bool get _isLoggedIn => Supabase.instance.client.auth.currentUser != null;
  bool get _isMobile => MediaQuery.of(context).size.width < 768;

  // Dynamic navigation items getter
  List<NavigationItem> get _navigationItems {
    final baseItems = [
      NavigationItem(
        icon: Icons.dashboard,
        label: 'Dashboard',
        route: '/',
        color: const Color(0xFF4AA0E6),
      ),
      NavigationItem(
        icon: Icons.menu_book,
        label: 'Courses',
        route: '/courses',
        color: const Color(0xFF4AA0E6),
      ),
      NavigationItem(
        icon: Icons.live_tv,
        label: 'Live Classes',
        route: '/live-classes',
        color: const Color(0xFF4AA0E6),
      ),
      NavigationItem(
        icon: Icons.apartment,
        label: 'Coaching Centers',
        route: '/coaching-centers',
        color: const Color(0xFF4AA0E6),
      ),
      NavigationItem(
        icon: Icons.search,
        label: 'Search',
        route: '/search',
        color: const Color(0xFF4AA0E6),
      ),
    ];

    if (_isLoggedIn) {
      baseItems.addAll([
        NavigationItem(
          icon: Icons.person,
          label: 'Profile',
          route: '/profile',
          color: const Color(0xFF4AA0E6),
        ),
        NavigationItem(
          icon: Icons.notifications,
          label: 'Notifications',
          route: '/notifications',
          color: const Color(0xFF4AA0E6),
        ),
        NavigationItem(
          icon: Icons.settings,
          label: 'Settings',
          route: '/settings',
          color: const Color(0xFF4AA0E6),
        ),
      ]);
    }

    return baseItems;
  }
  void _setupAuthListener() {
  _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
    debugPrint('🔄 Auth state changed: ${event.event}');
    
    if (event.event == AuthChangeEvent.signedOut) {
      if (mounted) {
        setState(() {
          _profile = null;
          _loading = false;
        });
      }
    } else if (event.event == AuthChangeEvent.signedIn || 
               event.event == AuthChangeEvent.tokenRefreshed) {
      _fetchProfile();
    }
  });
}


  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
    _setupAuthListener();
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

    // FIXED: Move context-dependent calls here
    _updateSelectedIndex();

    // Auto-collapse sidebar on mobile, expand on desktop
    if (_isMobile && _sidebarExpanded) {
      setState(() => _sidebarExpanded = false);
      _sidebarAnimationController.reset();
    } else if (!_isMobile && !_sidebarExpanded) {
      setState(() => _sidebarExpanded = true);
      _sidebarAnimationController.forward();
    } else if (_sidebarExpanded) {
      _sidebarAnimationController.forward();
    }
  }

  void _updateSelectedIndex() {
    // FIXED: This is now safe to call since we're in didChangeDependencies
    try {
      final currentLocation = GoRouterState.of(context).uri.toString();
      final navigationItems = _navigationItems;
      final index = navigationItems.indexWhere(
        (item) =>
            currentLocation == item.route ||
            (item.route != '/' && currentLocation.startsWith(item.route)),
      );
      if (index != -1 && index != _selectedIndex) {
        setState(() => _selectedIndex = index);
      }
    } catch (e) {
      // Graceful fallback if GoRouter context isn't available yet
      debugPrint('GoRouter context not available yet: $e');
    }
  }

  Future<void> _initializeData() async {
    if (_isLoggedIn) {
      await _fetchProfile();
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

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

  void _onNavigationItemSelected(int index) {
    final navigationItems = _navigationItems;
    if (index < navigationItems.length) {
      final item = navigationItems[index];
      context.go(item.route);
      setState(() => _selectedIndex = index);
      _closeMobileSidebar();
    }
  }

  @override
  void dispose() {
    _sidebarAnimationController.dispose();
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxSidebarWidth = _isMobile ? screenWidth * 0.85 : 280.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFD),
      body: Row(
        children: [
          // Animated Sidebar
          AnimatedBuilder(
            animation: _sidebarAnimation,
            builder: (context, child) {
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
                        ? _buildResponsiveSidebar(currentWidth)
                        : const SizedBox.shrink(),
                  ),

                  // Mobile overlay
                  if (_isMobile &&
                      _sidebarExpanded &&
                      _sidebarAnimation.value > 0.3)
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
                _buildResponsiveAppBar(),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveSidebar(double width) {
    return Container(
      width: width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isMobile ? 0.2 : 0.1),
            blurRadius: _isMobile ? 16 : 8,
            offset: Offset(_isMobile ? 4 : 2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_isMobile) _buildMobileHeader(),

          Expanded(
            child: DashboardSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: _onNavigationItemSelected,
              items: _navigationItems,
              profile: _profile,
              loading: _loading,
            ),
          ),

          if (!_isLoggedIn) _buildAuthSection(),
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

  Widget _buildAuthSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.go('/auth');
                _closeMobileSidebar();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4AA0E6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Sign In'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                context.go('/auth/register');
                _closeMobileSidebar();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF4AA0E6)),
                foregroundColor: const Color(0xFF4AA0E6),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Sign Up'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveAppBar() {
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
              name: _profile != null && _profile!['first_name'] != null
                  ? '${_profile!['first_name']} ${_profile!['last_name'] ?? ''}'
                  : null,
              avatarUrl: _profile?['avatar_url'],
            ),
          ),
        ],
      ),
    );
  }
}
