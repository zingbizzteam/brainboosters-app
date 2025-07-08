// screens/common/courses/courses_page.dart - UPDATED

import 'package:brainboosters_app/screens/common/courses/course_repository.dart';
import 'package:brainboosters_app/screens/common/courses/widgets/course_footer_section.dart';
import 'package:flutter/material.dart';
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
  // State for horizontal lists
  List<Map<String, dynamic>> _suggestedCourses = [];
  List<Map<String, dynamic>> _topRatedCourses = [];
  bool _loadingFeatured = true;

  // State for the main infinite scroll grid
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _allCourses = [];
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  static const int _pageSize = 8;

  // Add error state tracking
  String? _errorMessage;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  // NEW: Refresh coordination
  bool _isRefreshing = false;
  bool _categoriesRefreshTrigger = false;
  int _refreshCompletedComponents = 0;
  bool _heroRefreshTrigger = false;
  static const int _totalRefreshComponents =
      3; // categories, featured, all courses

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
      // NEW: Don't load more during refresh
      debugPrint('Scroll threshold reached, loading more courses...');
      _fetchAllCourses();
    }
  }

  // NEW: Enhanced refresh with coordination
  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    print('DEBUG: Starting coordinated refresh...');

    setState(() {
      _isRefreshing = true;
      _refreshCompletedComponents = 0;
      _categoriesRefreshTrigger = true;
      _heroRefreshTrigger = true; // NEW: Trigger hero refresh
      _page = 1;
      _hasMore = true;
    });

    CourseRepository.clearCache();

    await Future.wait([
      _fetchFeaturedCourses(isRefresh: true),
      _fetchAllCourses(isRefresh: true),
    ]);
    // Categories and hero will complete separately via callbacks
  }

  // NEW: Handle component refresh completion
  void _onComponentRefreshComplete() {
    _refreshCompletedComponents++;
    print(
      'DEBUG: Component refresh completed ($_refreshCompletedComponents/$_totalRefreshComponents)',
    );

    if (_refreshCompletedComponents >= _totalRefreshComponents) {
      setState(() {
        _isRefreshing = false;
        _categoriesRefreshTrigger = false;
        _heroRefreshTrigger = false; // NEW: Reset hero trigger
      });
      print('DEBUG: All components refresh completed');
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
      print('DEBUG: ${isRefresh ? "Refreshing" : "Loading"} all courses...');

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

        print('DEBUG: All courses loaded: ${_allCourses.length} total');

        // Notify refresh completion if this was a refresh
        if (isRefresh) {
          _onComponentRefreshComplete();
        }
      }
    } catch (e) {
      print('ERROR: Failed to fetch all courses: $e');

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

      print(
        'DEBUG: ${isRefresh ? "Refreshing" : "Loading"} featured courses...',
      );

      final featured = await CourseRepository.getFeaturedCourses(limit: 8);

      if (mounted) {
        setState(() {
          _topRatedCourses = featured.topRated;
          _suggestedCourses = featured.suggested;
          _loadingFeatured = false;
        });

        print('DEBUG: Featured courses loaded:');
        print('  - Top rated: ${_topRatedCourses.length} courses');
        print('  - Suggested: ${_suggestedCourses.length} courses');

        // Notify refresh completion if this was a refresh
        if (isRefresh) {
          _onComponentRefreshComplete();
        }
      }
    } catch (e) {
      print('ERROR: Failed to fetch featured courses: $e');

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
              CourseHeroSection(
                courseId: "990e8400-e29b-41d4-a716-446655440001",
                forceRefresh: _heroRefreshTrigger, // NEW
                onRefreshComplete: _onComponentRefreshComplete, // NEW
              ),

              // NEW: Categories with refresh coordination
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

              // All Courses Grid with proper error handling
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
