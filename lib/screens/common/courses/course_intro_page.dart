// screens/common/courses/course_intro_page.dart
import 'package:brainboosters_app/screens/common/courses/data/course_dummy_data.dart';
import 'package:brainboosters_app/screens/common/courses/models/course_model.dart';
import 'package:brainboosters_app/screens/common/courses/widgets/course_content_tab.dart';
import 'package:brainboosters_app/screens/common/courses/widgets/reviews_tab.dart';
import 'package:brainboosters_app/screens/common/courses/widgets/whats_included_tab.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/breadcrumb_widget.dart';
import '../widgets/hero_image_widget.dart';
import '../widgets/stats_widget.dart';
import '../widgets/tab_section_widget.dart';
import 'widgets/course_info_widget.dart';

class CourseIntroPage extends StatefulWidget {
  final String courseId;

  const CourseIntroPage({super.key, required this.courseId});

  @override
  State<CourseIntroPage> createState() => _CourseIntroPageState();
}

class _CourseIntroPageState extends State<CourseIntroPage>
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
    final course = CourseDummyData.courses.firstWhere(
      (c) => c.id == widget.courseId,
      orElse: () => throw Exception('Course not found'),
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
                        'Courses',
                        false,
                        onTap: () => context.go('/courses'),
                      ),
                      BreadcrumbItem(course.title, true),
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
                          'Courses',
                          false,
                          onTap: () => context.go('/courses'),
                        ),
                        BreadcrumbItem(course.title, true),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],

                  // Main Course Section
                  isDesktop || isTablet
                      ? _buildDesktopLayout(course)
                      : _buildMobileLayout(course),

                  const SizedBox(height: 40),

                  // Course Stats
                  StatsWidget(
                    items: [
                      StatItem(
                        icon: Icons.people_outline,
                        text: '6,57,849 Students',
                      ),
                      StatItem(icon: Icons.access_time, text: '6 hr'),
                      StatItem(
                        icon: Icons.calendar_today_outlined,
                        text: 'Last Updated on 23 May, 2023',
                      ),
                    ],
                    trailingWidget: _buildRating(),
                  ),

                  const SizedBox(height: 30),

                  // Tabs Section
                  TabSectionWidget(
                    tabController: _tabController,
                    tabs: const [
                      'About',
                      'Course Content',
                      "What's Included",
                      'Reviews',
                    ],
                    tabViews: [
                      _buildAboutTab(course, isMobile),
                      CourseContentTab(chapters: course.chapters),
                      WhatsIncludedTab(whatsIncluded: course.whatsIncluded),
                      ReviewsTab(reviews: course.reviews),
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

  Widget _buildDesktopLayout(Course course) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Side - Course Image
        Expanded(
          flex: 5,
          child: HeroImageWidget(
            imageUrl: course.imageUrl,
            title: 'The Complete\nPython Course',
            subtitle: 'From Zero to Hero in Python',
            badge: '2025',
            badgeColor: Colors.orange,
            overlayContent: _buildCourseImageOverlay(),
          ),
        ),

        const SizedBox(width: 40),

        // Right Side - Course Info
        Expanded(flex: 6, child: CourseInfoWidget(course: course)),
      ],
    );
  }

  Widget _buildMobileLayout(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroImageWidget(
          imageUrl: course.imageUrl,
          title: 'The Complete\nPython Course',
          subtitle: 'From Zero to Hero in Python',
          badge: '2025',
          badgeColor: Colors.orange,
          overlayContent: _buildCourseImageOverlay(),
        ),
        const SizedBox(height: 20),
        CourseInfoWidget(course: course),
      ],
    );
  }

  Widget _buildCourseImageOverlay() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;

    return Stack(
      children: [
        // Background pattern/design
        Positioned(
          top: 20,
          left: 20,
          child: Container(
            width: isMobile ? 50 : 60,
            height: isMobile ? 50 : 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.code,
              color: Colors.white,
              size: isMobile ? 25 : 30,
            ),
          ),
        ),

        // Python logo/icon
        Positioned(
          top: 30,
          left: 30,
          child: Container(
            width: isMobile ? 35 : 40,
            height: isMobile ? 35 : 40,
            decoration: const BoxDecoration(
              color: Colors.yellow,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'Py',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
            ),
          ),
        ),

        // Main content
        Positioned(
          left: 20,
          bottom: isMobile ? 60 : 80,
          right: isMobile ? 20 : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The Complete\nPython Course',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 22 : 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'From Zero to Hero in Python',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
            ],
          ),
        ),

        // Year badge
        Positioned(
          left: 20,
          bottom: 20,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '2025',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ),
        ),

        // Instructor image
        if (!isMobile)
          Positioned(
            right: 20,
            bottom: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://picsum.photos/120/180?random=instructor',
                width: 120,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRating() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Icon(
              Icons.star,
              size: 16,
              color: index < 4 ? Colors.amber : Colors.grey[300],
            );
          }),
        ),
        const SizedBox(width: 8),
        const Text(
          '4.8',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 4),
        Text(
          '(137 ratings)',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildAboutTab(Course course, bool isMobile) {
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
            'Ready to master one of the most powerful and in-demand programming languages? This hands-on, beginner-friendly course takes you from the very basics of Python all the way to building real-world applications. Whether you\'re a total newbie or looking to sharpen your skills, this course has you covered.',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'What you\'ll learn:',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildLearningPoint(
            'Python fundamentals: variables, data types, loops, functions, and more',
            isMobile,
          ),
          _buildLearningPoint(
            'Object-Oriented Programming (OOP) in Python',
            isMobile,
          ),
          _buildLearningPoint(
            'File handling, error handling, and working with libraries',
            isMobile,
          ),
          _buildLearningPoint(
            'Real-world projects to boost your confidence',
            isMobile,
          ),
          _buildLearningPoint(
            'An intro to web development, automation, and data analysis with Python',
            isMobile,
          ),
          const SizedBox(height: 24),
          Text(
            'Why join?',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildLearningPoint('No prior coding experience needed', isMobile),
          _buildLearningPoint(
            'Learn by doing – practical assignments and mini-projects',
            isMobile,
          ),
          _buildLearningPoint(
            'Get mentored by experts from The Leaders Academy',
            isMobile,
          ),
          _buildLearningPoint(
            'Lifetime access & certification upon completion',
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildLearningPoint(String text, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
