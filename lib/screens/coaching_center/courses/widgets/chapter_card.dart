// screens/coaching_center/courses/widgets/chapter_card.dart
import 'package:flutter/material.dart';

class ChapterCard extends StatelessWidget {
  final Map<String, dynamic> chapter;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onManageLessons;

  const ChapterCard({
    super.key,
    required this.chapter,
    required this.onEdit,
    required this.onDelete,
    required this.onManageLessons,
  });

  @override
  Widget build(BuildContext context) {
    final lessons = chapter['lessons'] as List<dynamic>? ?? [];
    final totalDuration = lessons.fold<int>(
      0,
      (sum, lesson) => sum + ((lesson['duration'] ?? 0) as int),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00B894).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${chapter['order_index'] + 1}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF00B894),
            ),
          ),
        ),
        title: Text(
          chapter['title'] ?? 'Untitled Chapter',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${lessons.length} lessons • ${totalDuration} minutes',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: PopupMenuButton(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'lessons':
                onManageLessons();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Color(0xFF00B894)),
                  SizedBox(width: 8),
                  Text('Edit Chapter'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'lessons',
              child: Row(
                children: [
                  Icon(Icons.video_library, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Manage Lessons'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete Chapter'),
                ],
              ),
            ),
          ],
        ),
        children: lessons.map<Widget>((lesson) => _buildLessonTile(lesson)).toList(),
      ),
    );
  }

  Widget _buildLessonTile(Map<String, dynamic> lesson) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: lesson['video_url'] != null ? Colors.green : Colors.grey,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          lesson['video_url'] != null ? Icons.play_arrow : Icons.video_library_outlined,
          color: Colors.white,
          size: 16,
        ),
      ),
      title: Text(lesson['title'] ?? 'Untitled Lesson'),
      subtitle: Text('${lesson['duration'] ?? 0} minutes'),
      trailing: lesson['is_preview'] == true
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PREVIEW',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            )
          : null,
    );
  }
}
