// lib/screens/student/profile/widgets/analytics_summary.dart
import 'package:brainboosters_app/screens/student/profile/widgets/profile_model.dart';
import 'package:flutter/material.dart';

class AnalyticsSummary extends StatelessWidget {
  final ProfileData profileData;

  const AnalyticsSummary({
    super.key,
    required this.profileData,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: constraints.maxWidth <= 600 ? 1.1 : 1.2,
          children: [
            _buildSummaryCard(
              'Learning Time',
              '${(profileData.summary['total_time_spent_minutes'] ?? 0) ~/ 60}h ${(profileData.summary['total_time_spent_minutes'] ?? 0) % 60}m',
              Icons.access_time,
              Colors.blue,
            ),
            _buildSummaryCard(
              'Lessons Completed',
              '${profileData.summary['total_lessons_completed'] ?? 0}',
              Icons.check_circle,
              Colors.green,
            ),
            _buildSummaryCard(
              'Average Score',
              '${(profileData.summary['average_quiz_score'] ?? 0).toStringAsFixed(1)}%',
              Icons.grade,
              Colors.orange,
            ),
            _buildSummaryCard(
              'Courses Enrolled',
              '${profileData.summary['total_courses_enrolled'] ?? 0}',
              Icons.school,
              Colors.purple,
            ),
          ],
        );
      },
    );
  }

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth > 1200) return 4;
    if (screenWidth > 900) return 3;
    if (screenWidth > 600) return 2;
    return 2; // 2x2 grid on mobile
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
