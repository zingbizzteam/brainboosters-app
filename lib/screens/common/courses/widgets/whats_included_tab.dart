import 'package:flutter/material.dart';
import '../models/course_model.dart';

class WhatsIncludedTab extends StatelessWidget {
  final WhatsIncluded whatsIncluded;
  const WhatsIncludedTab({super.key, required this.whatsIncluded});

  @override
  Widget build(BuildContext context) {
    final items = [
      if (whatsIncluded.certificate) _buildItem(Icons.card_membership, "Certificate of Completion"),
      if (whatsIncluded.quizzes) _buildItem(Icons.quiz, "Quizzes"),
      if (whatsIncluded.assignments) _buildItem(Icons.assignment, "Assignments"),
      if (whatsIncluded.downloadableResources) _buildItem(Icons.download, "Downloadable Resources"),
      if (whatsIncluded.lifetimeAccess) _buildItem(Icons.lock_open, "Lifetime Access"),
      if (whatsIncluded.accessOnMobile) _buildItem(Icons.phone_android, "Access on Mobile"),
      if (whatsIncluded.instructorQnA) _buildItem(Icons.question_answer, "Instructor Q&A"),
      if (whatsIncluded.communityAccess) _buildItem(Icons.people, "Community Access"),
    ];
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items,
    );
  }

  Widget _buildItem(IconData icon, String text) => ListTile(
    leading: Icon(icon, color: Colors.blue),
    title: Text(text),
  );
}
