class LiveClass {
  final String id;
  final String slug;
  final String title;
  final String description;
  final String imageUrl;
  final String thumbnailUrl;
  final DateTime startTime;
  final DateTime endTime;
  final String academy;
  final List<String> teachers;
  final String instructor;
  final String category;
  final String subject;
  final int duration;
  final bool isLive;
  final bool isRecorded;
  final bool isFree;
  final int maxParticipants;
  final int currentParticipants;
  final double price;
  final String difficulty;
  final List<String> tags;
  final String meetingLink;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double rating;
  final int totalRatings;
  final List<String> prerequisites;
  final String language;
  final bool isRecordingAvailable;
  final String recordingUrl;
  final Map<String, dynamic> metadata;

  // Analytics fields
  final int viewCount;
  final int chatMessageCount;
  final int reactionCount;
  final double averageEngagementScore;
  final Map<String, double> engagementScores; // userID -> score
  final int questionsAsked;
  final int resourceDownloads;

  // Comments
  final List<LiveClassComment> comments;

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
    // Analytics
    this.viewCount = 0,
    this.chatMessageCount = 0,
    this.reactionCount = 0,
    this.averageEngagementScore = 0.0,
    this.engagementScores = const {},
    this.questionsAsked = 0,
    this.resourceDownloads = 0,
    // Comments
    this.comments = const [],
  });

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

String get formattedPrice {
  return isFree ? 'Free' : '₹${price.toStringAsFixed(0)}';
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

double get engagementPercentage {
  return (averageEngagementScore * 100).clamp(0, 100);
}

String get engagementLevel {
  if (averageEngagementScore >= 0.8) return 'High';
  if (averageEngagementScore >= 0.5) return 'Medium';
  return 'Low';
}

 
  // New comment-related methods
  void addComment(LiveClassComment comment) {
    comments.add(comment);
  }

  List<LiveClassComment> get recentComments {
    return comments.take(5).toList();
  }

  // Factory constructor for JSON
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
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalRatings: json['total_ratings'] ?? 0,
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      language: json['language'] ?? 'English',
      isRecordingAvailable: json['is_recording_available'] ?? false,
      recordingUrl: json['recording_url'] ?? '',
      metadata: json['metadata'] ?? {},
      // Analytics
      viewCount: json['view_count'] ?? 0,
      chatMessageCount: json['chat_message_count'] ?? 0,
      reactionCount: json['reaction_count'] ?? 0,
      averageEngagementScore: (json['average_engagement_score'] ?? 0.0).toDouble(),
      engagementScores: Map<String, double>.from(json['engagement_scores'] ?? {}),
      questionsAsked: json['questions_asked'] ?? 0,
      resourceDownloads: json['resource_downloads'] ?? 0,
      // Comments
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => LiveClassComment.fromJson(e))
          .toList() ?? [],
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
      // Analytics
      'view_count': viewCount,
      'chat_message_count': chatMessageCount,
      'reaction_count': reactionCount,
      'average_engagement_score': averageEngagementScore,
      'engagement_scores': engagementScores,
      'questions_asked': questionsAsked,
      'resource_downloads': resourceDownloads,
      // Comments
      'comments': comments.map((e) => e.toJson()).toList(),
    };
  }

}

class LiveClassComment {
  final String id;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String text;
  final DateTime timestamp;
  final int likes;
  final List<LiveClassComment> replies;
  final Sentiment sentiment;

  const LiveClassComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.text,
    required this.timestamp,
    this.likes = 0,
    this.replies = const [],
    this.sentiment = Sentiment.neutral,
  });

  factory LiveClassComment.fromJson(Map<String, dynamic> json) {
    return LiveClassComment(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userAvatarUrl: json['user_avatar_url'] ?? '',
      text: json['text'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      likes: json['likes'] ?? 0,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => LiveClassComment.fromJson(e))
          .toList() ?? [],
      sentiment: Sentiment.values.firstWhere(
        (e) => e.name == json['sentiment'],
        orElse: () => Sentiment.neutral,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_avatar_url': userAvatarUrl,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'replies': replies.map((e) => e.toJson()).toList(),
      'sentiment': sentiment.name,
    };
  }
}

enum Sentiment {
  positive,
  negative,
  neutral,
  confused,
}
