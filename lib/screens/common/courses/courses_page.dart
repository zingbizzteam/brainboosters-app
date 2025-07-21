// screens/common/courses/courses_page.dart - ENHANCED VERSION
import 'package:brainboosters_app/screens/common/courses/course_repository.dart';
import 'package:brainboosters_app/screens/common/courses/widgets/course_footer_section.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/course_hero_section.dart';
import 'widgets/course_categories_section.dart';
import 'widgets/app_promotion_section.dart';
import 'widgets/horizontal_course_list.dart';
import 'widgets/all_courses_grid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  // ... [Keep all your existing state variables] ...

  List<Map<String, dynamic>> _suggestedCourses = [];
  List<Map<String, dynamic>> _topRatedCourses = [];
  bool _loadingFeatured = true;
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _allCourses = [];
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  static const int _pageSize = 8;
  String? _errorMessage;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  bool _isRefreshing = false;
  bool _categoriesRefreshTrigger = false;
  int _refreshCompletedComponents = 0;
  bool _heroRefreshTrigger = false;
  static const int _totalRefreshComponents = 3;

  // ... [Keep all your existing methods] ...

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final threshold = position.maxScrollExtent - 300;

    if (position.pixels >= threshold &&
        !_loadingMore &&
        _hasMore &&
        _errorMessage == null &&
        _allCourses.isNotEmpty &&
        !_isRefreshing) {
      debugPrint('Scroll threshold reached, loading more courses...');
      _fetchAllCourses();
    }
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    debugPrint('DEBUG: Starting coordinated refresh...');

    setState(() {
      _isRefreshing = true;
      _refreshCompletedComponents = 0;
      _categoriesRefreshTrigger = true;
      _heroRefreshTrigger = true;
      _page = 1;
      _hasMore = true;
    });

    CourseRepository.clearCache();

    await Future.wait([
      _fetchFeaturedCourses(isRefresh: true),
      _fetchAllCourses(isRefresh: true),
    ]);
  }

  void _onComponentRefreshComplete() {
    _refreshCompletedComponents++;
    debugPrint(
      'DEBUG: Component refresh completed ($_refreshCompletedComponents/$_totalRefreshComponents)',
    );

    if (_refreshCompletedComponents >= _totalRefreshComponents) {
      setState(() {
        _isRefreshing = false;
        _categoriesRefreshTrigger = false;
        _heroRefreshTrigger = false;
      });
      debugPrint('DEBUG: All components refresh completed');
    }
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _loadingFeatured = true;
      _errorMessage = null;
    });
    await Future.wait([_fetchFeaturedCourses(), _fetchAllCourses()]);
  }

  Future<void> _fetchAllCourses({bool isRefresh = false}) async {
    if (_loadingMore && !isRefresh) return;

    setState(() {
      _loadingMore = true;
      _errorMessage = null;
    });

    try {
      debugPrint(
        'DEBUG: ${isRefresh ? "Refreshing" : "Loading"} all courses...',
      );

      final result = await CourseRepository.getCourses(
        limit: _pageSize,
        offset: (_page - 1) * _pageSize,
        sortBy: CourseSortBy.newest,
      );

      if (mounted) {
        setState(() {
          if (_page == 1 || isRefresh) {
            _allCourses = result.courses;
          } else {
            _allCourses.addAll(result.courses);
          }

          _hasMore = result.hasMore;
          if (_hasMore && !isRefresh) {
            _page++;
          }

          _loadingMore = false;
          _retryCount = 0;
        });

        debugPrint('DEBUG: All courses loaded: ${_allCourses.length} total');

        if (isRefresh) {
          _onComponentRefreshComplete();
        }
      }
    } catch (e) {
      debugPrint('ERROR: Failed to fetch all courses: $e');

      if (mounted) {
        setState(() {
          _loadingMore = false;
          _errorMessage = 'Failed to load courses: $e';
        });

        if (isRefresh) {
          _onComponentRefreshComplete();
        }
      }
    }
  }

  Future<void> _fetchFeaturedCourses({bool isRefresh = false}) async {
    try {
      if (!isRefresh) {
        setState(() {
          _loadingFeatured = true;
        });
      }

      debugPrint(
        'DEBUG: ${isRefresh ? "Refreshing" : "Loading"} featured courses...',
      );

      final featured = await CourseRepository.getFeaturedCourses(limit: 8);

      if (mounted) {
        setState(() {
          _topRatedCourses = featured.topRated;
          _suggestedCourses = featured.suggested;
          _loadingFeatured = false;
        });

        debugPrint('DEBUG: Featured courses loaded:');
        debugPrint('  - Top rated: ${_topRatedCourses.length} courses');
        debugPrint('  - Suggested: ${_suggestedCourses.length} courses');

        if (isRefresh) {
          _onComponentRefreshComplete();
        }
      }
    } catch (e) {
      debugPrint('ERROR: Failed to fetch featured courses: $e');

      if (mounted) {
        setState(() {
          _loadingFeatured = false;
          _topRatedCourses = [];
          _suggestedCourses = [];
        });

        if (isRefresh) {
          _onComponentRefreshComplete();
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // NEW: Build enhanced navigation section
  Widget _buildNavigationSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'Explore Learning',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 12),

          // Navigation buttons row
          Row(
            children: [
              Expanded(
                child: _buildNavigationButton(
                  icon: Icons.live_tv_rounded,
                  title: 'Live Classes',
                  subtitle: 'Join interactive sessions',
                  color: Colors.red[500]!,
                  onTap: () => context.go(CommonRoutes.liveClassesRoute),
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 12),

              // Coaching Centers button
              Expanded(
                child: _buildNavigationButton(
                  icon: Icons.school_rounded,
                  title: 'Centers',
                  subtitle: 'Browse institutions',
                  color: Colors.blue[500]!,
                  onTap: () => context.go('/coaching-centers'),
                  isPrimary: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // NEW: Reusable navigation button component
  Widget _buildNavigationButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPrimary ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary ? color.withOpacity(0.3) : Colors.grey[200]!,
            width: isPrimary ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(isPrimary ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey[600],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[900],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Colors.blue,
        backgroundColor: Colors.white,
        strokeWidth: 2.5,
        displacement: 40.0,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Hero section
              CourseHeroSection(
                courseId: "990e8400-e29b-41d4-a716-446655440001",
                forceRefresh: _heroRefreshTrigger,
                onRefreshComplete: _onComponentRefreshComplete,
              ),

              // NEW: Enhanced navigation section
              _buildNavigationSection(),

              // Categories section
              CourseCategoriesSection(
                forceRefresh: _categoriesRefreshTrigger,
                onRefreshComplete: _onComponentRefreshComplete,
              ),

              // Suggested Courses Section
              HorizontalCourseList(
                title: 'Suggested For You',
                subtitle: 'Courses based on your learning goals and interests',
                courses: _suggestedCourses,
                loading: _loadingFeatured,
              ),

              // Top Rated Courses Section
              HorizontalCourseList(
                title: 'Top Rated Courses',
                subtitle: 'Highest rated courses by our students',
                courses: _topRatedCourses,
                loading: _loadingFeatured,
              ),

              // All Courses Grid
              AllCoursesGrid(
                courses: _allCourses,
                loading: (_loadingMore && _page == 1) || _isRefreshing,
                loadingMore: _loadingMore && _page > 1 && !_isRefreshing,
                hasMore: _hasMore,
                errorMessage: _errorMessage,
                onRetry: () {
                  if (_retryCount < _maxRetries) {
                    _retryCount++;
                    _fetchAllCourses();
                  }
                },
              ),

              if (kIsWeb) const AppPromotionSection(),
              if (kIsWeb) const CourseFooterSection(),
              if (!kIsWeb) const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
