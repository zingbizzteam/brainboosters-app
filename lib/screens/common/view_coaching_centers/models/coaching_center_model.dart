// models/coaching_center_model.dart
class CoachingCenter {
  final String id;
  final String slug;
  final String name;
  final double rating;
  final int reviews;
  final String description;
  final String location;
  final int coursesOffered;
  final int studentsEnrolled;
  final String imageUrl;
  final List<String> imageGallery;
  final List<String> specializations;
  final int experienceYears;
  final bool isVerified;
  final DateTime establishedDate;
  final String contactEmail;
  final String contactPhone;
  final List<String> facilities;
  final double fees;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional real-world fields
  final String website;
  final List<String> socialMediaLinks;
  final String licenseNumber;
  final List<String> certifications;
  final List<String> awards;
  final String foundersName;
  final List<String> languages;
  final List<String> teachingMethods;
  final String category; // Engineering, Medical, Competitive Exams, etc.
  final List<String> examsPrepared; // JEE, NEET, UPSC, etc.
  final List<String> batchTimings;
  final bool hasOnlineClasses;
  final bool hasOfflineClasses;
  final bool hasHybridClasses;
  final double successRate; // Percentage of students who passed
  final List<String> toppersList;
  final int facultyCount;
  final double averageClassSize;
  final bool hasLibrary;
  final bool hasLabFacility;
  final bool hasHostelFacility;
  final bool hasCafeteria;
  final bool hasTransportFacility;
  final String admissionProcess;
  final Map<String, dynamic> feeStructure; // Different courses and their fees
  final List<String> scholarshipOptions;
  final String refundPolicy;

  // Analytics fields
  final CoachingCenterAnalytics analytics;
  final List<CoachingCenterReview> studentReviews;
  final List<CoachingCenterBatch> batches;
  final List<CoachingCenterFaculty> faculty;
  final Map<String, dynamic> metadata;

  const CoachingCenter({
    required this.id,
    required this.slug,
    required this.name,
    required this.rating,
    required this.reviews,
    required this.description,
    required this.location,
    required this.coursesOffered,
    required this.studentsEnrolled,
    required this.imageUrl,
    required this.specializations,
    required this.experienceYears,
    required this.isVerified,
    required this.establishedDate,
    required this.contactEmail,
    required this.contactPhone,
    required this.facilities,
    required this.fees,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
    // Additional fields
    this.imageGallery = const [],
    this.website = '',
    this.socialMediaLinks = const [],
    this.licenseNumber = '',
    this.certifications = const [],
    this.awards = const [],
    this.foundersName = '',
    this.languages = const ['English'],
    this.teachingMethods = const [],
    this.category = '',
    this.examsPrepared = const [],
    this.batchTimings = const [],
    this.hasOnlineClasses = false,
    this.hasOfflineClasses = true,
    this.hasHybridClasses = false,
    this.successRate = 0.0,
    this.toppersList = const [],
    this.facultyCount = 0,
    this.averageClassSize = 0.0,
    this.hasLibrary = false,
    this.hasLabFacility = false,
    this.hasHostelFacility = false,
    this.hasCafeteria = false,
    this.hasTransportFacility = false,
    this.admissionProcess = '',
    this.feeStructure = const {},
    this.scholarshipOptions = const [],
    this.refundPolicy = '',
    // Analytics
    this.analytics = const CoachingCenterAnalytics(),
    this.studentReviews = const [],
    this.batches = const [],
    this.faculty = const [],
    this.metadata = const {},
  });

  // Existing getters
  String get formattedStudents {
    if (studentsEnrolled >= 100000) {
      return '${(studentsEnrolled / 100000).toStringAsFixed(1)}L';
    } else if (studentsEnrolled >= 1000) {
      return '${(studentsEnrolled / 1000).toStringAsFixed(1)}K';
    }
    return studentsEnrolled.toString();
  }

  String get formattedFees {
    return '₹${fees.toStringAsFixed(0)}';
  }

  // New getters
  String get formattedRating {
    return rating.toStringAsFixed(1);
  }

  String get formattedReviews {
    if (reviews >= 1000) {
      return '${(reviews / 1000).toStringAsFixed(1)}K';
    }
    return reviews.toString();
  }

  String get experienceText {
    return '$experienceYears+ years experience';
  }

  String get establishedYear {
    return establishedDate.year.toString();
  }

  String get successRateText {
    return '${successRate.toStringAsFixed(1)}% success rate';
  }

  String get facultyCountText {
    return '$facultyCount expert faculty';
  }

  String get averageClassSizeText {
    return '${averageClassSize.toStringAsFixed(0)} students per batch';
  }

  List<String> get availableTimings {
    return batchTimings.isNotEmpty ? batchTimings : ['Morning', 'Evening'];
  }

  String get classModesText {
    List<String> modes = [];
    if (hasOnlineClasses) modes.add('Online');
    if (hasOfflineClasses) modes.add('Offline');
    if (hasHybridClasses) modes.add('Hybrid');
    return modes.join(', ');
  }

  bool get hasMultipleModes {
    int modeCount = 0;
    if (hasOnlineClasses) modeCount++;
    if (hasOfflineClasses) modeCount++;
    if (hasHybridClasses) modeCount++;
    return modeCount > 1;
  }

  List<String> get allFacilities {
    List<String> allFacilities = List.from(facilities);
    if (hasLibrary) allFacilities.add('Library');
    if (hasLabFacility) allFacilities.add('Lab Facility');
    if (hasHostelFacility) allFacilities.add('Hostel');
    if (hasCafeteria) allFacilities.add('Cafeteria');
    if (hasTransportFacility) allFacilities.add('Transport');
    return allFacilities;
  }

  String get primarySpecialization {
    return specializations.isNotEmpty ? specializations.first : category;
  }

  List<CoachingCenterReview> get recentReviews {
    return studentReviews.take(5).toList();
  }

  double get averageBatchSize {
    if (batches.isEmpty) return averageClassSize;
    return batches.map((b) => b.currentStudents).reduce((a, b) => a + b) / batches.length;
  }

  int get totalCapacity {
    return batches.map((b) => b.maxCapacity).fold(0, (a, b) => a + b);
  }

  int get availableSeats {
    return totalCapacity - studentsEnrolled;
  }

  bool get hasAvailableSeats {
    return availableSeats > 0;
  }

  String get admissionStatus {
    if (!hasAvailableSeats) return 'Admission Closed';
    if (availableSeats <= 10) return 'Few Seats Left';
    return 'Admission Open';
  }

  // JSON serialization
  factory CoachingCenter.fromJson(Map<String, dynamic> json) {
    return CoachingCenter(
      id: json['id'] ?? '',
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviews: json['reviews'] ?? 0,
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      coursesOffered: json['courses_offered'] ?? 0,
      studentsEnrolled: json['students_enrolled'] ?? 0,
      imageUrl: json['image_url'] ?? '',
      specializations: List<String>.from(json['specializations'] ?? []),
      experienceYears: json['experience_years'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      establishedDate: DateTime.parse(json['established_date']),
      contactEmail: json['contact_email'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      facilities: List<String>.from(json['facilities'] ?? []),
      fees: (json['fees'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      // Additional fields
      imageGallery: List<String>.from(json['image_gallery'] ?? []),
      website: json['website'] ?? '',
      socialMediaLinks: List<String>.from(json['social_media_links'] ?? []),
      licenseNumber: json['license_number'] ?? '',
      certifications: List<String>.from(json['certifications'] ?? []),
      awards: List<String>.from(json['awards'] ?? []),
      foundersName: json['founders_name'] ?? '',
      languages: List<String>.from(json['languages'] ?? ['English']),
      teachingMethods: List<String>.from(json['teaching_methods'] ?? []),
      category: json['category'] ?? '',
      examsPrepared: List<String>.from(json['exams_prepared'] ?? []),
      batchTimings: List<String>.from(json['batch_timings'] ?? []),
      hasOnlineClasses: json['has_online_classes'] ?? false,
      hasOfflineClasses: json['has_offline_classes'] ?? true,
      hasHybridClasses: json['has_hybrid_classes'] ?? false,
      successRate: (json['success_rate'] ?? 0.0).toDouble(),
      toppersList: List<String>.from(json['toppers_list'] ?? []),
      facultyCount: json['faculty_count'] ?? 0,
      averageClassSize: (json['average_class_size'] ?? 0.0).toDouble(),
      hasLibrary: json['has_library'] ?? false,
      hasLabFacility: json['has_lab_facility'] ?? false,
      hasHostelFacility: json['has_hostel_facility'] ?? false,
      hasCafeteria: json['has_cafeteria'] ?? false,
      hasTransportFacility: json['has_transport_facility'] ?? false,
      admissionProcess: json['admission_process'] ?? '',
      feeStructure: json['fee_structure'] ?? {},
      scholarshipOptions: List<String>.from(json['scholarship_options'] ?? []),
      refundPolicy: json['refund_policy'] ?? '',
      // Analytics
      analytics: json['analytics'] != null 
          ? CoachingCenterAnalytics.fromJson(json['analytics'])
          : const CoachingCenterAnalytics(),
      studentReviews: (json['student_reviews'] as List<dynamic>?)
          ?.map((e) => CoachingCenterReview.fromJson(e))
          .toList() ?? [],
      batches: (json['batches'] as List<dynamic>?)
          ?.map((e) => CoachingCenterBatch.fromJson(e))
          .toList() ?? [],
      faculty: (json['faculty'] as List<dynamic>?)
          ?.map((e) => CoachingCenterFaculty.fromJson(e))
          .toList() ?? [],
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'rating': rating,
      'reviews': reviews,
      'description': description,
      'location': location,
      'courses_offered': coursesOffered,
      'students_enrolled': studentsEnrolled,
      'image_url': imageUrl,
      'specializations': specializations,
      'experience_years': experienceYears,
      'is_verified': isVerified,
      'established_date': establishedDate.toIso8601String(),
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'facilities': facilities,
      'fees': fees,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      // Additional fields
      'image_gallery': imageGallery,
      'website': website,
      'social_media_links': socialMediaLinks,
      'license_number': licenseNumber,
      'certifications': certifications,
      'awards': awards,
      'founders_name': foundersName,
      'languages': languages,
      'teaching_methods': teachingMethods,
      'category': category,
      'exams_prepared': examsPrepared,
      'batch_timings': batchTimings,
      'has_online_classes': hasOnlineClasses,
      'has_offline_classes': hasOfflineClasses,
      'has_hybrid_classes': hasHybridClasses,
      'success_rate': successRate,
      'toppers_list': toppersList,
      'faculty_count': facultyCount,
      'average_class_size': averageClassSize,
      'has_library': hasLibrary,
      'has_lab_facility': hasLabFacility,
      'has_hostel_facility': hasHostelFacility,
      'has_cafeteria': hasCafeteria,
      'has_transport_facility': hasTransportFacility,
      'admission_process': admissionProcess,
      'fee_structure': feeStructure,
      'scholarship_options': scholarshipOptions,
      'refund_policy': refundPolicy,
      // Analytics
      'analytics': analytics.toJson(),
      'student_reviews': studentReviews.map((e) => e.toJson()).toList(),
      'batches': batches.map((e) => e.toJson()).toList(),
      'faculty': faculty.map((e) => e.toJson()).toList(),
      'metadata': metadata,
    };
  }

  // CopyWith method for immutable updates
  CoachingCenter copyWith({
    String? id,
    String? slug,
    String? name,
    double? rating,
    int? reviews,
    String? description,
    String? location,
    int? coursesOffered,
    int? studentsEnrolled,
    String? imageUrl,
    List<String>? imageGallery,
    List<String>? specializations,
    int? experienceYears,
    bool? isVerified,
    DateTime? establishedDate,
    String? contactEmail,
    String? contactPhone,
    List<String>? facilities,
    double? fees,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? website,
    List<String>? socialMediaLinks,
    String? licenseNumber,
    List<String>? certifications,
    List<String>? awards,
    String? foundersName,
    List<String>? languages,
    List<String>? teachingMethods,
    String? category,
    List<String>? examsPrepared,
    List<String>? batchTimings,
    bool? hasOnlineClasses,
    bool? hasOfflineClasses,
    bool? hasHybridClasses,
    double? successRate,
    List<String>? toppersList,
    int? facultyCount,
    double? averageClassSize,
    bool? hasLibrary,
    bool? hasLabFacility,
    bool? hasHostelFacility,
    bool? hasCafeteria,
    bool? hasTransportFacility,
    String? admissionProcess,
    Map<String, dynamic>? feeStructure,
    List<String>? scholarshipOptions,
    String? refundPolicy,
    CoachingCenterAnalytics? analytics,
    List<CoachingCenterReview>? studentReviews,
    List<CoachingCenterBatch>? batches,
    List<CoachingCenterFaculty>? faculty,
    Map<String, dynamic>? metadata,
  }) {
    return CoachingCenter(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      description: description ?? this.description,
      location: location ?? this.location,
      coursesOffered: coursesOffered ?? this.coursesOffered,
      studentsEnrolled: studentsEnrolled ?? this.studentsEnrolled,
      imageUrl: imageUrl ?? this.imageUrl,
      imageGallery: imageGallery ?? this.imageGallery,
      specializations: specializations ?? this.specializations,
      experienceYears: experienceYears ?? this.experienceYears,
      isVerified: isVerified ?? this.isVerified,
      establishedDate: establishedDate ?? this.establishedDate,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      facilities: facilities ?? this.facilities,
      fees: fees ?? this.fees,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      website: website ?? this.website,
      socialMediaLinks: socialMediaLinks ?? this.socialMediaLinks,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      certifications: certifications ?? this.certifications,
      awards: awards ?? this.awards,
      foundersName: foundersName ?? this.foundersName,
      languages: languages ?? this.languages,
      teachingMethods: teachingMethods ?? this.teachingMethods,
      category: category ?? this.category,
      examsPrepared: examsPrepared ?? this.examsPrepared,
      batchTimings: batchTimings ?? this.batchTimings,
      hasOnlineClasses: hasOnlineClasses ?? this.hasOnlineClasses,
      hasOfflineClasses: hasOfflineClasses ?? this.hasOfflineClasses,
      hasHybridClasses: hasHybridClasses ?? this.hasHybridClasses,
      successRate: successRate ?? this.successRate,
      toppersList: toppersList ?? this.toppersList,
      facultyCount: facultyCount ?? this.facultyCount,
      averageClassSize: averageClassSize ?? this.averageClassSize,
      hasLibrary: hasLibrary ?? this.hasLibrary,
      hasLabFacility: hasLabFacility ?? this.hasLabFacility,
      hasHostelFacility: hasHostelFacility ?? this.hasHostelFacility,
      hasCafeteria: hasCafeteria ?? this.hasCafeteria,
      hasTransportFacility: hasTransportFacility ?? this.hasTransportFacility,
      admissionProcess: admissionProcess ?? this.admissionProcess,
      feeStructure: feeStructure ?? this.feeStructure,
      scholarshipOptions: scholarshipOptions ?? this.scholarshipOptions,
      refundPolicy: refundPolicy ?? this.refundPolicy,
      analytics: analytics ?? this.analytics,
      studentReviews: studentReviews ?? this.studentReviews,
      batches: batches ?? this.batches,
      faculty: faculty ?? this.faculty,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoachingCenter && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CoachingCenter(id: $id, name: $name, location: $location, rating: $rating)';
  }
}

// Supporting models
class CoachingCenterAnalytics {
  final int totalEnquiries;
  final int admissionsThisMonth;
  final int activeStudents;
  final double averageAttendance;
  final int successfulPlacements;
  final double studentSatisfactionScore;
  final Map<String, int> monthlyEnrollments;
  final Map<String, double> subjectWisePerformance;
  final int websiteVisits;
  final int brochureDownloads;

  const CoachingCenterAnalytics({
    this.totalEnquiries = 0,
    this.admissionsThisMonth = 0,
    this.activeStudents = 0,
    this.averageAttendance = 0.0,
    this.successfulPlacements = 0,
    this.studentSatisfactionScore = 0.0,
    this.monthlyEnrollments = const {},
    this.subjectWisePerformance = const {},
    this.websiteVisits = 0,
    this.brochureDownloads = 0,
  });

  factory CoachingCenterAnalytics.fromJson(Map<String, dynamic> json) {
    return CoachingCenterAnalytics(
      totalEnquiries: json['total_enquiries'] ?? 0,
      admissionsThisMonth: json['admissions_this_month'] ?? 0,
      activeStudents: json['active_students'] ?? 0,
      averageAttendance: (json['average_attendance'] ?? 0.0).toDouble(),
      successfulPlacements: json['successful_placements'] ?? 0,
      studentSatisfactionScore: (json['student_satisfaction_score'] ?? 0.0).toDouble(),
      monthlyEnrollments: Map<String, int>.from(json['monthly_enrollments'] ?? {}),
      subjectWisePerformance: Map<String, double>.from(json['subject_wise_performance'] ?? {}),
      websiteVisits: json['website_visits'] ?? 0,
      brochureDownloads: json['brochure_downloads'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_enquiries': totalEnquiries,
      'admissions_this_month': admissionsThisMonth,
      'active_students': activeStudents,
      'average_attendance': averageAttendance,
      'successful_placements': successfulPlacements,
      'student_satisfaction_score': studentSatisfactionScore,
      'monthly_enrollments': monthlyEnrollments,
      'subject_wise_performance': subjectWisePerformance,
      'website_visits': websiteVisits,
      'brochure_downloads': brochureDownloads,
    };
  }
}

class CoachingCenterReview {
  final String id;
  final String studentName;
  final String studentAvatarUrl;
  final double rating;
  final String comment;
  final DateTime reviewDate;
  final String course;
  final bool isVerified;

  const CoachingCenterReview({
    required this.id,
    required this.studentName,
    required this.studentAvatarUrl,
    required this.rating,
    required this.comment,
    required this.reviewDate,
    required this.course,
    this.isVerified = false,
  });

  factory CoachingCenterReview.fromJson(Map<String, dynamic> json) {
    return CoachingCenterReview(
      id: json['id'] ?? '',
      studentName: json['student_name'] ?? '',
      studentAvatarUrl: json['student_avatar_url'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      reviewDate: DateTime.parse(json['review_date']),
      course: json['course'] ?? '',
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': studentName,
      'student_avatar_url': studentAvatarUrl,
      'rating': rating,
      'comment': comment,
      'review_date': reviewDate.toIso8601String(),
      'course': course,
      'is_verified': isVerified,
    };
  }
}

class CoachingCenterBatch {
  final String id;
  final String name;
  final String course;
  final String timing;
  final int maxCapacity;
  final int currentStudents;
  final DateTime startDate;
  final DateTime endDate;
  final String instructor;
  final double fees;
  final String mode; // Online, Offline, Hybrid

  const CoachingCenterBatch({
    required this.id,
    required this.name,
    required this.course,
    required this.timing,
    required this.maxCapacity,
    required this.currentStudents,
    required this.startDate,
    required this.endDate,
    required this.instructor,
    required this.fees,
    required this.mode,
  });

  bool get hasAvailableSeats => currentStudents < maxCapacity;
  int get availableSeats => maxCapacity - currentStudents;
  double get occupancyPercentage => (currentStudents / maxCapacity) * 100;

  factory CoachingCenterBatch.fromJson(Map<String, dynamic> json) {
    return CoachingCenterBatch(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      course: json['course'] ?? '',
      timing: json['timing'] ?? '',
      maxCapacity: json['max_capacity'] ?? 0,
      currentStudents: json['current_students'] ?? 0,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      instructor: json['instructor'] ?? '',
      fees: (json['fees'] ?? 0.0).toDouble(),
      mode: json['mode'] ?? 'Offline',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'course': course,
      'timing': timing,
      'max_capacity': maxCapacity,
      'current_students': currentStudents,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'instructor': instructor,
      'fees': fees,
      'mode': mode,
    };
  }
}

class CoachingCenterFaculty {
  final String id;
  final String name;
  final String designation;
  final String qualification;
  final int experienceYears;
  final List<String> subjects;
  final String imageUrl;
  final String bio;
  final double rating;

  const CoachingCenterFaculty({
    required this.id,
    required this.name,
    required this.designation,
    required this.qualification,
    required this.experienceYears,
    required this.subjects,
    required this.imageUrl,
    required this.bio,
    this.rating = 0.0,
  });

  factory CoachingCenterFaculty.fromJson(Map<String, dynamic> json) {
    return CoachingCenterFaculty(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      designation: json['designation'] ?? '',
      qualification: json['qualification'] ?? '',
      experienceYears: json['experience_years'] ?? 0,
      subjects: List<String>.from(json['subjects'] ?? []),
      imageUrl: json['image_url'] ?? '',
      bio: json['bio'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'designation': designation,
      'qualification': qualification,
      'experience_years': experienceYears,
      'subjects': subjects,
      'image_url': imageUrl,
      'bio': bio,
      'rating': rating,
    };
  }
}
