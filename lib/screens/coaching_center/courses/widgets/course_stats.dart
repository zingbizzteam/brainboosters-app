// screens/coaching_center/courses/widgets/course_stats.dart
import 'package:flutter/material.dart';

class CourseStats extends StatelessWidget {
  final Map<String, dynamic> stats;

  const CourseStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Total Courses',
              stats['total_courses']?.toString() ?? '0',
              Icons.book,
              const Color(0xFF00B894),
            ),
            _buildStatItem(
              'Published',
              stats['published_courses']?.toString() ?? '0',
              Icons.visibility,
              Colors.green,
            ),
            _buildStatItem(
              'Draft',
              stats['draft_courses']?.toString() ?? '0',
              Icons.edit,
              Colors.orange,
            ),
            _buildStatItem(
              'Total Revenue',
              '₹${stats['total_revenue']?.toString() ?? '0'}',
              Icons.currency_rupee,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
