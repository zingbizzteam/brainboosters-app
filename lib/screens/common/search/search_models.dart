// search_models.dart
enum SearchEntityType {
  courses,
  coachingCenters,
  liveClasses,
  teachers,
}

enum SearchSortBy {
  relevance,
  newest,
  oldest,
  rating,
  priceLowToHigh,
  priceHighToLow,
  popularity,
}

enum CourseLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

class SearchFilters {
  final List<String> categories;
  final List<CourseLevel> levels;
  final PriceRange? priceRange;
  final double? minRating;
  final bool? isFree;
  final DateRange? dateRange;
  final int? minExperience;
  final List<String> specializations;

  SearchFilters({
    this.categories = const [],
    this.levels = const [],
    this.priceRange,
    this.minRating,
    this.isFree,
    this.dateRange,
    this.minExperience,
    this.specializations = const [],
  });

  SearchFilters copyWith({
    List<String>? categories,
    List<CourseLevel>? levels,
    PriceRange? priceRange,
    double? minRating,
    bool? isFree,
    DateRange? dateRange,
    int? minExperience,
    List<String>? specializations,
  }) {
    return SearchFilters(
      categories: categories ?? this.categories,
      levels: levels ?? this.levels,
      priceRange: priceRange ?? this.priceRange,
      minRating: minRating ?? this.minRating,
      isFree: isFree ?? this.isFree,
      dateRange: dateRange ?? this.dateRange,
      minExperience: minExperience ?? this.minExperience,
      specializations: specializations ?? this.specializations,
    );
  }
}

class PriceRange {
  final double min;
  final double max;

  PriceRange({required this.min, required this.max});
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});
}

class SearchResults {
  final List<SearchResult> results;
  final bool hasMore;
  final int totalCount;
  final String query;

  SearchResults({
    required this.results,
    required this.hasMore,
    required this.totalCount,
    required this.query,
  });
}

class SearchResult {
  final String id;
  final SearchEntityType entityType;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? subtitle;
  final double? rating;
  final int? reviewCount;
  final double? price;
  final String? currency;
  final DateTime createdAt;
  final double relevanceScore;
  final double? popularityScore;
  final Map<String, dynamic> metadata;

  SearchResult({
    required this.id,
    required this.entityType,
    required this.title,
    this.description,
    this.imageUrl,
    this.subtitle,
    this.rating,
    this.reviewCount,
    this.price,
    this.currency,
    required this.createdAt,
    required this.relevanceScore,
    this.popularityScore,
    this.metadata = const {},
  });

  factory SearchResult.fromCourse(Map<String, dynamic> data) {
    return SearchResult(
      id: data['id'],
      entityType: SearchEntityType.courses,
      title: data['title'],
      description: data['short_description'] ?? data['description'],
      imageUrl: data['thumbnail_url'],
      subtitle: data['coaching_centers']['center_name'],
      rating: data['rating']?.toDouble(),
      reviewCount: data['total_reviews'],
      price: data['price']?.toDouble(),
      currency: data['currency'],
      createdAt: DateTime.parse(data['created_at']),
      relevanceScore: _calculateCourseRelevance(data),
      popularityScore: data['enrollment_count']?.toDouble(),
      metadata: {
        'category': data['category'],
        'level': data['level'],
        'duration_hours': data['duration_hours'],
        'total_lessons': data['total_lessons'],
        'is_featured': data['is_featured'],
        'coaching_center': data['coaching_centers'],
        'teacher': data['teachers'],
      },
    );
  }

  factory SearchResult.fromCoachingCenter(Map<String, dynamic> data) {
    return SearchResult(
      id: data['id'],
      entityType: SearchEntityType.coachingCenters,
      title: data['center_name'],
      description: data['description'],
      imageUrl: data['logo_url'],
      subtitle: '${data['total_courses']} courses • ${data['total_students']} students',
      createdAt: DateTime.parse(data['created_at']),
      relevanceScore: _calculateCenterRelevance(data),
      popularityScore: data['total_students']?.toDouble(),
      metadata: {
        'contact_email': data['contact_email'],
        'contact_phone': data['contact_phone'],
        'address': data['address'],
        'total_courses': data['total_courses'],
        'total_students': data['total_students'],
      },
    );
  }

  factory SearchResult.fromLiveClass(Map<String, dynamic> data) {
    return SearchResult(
      id: data['id'],
      entityType: SearchEntityType.liveClasses,
      title: data['title'],
      description: data['description'],
      imageUrl: data['thumbnail_url'],
      subtitle: data['coaching_centers']['center_name'],
      price: data['is_free'] ? 0.0 : data['price']?.toDouble(),
      currency: data['currency'],
      createdAt: DateTime.parse(data['scheduled_at']),
      relevanceScore: _calculateLiveClassRelevance(data),
      popularityScore: data['current_participants']?.toDouble(),
      metadata: {
        'scheduled_at': data['scheduled_at'],
        'duration_minutes': data['duration_minutes'],
        'max_participants': data['max_participants'],
        'current_participants': data['current_participants'],
        'status': data['status'],
        'is_free': data['is_free'],
        'coaching_center': data['coaching_centers'],
        'teacher': data['teachers'],
      },
    );
  }

  factory SearchResult.fromTeacher(Map<String, dynamic> data) {
    final profile = data['user_profiles'];
    return SearchResult(
      id: data['id'],
      entityType: SearchEntityType.teachers,
      title: '${profile['first_name']} ${profile['last_name']}',
      description: data['bio'],
      imageUrl: profile['avatar_url'],
      subtitle: data['coaching_centers']['center_name'],
      rating: data['rating']?.toDouble(),
      reviewCount: data['total_reviews'],
      createdAt: DateTime.now(), // Teachers don't have created_at in the query
      relevanceScore: _calculateTeacherRelevance(data),
      popularityScore: data['total_reviews']?.toDouble(),
      metadata: {
        'specializations': data['specializations'],
        'qualifications': data['qualifications'],
        'experience_years': data['experience_years'],
        'is_verified': data['is_verified'],
        'coaching_center': data['coaching_centers'],
      },
    );
  }

  static double _calculateCourseRelevance(Map<String, dynamic> data) {
    double score = 0.0;
    
    // Rating weight (0-5 -> 0-50 points)
    score += (data['rating'] ?? 0) * 10;
    
    // Enrollment count weight (normalized)
    score += (data['enrollment_count'] ?? 0) * 0.1;
    
    // Featured courses get bonus
    if (data['is_featured'] == true) score += 20;
    
    // Recent courses get slight bonus
    final daysOld = DateTime.now().difference(DateTime.parse(data['created_at'])).inDays;
    if (daysOld < 30) score += 10;
    
    return score;
  }

  static double _calculateCenterRelevance(Map<String, dynamic> data) {
    double score = 0.0;
    
    // Student count weight
    score += (data['total_students'] ?? 0) * 0.1;
    
    // Course count weight
    score += (data['total_courses'] ?? 0) * 2;
    
    return score;
  }

  static double _calculateLiveClassRelevance(Map<String, dynamic> data) {
    double score = 0.0;
    
    // Upcoming classes get higher score
    final scheduledAt = DateTime.parse(data['scheduled_at']);
    final hoursUntil = scheduledAt.difference(DateTime.now()).inHours;
    
    if (hoursUntil > 0 && hoursUntil < 24) {
      score += 50; // Classes in next 24 hours
    } else if (hoursUntil >= 24 && hoursUntil < 168) {
      score += 30; // Classes in next week
    }
    
    // Participation rate
    final maxParticipants = data['max_participants'] ?? 1;
    final currentParticipants = data['current_participants'] ?? 0;
    score += (currentParticipants / maxParticipants) * 20;
    
    return score;
  }

  static double _calculateTeacherRelevance(Map<String, dynamic> data) {
    double score = 0.0;
    
    // Rating weight
    score += (data['rating'] ?? 0) * 10;
    
    // Experience weight
    score += (data['experience_years'] ?? 0) * 2;
    
    // Review count weight
    score += (data['total_reviews'] ?? 0) * 0.5;
    
    // Verified teachers get bonus
    if (data['is_verified'] == true) score += 25;
    
    return score;
  }
}

class SearchException implements Exception {
  final String message;
  SearchException(this.message);
  
  @override
  String toString() => 'SearchException: $message';
}
