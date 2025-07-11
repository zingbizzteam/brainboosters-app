// lib/models/profile_data.dart
class ProfileData {
  final Map<String, dynamic>? userProfile;
  final Map<String, dynamic> analyticsReport;

  ProfileData({
    required this.userProfile,
    required this.analyticsReport,
  });

  Map<String, dynamic>? get student => userProfile?['students'];
  Map<String, dynamic> get summary => analyticsReport['summary'] ?? {};
  List<Map<String, dynamic>> get learningAnalytics => 
      (analyticsReport['learning_analytics'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
  List<Map<String, dynamic>> get courseProgress => 
      (analyticsReport['course_progress'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
  List<Map<String, dynamic>> get testPerformance => 
      (analyticsReport['test_performance'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

  String get fullName {
    final firstName = userProfile?['first_name'] ?? '';
    final lastName = userProfile?['last_name'] ?? '';
    return '$firstName $lastName'.trim();
  }

  String? get avatarUrl => userProfile?['avatar_url'];
  String? get gradeLevel => student?['grade_level']?.toString();
  int get level => student?['level'] ?? 1;
  int get currentStreak => student?['current_streak_days'] ?? 0;
  int get totalPoints => student?['total_points'] ?? 0;
}
