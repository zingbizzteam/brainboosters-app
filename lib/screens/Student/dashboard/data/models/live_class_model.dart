class LiveClass {
  final String id;
  final String slug;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime startTime;
  final DateTime endTime;
  final String academy;
  final List<String> teachers;
  final String category;
  final String subject;
  final int duration; // in minutes
  final bool isLive;
  final bool isRecorded;
  final int maxParticipants;
  final int currentParticipants;
  final double price;
  final String difficulty; // Beginner, Intermediate, Advanced
  final List<String> tags;
  final String meetingLink;
  final String status; // upcoming, live, completed, cancelled

  const LiveClass({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.startTime,
    required this.endTime,
    required this.academy,
    required this.teachers,
    required this.category,
    required this.subject,
    required this.duration,
    required this.isLive,
    required this.isRecorded,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.price,
    required this.difficulty,
    required this.tags,
    required this.meetingLink,
    required this.status,
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
}