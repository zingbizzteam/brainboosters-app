class Lesson {
  final String id;
  final String title;
  final String videoUrl;
  final String content;
  final int duration; // in minutes
  final bool isPreview;
  final bool isCompleted;
  final DateTime createdAt;

  const Lesson({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.content,
    required this.duration,
    this.isPreview = false,
    this.isCompleted = false,
    required this.createdAt,
  });
}
