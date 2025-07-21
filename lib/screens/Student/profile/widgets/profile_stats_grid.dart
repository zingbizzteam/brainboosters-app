import 'package:flutter/material.dart';

class ProfileStatsGrid extends StatelessWidget {
  final Map<String, dynamic> analyticsData;
  final Map<String, dynamic> studentData;

  const ProfileStatsGrid({
    super.key,
    required this.analyticsData,
    required this.studentData,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          'Total Courses',
          '${analyticsData['total_courses']}',
          Icons.book,
          const Color(0xFF3498DB),
        ),
        _buildStatCard(
          'Completed',
          '${analyticsData['completed_courses']}',
          Icons.check_circle,
          const Color(0xFF27AE60),
        ),
        _buildStatCard(
          'Hours Learned',
          '${(analyticsData['total_hours'] as num).toStringAsFixed(1)}h',
          Icons.access_time,
          const Color(0xFFE67E22),
        ),
        _buildStatCard(
          'Total Points',
          '${analyticsData['total_points']}',
          Icons.star,
          const Color(0xFFD4845C),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
