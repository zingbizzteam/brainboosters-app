import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'course_intro_repository.dart';
import '../../widgets/breadcrumb_widget.dart';
import '../../widgets/hero_image_widget.dart';
import '../../widgets/stats_widget.dart';
import '../../widgets/tab_section_widget.dart';
import 'widgets/course_info_widget.dart';
import 'widgets/course_content_tab.dart';
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
    // FIXED: Schedule data loading after the first frame is built
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadCourse();
    });
  }

  // FIXED: Enhanced data loading method with better safety
  Future<void> _loadCourse() async {
    try {
      // FIXED: Always set loading state at the beginning
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
          _courseData = null; // Clear previous data
        });
      }

      final results = await Future.wait([
        CourseIntroRepository.getCourseById(widget.courseId),
        CourseIntroRepository.getCourseReviews(widget.courseId),
      ]);

      final courseData = results[0] as Map<String, dynamic>?;
      final reviews = results[1] as List<Map<String, dynamic>>;

      if (!mounted) return; // Exit if widget is disposed

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

  void _onEnrollmentChanged() {
    _loadCourse();
  }

  // FIXED: Safe navigation helper
  void _handleBackNavigation() {
    if (GoRouter.of(context).canPop()) {
      context.pop();
    } else {
      context.go('/courses');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            // FIXED: All logic inside Builder to ensure proper state checking
            if (_isLoading || _courseData == null) {
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

            if (_error != null) {
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
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: TextStyle(
                                color: Colors.red[600],
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _loadCourse,
                              child: const Text('Retry'),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => context.go('/courses'),
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

            // Now we know _courseData is not null
            final course = _courseData!;
            return _buildCourseContent(course);
          },
        ),
      ),
    );
  }

  // FIXED: Separate method for course content to ensure course is never null
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
          title: isMobile
              ? null
              : BreadcrumbWidget(
                  items: [
                    BreadcrumbItem('Home', false, onTap: () => context.go('/')),
                    BreadcrumbItem(
                      'Courses',
                      false,
                      onTap: () => context.go('/courses'),
                    ),
                    BreadcrumbItem(
                      course['title']?.toString() ?? 'Course',
                      true,
                    ),
                  ],
                ),
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
                      BreadcrumbItem(
                        course['title']?.toString() ?? 'Course',
                        true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                isDesktop || isTablet
                    ? _buildDesktopLayout(course)
                    : _buildMobileLayout(course),

                const SizedBox(height: 40),

                StatsWidget(
                  items: [
                    StatItem(
                      icon: Icons.people_outline,
                      text: '${course['enrollment_count'] ?? 0} Students',
                    ),
                    StatItem(
                      icon: Icons.access_time,
                      text:
                          '${course['duration_hours']?.toStringAsFixed(1) ?? '0'} hr',
                    ),
                    StatItem(
                      icon: Icons.play_circle_outline,
                      text: '${course['total_lessons'] ?? 0} Lessons',
                    ),
                    StatItem(
                      icon: Icons.calendar_today_outlined,
                      text: 'Updated ${_formatDate(course['last_updated'])}',
                    ),
                  ],
                  trailingWidget: _buildRating(course),
                ),

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
                      _buildAboutTab(course, isMobile),
                      CourseContentTab(chapters: _getChapters(course)),
                      WhatsIncludedTab(
                        whatsIncluded: _getWhatsIncluded(course),
                      ),
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

  Widget _buildDesktopLayout(Map<String, dynamic> course) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: HeroImageWidget(
            imageUrl: course['thumbnail_url']?.toString() ?? '',
            title: course['title']?.toString() ?? '',
            subtitle: course['short_description']?.toString() ?? '',
            badge: DateTime.now().year.toString(),
            badgeColor: Colors.orange,
            overlayContent: _buildCourseImageOverlay(course),
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 6,
          child: CourseInfoWidget(
            course: course,
            isEnrolled: _isEnrolled,
            onEnrollmentChanged: _onEnrollmentChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Map<String, dynamic> course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroImageWidget(
          imageUrl: course['thumbnail_url']?.toString() ?? '',
          title: course['title']?.toString() ?? '',
          subtitle: course['short_description']?.toString() ?? '',
          badge: DateTime.now().year.toString(),
          badgeColor: Colors.orange,
          overlayContent: _buildCourseImageOverlay(course),
        ),
        const SizedBox(height: 20),
        CourseInfoWidget(
          course: course,
          isEnrolled: _isEnrolled,
          onEnrollmentChanged: _onEnrollmentChanged,
        ),
      ],
    );
  }

  Widget _buildCourseImageOverlay(Map<String, dynamic> course) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;

    return Stack(
      children: [
        Positioned(
          top: 20,
          left: 20,
          child: Container(
            width: isMobile ? 50 : 60,
            height: isMobile ? 50 : 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.school,
              color: Colors.white,
              size: isMobile ? 25 : 30,
            ),
          ),
        ),
        Positioned(
          left: 20,
          bottom: isMobile ? 60 : 80,
          right: isMobile ? 20 : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course['title']?.toString() ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 22 : 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                course['short_description']?.toString() ??
                    course['description']?.toString() ??
                    '',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isMobile ? 14 : 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
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
              DateTime.now().year.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ),
        ),
        if (!isMobile && _getTeachers(course).isNotEmpty)
          Positioned(
            right: 20,
            bottom: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _getTeachers(course).first['avatar_url'] ??
                    'https://picsum.photos/120/180?random=instructor',
                width: 120,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 180,
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, size: 40),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRating(Map<String, dynamic> course) {
    final rating = (course['rating'] as num?)?.toDouble() ?? 0.0;
    final totalReviews = course['total_reviews'] as int? ?? 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Icon(
              Icons.star,
              size: 16,
              color: index < rating.floor() ? Colors.amber : Colors.grey[300],
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 4),
        Text(
          '($totalReviews ratings)',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildAboutTab(Map<String, dynamic> course, bool isMobile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailSection('Course Details', [
            _buildDetailRow(
              'Category',
              course['category']?.toString() ?? 'Not specified',
            ),
            if (course['subcategory'] != null)
              _buildDetailRow('Subcategory', course['subcategory'].toString()),
            _buildDetailRow(
              'Level',
              course['level']?.toString() ?? 'Not specified',
            ),
            _buildDetailRow(
              'Language',
              course['language']?.toString() ?? 'English',
            ),
            if (course['duration_hours'] != null)
              _buildDetailRow('Duration', '${course['duration_hours']} hours'),
            if (course['total_lessons'] != null && course['total_lessons'] > 0)
              _buildDetailRow(
                'Total Lessons',
                '${course['total_lessons']} lessons',
              ),
          ], isMobile),

          const SizedBox(height: 24),

          Text(
            'Description',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            course['about']?.toString() ??
                course['description']?.toString() ??
                'No description available.',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),

          if (course['what_you_learn'] != null) ...[
            const SizedBox(height: 24),
            Text(
              'What you\'ll learn:',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...(_parseJsonArray(
              course['what_you_learn'],
            ).map((item) => _buildLearningPoint(item.toString(), isMobile))),
          ],

          if (course['prerequisites'] != null &&
              _parseJsonArray(course['prerequisites']).isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Prerequisites:',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...(_parseJsonArray(
              course['prerequisites'],
            ).map((item) => _buildLearningPoint(item.toString(), isMobile))),
          ],

          if (course['course_requirements'] != null) ...[
            const SizedBox(height: 24),
            Text(
              'Requirements:',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...(_parseJsonArray(
              course['course_requirements'],
            ).map((item) => _buildLearningPoint(item.toString(), isMobile))),
          ],

          if (course['target_audience'] != null) ...[
            const SizedBox(height: 24),
            Text(
              'Who this course is for:',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...(_parseJsonArray(
              course['target_audience'],
            ).map((item) => _buildLearningPoint(item.toString(), isMobile))),
          ],

          if (course['tags'] != null &&
              _parseJsonArray(course['tags']).isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Tags:',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (_parseJsonArray(course['tags']).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Text(
                    tag.toString(),
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList()),
            ),
          ],

          // Add bottom spacing for tab content
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    List<Widget> details,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(children: details),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
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

  // Helper methods to extract data from the new structure
  List<Map<String, dynamic>> _getTeachers(Map<String, dynamic> course) {
    final courseTeachers = course['course_teachers'] as List?;
    if (courseTeachers == null) return [];

    return courseTeachers.map((ct) {
      final teacher = ct['teachers'] as Map<String, dynamic>?;
      final userProfile = teacher?['user_profiles'] as Map<String, dynamic>?;

      return {
        'id': teacher?['id'],
        'name':
            '${userProfile?['first_name'] ?? ''} ${userProfile?['last_name'] ?? ''}'
                .trim(),
        'avatar_url': userProfile?['avatar_url'],
        'role': ct['role'],
        'is_primary': ct['is_primary'],
      };
    }).toList();
  }

  List<Map<String, dynamic>> _getChapters(Map<String, dynamic> course) {
    final chapters = course['chapters'] as List?;
    if (chapters == null) return [];

    return chapters
        .map((chapter) => Map<String, dynamic>.from(chapter))
        .toList();
  }

  // Returns a List<String> of included features for WhatsIncludedTab
  List<String> _getWhatsIncluded(Map<String, dynamic> course) {
    final courseIncludes = course['course_includes'];
    return _parseJsonArray(courseIncludes);
  }

  // FIXED: Helper method to parse JSON arrays from your seed data
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
        print('Error parsing JSON: $e');
      }
    }

    return [];
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';

    try {
      final dateTime = date is DateTime
          ? date
          : DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
