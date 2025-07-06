// lib/screens/common/coaching_centers/coaching_center_details/coaching_center_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

import 'package:brainboosters_app/screens/common/coaching_centers/coaching_center_repository.dart';
import 'package:brainboosters_app/screens/common/widgets/breadcrumb_widget.dart';
import 'package:brainboosters_app/screens/common/widgets/tab_section_widget.dart';

import 'widgets/coaching_center_header_widget.dart';
import 'widgets/coaching_center_about_tab.dart';
import 'widgets/coaching_center_courses_tab.dart';
import 'widgets/coaching_center_faculty_tab.dart';
import 'widgets/coaching_center_analytics_tab.dart';

class CoachingCenterDetailPage extends StatefulWidget {
  final String centerId;
  const CoachingCenterDetailPage({super.key, required this.centerId});

  @override
  State<CoachingCenterDetailPage> createState() =>
      _CoachingCenterDetailPageState();
}

class _CoachingCenterDetailPageState extends State<CoachingCenterDetailPage>
    with TickerProviderStateMixin {
  // ──────────────────── state ────────────────────
  Map<String, dynamic>? _center;
  bool _loading = true;
  String? _error;
  late final TabController _tabCtrl;

  // ──────────────────── lifecycle ────────────────────
  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    SchedulerBinding.instance.addPostFrameCallback((_) => _fetchCenter());
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ──────────────────── data ────────────────────
  Future<void> _fetchCenter() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final res = await CoachingCenterRepository.getCoachingCenterById(
        widget.centerId,
      );
      if (!mounted) return;

      setState(() {
        _center = res;
        _loading = false;
        if (res == null) _error = 'Coaching center not found';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load coaching center: $e';
        _loading = false;
      });
    }
  }

  // ──────────────────── navigation helpers ────────────────────
  void _onBack() {
    final router = GoRouter.of(context);
    router.canPop() ? router.pop() : router.go('/coaching-centers');
  }

  // ──────────────────── build ────────────────────
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 768;
    final isTablet = w >= 768 && w < 1200;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorView(msg: _error!, onRetry: _fetchCenter, onBack: _onBack)
          : _DetailSlivers(
              center: _center!,
              tabCtrl: _tabCtrl,
              isMobile: isMobile,
              isTablet: isTablet,
              onBack: _onBack,
            ),
    );
  }
}

/*────────────────────────────────────────────────────────────────────────────*/

/// SLIVER-BASED MAIN CONTENT  (mirrors Course-Intro screen style)
class _DetailSlivers extends StatelessWidget {
  const _DetailSlivers({
    required this.center,
    required this.tabCtrl,
    required this.isMobile,
    required this.isTablet,
    required this.onBack,
  });

  final Map<String, dynamic> center;
  final TabController tabCtrl;
  final bool isMobile;
  final bool isTablet;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final hPad = isMobile
        ? 16.0
        : isTablet
        ? 40.0
        : 80.0;

    return CustomScrollView(
      slivers: [
        /*── App-bar with breadcrumbs ──*/
        SliverAppBar(
          pinned: true,
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: onBack,
          ),
          title: isMobile
              ? null
              : BreadcrumbWidget(
                  items: [
                    BreadcrumbItem('Home', false, onTap: () => context.go('/')),
                    BreadcrumbItem(
                      'Coaching Centers',
                      false,
                      onTap: () => context.go('/coaching-centers'),
                    ),
                    BreadcrumbItem(center['center_name'], true),
                  ],
                ),
        ),

        /*── Top spacing for mobile breadcrumb ──*/
        if (isMobile)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: BreadcrumbWidget(
                items: [
                  BreadcrumbItem('Home', false, onTap: () => context.go('/')),
                  BreadcrumbItem(
                    'Coaching Centers',
                    false,
                    onTap: () => context.go('/coaching-centers'),
                  ),
                  BreadcrumbItem(center['center_name'], true),
                ],
              ),
            ),
          ),

        /*── Header section ──*/
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
            child: CoachingCenterHeaderWidget(
              coachingCenter: center,
              isMobile: isMobile,
            ),
          ),
        ),

        /*── Persistent TabBar (sticks under app-bar) ──*/
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyTabBarDelegate(
            TabBar(
              controller: tabCtrl,
              splashFactory: NoSplash.splashFactory,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.red,
              tabs: const [
                Tab(text: 'About'),
                Tab(text: 'Courses'),
                Tab(text: 'Faculty'),
                Tab(text: 'Analytics'),
              ],
            ),
          ),
        ),

        /*── TabBar views ──*/
        SliverFillRemaining(
          hasScrollBody: true,
          child: TabBarView(
            controller: tabCtrl,
            children: [
              CoachingCenterAboutTab(center: center, isMobile: isMobile),
              CoachingCenterCoursesTab(center: center, isMobile: isMobile),
              CoachingCenterFacultyTab(center: center, isMobile: isMobile),
              CoachingCenterAnalyticsTab(center: center, isMobile: isMobile),
            ],
          ),
        ),
      ],
    );
  }
}

/*────────────────────────────────────────────────────────────────────────────*/

/// Sticky header helper (same pattern as Course-Intro)
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  _StickyTabBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Container(color: Colors.white, child: _tabBar);

  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  bool shouldRebuild(_StickyTabBarDelegate old) => false;
}

/*────────────────────────────────────────────────────────────────────────────*/

/// Error / empty-state view
class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.msg,
    required this.onRetry,
    required this.onBack,
  });

  final String msg;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            msg,
            style: TextStyle(color: Colors.red[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onBack,
            child: const Text('Back to Coaching Centers'),
          ),
        ],
      ),
    ),
  );
}
