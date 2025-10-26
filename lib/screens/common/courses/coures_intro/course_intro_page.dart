// screens/common/courses/coures_intro/course_intro_page.dart

import 'dart:convert';
import 'package:brainboosters_app/screens/common/widgets/tab_section_widget.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'course_intro_repository.dart';
import '../../widgets/breadcrumb_widget.dart';
import 'widgets/course_about_tab.dart';
import 'widgets/course_content_tab.dart';
import 'widgets/course_hero_section.dart';
import 'widgets/course_stats_section.dart';
import 'widgets/reviews_tab.dart';
import 'widgets/whats_included_tab.dart';

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
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        CourseIntroRepository.getCourseById(widget.courseId),
        CourseIntroRepository.getCourseReviews(widget.courseId),
      ]);

      if (!mounted) return;

      final courseData = results[0] as Map<String, dynamic>?;
      final reviews = results[1] as List<Map<String, dynamic>>;

      if (courseData == null) {
        setState(() {
          _error = 'Course not found or not available.';
          _isLoading = false;
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
          _error = 'Failed to load course details: $e';
          _isLoading = false;
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
            if (_isLoading) {
              return _buildLoadingState();
            }
            if (_error != null) {
              return _buildErrorState();
            }
            if (_courseData != null) {
              return _buildCourseContent(_courseData!);
            }
            return Container(); // Should not happen
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState() {
    return Center(
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
          ],
        ),
      ),
    );
  }

  Widget _buildCourseContent(Map<String, dynamic> course) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isDesktop = screenWidth > 1200;
  final isTablet = screenWidth > 768 && screenWidth <= 1200;
  final isMobile = screenWidth <= 768;

  return Column(
    children: [
      // ✅ FIXED: Use regular AppBar instead of SliverAppBar
      AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _handleBackNavigation,
        ),
        title: isMobile ? null : _buildBreadcrumbs(course),
      ),
      // ✅ FIXED: Use Expanded here instead of SliverFillRemaining
      Expanded(
        child: SingleChildScrollView(
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
              // ✅ FIXED: Set explicit height for TabSection
              SizedBox(
                height: 600, // Or calculate based on screen height
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
                    CourseContentTab(chapters: course['chapters'] ?? []),
                    WhatsIncludedTab(whatsIncluded: _getWhatsIncluded(course)),
                    ReviewsTab(reviews: _reviews),
                  ],
                ),
              ),
              const SizedBox(height: 40),
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
        BreadcrumbItem('Courses', false,
            onTap: () => context.go('/courses')),
        BreadcrumbItem(course['title']?.toString() ?? 'Course', true),
      ],
    );
  }

  // ✅ FIXED: Changed from _getChapters to _getLessons to match repository
  List<Map<String, dynamic>> _getLessons(Map<String, dynamic> course) {
    final lessons = course['lessons'] as List?;
    if (lessons == null) return [];
    return lessons.map((lesson) => Map<String, dynamic>.from(lesson)).toList();
  }

  List<String> _getWhatsIncluded(Map<String, dynamic> course) {
    final courseIncludes = course['course_includes'];
    if (courseIncludes is Map && courseIncludes.containsKey('includes')) {
      final includes = courseIncludes['includes'];
      if (includes is List) {
        return includes.map((item) => item.toString()).toList();
      }
    }
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
      } catch (_) {}
    }
    return [];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

