import 'package:brainboosters_app/screens/common/coaching_centers/coaching_center_repository.dart';
import 'package:brainboosters_app/screens/common/coaching_centers/widgets/coaching_center_hero_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../ui/navigation/common_routes/common_routes.dart';
import 'widgets/coaching_center_card.dart';
import '../courses/widgets/app_promotion_section.dart';
import '../courses/widgets/course_footer_section.dart';

class CoachingCentersPage extends StatefulWidget {
  const CoachingCentersPage({super.key});

  @override
  State<CoachingCentersPage> createState() => _CoachingCentersPageState();
}

class _CoachingCentersPageState extends State<CoachingCentersPage> {
  // Horizontal scroll sections data
  List<Map<String, dynamic>> nearbyCoachingCenters = [];
  List<Map<String, dynamic>> topCoachingCenters = [];
  List<Map<String, dynamic>> mostLovedCoachingCenters = [];

  // Main grid data
  List<Map<String, dynamic>> allCoachingCenters = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool isLoadingHorizontalSections = true;
  String? error;

  // Pagination
  int currentPage = 0;
  final int pageSize = 12;
  bool hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  // Flag to prevent multiple simultaneous loads
  bool _isLoadingInProgress = false;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to avoid build-during-build issues
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (_isLoadingInProgress) return;

    try {
      setState(() {
        isLoading = true;
        isLoadingHorizontalSections = true;
        error = null;
        _isLoadingInProgress = true;
      });

      final results = await Future.wait([
        CoachingCenterRepository.getNearbyCoachingCenters(limit: 5),
        CoachingCenterRepository.getTopCoachingCenters(limit: 5),
        CoachingCenterRepository.getMostLovedCoachingCenters(limit: 5),
        CoachingCenterRepository.getCoachingCenters(limit: pageSize, offset: 0),
      ]);

      if (mounted) {
        setState(() {
          nearbyCoachingCenters = results[0];
          topCoachingCenters = results[1];
          mostLovedCoachingCenters = results[2];
          allCoachingCenters = results[3];
          isLoading = false;
          isLoadingHorizontalSections = false;
          hasMoreData = results[3].length == pageSize;
          _isLoadingInProgress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Failed to load coaching centers: $e';
          isLoading = false;
          isLoadingHorizontalSections = false;
          _isLoadingInProgress = false;
        });
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (isLoadingMore || !hasMoreData || _isLoadingInProgress) return;

    setState(() {
      isLoadingMore = true;
      _isLoadingInProgress = true;
    });

    try {
      final newData = await CoachingCenterRepository.getCoachingCenters(
        limit: pageSize,
        offset: allCoachingCenters.length,
      );

      if (mounted) {
        setState(() {
          allCoachingCenters.addAll(newData);
          hasMoreData = newData.length == pageSize;
          isLoadingMore = false;
          _isLoadingInProgress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingMore = false;
          _isLoadingInProgress = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load more data: $e')));
      }
    }
  }

  void _onScroll() {
    // Use post-frame callback to avoid setState during build
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _loadMoreData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              // Hero Section
              const CoachingCenterHeroSection(),
              const SizedBox(height: 20),

              // Horizontal Scroll Sections
              if (isLoadingHorizontalSections) ...[
                _buildHorizontalSectionShimmer(
                  context,
                  'Coaching Centers Near You',
                ),
                _buildHorizontalSectionShimmer(context, 'Top Coaching Centers'),
                _buildHorizontalSectionShimmer(context, 'Most Loved Centers'),
              ] else ...[
                _buildHorizontalSection(
                  context,
                  'Coaching Centers Near You',
                  'Find quality education close to your location',
                  nearbyCoachingCenters,
                ),
                _buildHorizontalSection(
                  context,
                  'Top Coaching Centers',
                  'Most popular centers with highest enrollments',
                  topCoachingCenters,
                ),
                _buildHorizontalSection(
                  context,
                  'Most Loved Centers',
                  'Centers with the best course offerings',
                  mostLovedCoachingCenters,
                ),
              ],

              // All Coaching Centers Grid
              _buildAllCoachingCentersSection(context),

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

  Widget _buildHorizontalSectionShimmer(BuildContext context, String title) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: isMobile ? 20 : 24,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: isMobile ? 14 : 16,
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: isMobile ? 280 : 320,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
              ),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: isMobile ? 280 : 320,
                  margin: const EdgeInsets.only(right: 16),
                  child: _buildCoachingCenterCardShimmer(isMobile),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachingCenterCardShimmer(bool isMobile) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            Container(
              height: isMobile ? 110 : 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
            // Content shimmer
            // Content shimmer with overflow protection
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize
                      .min, // NEW: Prevent column from taking full height
                  children: [
                    Container(
                      height: 18,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(height: 14, width: 200, color: Colors.white),
                    const SizedBox(height: 12),
                    // Wrap the Row in Flexible to prevent overflow
                    Flexible(
                      child: Row(
                        children: [
                          Container(
                            height: 24,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 24,
                            width: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer shimmer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(height: 12, width: 120, color: Colors.white),
                  Container(
                    height: 28,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalSection(
    BuildContext context,
    String title,
    String subtitle,
    List<Map<String, dynamic>> coachingCenters,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    if (coachingCenters.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: isMobile ? 280 : 320,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
              ),
              itemCount: coachingCenters.length,
              itemBuilder: (context, index) {
                return Container(
                  width: isMobile ? 280 : 320,
                  margin: const EdgeInsets.only(right: 16),
                  child: CoachingCenterCard(
                    coachingCenter: coachingCenters[index],
                    onTap: () {
                      context.push(
                        CommonRoutes.getCoachingCenterDetailRoute(
                          coachingCenters[index]['id'],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllCoachingCentersSection(BuildContext context) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Coaching Centers',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Explore all approved coaching centers',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          if (isLoading)
            _buildGridShimmer(context, isMobile, isTablet)
          else if (error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      error!,
                      style: TextStyle(color: Colors.red[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadInitialData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (allCoachingCenters.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No coaching centers found',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            _buildCoachingCentersGrid(context, isMobile, isTablet),
        ],
      ),
    );
  }

  Widget _buildGridShimmer(BuildContext context, bool isMobile, bool isTablet) {
    int crossAxisCount;
    if (isMobile) {
      crossAxisCount = 1;
    } else if (isTablet) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 3;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isMobile ? 1.1 : 0.9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6, // Show 6 shimmer items
      itemBuilder: (context, index) {
        return _buildCoachingCenterCardShimmer(isMobile);
      },
    );
  }

  Widget _buildCoachingCentersGrid(
    BuildContext context,
    bool isMobile,
    bool isTablet,
  ) {
    int crossAxisCount;
    if (isMobile) {
      crossAxisCount = 1;
    } else if (isTablet) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 3;
    }

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: isMobile ? 1.1 : 0.9,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: allCoachingCenters.length,
          itemBuilder: (context, index) {
            return CoachingCenterCard(
              coachingCenter: allCoachingCenters[index],
              onTap: () {
                context.push(
                  CommonRoutes.getCoachingCenterDetailRoute(
                    allCoachingCenters[index]['id'],
                  ),
                );
              },
            );
          },
        ),

        // Loading indicator for pagination
        if (isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),

        // Load more button (fallback)
        if (!isLoadingMore && hasMoreData)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: OutlinedButton(
              onPressed: _loadMoreData,
              child: const Text('Load More'),
            ),
          ),
      ],
    );
  }
}
