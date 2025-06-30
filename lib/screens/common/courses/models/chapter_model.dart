import 'lesson_model.dart';

class Chapter {
  final String id;
  final String title;
  final String description;
  final int order;
  final List<Lesson> lessons;

  const Chapter({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.lessons,
  });
}
