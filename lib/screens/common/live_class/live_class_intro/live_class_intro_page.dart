import 'package:brainboosters_app/screens/common/live_class/live_class_repository.dart';
import 'package:brainboosters_app/screens/common/widgets/breadcrumb_widget.dart';
import 'package:brainboosters_app/screens/common/widgets/hero_image_widget.dart';
import 'package:brainboosters_app/screens/common/widgets/stats_widget.dart';
import 'package:brainboosters_app/screens/common/widgets/tab_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/live_class_info_widget.dart';

class LiveClassIntroPage extends StatefulWidget {
  final String liveClassId;

  const LiveClassIntroPage({super.key, required this.liveClassId});

  @override
  State<LiveClassIntroPage> createState() => _LiveClassIntroPageState();
}

class _LiveClassIntroPageState extends State<LiveClassIntroPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? liveClass;
  Map<String, dynamic>? currentUser;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPageData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // FIXED: Load both live class data and current user data
  Future<void> _loadPageData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Load live class and user data in parallel
      final results = await Future.wait([
        LiveClassRepository.getLiveClassById(widget.liveClassId),
        _getCurrentUserData(),
      ]);

      final liveClassResult = results[0] as Map<String, dynamic>?;
      final userResult = results[1] as Map<String, dynamic>?;

      setState(() {
        liveClass = liveClassResult;
        currentUser = userResult;
        isLoading = false;
        if (liveClassResult == null) {
          error = 'Live class not found or you do not have access to it';
        }
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load live class: $e';
        isLoading = false;
      });
    }
  }

  // FIXED: Get current user data from authentication system
  Future<Map<String, dynamic>?> _getCurrentUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return null;

      final userProfile = await Supabase.instance.client
          .from('user_profiles')
          .select('first_name, last_name, avatar_url')
          .eq('id', user.id)
          .single();

      return {
        'first_name': userProfile['first_name'],
        'last_name': userProfile['last_name'],
        'avatar_url': userProfile['avatar_url'],
        'email': user.email,
      };
    } catch (e) {
      debugPrint('Error loading user data: $e');
      return null;
    }
  }

  // FIXED: Smart navigation with fallback strategy
  void _handleBackNavigation() {
    // Check if we can pop (there's a navigation stack)
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      // Fallback navigation based on context
      final currentLocation = GoRouterState.of(context).uri.toString();
      
      if (currentLocation.contains('/live-class/')) {
        // If we're on a live class page, go to live classes list
        context.go('/live-classes');
      } else {
        // Default fallback to home
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;
    final isMobile = screenWidth <= 768;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Breadcrumb
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            expandedHeight: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: _handleBackNavigation, // FIXED: Smart navigation
            ),
            title: isMobile
                ? null
                : BreadcrumbWidget(
                    items: [
                      BreadcrumbItem(
                        'Home',
                        false,
                        onTap: () => context.go('/'),
                      ),
                      BreadcrumbItem(
                        'Live Classes',
                        false,
                        onTap: () => context.go('/live-classes'),
                      ),
                      BreadcrumbItem(liveClass?['title'] ?? 'Live Class', true),
                    ],
                  ),
            actions: [
              if (!isMobile) ...[
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    // TODO: Implement notifications
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildUserProfile(), // FIXED: Dynamic user profile
                ),
              ],
            ],
          ),

          // Main Content
          SliverToBoxAdapter(
            child: _buildContent(isDesktop, isTablet, isMobile),
          ),
        ],
      ),
    );
  }

  // FIXED: Dynamic user profile widget
  Widget _buildUserProfile() {
    if (currentUser == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Login'),
          ),
        ],
      );
    }

    final firstName = currentUser!['first_name'] ?? '';
    final lastName = currentUser!['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    final avatarUrl = currentUser!['avatar_url'];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          fullName.isEmpty ? 'User' : fullName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 16,
          backgroundImage: avatarUrl != null
              ? NetworkImage(avatarUrl)
              : null,
          child: avatarUrl == null
              ? Text(
                  fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 12),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildContent(bool isDesktop, bool isTablet, bool isMobile) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(100),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                error!,
                style: TextStyle(color: Colors.red[600], fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _loadPageData,
                    child: const Text('Retry'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () => context.go('/live-classes'),
                    child: const Text('Browse Live Classes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (liveClass == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.tv_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Live class not found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'The live class you\'re looking for doesn\'t exist or has been removed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/live-classes'),
                child: const Text('Browse Live Classes'),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : (isTablet ? 40 : 16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Breadcrumb for mobile
          if (isMobile) ...[
            BreadcrumbWidget(
              items: [
                BreadcrumbItem('Home', false, onTap: () => context.go('/')),
                BreadcrumbItem(
                  'Live Classes',
                  false,
                  onTap: () => context.go('/live-classes'),
                ),
                BreadcrumbItem(liveClass!['title'], true),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Main Live Class Section
          isDesktop || isTablet
              ? _buildDesktopLayout(liveClass!)
              : _buildMobileLayout(liveClass!),

          const SizedBox(height: 40),

          // Live Class Stats
          StatsWidget(
            items: [
              StatItem(
                icon: Icons.people_outline,
                text:
                    '${liveClass!['current_participants']}/${liveClass!['max_participants']} Enrolled',
              ),
              StatItem(
                icon: Icons.access_time,
                text: _getFormattedTime(liveClass!['scheduled_at']),
              ),
              StatItem(
                icon: Icons.timer,
                text: '${liveClass!['duration_minutes']} minutes',
              ),
              StatItem(
                icon: Icons.live_tv,
                text: _getStatus(liveClass!['status']),
              ),
            ],
            trailingWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(
                  liveClass!['status'],
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor(liveClass!['status']),
                ),
              ),
              child: Text(
                liveClass!['status'].toString().toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(liveClass!['status']),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Tabs Section
          TabSectionWidget(
            tabController: _tabController,
            tabs: const ['About', 'Comments', "What's included", 'Analytics'],
            tabViews: [
              _buildAboutTab(liveClass!, isMobile),
              _buildCommentsTab(liveClass!, isMobile),
              _buildWhatsIncludedTab(liveClass!, isMobile),
              _buildAnalyticsTab(liveClass!, isMobile),
            ],
          ),

          const SizedBox(height: 40), // Add bottom padding
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(Map<String, dynamic> liveClass) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Side - Live Class Image
        Expanded(
          flex: 5,
          child: HeroImageWidget(
            imageUrl: liveClass['thumbnail_url'] ?? '',
            title: liveClass['title'] ?? '',
            subtitle: liveClass['description'] ?? '',
            badge: 'Live Class',
            badgeColor: _getStatusColor(liveClass['status']),
            overlayContent: _buildImageOverlay(liveClass),
          ),
        ),
        const SizedBox(width: 40),
        // Right Side - Live Class Info
        Expanded(flex: 6, child: LiveClassInfoWidget(liveClass: liveClass)),
      ],
    );
  }

  Widget _buildMobileLayout(Map<String, dynamic> liveClass) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroImageWidget(
          imageUrl: liveClass['thumbnail_url'] ?? '',
          title: liveClass['title'] ?? '',
          subtitle: liveClass['description'] ?? '',
          badge: 'Live Class',
          badgeColor: _getStatusColor(liveClass['status']),
          overlayContent: _buildImageOverlay(liveClass),
        ),
        const SizedBox(height: 20),
        LiveClassInfoWidget(liveClass: liveClass),
      ],
    );
  }

  Widget _buildImageOverlay(Map<String, dynamic> liveClass) {
    return Positioned(
      left: 20,
      top: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(liveClass['status']),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              liveClass['status'].toString().toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            liveClass['title'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab(Map<String, dynamic> liveClass, bool isMobile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            liveClass['description'] ?? 'No description available',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Class Details:',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Duration',
            '${liveClass['duration_minutes']} minutes',
            isMobile,
          ),
          _buildDetailRow('Status', liveClass['status'] ?? 'Unknown', isMobile),
          _buildDetailRow(
            'Max Participants',
            '${liveClass['max_participants']}',
            isMobile,
          ),
          _buildDetailRow(
            'Current Participants',
            '${liveClass['current_participants']}',
            isMobile,
          ),

          if (liveClass['teachers'] != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              'Instructor',
              _getInstructorName(liveClass['teachers']),
              isMobile,
            ),
          ],

          if (liveClass['coaching_centers'] != null) ...[
            _buildDetailRow(
              'Academy',
              liveClass['coaching_centers']['center_name'] ?? '',
              isMobile,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentsTab(Map<String, dynamic> liveClass, bool isMobile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comments',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'No comments yet. Be the first to comment!',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsIncludedTab(Map<String, dynamic> liveClass, bool isMobile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's Included",
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildIncludedItem(Icons.live_tv, 'Live Interactive Session', true),
          _buildIncludedItem(
            Icons.record_voice_over,
            'Q&A with Instructor',
            liveClass['q_and_a_enabled'] ?? true,
          ),
          _buildIncludedItem(
            Icons.chat,
            'Live Chat',
            liveClass['chat_enabled'] ?? true,
          ),
          _buildIncludedItem(
            Icons.video_library,
            'Recording Access',
            liveClass['recording_url'] != null,
          ),
          _buildIncludedItem(Icons.group, 'Community Access', true),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(Map<String, dynamic> liveClass, bool isMobile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Class Analytics',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildAnalyticsCard('Participation', [
            _buildMetricRow(
              'Current Participants',
              '${liveClass['current_participants']}',
            ),
            _buildMetricRow('Max Capacity', '${liveClass['max_participants']}'),
            _buildMetricRow(
              'Enrollment Rate',
              '${((liveClass['current_participants'] / liveClass['max_participants']) * 100).toStringAsFixed(1)}%',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncludedItem(IconData icon, String text, bool isIncluded) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isIncluded ? Icons.check_circle : Icons.cancel,
            color: isIncluded ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isIncluded ? Colors.black : Colors.grey[600],
                decoration: isIncluded ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, List<Widget> metrics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...metrics,
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _getFormattedTime(String? scheduledAt) {
    if (scheduledAt == null) return 'Not scheduled';

    final dt = DateTime.tryParse(scheduledAt);
    if (dt == null) return 'Invalid date';

    return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _getStatus(String? status) {
    return status?.toUpperCase() ?? 'UNKNOWN';
  }

  String _getInstructorName(Map<String, dynamic>? teachers) {
    if (teachers == null) return 'Unknown Instructor';

    final userProfiles = teachers['user_profiles'];
    if (userProfiles is Map) {
      final firstName = userProfiles['first_name']?.toString() ?? '';
      final lastName = userProfiles['last_name']?.toString() ?? '';
      return '$firstName $lastName'.trim();
    }

    return 'Unknown Instructor';
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'live':
        return Colors.red;
      case 'scheduled':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
