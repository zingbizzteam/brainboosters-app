// models/coaching_center_model.dart
class CoachingCenter {
  final String id;
  final String name;
  final double rating;
  final int reviews;
  final String description;
  final String location;
  final int coursesOffered;
  final int studentsEnrolled;
  final String imageUrl;
  final List<String> specializations;
  final int experienceYears;
  final bool isVerified;
  final DateTime establishedDate;
  final String contactEmail;
  final String contactPhone;
  final List<String> facilities;
  final double fees;
  final String address;

  CoachingCenter({
    required this.id,
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
  });

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
}
