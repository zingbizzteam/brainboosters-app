import 'package:flutter/material.dart';

class CourseDetailSection extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isMobile;

  const CourseDetailSection({
    super.key,
    required this.course,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course Details',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _buildDetailRow('Category', course['category']?.toString() ?? 'Not specified'),
              if (course['subcategory'] != null)
                _buildDetailRow('Subcategory', course['subcategory'].toString()),
              _buildDetailRow('Level', course['level']?.toString() ?? 'Not specified'),
              _buildDetailRow('Language', course['language']?.toString() ?? 'English'),
              if (course['duration_hours'] != null)
                _buildDetailRow('Duration', '${course['duration_hours']} hours'),
              if (course['total_lessons'] != null && course['total_lessons'] > 0)
                _buildDetailRow('Total Lessons', '${course['total_lessons']} lessons'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }
}
