import 'dart:convert';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'course_intro_repository.dart';
import '../../widgets/breadcrumb_widget.dart';
import '../../widgets/tab_section_widget.dart';
import 'widgets/course_content_tab.dart';
import 'widgets/reviews_tab.dart';
import 'widgets/whats_included_tab.dart';
import 'widgets/course_hero_section.dart';
import 'widgets/course_stats_section.dart';
import 'widgets/course_about_tab.dart';

class CourseIntroPage extends StatefulWidget {
  final String courseId;

  const CourseIntroPage({super.key, required this.courseId});

  @override
  State<CourseIntroPage> createState() => _CourseIntroPageState();
}

class _CourseIntroPageState extends State<CourseIntroPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _courseData;
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  String? _error;
  bool _isEnrolled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadCourse();
    });
  }

  Future<void> _loadCourse() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
          _courseData = null;
        });
      }

      final results = await Future.wait([
        CourseIntroRepository.getCourseById(widget.courseId),
        CourseIntroRepository.getCourseReviews(widget.courseId),
      ]);

      final courseData = results[0] as Map<String, dynamic>?;
      final reviews = results[1] as List<Map<String, dynamic>>;

      if (!mounted) return;

      if (courseData == null) {
        setState(() {
          _error = 'Course not found';
          _isLoading = false;
          _courseData = null;
        });
        return;
      }

      final isEnrolled = courseData['enrollment'] != null;

      setState(() {
        _courseData = courseData;
        _reviews = reviews;
        _isEnrolled = isEnrolled;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load course: $e';
          _isLoading = false;
          _courseData = null;
        });
      }
    }
  }

  void _onEnrollmentChanged() => _loadCourse();

  void _handleBackNavigation() {
    if (GoRouter.of(context).canPop()) {
      context.pop();
    } else {
      context.go(CommonRoutes.coursesRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (_isLoading || _courseData == null) {
              return _buildLoadingState();
            }

            if (_error != null) {
              return _buildErrorState();
            }

            return _buildCourseContent(_courseData!);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _handleBackNavigation,
          ),
          title: const Text('Loading...'),
        ),
        const Expanded(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _handleBackNavigation,
          ),
          title: const Text('Error'),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(color: Colors.red[600], fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadCourse,
                    child: const Text('Retry'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go(CommonRoutes.coursesRoute),
                    child: const Text('Back to Courses'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseContent(Map<String, dynamic> course) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;
    final isMobile = screenWidth <= 768;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          pinned: true,
          expandedHeight: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _handleBackNavigation,
          ),
          title: isMobile ? null : _buildBreadcrumbs(course),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 80 : (isTablet ? 40 : 16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                if (isMobile) ...[
                  _buildBreadcrumbs(course),
                  const SizedBox(height: 20),
                ],
                CourseHeroSection(
                  course: course,
                  isEnrolled: _isEnrolled,
                  onEnrollmentChanged: _onEnrollmentChanged,
                  isDesktop: isDesktop,
                  isTablet: isTablet,
                ),
                const SizedBox(height: 40),
                CourseStatsSection(course: course),
                const SizedBox(height: 30),
                Expanded(
                  child: TabSectionWidget(
                    tabController: _tabController,
                    tabs: const [
                      'About',
                      'Course Content',
                      "What's Included",
                      'Reviews',
                    ],
                    tabViews: [
                      CourseAboutTab(course: course),
                      CourseContentTab(chapters: _getChapters(course)),
                      WhatsIncludedTab(whatsIncluded: _getWhatsIncluded(course)),
                      ReviewsTab(reviews: _reviews),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreadcrumbs(Map<String, dynamic> course) {
    return BreadcrumbWidget(
      items: [
        BreadcrumbItem('Home', false, onTap: () => context.go('/')),
        BreadcrumbItem('Courses', false, onTap: () => context.go('/courses')),
        BreadcrumbItem(course['title']?.toString() ?? 'Course', true),
      ],
    );
  }

  List<Map<String, dynamic>> _getChapters(Map<String, dynamic> course) {
    final chapters = course['chapters'] as List?;
    if (chapters == null) return [];
    return chapters.map((chapter) => Map<String, dynamic>.from(chapter)).toList();
  }

  List<String> _getWhatsIncluded(Map<String, dynamic> course) {
    final courseIncludes = course['course_includes'];
    return _parseJsonArray(courseIncludes);
  }

  List<String> _parseJsonArray(dynamic jsonData) {
    if (jsonData == null) return [];
    if (jsonData is List) {
      return jsonData.map((item) => item.toString()).toList();
    }
    if (jsonData is String) {
      try {
        final parsed = jsonDecode(jsonData);
        if (parsed is List) {
          return parsed.map((item) => item.toString()).toList();
        }
      } catch (e) {
        debugPrint('Error parsing JSON: $e');
      }
    }
    return [];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
