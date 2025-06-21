import 'package:flutter/material.dart';
import '../models/chapter_model.dart';

class CourseContentTab extends StatelessWidget {
  final List<Chapter> chapters;

  const CourseContentTab({super.key, required this.chapters});

  @override
  Widget build(BuildContext context) {
    if (chapters.isEmpty) {
      return const Center(child: Text("No course content available."));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: chapters.length,
      itemBuilder: (context, i) {
        final chapter = chapters[i];
        return ExpansionTile(
          title: Text(chapter.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(chapter.description),
          children: chapter.lessons.map((lesson) {
            return ListTile(
              leading: Icon(lesson.isPreview ? Icons.visibility : Icons.lock),
              title: Text(lesson.title),
              subtitle: Text('${lesson.duration} min'),
              trailing: lesson.isCompleted
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
            );
          }).toList(),
        );
      },
    );
  }
}
