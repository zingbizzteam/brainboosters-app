// screens/common/courses/courses_page.dart
import 'package:brainboosters_app/screens/common/courses/widgets/course_footer_section.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
        _allCourses.isNotEmpty) {
      debugPrint('Scroll threshold reached, loading more courses...');
      _fetchAllCourses();
    }
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _loadingFeatured = true;
      _errorMessage = null;
    });

    await Future.wait([_fetchFeaturedCourses(), _fetchAllCourses()]);
  }

  // FIXED: Complete query with all required fields
  Future<void> _fetchAllCourses() async {
    if (_loadingMore) return;

    setState(() {
      _loadingMore = true;
      _errorMessage = null;
    });

    try {
      debugPrint('Fetching courses - Page: $_page, PageSize: $_pageSize');

      final startIndex = (_page - 1) * _pageSize;
      final endIndex = startIndex + _pageSize - 1;

      final response = await Supabase.instance.client
          .from('courses')
          .select('''
          id, 
          title, 
          thumbnail_url, 
          category, 
          level, 
          price, 
          original_price,
          rating, 
          total_reviews, 
          total_lessons,
          duration_hours,
          enrollment_count,
          coaching_center_id, 
          coaching_centers(center_name)
        ''')
          .eq('is_published', true)
          .order('created_at', ascending: false)
          .range(startIndex, endIndex)
          .timeout(const Duration(seconds: 15));

      final newCourses = List<Map<String, dynamic>>.from(response);

      debugPrint('Fetched ${newCourses.length} courses for page $_page');

      if (mounted) {
        setState(() {
          if (_page == 1) {
            _allCourses = newCourses;
          } else {
            _allCourses.addAll(newCourses);
          }

          _hasMore = newCourses.length == _pageSize;

          if (_hasMore) {
            _page++;
          }

          _loadingMore = false;
          _retryCount = 0;
        });

        debugPrint('Total courses loaded: ${_allCourses.length}');
        debugPrint('Has more: $_hasMore');
        debugPrint('Next page: $_page');
      }
    } catch (e) {
      debugPrint('Error fetching courses: $e');

      if (mounted) {
        setState(() {
          _loadingMore = false;
          _errorMessage = 'Failed to load courses: ${e.toString()}';
        });

        if (_page == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load courses. Please try again.'),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  if (_retryCount < _maxRetries) {
                    _retryCount++;
                    _fetchAllCourses();
                  }
                },
              ),
            ),
          );
        }
      }
    }
  }

  // FIXED: Complete query with all required fields
  Future<void> _fetchFeaturedCourses() async {
    try {
      // Top rated courses with complete data
      final topRatedResponse = await Supabase.instance.client
          .from('courses')
          .select('''
          id, 
          title, 
          thumbnail_url, 
          category, 
          level, 
          price, 
          original_price,
          rating,
          total_reviews, 
          total_lessons,
          duration_hours,
          enrollment_count,
          coaching_center_id,
          coaching_centers(center_name)
        ''')
          .eq('is_published', true)
          .gte('rating', 4.0)
          .order('rating', ascending: false)
          .limit(8)
          .timeout(const Duration(seconds: 10));

      final topRated =
          (topRatedResponse as List?)?.cast<Map<String, dynamic>>() ?? [];

      List<Map<String, dynamic>> suggested = [];
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        try {
          final studentData = await Supabase.instance.client
              .from('students')
              .select('learning_goals')
              .eq('user_id', user.id)
              .maybeSingle()
              .timeout(const Duration(seconds: 5));

          List<String> userGoals = [];
          if (studentData != null && studentData['learning_goals'] != null) {
            userGoals = List<String>.from(
              studentData['learning_goals'] as List,
            );
          }

          if (userGoals.isNotEmpty) {
            // Suggested courses with complete data
            final suggestedResponse = await Supabase.instance.client
                .from('courses')
                .select('''
                id, 
                title, 
                thumbnail_url, 
                category, 
                level, 
                price, 
                original_price,
                rating,
                total_reviews, 
                total_lessons,
                duration_hours,
                enrollment_count,
                coaching_center_id,
                coaching_centers(center_name)
              ''')
                .eq('is_published', true)
                .overlaps('tags', userGoals)
                .order('rating', ascending: false)
                .limit(8)
                .timeout(const Duration(seconds: 10));

            suggested =
                (suggestedResponse as List?)?.cast<Map<String, dynamic>>() ??
                [];
          }
        } catch (e) {
          debugPrint('Error fetching personalized courses: $e');
        }
      }

      // Fallback to popular courses with complete data
      if (suggested.isEmpty) {
        try {
          final popularResponse = await Supabase.instance.client
              .from('courses')
              .select('''
              id, 
              title, 
              thumbnail_url, 
              category, 
              level, 
              price, 
              original_price,
              rating,
              total_reviews, 
              total_lessons,
              duration_hours,
              enrollment_count,
              coaching_center_id,
              coaching_centers(center_name)
            ''')
              .eq('is_published', true)
              .order('enrollment_count', ascending: false)
              .limit(8)
              .timeout(const Duration(seconds: 10));

          suggested =
              (popularResponse as List?)?.cast<Map<String, dynamic>>() ?? [];
        } catch (e) {
          debugPrint('Error fetching popular courses: $e');
        }
      }

      debugPrint('Top rated courses fetched: ${topRated.length}');
      debugPrint('Suggested courses fetched: ${suggested.length}');

      if (mounted) {
        setState(() {
          _topRatedCourses = topRated;
          _suggestedCourses = suggested;
          _loadingFeatured = false;
        });
      }
    } catch (e) {
      debugPrint('Error in _fetchFeaturedCourses: $e');
      if (mounted) {
        setState(() {
          _loadingFeatured = false;
          _topRatedCourses = [];
          _suggestedCourses = [];
        });
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
        onRefresh: () async {
          _page = 1;
          _hasMore = true;
          await _fetchInitialData();
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              const CourseHeroSection(),
              const CourseCategoriesSection(),

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
                loading: _loadingMore && _page == 1,
                loadingMore: _loadingMore && _page > 1,
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
