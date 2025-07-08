import 'package:supabase_flutter/supabase_flutter.dart';

class CourseRepository {
  static final _client = Supabase.instance.client;

  // Cache for category counts (expires after 5 minutes)
  static final Map<String, _CachedCount> _countCache = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Get course count for category without fetching data
  static Future<int> getCourseCountByCategory(String categoryName) async {
    try {
      final response = await _client
          .from('courses')
          .select('id')
          .eq('is_published', true)
          .eq('category', categoryName)
          .count(CountOption.exact);

      return response.count ?? 0;
    } catch (e) {
      throw CourseRepositoryException('Failed to get course count: $e');
    }
  }

  /// Get all category counts in a single batch operation
  static Future<Map<String, int>> getAllCategoryCounts() async {
    try {
      final response = await _client
          .from('courses')
          .select('category')
          .eq('is_published', true);

      final countMap = <String, int>{};
      for (final course in response) {
        final category = course['category'] as String?;
        if (category != null) {
          countMap[category] = (countMap[category] ?? 0) + 1;
        }
      }
      // Cache all results
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
    String? category,
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
            coaching_centers(center_name),
            created_at,
            updated_at
          ''')
          .eq('is_published', true);

      // Apply filters
      if (category != null) {
        query = query.eq('category', category);
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'title.ilike.%$searchQuery%,category.ilike.%$searchQuery%',
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

      // Sorting
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
        case CourseSortBy.price_low:
          orderByField = 'price';
          ascending = true;
          break;
        case CourseSortBy.price_high:
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
          .select('learning_goals, preferred_categories, skill_level')
          .eq('user_id', user.id)
          .maybeSingle();
      if (studentData == null) {
        return _getPopularCourses(limit);
      }
      // Layer 1: Learning goals
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
      // Layer 2: Preferred categories
      final preferredCategories = studentData['preferred_categories'] as List?;
      if (preferredCategories != null && preferredCategories.isNotEmpty) {
        try {
          final categoryBasedCourses = await _getCoursesByCategories(
            preferredCategories.cast<String>(),
            limit,
          );
          if (categoryBasedCourses.isNotEmpty) return categoryBasedCourses;
        } catch (_) {}
      }
      // Layer 3: Skill level
      final skillLevel = studentData['skill_level'] as String?;
      if (skillLevel != null) {
        try {
          final levelBasedCourses = await _getCoursesByLevel(skillLevel, limit);
          if (levelBasedCourses.isNotEmpty) return levelBasedCourses;
        } catch (_) {}
      }
      // Layer 4: Enrollment history
      try {
        final historyBasedCourses = await _getCoursesByEnrollmentHistory(
          user.id,
          limit,
        );
        if (historyBasedCourses.isNotEmpty) return historyBasedCourses;
      } catch (_) {}
      // Layer 5: Fallback to top-rated
      return _getTopRatedCourses(limit);
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
          category,
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
        .gte('rating', 3.5)
        .order('rating', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> _getCoursesByCategories(
    List<String> categories,
    int limit,
  ) async {
    final response = await _client
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
          coaching_centers(center_name)
        ''')
        .eq('is_published', true)
        .inFilter('category', categories)
        .gte('rating', 3.5)
        .order('enrollment_count', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> _getCoursesByLevel(
    String skillLevel,
    int limit,
  ) async {
    final response = await _client
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
          coaching_centers(center_name)
        ''')
        .eq('is_published', true)
        .eq('level', skillLevel)
        .gte('rating', 4.0)
        .order('rating', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> _getCoursesByEnrollmentHistory(
    String userId,
    int limit,
  ) async {
    final enrolledCourses = await _client
        .from('course_enrollments')
        .select('courses(category)')
        .eq('student_id', userId)
        .eq('is_active', true);
    if (enrolledCourses.isEmpty) return [];
    final enrolledCategories = enrolledCourses
        .map((e) => e['courses']['category'] as String?)
        .where((category) => category != null)
        .cast<String>()
        .toSet()
        .toList();
    if (enrolledCategories.isEmpty) return [];
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
          category,
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
        .inFilter('category', enrolledCategories)
        .gte('rating', 4.0);
    if (excludeIds.isNotEmpty) {
      query = query.not('id', 'in', '(${excludeIds.join(',')})');
    }
    final response = await query.order('rating', ascending: false).limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get featured courses (top rated, popular, suggested)
  static Future<FeaturedCourses> getFeaturedCourses({int limit = 8}) async {
    try {
      final results = await Future.wait([
        _getTopRatedCourses(limit),
        _getPopularCourses(limit),
        getSuggestedCourses(limit),
      ]);
      return FeaturedCourses(
        topRated: results[0],
        popular: results[1],
        suggested: results[2],
      );
    } catch (e) {
      throw CourseRepositoryException('Failed to fetch featured courses: $e');
    }
  }

  /// Get course by ID with full details
  /// Get course by ID with full details
  static Future<Map<String, dynamic>?> getCourseById(String courseId) async {
    try {
      final course = await _client
          .from('courses')
          .select('''
          *,
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

      // Try to fetch lessons with fallback for missing columns
      final lessons = await _fetchLessonsWithFallback(courseId);
      course['lessons'] = lessons;
      return course;
    } catch (e) {
      throw CourseRepositoryException('Failed to fetch course details: $e');
    }
  }

  /// Fetch lessons with graceful handling of missing columns
  static Future<List<Map<String, dynamic>>> _fetchLessonsWithFallback(
    String courseId,
  ) async {
    try {
      // First, try with all expected columns
      return await _client
          .from('lessons')
          .select('id, title, duration_minutes, lesson_order, is_preview')
          .eq('course_id', courseId)
          .order('lesson_order', ascending: true);
    } catch (e) {
      if (e.toString().contains('does not exist')) {
        // Fallback: fetch only basic columns that should exist
        try {
          final basicLessons = await _client
              .from('lessons')
              .select('id, title, lesson_order')
              .eq('course_id', courseId)
              .order('lesson_order', ascending: true);

          // Add default values for missing fields
          return basicLessons
              .map(
                (lesson) => {
                  ...lesson,
                  'duration_minutes': 0,
                  'is_preview': false,
                },
              )
              .toList();
        } catch (fallbackError) {
          // If even basic query fails, return empty list
          return [];
        }
      }
      rethrow;
    }
  }

  /// Search courses with advanced filters
  static Future<List<Map<String, dynamic>>> searchCourses({
    required String query,
    int limit = 20,
    String? category,
    CourseLevel? level,
  }) async {
    try {
      var searchQuery = _client
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
            coaching_centers(center_name)
          ''')
          .eq('is_published', true)
          .or(
            'title.ilike.%$query%,category.ilike.%$query%,description.ilike.%$query%',
          );
      if (category != null) {
        searchQuery = searchQuery.eq('category', category);
      }
      if (level != null) {
        searchQuery = searchQuery.eq('level', level.name);
      }
      final response = await searchQuery
          .order('rating', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw CourseRepositoryException('Failed to search courses: $e');
    }
  }

  /// Get courses by coaching center
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
            category,
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

  /// Clear cache (useful for testing or force refresh)
  static void clearCache() {
    _countCache.clear();
  }

  // Private helper methods
  static Future<List<Map<String, dynamic>>> _getTopRatedCourses(
    int limit,
  ) async {
    final response = await _client
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
          coaching_centers(center_name)
        ''')
        .eq('is_published', true)
        .gte('rating', 4.0)
        .order('rating', ascending: false)
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
          category,
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

enum CourseSortBy { newest, oldest, rating, price_low, price_high, popular }

enum CourseLevel { beginner, intermediate, advanced }

class CourseRepositoryException implements Exception {
  final String message;
  CourseRepositoryException(this.message);
  @override
  String toString() => 'CourseRepositoryException: $message';
}
