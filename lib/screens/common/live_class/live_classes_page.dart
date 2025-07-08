// screens/common/live_class/live_classes_page.dart

import 'package:brainboosters_app/screens/common/live_class/live_class_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../ui/navigation/common_routes/common_routes.dart';
import 'widgets/live_class_hero_section.dart';
import 'widgets/featured_instructors_section.dart';
import 'widgets/live_class_card.dart';
import '../courses/widgets/app_promotion_section.dart';
import '../courses/widgets/course_footer_section.dart';

class LiveClassesPage extends StatefulWidget {
  const LiveClassesPage({super.key});

  @override
  State<LiveClassesPage> createState() => _LiveClassesPageState();
}

class _LiveClassesPageState extends State<LiveClassesPage> {
  List<Map<String, dynamic>> upcomingLiveClasses = [];
  List<Map<String, dynamic>> technologyLiveClasses = [];
  bool isLoading = true;
  bool isRefreshing = false; // NEW: Track refresh state
  String? error;

  // NEW: Refresh coordination
  int _refreshCompletedComponents = 0;
  static const int _totalRefreshComponents =
      3; // upcoming, technology, instructors

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadLiveClasses();
    });
  }

  // NEW: Enhanced refresh with coordination
  Future<void> _handleRefresh() async {
    if (isRefreshing) return;

    print('DEBUG: Starting coordinated live classes refresh...');

    setState(() {
      isRefreshing = true;
      isLoading = true; // Show skeleton during refresh
      _refreshCompletedComponents = 0;
      error = null;
    });

    // Clear any caches if you have them
    // LiveClassRepository.clearCache(); // Implement if needed

    await _loadLiveClasses(isRefresh: true);
  }

  Future<void> _loadLiveClasses({bool isRefresh = false}) async {
    try {
      if (!isRefresh) {
        setState(() {
          isLoading = true;
          error = null;
        });
      }

      print('DEBUG: ${isRefresh ? "Refreshing" : "Loading"} live classes...');

      final results = await Future.wait([
        LiveClassRepository.getUpcomingLiveClasses(limit: 8),
        LiveClassRepository.getLiveClassesByCategory('Technology', limit: 8),
      ]);

      if (mounted) {
        setState(() {
          upcomingLiveClasses = results[0];
          technologyLiveClasses = results[1];
          isLoading = false;
          isRefreshing = false;
        });

        print('DEBUG: Live classes loaded:');
        print('  - Upcoming: ${upcomingLiveClasses.length} classes');
        print('  - Technology: ${technologyLiveClasses.length} classes');
      }
    } catch (e) {
      print('ERROR: Failed to load live classes: $e');

      if (mounted) {
        setState(() {
          error = 'Failed to load live classes: $e';
          isLoading = false;
          isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Colors.purple,
        backgroundColor: Colors.white,
        strokeWidth: 2.5,
        displacement: 40.0,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Hero Section
              const LiveClassHeroSection(),

              // Upcoming Live Classes
              _buildUpcomingLiveClassesSection(context),

              // Featured Instructors with refresh coordination
              FeaturedInstructorsSection(
                forceRefresh: isRefreshing,
                onRefreshComplete: () {
                  // Handle instructor section refresh completion if needed
                },
              ),

              // Live Classes by Category
              _buildLiveClassesByCategorySection(context),

              // App Promotion - Only on Web
              if (kIsWeb) const AppPromotionSection(),

              // Footer - Only on Web
              if (kIsWeb) const CourseFooterSection(),

              // Footer spacing for mobile
              if (!kIsWeb) const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingLiveClassesSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
        vertical: 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upcoming Live Classes',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join interactive sessions with expert instructors',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // NEW: Show shimmer when loading (including refresh)
          if (isLoading)
            _buildUpcomingLiveClassesShimmer(isMobile, isTablet)
          else if (error != null)
            _buildErrorState()
          else if (upcomingLiveClasses.isEmpty)
            _buildEmptyState('No upcoming live classes available')
          else
            _buildDynamicLiveClassGrid(
              context,
              upcomingLiveClasses,
              isMobile,
              isTablet,
            ),
        ],
      ),
    );
  }

  Widget _buildLiveClassesByCategorySection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
        vertical: 40,
      ),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Technology Live Classes',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Master the latest in technology with live instruction',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // NEW: Show shimmer when loading (including refresh)
          if (isLoading)
            _buildTechnologyLiveClassesShimmer(isMobile, isTablet)
          else if (technologyLiveClasses.isEmpty)
            _buildEmptyState('No technology live classes available')
          else
            _buildDynamicLiveClassGrid(
              context,
              technologyLiveClasses,
              isMobile,
              isTablet,
            ),

          const SizedBox(height: 32),

          // View All Button
          Center(
            child: OutlinedButton(
              onPressed: () {
                context.push(CommonRoutes.getSearchCoursesRoute(''));
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View All Live Classes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Shimmer for upcoming live classes
  Widget _buildUpcomingLiveClassesShimmer(bool isMobile, bool isTablet) {
    print('DEBUG: Rendering upcoming live classes shimmer');

    int crossAxisCount;
    if (isMobile) {
      crossAxisCount = 1;
    } else if (isTablet) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 4;
    }

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: isMobile ? 1.2 : 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 4, // Show 4 shimmer cards
        itemBuilder: (context, index) {
          return _buildLiveClassShimmerCard(isMobile, isTablet);
        },
      ),
    );
  }

  // NEW: Shimmer for technology live classes
  Widget _buildTechnologyLiveClassesShimmer(bool isMobile, bool isTablet) {
    print('DEBUG: Rendering technology live classes shimmer');

    int crossAxisCount;
    if (isMobile) {
      crossAxisCount = 1;
    } else if (isTablet) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 4;
    }

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: isMobile ? 1.2 : 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 4, // Show 4 shimmer cards
        itemBuilder: (context, index) {
          return _buildLiveClassShimmerCard(isMobile, isTablet);
        },
      ),
    );
  }

  // NEW: Individual shimmer card
  Widget _buildLiveClassShimmerCard(bool isMobile, bool isTablet) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 360;

    double cardWidth;
    if (isSmallMobile) {
      cardWidth = screenWidth * 0.75;
    } else if (isMobile) {
      cardWidth = screenWidth * 0.60;
    } else if (isTablet) {
      cardWidth = 300;
    } else {
      cardWidth = 320;
    }

    final thumbnailHeight = cardWidth * (9 / 16);
    final adaptivePadding = cardWidth < 200
        ? 8.0
        : (isSmallMobile ? 10.0 : 12.0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thumbnail shimmer
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              child: Container(
                height: thumbnailHeight,
                width: double.infinity,
                color: Colors.white,
              ),
            ),

            // Content shimmer
            Padding(
              padding: EdgeInsets.all(adaptivePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Instructor name shimmer
                  Container(
                    height: 12,
                    width: cardWidth * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(
                    height: cardWidth < 200 ? 2 : (isSmallMobile ? 3 : 4),
                  ),

                  // Title shimmer
                  Container(
                    height: isSmallMobile ? 14 : 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: isSmallMobile ? 14 : 16,
                    width: cardWidth * 0.7,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(
                    height: cardWidth < 200 ? 3 : (isSmallMobile ? 4 : 6),
                  ),

                  // Description shimmer (only for wider cards)
                  if (cardWidth >= 200) ...[
                    Container(
                      height: 10,
                      width: cardWidth * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: isSmallMobile ? 4 : 6),
                  ],

                  // Time and duration row shimmer
                  if (cardWidth >= 180) ...[
                    Row(
                      children: [
                        Container(
                          height: 10,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(width: isSmallMobile ? 6 : 8),
                        Container(
                          height: 10,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: cardWidth < 200 ? 4 : (isSmallMobile ? 6 : 8),
                    ),
                  ],

                  // Bottom row shimmer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 12,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        height: 20,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Live Classes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error ?? 'Something went wrong',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLiveClasses,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.live_tv_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicLiveClassGrid(
    BuildContext context,
    List<Map<String, dynamic>> liveClasses,
    bool isMobile,
    bool isTablet,
  ) {
    int crossAxisCount;
    if (isMobile) {
      crossAxisCount = 1;
    } else if (isTablet) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 4;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isMobile ? 1.2 : 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: liveClasses.length,
      itemBuilder: (context, index) {
        return LiveClassCard(
          liveClass: liveClasses[index],
          onTap: () {
            context.push(
              CommonRoutes.getLiveClassDetailRoute(liveClasses[index]['id']),
            );
          },
        );
      },
    );
  }
}
