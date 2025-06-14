// screens/common/live_class/live_class_intro_page.dart
import 'package:brainboosters_app/screens/Student/dashboard/data/live_class_dummy_data.dart';
import 'package:brainboosters_app/screens/Student/dashboard/data/models/live_class_model.dart';
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

class _LiveClassIntroPageState extends State<LiveClassIntroPage> with TickerProviderStateMixin {
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
            title: isMobile ? null : BreadcrumbWidget(
              items: [
                BreadcrumbItem('Home', false),
                BreadcrumbItem('Python Coaching Centers', false),
                BreadcrumbItem('The Leaders Academy', false),
                BreadcrumbItem('Live Classes', false),
                BreadcrumbItem('The 10 weeks Python Bootcamp', true),
              ],
            ),
            actions: [
              if (!isMobile) ...[
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.black),
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
                        BreadcrumbItem('Home', false),
                        BreadcrumbItem('Python Coaching Centers', false),
                        BreadcrumbItem('The Leaders Academy', false),
                        BreadcrumbItem('Live Classes', false),
                        BreadcrumbItem('The 10 weeks Python Bootcamp', true),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Main Live Class Section
                  isDesktop || isTablet 
                    ? _buildDesktopLayout(liveClass)
                    : _buildMobileLayout(liveClass),
                  
                  const SizedBox(height: 40),
                  
                  // Live Class Stats
                  StatsWidget(
                    items: [
                      StatItem(
                        icon: Icons.people_outline,
                        text: '50 Students Enrolled',
                      ),
                      StatItem(
                        icon: Icons.access_time,
                        text: 'Mon - Fri 7:00 PM to 9:00 PM',
                      ),
                      StatItem(
                        icon: Icons.calendar_today_outlined,
                        text: 'Starts on 4th Aug 2025',
                      ),
                    ],
                    trailingWidget: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: const Text(
                        'Limited Seats only!',
                        style: TextStyle(
                          color: Colors.blue,
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
                    tabs: const ['About', 'Syllabus', "What's included", 'About the Instructor'],
                    tabViews: [
                      _buildAboutTab(liveClass, isMobile),
                      _buildSyllabusTab(),
                      _buildWhatsIncludedTab(),
                      _buildInstructorTab(),
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

  Widget _buildDesktopLayout(LiveClass liveClass) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Side - Live Class Image
        Expanded(
          flex: 5,
          child: HeroImageWidget(
            imageUrl: liveClass.imageUrl,
            title: 'The 10 weeks Python Bootcamp',
            subtitle: 'Learn Python like a Professional! Start from the basics and go all the way to creating your own applications and games',
            badge: 'Live Class',
            badgeColor: Colors.green,
            overlayContent: _buildImageOverlay(),
          ),
        ),
        
        const SizedBox(width: 40),
        
        // Right Side - Live Class Info
        Expanded(
          flex: 6,
          child: LiveClassInfoWidget(liveClass: liveClass),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(LiveClass liveClass) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroImageWidget(
          imageUrl: liveClass.imageUrl,
          title: 'The 10 weeks Python Bootcamp',
          subtitle: 'Learn Python like a Professional! Start from the basics and go all the way to creating your own applications and games',
          badge: 'Live Class',
          badgeColor: Colors.green,
          overlayContent: _buildImageOverlay(),
        ),
        const SizedBox(height: 20),
        LiveClassInfoWidget(liveClass: liveClass),
      ],
    );
  }

  Widget _buildImageOverlay() {
    return Positioned(
      left: 20,
      top: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Live Class',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '10 wk\nPython\nBootcamp',
            style: TextStyle(
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
            'Jumpstart your coding journey with this fast-paced, hands-on 10-week Python Bootcamp. Designed for absolute beginners and aspiring developers, this live online class helps you build strong Python skills from the ground up — in just 10 weeks.',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'What to Expect:',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 12),
          _buildExpectationItem('✅ Live instructor-led sessions every week', isMobile),
          _buildExpectationItem('✅ Clear explanations + practical coding challenges', isMobile),
          _buildExpectationItem('✅ Build mini-projects after every module', isMobile),
          const SizedBox(height: 24),
          Text(
            'Learn the essentials:',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildLearningPoint('• Python basics', isMobile),
          _buildLearningPoint('• Functions & loops', isMobile),
          _buildLearningPoint('• Data structures', isMobile),
          _buildLearningPoint('• OOP (Object-Oriented Programming)', isMobile),
          _buildLearningPoint('• File handling & error handling', isMobile),
          _buildLearningPoint('• Introduction to real-world use cases (automation, web, data)', isMobile),
          const SizedBox(height: 24),
          Text(
            'Perfect for:',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Students, career-switchers, entrepreneurs, or anyone who wants to learn Python the right way — fast, structured, and interactive.',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpectationItem(String text, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isMobile ? 14 : 16,
          color: Colors.green,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildLearningPoint(String text, bool isMobile) {
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

  Widget _buildSyllabusTab() {
    return const Center(
      child: Text('Syllabus content will be displayed here'),
    );
  }

  Widget _buildWhatsIncludedTab() {
    return const Center(
      child: Text('What\'s included content will be displayed here'),
    );
  }

  Widget _buildInstructorTab() {
    return const Center(
      child: Text('Instructor information will be displayed here'),
    );
  }
}
