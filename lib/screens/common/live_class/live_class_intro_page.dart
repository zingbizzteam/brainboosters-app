// screens/common/live_class/live_class_intro_page.dart
import 'package:brainboosters_app/screens/common/live_class/data/live_class_dummy_data.dart';
import 'package:brainboosters_app/screens/common/live_class/models/live_class_model.dart';
import 'package:brainboosters_app/screens/common/widgets/breadcrumb_widget.dart';
import 'package:brainboosters_app/screens/common/widgets/hero_image_widget.dart';
import 'package:brainboosters_app/screens/common/widgets/stats_widget.dart';
import 'package:brainboosters_app/screens/common/widgets/tab_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liveClass = LiveClassDummyData.liveClasses.firstWhere(
      (lc) => lc.id == widget.liveClassId,
      orElse: () => throw Exception('Live class not found'),
    );

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
              onPressed: () => context.pop(),
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
                      BreadcrumbItem(liveClass.title, true),
                    ],
                  ),
            actions: [
              if (!isMobile) ...[
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {},
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Sivakumar',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(
                          'https://picsum.photos/32/32?random=user',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
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
                        BreadcrumbItem(liveClass.title, true),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Main Live Class Section
                  isDesktop || isTablet
                      ? _buildDesktopLayout(liveClass)
                      : _buildMobileLayout(liveClass),

                  const SizedBox(height: 40),

                  // Live Class Stats with Analytics
                  StatsWidget(
                    items: [
                      StatItem(
                        icon: Icons.people_outline,
                        text:
                            '${liveClass.currentParticipants}/${liveClass.maxParticipants} Enrolled',
                      ),
                      StatItem(
                        icon: Icons.access_time,
                        text: liveClass.formattedTime,
                      ),
                      StatItem(
                        icon: Icons.visibility,
                        text: '${liveClass.viewCount} Views',
                      ),
                      StatItem(
                        icon: Icons.star,
                        text:
                            '${liveClass.rating} (${liveClass.totalRatings} reviews)',
                      ),
                    ],
                    trailingWidget: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          liveClass.status,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(liveClass.status),
                        ),
                      ),
                      child: Text(
                        liveClass.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(liveClass.status),
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
                    tabs: const [
                      'About',
                      'Comments',
                      "What's included",
                      'Analytics',
                    ],
                    tabViews: [
                      _buildAboutTab(liveClass, isMobile),
                      _buildCommentsTab(liveClass, isMobile),
                      _buildWhatsIncludedTab(liveClass, isMobile),
                      _buildAnalyticsTab(liveClass, isMobile),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'live':
        return Colors.red;
      case 'upcoming':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDesktopLayout(LiveClass liveClass) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Side - Live Class Image
        Expanded(
          flex: 5,
          child: HeroImageWidget(
            imageUrl: liveClass.imageUrl,
            title: liveClass.title,
            subtitle: liveClass.description,
            badge: 'Live Class',
            badgeColor: _getStatusColor(liveClass.status),
            overlayContent: _buildImageOverlay(liveClass),
          ),
        ),
        const SizedBox(width: 40),
        // Right Side - Live Class Info
        Expanded(flex: 6, child: LiveClassInfoWidget(liveClass: liveClass)),
      ],
    );
  }

  Widget _buildMobileLayout(LiveClass liveClass) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroImageWidget(
          imageUrl: liveClass.imageUrl,
          title: liveClass.title,
          subtitle: liveClass.description,
          badge: 'Live Class',
          badgeColor: _getStatusColor(liveClass.status),
          overlayContent: _buildImageOverlay(liveClass),
        ),
        const SizedBox(height: 20),
        LiveClassInfoWidget(liveClass: liveClass),
      ],
    );
  }

  Widget _buildImageOverlay(LiveClass liveClass) {
    return Positioned(
      left: 20,
      top: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(liveClass.status),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              liveClass.status.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            liveClass.subject,
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

  Widget _buildAboutTab(LiveClass liveClass, bool isMobile) {
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
            liveClass.description,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),

          if (liveClass.prerequisites.isNotEmpty) ...[
            Text(
              'Prerequisites:',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            ...liveClass.prerequisites.map(
              (prereq) => _buildBulletPoint('• $prereq', isMobile),
            ),
            const SizedBox(height: 24),
          ],

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
            '${liveClass.duration} minutes',
            isMobile,
          ),
          _buildDetailRow('Difficulty', liveClass.difficulty, isMobile),
          _buildDetailRow('Language', liveClass.language, isMobile),
          _buildDetailRow('Instructor', liveClass.instructor, isMobile),
          _buildDetailRow('Academy', liveClass.academy, isMobile),
        ],
      ),
    );
  }

  Widget _buildCommentsTab(LiveClass liveClass, bool isMobile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Comments (${liveClass.comments.length})',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Engagement: ${liveClass.engagementPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (liveClass.comments.isEmpty)
            const Center(
              child: Text(
                'No comments yet. Be the first to comment!',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...liveClass.comments.map(
              (comment) => _buildCommentCard(comment, isMobile),
            ),
        ],
      ),
    );
  }

  Widget _buildWhatsIncludedTab(LiveClass liveClass, bool isMobile) {
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
            true,
          ),
          _buildIncludedItem(
            Icons.download,
            'Downloadable Resources',
            liveClass.isRecordingAvailable,
          ),
          _buildIncludedItem(
            Icons.video_library,
            'Recording Access',
            liveClass.isRecordingAvailable,
          ),
          _buildIncludedItem(
            Icons.edit_document,
            'Certificate',
            liveClass.metadata['certification'] == true,
          ),
          _buildIncludedItem(Icons.group, 'Community Access', true),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(LiveClass liveClass, bool isMobile) {
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

          // Engagement Metrics
          _buildAnalyticsCard('Engagement Metrics', [
            _buildMetricRow(
              'Average Engagement',
              '${liveClass.engagementPercentage.toStringAsFixed(1)}%',
            ),
            _buildMetricRow('Chat Messages', '${liveClass.chatMessageCount}'),
            _buildMetricRow('Reactions', '${liveClass.reactionCount}'),
            _buildMetricRow('Questions Asked', '${liveClass.questionsAsked}'),
          ]),

          const SizedBox(height: 20),

          // Participation Metrics
          _buildAnalyticsCard('Participation', [
            _buildMetricRow('Total Views', '${liveClass.viewCount}'),
            _buildMetricRow(
              'Current Participants',
              '${liveClass.currentParticipants}',
            ),
            _buildMetricRow('Max Capacity', '${liveClass.maxParticipants}'),
            _buildMetricRow(
              'Resource Downloads',
              '${liveClass.resourceDownloads}',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isMobile ? 14 : 16,
          color: Colors.grey[700],
          height: 1.5,
        ),
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
            width: 100,
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

  Widget _buildCommentCard(LiveClassComment comment, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(comment.userAvatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatTimestamp(comment.timestamp),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${comment.likes}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(comment.text, style: const TextStyle(fontSize: 14)),

          // Replies
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...comment.replies.map(
              (reply) => Container(
                margin: const EdgeInsets.only(left: 20, top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: NetworkImage(reply.userAvatarUrl),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          reply.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(reply.text, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
