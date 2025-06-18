class LiveClass {
  final String id;
  final String slug;
  final String title;
  final String description;
  final String imageUrl;
  final String thumbnailUrl; // Added for better image handling
  final DateTime startTime;
  final DateTime endTime;
  final String academy;
  final List<String> teachers;
  final String instructor; // Primary instructor name for easy access
  final String category;
  final String subject;
  final int duration; // in minutes
  final bool isLive;
  final bool isRecorded;
  final bool isFree; // Added for pricing logic
  final int maxParticipants;
  final int currentParticipants;
  final double price;
  final String difficulty; // Beginner, Intermediate, Advanced
  final List<String> tags;
  final String meetingLink;
  final String status; // upcoming, live, completed, cancelled
  final DateTime createdAt; // Added for sorting
  final DateTime updatedAt; // Added for tracking updates
  final double rating; // Added for rating system
  final int totalRatings; // Added for rating count
  final List<String> prerequisites; // Added for course requirements
  final String language; // Added for language support
  final bool isRecordingAvailable; // Added to check if recording is available
  final String recordingUrl; // Added for recorded session access
  final Map<String, dynamic> metadata; // Added for additional flexible data

  const LiveClass({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.startTime,
    required this.endTime,
    required this.academy,
    required this.teachers,
    required this.instructor,
    required this.category,
    required this.subject,
    required this.duration,
    required this.isLive,
    required this.isRecorded,
    required this.isFree,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.price,
    required this.difficulty,
    required this.tags,
    required this.meetingLink,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.prerequisites = const [],
    this.language = 'English',
    this.isRecordingAvailable = false,
    this.recordingUrl = '',
    this.metadata = const {},
  });

  // Getters for computed properties
  String get formattedTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final classDate = DateTime(startTime.year, startTime.month, startTime.day);
    
    String timeStr = "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
    
    if (classDate == today) {
      return "Today, $timeStr";
    } else if (classDate == tomorrow) {
      return "Tomorrow, $timeStr";
    } else {
      return "${startTime.day}/${startTime.month}/${startTime.year}, $timeStr";
    }
  }

  String get formattedDuration {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    
    if (hours > 0) {
      return minutes > 0 ? "${hours}h ${minutes}m" : "${hours}h";
    } else {
      return "${minutes}m";
    }
  }

  String get formattedPrice {
    return isFree ? 'Free' : '₹${price.toStringAsFixed(0)}';
  }

  String get availabilityStatus {
    final now = DateTime.now();
    final spotsLeft = maxParticipants - currentParticipants;
    
    if (status == 'cancelled') return 'Cancelled';
    if (status == 'completed') return 'Completed';
    if (now.isAfter(endTime)) return 'Ended';
    if (now.isAfter(startTime) && now.isBefore(endTime)) return 'Live Now';
    if (spotsLeft <= 0) return 'Full';
    if (spotsLeft <= 5) return 'Almost Full';
    return 'Available';
  }

  bool get canJoin {
    final now = DateTime.now();
    return status == 'upcoming' && 
           now.isBefore(endTime) && 
           currentParticipants < maxParticipants;
  }

  bool get isStartingSoon {
    final now = DateTime.now();
    final timeDiff = startTime.difference(now).inMinutes;
    return timeDiff <= 15 && timeDiff > 0;
  }

  bool get hasStarted {
    return DateTime.now().isAfter(startTime);
  }

  bool get hasEnded {
    return DateTime.now().isAfter(endTime);
  }

  int get spotsRemaining {
    return maxParticipants - currentParticipants;
  }

  double get occupancyPercentage {
    return (currentParticipants / maxParticipants) * 100;
  }

  String get primaryTeacher {
    return teachers.isNotEmpty ? teachers.first : instructor;
  }

  // Factory constructor for creating from JSON
  factory LiveClass.fromJson(Map<String, dynamic> json) {
    return LiveClass(
      id: json['id'] ?? '',
      slug: json['slug'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? json['image_url'] ?? '',
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      academy: json['academy'] ?? '',
      teachers: List<String>.from(json['teachers'] ?? []),
      instructor: json['instructor'] ?? '',
      category: json['category'] ?? '',
      subject: json['subject'] ?? '',
      duration: json['duration'] ?? 0,
      isLive: json['is_live'] ?? false,
      isRecorded: json['is_recorded'] ?? false,
      isFree: json['is_free'] ?? false,
      maxParticipants: json['max_participants'] ?? 0,
      currentParticipants: json['current_participants'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      difficulty: json['difficulty'] ?? 'Beginner',
      tags: List<String>.from(json['tags'] ?? []),
      meetingLink: json['meeting_link'] ?? '',
      status: json['status'] ?? 'upcoming',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalRatings: json['total_ratings'] ?? 0,
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      language: json['language'] ?? 'English',
      isRecordingAvailable: json['is_recording_available'] ?? false,
      recordingUrl: json['recording_url'] ?? '',
      metadata: json['metadata'] ?? {},
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'thumbnail_url': thumbnailUrl,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'academy': academy,
      'teachers': teachers,
      'instructor': instructor,
      'category': category,
      'subject': subject,
      'duration': duration,
      'is_live': isLive,
      'is_recorded': isRecorded,
      'is_free': isFree,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'price': price,
      'difficulty': difficulty,
      'tags': tags,
      'meeting_link': meetingLink,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'rating': rating,
      'total_ratings': totalRatings,
      'prerequisites': prerequisites,
      'language': language,
      'is_recording_available': isRecordingAvailable,
      'recording_url': recordingUrl,
      'metadata': metadata,
    };
  }

  // Copy with method for immutable updates
  LiveClass copyWith({
    String? id,
    String? slug,
    String? title,
    String? description,
    String? imageUrl,
    String? thumbnailUrl,
    DateTime? startTime,
    DateTime? endTime,
    String? academy,
    List<String>? teachers,
    String? instructor,
    String? category,
    String? subject,
    int? duration,
    bool? isLive,
    bool? isRecorded,
    bool? isFree,
    int? maxParticipants,
    int? currentParticipants,
    double? price,
    String? difficulty,
    List<String>? tags,
    String? meetingLink,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    int? totalRatings,
    List<String>? prerequisites,
    String? language,
    bool? isRecordingAvailable,
    String? recordingUrl,
    Map<String, dynamic>? metadata,
  }) {
    return LiveClass(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      academy: academy ?? this.academy,
      teachers: teachers ?? this.teachers,
      instructor: instructor ?? this.instructor,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      duration: duration ?? this.duration,
      isLive: isLive ?? this.isLive,
      isRecorded: isRecorded ?? this.isRecorded,
      isFree: isFree ?? this.isFree,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      price: price ?? this.price,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      meetingLink: meetingLink ?? this.meetingLink,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      prerequisites: prerequisites ?? this.prerequisites,
      language: language ?? this.language,
      isRecordingAvailable: isRecordingAvailable ?? this.isRecordingAvailable,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LiveClass && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'LiveClass(id: $id, title: $title, startTime: $startTime, status: $status)';
  }
}
