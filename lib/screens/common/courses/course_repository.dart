import 'package:supabase_flutter/supabase_flutter.dart';

class CourseRepository {
  static final _client = Supabase.instance.client;

  // Cache for category counts (expires after 5 minutes)
  static final Map<String, _CachedCount> _countCache = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Get course count for category without fetching data
  static Future<int> getCourseCountByCategory(String categoryId) async {
    try {
      final response = await _client
          .from('courses')
          .select('id')
          .eq('is_published', true)
          .eq('category_id', categoryId)
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      throw CourseRepositoryException('Failed to get course count: $e');
    }
  }

  /// Get all category counts in a single batch operation
  static Future<Map<String, int>> getAllCategoryCounts() async {
    try {
      final response = await _client
          .from('courses')
          .select('category_id')
          .eq('is_published', true);

      final countMap = <String, int>{};
      for (final course in response) {
        final categoryId = course['category_id'] as String?;
        if (categoryId != null) {
          countMap[categoryId] = (countMap[categoryId] ?? 0) + 1;
        }
      }

      for (final entry in countMap.entries) {
        final cacheKey = 'count_${entry.key}';
        _countCache[cacheKey] = _CachedCount(entry.value, DateTime.now());
      }

      return countMap;
    } catch (e) {
      throw CourseRepositoryException('Failed to get category counts: $e');
    }
  }

  /// Get paginated courses with full details
  static Future<PaginatedCourses> getCourses({
    int limit = 12,
    int offset = 0,
    String? categoryId,
    String? searchQuery,
    CourseSortBy sortBy = CourseSortBy.newest,
    CourseLevel? level,
    double? minRating,
    double? maxPrice,
  }) async {
    try {
      var query = _client
          .from('courses')
          .select('''
            id,
            title,
            thumbnail_url,
            category_id,
            course_categories!left(id, name, slug),
            level,
            price,
            original_price,
            rating,
            total_reviews,
            total_lessons,
            duration_hours,
            enrollment_count,
            coaching_center_id,
            coaching_centers(center_name),
            created_at,
            updated_at
          ''')
          .eq('is_published', true);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'title.ilike.%$searchQuery%,course_categories.name.ilike.%$searchQuery%',
        );
      }

      if (level != null) {
        query = query.eq('level', level.name);
      }

      if (minRating != null) {
        query = query.gte('rating', minRating);
      }

      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }

      String orderByField;
      bool ascending;
      switch (sortBy) {
        case CourseSortBy.newest:
          orderByField = 'created_at';
          ascending = false;
          break;
        case CourseSortBy.oldest:
          orderByField = 'created_at';
          ascending = true;
          break;
        case CourseSortBy.rating:
          orderByField = 'rating';
          ascending = false;
          break;
        case CourseSortBy.priceLow:
          orderByField = 'price';
          ascending = true;
          break;
        case CourseSortBy.priceHigh:
          orderByField = 'price';
          ascending = false;
          break;
        case CourseSortBy.popular:
          orderByField = 'enrollment_count';
          ascending = false;
          break;
      }

      final response = await query
          .order(orderByField, ascending: ascending)
          .range(offset, offset + limit - 1)
          .timeout(const Duration(seconds: 15));

      final courses = List<Map<String, dynamic>>.from(response);
      final hasMore = courses.length == limit;

      return PaginatedCourses(
        courses: courses,
        hasMore: hasMore,
        totalFetched: offset + courses.length,
      );
    } catch (e) {
      throw CourseRepositoryException('Failed to fetch courses: $e');
    }
  }

  /// Get suggested courses (personalized)
  static Future<List<Map<String, dynamic>>> getSuggestedCourses(
    int limit,
  ) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return _getPopularCourses(limit);
      }

      final studentData = await _client
          .from('students')
          .select('learning_goals, preferred_learning_style')
          .eq('user_id', user.id)
          .maybeSingle();

      if (studentData == null) {
        return _getPopularCourses(limit);
      }

      final userGoals = studentData['learning_goals'] as List?;
      if (userGoals != null && userGoals.isNotEmpty) {
        try {
          final tagBasedCourses = await _getCoursesByTags(
            userGoals.cast<String>(),
            limit,
          );
          if (tagBasedCourses.isNotEmpty) return tagBasedCourses;
        } catch (_) {}
      }

      try {
        final historyBasedCourses = await _getCoursesByEnrollmentHistory(
          user.id,
          limit,
        );
        if (historyBasedCourses.isNotEmpty) return historyBasedCourses;
      } catch (_) {}

      // ✅ FIXED: Fallback to all published courses instead of top-rated
      return _getAllCourses(limit);
    } catch (_) {
      return _getPopularCourses(limit);
    }
  }

  static Future<List<Map<String, dynamic>>> _getCoursesByTags(
    List<String> tags,
    int limit,
  ) async {
    final response = await _client
        .from('courses')
        .select('''
          id,
          title,
          thumbnail_url,
          category_id,
          course_categories!left(id, name, slug),
          level,
          price,
          original_price,
          rating,
          total_reviews,
          total_lessons,
          duration_hours,
          enrollment_count,
          coaching_centers(center_name)
        ''')
        .eq('is_published', true)
        .overlaps('tags', tags)
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> _getCoursesByEnrollmentHistory(
    String userId,
    int limit,
  ) async {
    final enrolledCourses = await _client
        .from('course_enrollments')
        .select('courses(category_id)')
        .eq('student_id', userId)
        .eq('is_active', true);

    if (enrolledCourses.isEmpty) return [];

    final enrolledCategoryIds = enrolledCourses
        .map((e) => e['courses']?['category_id'] as String?)
        .where((categoryId) => categoryId != null)
        .cast<String>()
        .toSet()
        .toList();

    if (enrolledCategoryIds.isEmpty) return [];

    final enrolledCourseIds = await _client
        .from('course_enrollments')
        .select('course_id')
        .eq('student_id', userId)
        .eq('is_active', true);

    final excludeIds = enrolledCourseIds
        .map((e) => e['course_id'] as String)
        .toList();

    var query = _client
        .from('courses')
        .select('''
          id,
          title,
          thumbnail_url,
          category_id,
          course_categories!left(id, name, slug),
          level,
          price,
          original_price,
          rating,
          total_reviews,
          total_lessons,
          duration_hours,
          enrollment_count,
          coaching_centers(center_name)
        ''')
        .eq('is_published', true)
        .inFilter('category_id', enrolledCategoryIds);

    if (excludeIds.isNotEmpty) {
      query = query.not('id', 'in', '(${excludeIds.join(',')})');
    }

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get featured courses (top rated, popular, suggested)
  static Future<FeaturedCourses> getFeaturedCourses({int limit = 10}) async {
    try {
      final responses = await Future.wait([
        _getTopRatedCourses(limit),
        _getPopularCourses(limit),
        getSuggestedCourses(limit),
      ]);

      return FeaturedCourses(
        topRated: responses[0],
        popular: responses[1],
        suggested: responses[2],
      );
    } catch (e) {
      throw CourseRepositoryException('Failed to fetch featured courses: $e');
    }
  }

  /// Get course by ID with full details
  static Future<Map<String, dynamic>?> getCourseById(String courseId) async {
    try {
      final course = await _client
          .from('courses')
          .select('''
            *,
            course_categories!left(id, name, slug),
            coaching_centers(
              id,
              center_name,
              description,
              logo_url
            )
          ''')
          .eq('id', courseId)
          .eq('is_published', true)
          .maybeSingle();

      if (course == null) return null;

      final lessons = await _fetchLessonsWithFallback(courseId);
      course['lessons'] = lessons;

      return course;
    } catch (e) {
      throw CourseRepositoryException('Failed to fetch course details: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> _fetchLessonsWithFallback(
    String courseId,
  ) async {
    try {
      return await _client
          .from('lessons')
          .select('id, title, video_duration, lesson_number, is_free')
          .eq('course_id', courseId)
          .order('lesson_number', ascending: true);
    } catch (e) {
      if (e.toString().contains('does not exist')) {
        try {
          final basicLessons = await _client
              .from('lessons')
              .select('id, title, lesson_number')
              .eq('course_id', courseId)
              .order('lesson_number', ascending: true);

          return basicLessons
              .map(
                (lesson) => {
                  ...lesson,
                  'video_duration': 0,
                  'is_free': false,
                },
              )
              .toList();
        } catch (fallbackError) {
          return [];
        }
      }
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> searchCourses({
    required String query,
    int limit = 20,
    String? categoryId,
  }) async {
    try {
      var searchQuery = _client
          .from('courses')
          .select('''
            id,
            title,
            thumbnail_url,
            category_id,
            course_categories!left(id, name, slug),
            level,
            price,
            original_price,
            rating,
            total_reviews,
            coaching_centers(center_name)
          ''')
          .eq('is_published', true)
          .or(
            'title.ilike.%$query%,course_categories.name.ilike.%$query%,description.ilike.%$query%',
          );

      if (categoryId != null) {
        searchQuery = searchQuery.eq('category_id', categoryId);
      }

      final response = await searchQuery
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw CourseRepositoryException('Failed to search courses: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getCoursesByCoachingCenter({
    required String coachingCenterId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('courses')
          .select('''
            id,
            title,
            thumbnail_url,
            category_id,
            course_categories!left(id, name, slug),
            level,
            price,
            original_price,
            rating,
            total_reviews,
            total_lessons,
            duration_hours,
            enrollment_count
          ''')
          .eq('is_published', true)
          .eq('coaching_center_id', coachingCenterId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw CourseRepositoryException(
        'Failed to fetch coaching center courses: $e',
      );
    }
  }

  static void clearCache() {
    _countCache.clear();
  }

  // ✅ FIXED: Remove rating filter, show up to 10 courses
  static Future<List<Map<String, dynamic>>> _getTopRatedCourses(
    int limit,
  ) async {
    final response = await _client
        .from('courses')
        .select('''
          id,
          title,
          thumbnail_url,
          category_id,
          course_categories!left(id, name, slug),
          level,
          price,
          original_price,
          rating,
          total_reviews,
          total_lessons,
          duration_hours,
          enrollment_count,
          coaching_centers(center_name)
        ''')
        .eq('is_published', true)
        .order('rating', ascending: false)
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> _getPopularCourses(
    int limit,
  ) async {
    final response = await _client
        .from('courses')
        .select('''
          id,
          title,
          thumbnail_url,
          category_id,
          course_categories!left(id, name, slug),
          level,
          price,
          original_price,
          rating,
          total_reviews,
          total_lessons,
          duration_hours,
          enrollment_count,
          coaching_centers(center_name)
        ''')
        .eq('is_published', true)
        .order('enrollment_count', ascending: false)
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  // ✅ NEW: Get all published courses (fallback)
  static Future<List<Map<String, dynamic>>> _getAllCourses(
    int limit,
  ) async {
    final response = await _client
        .from('courses')
        .select('''
          id,
          title,
          thumbnail_url,
          category_id,
          course_categories!left(id, name, slug),
          level,
          price,
          original_price,
          rating,
          total_reviews,
          total_lessons,
          duration_hours,
          enrollment_count,
          coaching_centers(center_name)
        ''')
        .eq('is_published', true)
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }
}

// Supporting classes
class _CachedCount {
  final int count;
  final DateTime timestamp;

  _CachedCount(this.count, this.timestamp);

  bool get isExpired =>
      DateTime.now().difference(timestamp) > CourseRepository._cacheExpiry;
}

class PaginatedCourses {
  final List<Map<String, dynamic>> courses;
  final bool hasMore;
  final int totalFetched;

  PaginatedCourses({
    required this.courses,
    required this.hasMore,
    required this.totalFetched,
  });
}

class FeaturedCourses {
  final List<Map<String, dynamic>> topRated;
  final List<Map<String, dynamic>> popular;
  final List<Map<String, dynamic>> suggested;

  FeaturedCourses({
    required this.topRated,
    required this.popular,
    required this.suggested,
  });
}

enum CourseSortBy { newest, oldest, rating, priceLow, priceHigh, popular }

enum CourseLevel { beginner, intermediate, advanced }

class CourseRepositoryException implements Exception {
  final String message;

  CourseRepositoryException(this.message);

  @override
  String toString() => 'CourseRepositoryException: $message';
}
