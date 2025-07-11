import 'package:brainboosters_app/screens/common/search/search_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchRepository {
  static final _client = Supabase.instance.client;

  /// Unified search across all entity types
  static Future<SearchResults> searchAll({
    required String query,
    int limit = 20,
    int offset = 0,
    List<SearchEntityType> entityTypes = const [
      SearchEntityType.courses,
      SearchEntityType.coachingCenters,
      SearchEntityType.liveClasses,
      SearchEntityType.teachers,
    ],
    SearchFilters? filters,
    SearchSortBy sortBy = SearchSortBy.relevance,
  }) async {
    try {
      final results = <SearchResult>[];

      // Search each entity type in parallel
      final futures = <Future<List<SearchResult>>>[];

      if (entityTypes.contains(SearchEntityType.courses)) {
        futures.add(
          _searchCourses(
            query,
            limit ~/ entityTypes.length,
            offset,
            filters,
            sortBy,
          ),
        );
      }
      if (entityTypes.contains(SearchEntityType.coachingCenters)) {
        futures.add(
          _searchCoachingCenters(
            query,
            limit ~/ entityTypes.length,
            offset,
            filters,
            sortBy,
          ),
        );
      }
      if (entityTypes.contains(SearchEntityType.liveClasses)) {
        futures.add(
          _searchLiveClasses(
            query,
            limit ~/ entityTypes.length,
            offset,
            filters,
            sortBy,
          ),
        );
      }
      if (entityTypes.contains(SearchEntityType.teachers)) {
        futures.add(
          _searchTeachers(
            query,
            limit ~/ entityTypes.length,
            offset,
            filters,
            sortBy,
          ),
        );
      }

      final searchResults = await Future.wait(futures);

      // Combine and sort results
      for (final entityResults in searchResults) {
        results.addAll(entityResults);
      }

      // Sort combined results by relevance/date
      _sortCombinedResults(results, sortBy);

      return SearchResults(
        results: results.take(limit).toList(),
        hasMore: results.length >= limit,
        totalCount: results.length,
        query: query,
      );
    } catch (e) {
      throw SearchException('Failed to search: $e');
    }
  }

  /// Search courses with advanced filtering
  static Future<List<SearchResult>> _searchCourses(
    String query,
    int limit,
    int offset,
    SearchFilters? filters,
    SearchSortBy sortBy,
  ) async {
    var searchQuery = _client
        .from('courses')
        .select('''
          id,
          title,
          description,
          short_description,
          thumbnail_url,
          category,
          subcategory,
          level,
          price,
          original_price,
          currency,
          rating,
          total_reviews,
          enrollment_count,
          duration_hours,
          total_lessons,
          is_featured,
          created_at,
          coaching_centers!inner(
            id,
            center_name,
            logo_url
          ),
          teachers(
            id,
            user_profiles(first_name, last_name, avatar_url)
          )
        ''')
        .eq('is_published', true)
        .or(
          'title.ilike.%$query%,description.ilike.%$query%,category.ilike.%$query%,subcategory.ilike.%$query%',
        );

    // Apply filters
    if (filters != null) {
      if (filters.categories.isNotEmpty) {
        searchQuery = searchQuery.inFilter('category', filters.categories);
      }
      if (filters.levels.isNotEmpty) {
        searchQuery = searchQuery.inFilter(
          'level',
          filters.levels.map((e) => e.name).toList(),
        );
      }
      if (filters.priceRange != null) {
        searchQuery = searchQuery
            .gte('price', filters.priceRange!.min)
            .lte('price', filters.priceRange!.max);
      }
      if (filters.minRating != null) {
        searchQuery = searchQuery.gte('rating', filters.minRating!);
      }
      if (filters.isFree != null) {
        if (filters.isFree!) {
          searchQuery = searchQuery.eq('price', 0);
        } else {
          searchQuery = searchQuery.gt('price', 0);
        }
      }
    }

    // Apply sorting - Fixed approach
    String orderByField;
    bool ascending;
    switch (sortBy) {
      case SearchSortBy.relevance:
        orderByField = 'rating';
        ascending = false;
        break;
      case SearchSortBy.newest:
        orderByField = 'created_at';
        ascending = false;
        break;
      case SearchSortBy.oldest:
        orderByField = 'created_at';
        ascending = true;
        break;
      case SearchSortBy.rating:
        orderByField = 'rating';
        ascending = false;
        break;
      case SearchSortBy.priceLowToHigh:
        orderByField = 'price';
        ascending = true;
        break;
      case SearchSortBy.priceHighToLow:
        orderByField = 'price';
        ascending = false;
        break;
      case SearchSortBy.popularity:
        orderByField = 'enrollment_count';
        ascending = false;
        break;
    }

    final response = await searchQuery
        .order(orderByField, ascending: ascending)
        .range(offset, offset + limit - 1)
        .timeout(const Duration(seconds: 10));

    return List<Map<String, dynamic>>.from(
      response,
    ).map((data) => SearchResult.fromCourse(data)).toList();
  }

  /// Search coaching centers
  static Future<List<SearchResult>> _searchCoachingCenters(
    String query,
    int limit,
    int offset,
    SearchFilters? filters,
    SearchSortBy sortBy,
  ) async {
    var searchQuery = _client
        .from('coaching_centers')
        .select('''
          id,
          center_name,
          description,
          logo_url,
          contact_email,
          contact_phone,
          address,
          total_courses,
          total_students,
          created_at
        ''')
        .eq('approval_status', 'approved')
        .eq('is_active', true)
        .or('center_name.ilike.%$query%,description.ilike.%$query%');

    // Apply sorting - Fixed approach
    String orderByField;
    bool ascending;
    switch (sortBy) {
      case SearchSortBy.relevance:
      case SearchSortBy.popularity:
        orderByField = 'total_students';
        ascending = false;
        break;
      case SearchSortBy.newest:
        orderByField = 'created_at';
        ascending = false;
        break;
      case SearchSortBy.oldest:
        orderByField = 'created_at';
        ascending = true;
        break;
      case SearchSortBy.rating:
        orderByField = 'center_name';
        ascending = true;
        break;
      case SearchSortBy.priceLowToHigh:
      case SearchSortBy.priceHighToLow:
        orderByField = 'center_name';
        ascending = true;
        break;
    }

    final response = await searchQuery
        .order(orderByField, ascending: ascending)
        .range(offset, offset + limit - 1)
        .timeout(const Duration(seconds: 10));

    return List<Map<String, dynamic>>.from(
      response,
    ).map((data) => SearchResult.fromCoachingCenter(data)).toList();
  }

  /// Search live classes
  static Future<List<SearchResult>> _searchLiveClasses(
    String query,
    int limit,
    int offset,
    SearchFilters? filters,
    SearchSortBy sortBy,
  ) async {
    var searchQuery = _client
        .from('live_classes')
        .select('''
          id,
          title,
          description,
          scheduled_at,
          duration_minutes,
          max_participants,
          current_participants,
          price,
          currency,
          is_free,
          status,
          thumbnail_url,
          coaching_centers!inner(
            id,
            center_name,
            logo_url
          ),
          teachers(
            id,
            user_profiles(first_name, last_name, avatar_url)
          )
        ''')
        .inFilter('status', ['scheduled', 'live'])
        .or('title.ilike.%$query%,description.ilike.%$query%');

    // Apply filters
    if (filters != null) {
      if (filters.isFree != null) {
        searchQuery = searchQuery.eq('is_free', filters.isFree!);
      }
      if (filters.dateRange != null) {
        searchQuery = searchQuery
            .gte('scheduled_at', filters.dateRange!.start.toIso8601String())
            .lte('scheduled_at', filters.dateRange!.end.toIso8601String());
      }
    }

    // Apply sorting - Fixed approach
    String orderByField;
    bool ascending;
    switch (sortBy) {
      case SearchSortBy.relevance:
      case SearchSortBy.newest:
        orderByField = 'scheduled_at';
        ascending = true;
        break;
      case SearchSortBy.oldest:
        orderByField = 'scheduled_at';
        ascending = false;
        break;
      case SearchSortBy.popularity:
        orderByField = 'current_participants';
        ascending = false;
        break;
      case SearchSortBy.rating:
        orderByField = 'scheduled_at';
        ascending = true;
        break;
      case SearchSortBy.priceLowToHigh:
        orderByField = 'price';
        ascending = true;
        break;
      case SearchSortBy.priceHighToLow:
        orderByField = 'price';
        ascending = false;
        break;
    }

    final response = await searchQuery
        .order(orderByField, ascending: ascending)
        .range(offset, offset + limit - 1)
        .timeout(const Duration(seconds: 10));

    return List<Map<String, dynamic>>.from(
      response,
    ).map((data) => SearchResult.fromLiveClass(data)).toList();
  }

  /// Search teachers
  /// Search teachers - COMPLETELY FIXED
  static Future<List<SearchResult>> _searchTeachers(
    String query,
    int limit,
    int offset,
    SearchFilters? filters,
    SearchSortBy sortBy,
  ) async {
    try {
      // Use separate queries for each search field to avoid parsing issues
      final teacherIds = <String>{};
      final teacherData = <String, Map<String, dynamic>>{};

      // Search by first name
      if (query.isNotEmpty) {
        final firstNameResults = await _client
            .from('teachers')
            .select('''
            id,
            specializations,
            qualifications,
            experience_years,
            bio,
            rating,
            total_reviews,
            is_verified,
            user_profiles!inner(
              first_name,
              last_name,
              avatar_url
            ),
            coaching_centers!inner(
              id,
              center_name,
              logo_url
            )
          ''')
            .eq('is_verified', true)
            .ilike('user_profiles.first_name', '%$query%')
            .limit(limit);

        for (final teacher in firstNameResults) {
          final id = teacher['id'] as String;
          teacherIds.add(id);
          teacherData[id] = teacher;
        }

        // Search by last name
        final lastNameResults = await _client
            .from('teachers')
            .select('''
            id,
            specializations,
            qualifications,
            experience_years,
            bio,
            rating,
            total_reviews,
            is_verified,
            user_profiles!inner(
              first_name,
              last_name,
              avatar_url
            ),
            coaching_centers!inner(
              id,
              center_name,
              logo_url
            )
          ''')
            .eq('is_verified', true)
            .ilike('user_profiles.last_name', '%$query%')
            .limit(limit);

        for (final teacher in lastNameResults) {
          final id = teacher['id'] as String;
          teacherIds.add(id);
          teacherData[id] = teacher;
        }

        // Search by bio
        final bioResults = await _client
            .from('teachers')
            .select('''
            id,
            specializations,
            qualifications,
            experience_years,
            bio,
            rating,
            total_reviews,
            is_verified,
            user_profiles!inner(
              first_name,
              last_name,
              avatar_url
            ),
            coaching_centers!inner(
              id,
              center_name,
              logo_url
            )
          ''')
            .eq('is_verified', true)
            .ilike('bio', '%$query%')
            .limit(limit);

        for (final teacher in bioResults) {
          final id = teacher['id'] as String;
          teacherIds.add(id);
          teacherData[id] = teacher;
        }
      }

      // Convert to list and apply filters
      var results = teacherIds.map((id) => teacherData[id]!).toList();

      // Apply additional filters
      if (filters != null) {
        results = results.where((teacher) {
          if (filters.minExperience != null) {
            final experience = teacher['experience_years'] as int?;
            if (experience == null || experience < filters.minExperience!) {
              return false;
            }
          }
          if (filters.minRating != null) {
            final rating = teacher['rating'] as double?;
            if (rating == null || rating < filters.minRating!) {
              return false;
            }
          }
          if (filters.specializations.isNotEmpty) {
            final teacherSpecs = teacher['specializations'] as List?;
            if (teacherSpecs == null ||
                !filters.specializations.any(
                  (spec) => teacherSpecs.contains(spec),
                )) {
              return false;
            }
          }
          return true;
        }).toList();
      }

      // Apply sorting
      _sortTeacherResults(results, sortBy);

      // Apply pagination
      final startIndex = offset;
      final endIndex = (startIndex + limit).clamp(0, results.length);
      final paginatedResults = results.sublist(startIndex, endIndex);

      return paginatedResults
          .map((data) => SearchResult.fromTeacher(data))
          .toList();
    } catch (e) {
      throw SearchException('Failed to search teachers: $e');
    }
  }

  static void _sortTeacherResults(
    List<Map<String, dynamic>> results,
    SearchSortBy sortBy,
  ) {
    switch (sortBy) {
      case SearchSortBy.relevance:
      case SearchSortBy.rating:
        results.sort(
          (a, b) => ((b['rating'] as double?) ?? 0).compareTo(
            (a['rating'] as double?) ?? 0,
          ),
        );
        break;
      case SearchSortBy.popularity:
        results.sort(
          (a, b) => ((b['total_reviews'] as int?) ?? 0).compareTo(
            (a['total_reviews'] as int?) ?? 0,
          ),
        );
        break;
      case SearchSortBy.newest:
      case SearchSortBy.oldest:
      case SearchSortBy.priceLowToHigh:
      case SearchSortBy.priceHighToLow:
        results.sort((a, b) {
          final aName = a['user_profiles']['first_name'] as String? ?? '';
          final bName = b['user_profiles']['first_name'] as String? ?? '';
          return aName.compareTo(bName);
        });
        break;
    }
  }

  /// Sort combined results from different entity types
  static void _sortCombinedResults(
    List<SearchResult> results,
    SearchSortBy sortBy,
  ) {
    switch (sortBy) {
      case SearchSortBy.relevance:
        results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
        break;
      case SearchSortBy.newest:
        results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SearchSortBy.oldest:
        results.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SearchSortBy.rating:
        results.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case SearchSortBy.popularity:
        results.sort(
          (a, b) => (b.popularityScore ?? 0).compareTo(a.popularityScore ?? 0),
        );
        break;
      case SearchSortBy.priceLowToHigh:
        results.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case SearchSortBy.priceHighToLow:
        results.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
    }
  }

  /// Get search suggestions
  static Future<List<String>> getSearchSuggestions(String query) async {
    if (query.length < 2) return [];

    try {
      final suggestions = <String>{};

      // Get course suggestions
      final courseResponse = await _client
          .from('courses')
          .select('title, category')
          .eq('is_published', true)
          .or('title.ilike.%$query%,category.ilike.%$query%')
          .limit(5);

      for (final course in courseResponse) {
        suggestions.add(course['title']);
        suggestions.add(course['category']);
      }

      // Get coaching center suggestions
      final centerResponse = await _client
          .from('coaching_centers')
          .select('center_name')
          .eq('is_active', true)
          .ilike('center_name', '%$query%')
          .limit(3);

      for (final center in centerResponse) {
        suggestions.add(center['center_name']);
      }

      return suggestions.take(8).toList();
    } catch (e) {
      return [];
    }
  }
}
