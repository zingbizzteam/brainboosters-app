
import 'package:brainboosters_app/screens/authentication/models/enums.dart';

class Student {
  final String id;
  final String studentId;
  final DateTime? dateOfBirth;
  final Gender? gender;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? parentName;
  final String? parentPhone;
  final String? parentEmail;
  final String? educationLevel;
  final String? schoolCollege;
  final String preferredLanguage;
  final List<String> learningGoals;
  final List<String> interests;
  final bool onboardingCompleted;
  final int totalCoursesEnrolled;
  final int totalCoursesCompleted;
  final int totalStudyHours;
  final int currentStreak;
  final int maxStreak;
  final int pointsEarned;
  final List<String> badgesEarned;
  final DateTime createdAt;
  final DateTime updatedAt;

  Student({
    required this.id,
    required this.studentId,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.parentName,
    this.parentPhone,
    this.parentEmail,
    this.educationLevel,
    this.schoolCollege,
    this.preferredLanguage = 'english',
    this.learningGoals = const [],
    this.interests = const [],
    this.onboardingCompleted = false,
    this.totalCoursesEnrolled = 0,
    this.totalCoursesCompleted = 0,
    this.totalStudyHours = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.pointsEarned = 0,
    this.badgesEarned = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      studentId: json['student_id'],
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth']) 
          : null,
      gender: json['gender'] != null 
          ? Gender.values.firstWhere(
              (e) => e.toString().split('.').last == json['gender']
            ) 
          : null,
      address: json['address'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      parentName: json['parent_name'],
      parentPhone: json['parent_phone'],
      parentEmail: json['parent_email'],
      educationLevel: json['education_level'],
      schoolCollege: json['school_college'],
      preferredLanguage: json['preferred_language'] ?? 'english',
      learningGoals: List<String>.from(json['learning_goals'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
      onboardingCompleted: json['onboarding_completed'] ?? false,
      totalCoursesEnrolled: json['total_courses_enrolled'] ?? 0,
      totalCoursesCompleted: json['total_courses_completed'] ?? 0,
      totalStudyHours: json['total_study_hours'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      maxStreak: json['max_streak'] ?? 0,
      pointsEarned: json['points_earned'] ?? 0,
      badgesEarned: List<String>.from(json['badges_earned'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender?.toString().split('.').last,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'parent_name': parentName,
      'parent_phone': parentPhone,
      'parent_email': parentEmail,
      'education_level': educationLevel,
      'school_college': schoolCollege,
      'preferred_language': preferredLanguage,
      'learning_goals': learningGoals,
      'interests': interests,
      'onboarding_completed': onboardingCompleted,
      'total_courses_enrolled': totalCoursesEnrolled,
      'total_courses_completed': totalCoursesCompleted,
      'total_study_hours': totalStudyHours,
      'current_streak': currentStreak,
      'max_streak': maxStreak,
      'points_earned': pointsEarned,
      'badges_earned': badgesEarned,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Student copyWith({
    String? id,
    String? studentId,
    DateTime? dateOfBirth,
    Gender? gender,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? parentName,
    String? parentPhone,
    String? parentEmail,
    String? educationLevel,
    String? schoolCollege,
    String? preferredLanguage,
    List<String>? learningGoals,
    List<String>? interests,
    bool? onboardingCompleted,
    int? totalCoursesEnrolled,
    int? totalCoursesCompleted,
    int? totalStudyHours,
    int? currentStreak,
    int? maxStreak,
    int? pointsEarned,
    List<String>? badgesEarned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      parentEmail: parentEmail ?? this.parentEmail,
      educationLevel: educationLevel ?? this.educationLevel,
      schoolCollege: schoolCollege ?? this.schoolCollege,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      learningGoals: learningGoals ?? this.learningGoals,
      interests: interests ?? this.interests,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      totalCoursesEnrolled: totalCoursesEnrolled ?? this.totalCoursesEnrolled,
      totalCoursesCompleted: totalCoursesCompleted ?? this.totalCoursesCompleted,
      totalStudyHours: totalStudyHours ?? this.totalStudyHours,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      badgesEarned: badgesEarned ?? this.badgesEarned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
