class Faculty {
  final String id;
  final String facultyId;
  final String? title;
  final List<String> qualification;
  final List<String> specialization;
  final int? experienceYears;
  final String? bio;
  final List<String> expertiseSubjects;
  final List<String> languagesSpoken;
  final double rating;
  final int totalReviews;
  final int totalStudentsTaught;
  final int totalCoursesCreated;
  final int totalCoursesEnrolled;
  final int totalLiveSessions;
  final double? hourlyRate;
  final Map<String, dynamic>? availabilitySchedule;
  final bool isVerifiedEducator;
  final List<String> verificationDocuments;
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? panNumber;
  final String? aadharNumber;
  final String? resumeUrl;
  final List<String> certificates;
  final Map<String, dynamic>? socialLinks;
  final List<String> teachingMode;
  final int? preferredBatchSize;
  final DateTime createdAt;
  final DateTime updatedAt;

  Faculty({
    required this.id,
    required this.facultyId,
    this.title,
    this.qualification = const [],
    this.specialization = const [],
    this.experienceYears,
    this.bio,
    this.expertiseSubjects = const [],
    this.languagesSpoken = const [],
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalStudentsTaught = 0,
    this.totalCoursesCreated = 0,
    this.totalCoursesEnrolled = 0,
    this.totalLiveSessions = 0,
    this.hourlyRate,
    this.availabilitySchedule,
    this.isVerifiedEducator = false,
    this.verificationDocuments = const [],
    this.bankAccountNumber,
    this.ifscCode,
    this.panNumber,
    this.aadharNumber,
    this.resumeUrl,
    this.certificates = const [],
    this.socialLinks,
    this.teachingMode = const ['online'],
    this.preferredBatchSize,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      id: json['id'],
      facultyId: json['faculty_id'],
      title: json['title'],
      qualification: List<String>.from(json['qualification'] ?? []),
      specialization: List<String>.from(json['specialization'] ?? []),
      experienceYears: json['experience_years'],
      bio: json['bio'],
      expertiseSubjects: List<String>.from(json['expertise_subjects'] ?? []),
      languagesSpoken: List<String>.from(json['languages_spoken'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      totalStudentsTaught: json['total_students_taught'] ?? 0,
      totalCoursesCreated: json['total_courses_created'] ?? 0,
      totalCoursesEnrolled: json['total_courses_enrolled'] ?? 0,
      totalLiveSessions: json['total_live_sessions'] ?? 0,
      hourlyRate: json['hourly_rate']?.toDouble(),
      availabilitySchedule: json['availability_schedule'],
      isVerifiedEducator: json['is_verified_educator'] ?? false,
      verificationDocuments: List<String>.from(json['verification_documents'] ?? []),
      bankAccountNumber: json['bank_account_number'],
      ifscCode: json['ifsc_code'],
      panNumber: json['pan_number'],
      aadharNumber: json['aadhar_number'],
      resumeUrl: json['resume_url'],
      certificates: List<String>.from(json['certificates'] ?? []),
      socialLinks: json['social_links'],
      teachingMode: List<String>.from(json['teaching_mode'] ?? ['online']),
      preferredBatchSize: json['preferred_batch_size'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'faculty_id': facultyId,
      'title': title,
      'qualification': qualification,
      'specialization': specialization,
      'experience_years': experienceYears,
      'bio': bio,
      'expertise_subjects': expertiseSubjects,
      'languages_spoken': languagesSpoken,
      'rating': rating,
      'total_reviews': totalReviews,
      'total_students_taught': totalStudentsTaught,
      'total_courses_created': totalCoursesCreated,
      'total_courses_enrolled': totalCoursesEnrolled,
      'total_live_sessions': totalLiveSessions,
      'hourly_rate': hourlyRate,
      'availability_schedule': availabilitySchedule,
      'is_verified_educator': isVerifiedEducator,
      'verification_documents': verificationDocuments,
      'bank_account_number': bankAccountNumber,
      'ifsc_code': ifscCode,
      'pan_number': panNumber,
      'aadhar_number': aadharNumber,
      'resume_url': resumeUrl,
      'certificates': certificates,
      'social_links': socialLinks,
      'teaching_mode': teachingMode,
      'preferred_batch_size': preferredBatchSize,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Faculty copyWith({
    String? id,
    String? facultyId,
    String? title,
    List<String>? qualification,
    List<String>? specialization,
    int? experienceYears,
    String? bio,
    List<String>? expertiseSubjects,
    List<String>? languagesSpoken,
    double? rating,
    int? totalReviews,
    int? totalStudentsTaught,
    int? totalCoursesCreated,
    int? totalCoursesEnrolled,
    int? totalLiveSessions,
    double? hourlyRate,
    Map<String, dynamic>? availabilitySchedule,
    bool? isVerifiedEducator,
    List<String>? verificationDocuments,
    String? bankAccountNumber,
    String? ifscCode,
    String? panNumber,
    String? aadharNumber,
    String? resumeUrl,
    List<String>? certificates,
    Map<String, dynamic>? socialLinks,
    List<String>? teachingMode,
    int? preferredBatchSize,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Faculty(
      id: id ?? this.id,
      facultyId: facultyId ?? this.facultyId,
      title: title ?? this.title,
      qualification: qualification ?? this.qualification,
      specialization: specialization ?? this.specialization,
      experienceYears: experienceYears ?? this.experienceYears,
      bio: bio ?? this.bio,
      expertiseSubjects: expertiseSubjects ?? this.expertiseSubjects,
      languagesSpoken: languagesSpoken ?? this.languagesSpoken,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalStudentsTaught: totalStudentsTaught ?? this.totalStudentsTaught,
      totalCoursesCreated: totalCoursesCreated ?? this.totalCoursesCreated,
      totalCoursesEnrolled: totalCoursesEnrolled ?? this.totalCoursesEnrolled,
      totalLiveSessions: totalLiveSessions ?? this.totalLiveSessions,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      availabilitySchedule: availabilitySchedule ?? this.availabilitySchedule,
      isVerifiedEducator: isVerifiedEducator ?? this.isVerifiedEducator,
      verificationDocuments: verificationDocuments ?? this.verificationDocuments,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      panNumber: panNumber ?? this.panNumber,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      certificates: certificates ?? this.certificates,
      socialLinks: socialLinks ?? this.socialLinks,
      teachingMode: teachingMode ?? this.teachingMode,
      preferredBatchSize: preferredBatchSize ?? this.preferredBatchSize,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
