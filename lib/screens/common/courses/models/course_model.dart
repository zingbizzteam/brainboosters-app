import 'chapter_model.dart';
import 'review_model.dart';

class CourseAnalytics {
  final int enrolledCount;
  final int completedCount;
  final int viewCount;
  final int likes;
  final int shares;
  final int questionsAsked;
  final int discussions;

  const CourseAnalytics({
    this.enrolledCount = 0,
    this.completedCount = 0,
    this.viewCount = 0,
    this.likes = 0,
    this.shares = 0,
    this.questionsAsked = 0,
    this.discussions = 0,
  });
}

class WhatsIncluded {
  final bool certificate;
  final bool quizzes;
  final bool assignments;
  final bool downloadableResources;
  final bool lifetimeAccess;
  final bool accessOnMobile;
  final bool instructorQnA;
  final bool communityAccess;

  const WhatsIncluded({
    this.certificate = false,
    this.quizzes = false,
    this.assignments = false,
    this.downloadableResources = false,
    this.lifetimeAccess = false,
    this.accessOnMobile = false,
    this.instructorQnA = false,
    this.communityAccess = false,
  });
}

class Course {
  final String id;
  final String slug;
  final String title;
  final String description;
  final String imageUrl;
  final String academy;
  final List<String> instructors;
  final String category;
  final String subject;
  final double rating;
  final int totalRatings;
  final double price;
  final double originalPrice;
  final String difficulty; // Beginner, Intermediate, Advanced
  final int duration; // in hours
  final int totalLessons;
  final List<String> tags;
  final bool isCertified;
  final bool isEnrolled;
  final double progress; // 0.0 to 1.0
  final DateTime createdAt;
  final DateTime updatedAt;
  final String language;
  final List<String> requirements;
  final List<String> whatYouWillLearn;

  // New fields
  final CourseAnalytics analytics;
  final WhatsIncluded whatsIncluded;
  final List<Chapter> chapters;
  final List<Review> reviews;
  final List<String> courseContentTitles; // e.g. ["Introduction", "Basics", "Advanced Topics"]

  const Course({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.academy,
    required this.instructors,
    required this.category,
    required this.subject,
    required this.rating,
    required this.totalRatings,
    required this.price,
    required this.originalPrice,
    required this.difficulty,
    required this.duration,
    required this.totalLessons,
    required this.tags,
    required this.isCertified,
    required this.isEnrolled,
    required this.progress,
    required this.createdAt,
    required this.updatedAt,
    required this.language,
    required this.requirements,
    required this.whatYouWillLearn,
    // New
    this.analytics = const CourseAnalytics(),
    this.whatsIncluded = const WhatsIncluded(),
    this.chapters = const [],
    this.reviews = const [],
    this.courseContentTitles = const [],
  });

  bool get isFree => price == 0.0;
  bool get hasDiscount => originalPrice > price;
  double get discountPercentage => hasDiscount ? ((originalPrice - price) / originalPrice) * 100 : 0.0;
  String get formattedDuration => duration > 1 ? '$duration hours' : '$duration hour';
  String get formattedPrice => isFree ? 'Free' : '₹${price.toStringAsFixed(0)}';
}
