// lib/screens/student/profile/profile_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'profile_repository.dart';
import 'widgets/analytics_summary.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_model.dart';
import 'widgets/shimmer_widgets.dart';
import 'widgets/analytics_tab.dart';
import 'widgets/courses_tab.dart';
import 'widgets/certificates_tab.dart';
import 'widgets/analytics_filters.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  ProfileData? _profileData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfileData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userProfile = await ProfileRepository.getCurrentUserProfile();
      final analyticsReport = await ProfileRepository.generateAnalyticsReport();

      setState(() {
        _profileData = ProfileData(
          userProfile: userProfile,
          analyticsReport: analyticsReport,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: _isLoading
          ? const ProfileShimmer()
          : _error != null
          ? _buildErrorState()
          : _profileData == null
          ? _buildNoDataState()
          : _buildProfileContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadProfileData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No profile data available'),
        ],
      ),
    );
  }

  // FIXED: Constraint-aware layout that prevents overflow
  Widget _buildProfileContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available space and adaptive spacing
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;
        final isCompactScreen = screenHeight < 600;
        final isMobile = screenWidth <= 768;

        // Adaptive spacing based on available height
        final basePadding = isCompactScreen ? 8.0 : 16.0;
        final headerHeight = isCompactScreen ? 160.0 : 200.0;

        return CustomScrollView(
          slivers: [
            // Fixed Header with Adaptive Height
            SliverToBoxAdapter(
              child: Container(
                height: headerHeight,
                child: ProfileHeader(profileData: _profileData!),
              ),
            ),

            // Analytics Summary with Adaptive Padding
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(basePadding),
                child: AnalyticsSummary(profileData: _profileData!),
              ),
            ),

            // Analytics Filters with Adaptive Padding
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: basePadding),
                child: AnalyticsFilters(
                  profileData: _profileData!,
                  onFiltersChanged: _loadProfileData,
                ),
              ),
            ),

            // Tab Content with Flexible Height
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.all(basePadding),
                child: Column(
                  children: [
                    // Responsive Tab Bar
                    _buildResponsiveTabBar(isMobile),
                    SizedBox(height: isCompactScreen ? 10 : 20),

                    // Flexible Tab Content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          AnalyticsTab(profileData: _profileData!),
                          CoursesTab(profileData: _profileData!),
                          CertificatesTab(
                            profileData: _profileData!,
                            onRefresh: _loadProfileData,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResponsiveTabBar(bool isMobile) {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.blue[900],
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.blue[900],
      isScrollable: isMobile,
      labelStyle: TextStyle(
        fontSize: isMobile ? 14 : 16,
        fontWeight: FontWeight.w600,
      ),
      tabs: const [
        Tab(text: 'Analytics'),
        Tab(text: 'Courses'),
        Tab(text: 'Certificates'),
      ],
    );
  }
}
