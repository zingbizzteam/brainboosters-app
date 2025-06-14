import 'package:flutter/material.dart';

class EnrolledCourseList extends StatelessWidget {
  const EnrolledCourseList({super.key});
  @override
  Widget build(BuildContext context) {
    final courses = [
      {
        "title": "The Complete Python Course: From Zero to Hero in Python",
        "academy": "Leader Academy",
      },
      {
        "title": "Generative AI: Prompt Engineering Basics",
        "academy": "Leader Academy",
      },
    ];

    return Column(
      children: courses.map((c) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        c['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "By ${c['academy']}",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 4,
                      width: double.infinity,
                      color: const Color(0xFF4AA0E6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
