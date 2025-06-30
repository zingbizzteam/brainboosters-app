// screens/coaching_center/analytics/widgets/stats_grid.dart
import 'package:flutter/material.dart';

class StatsGrid extends StatelessWidget {
  final Map<String, dynamic> analytics;

  const StatsGrid({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          'Total Students',
          analytics['total_students']?.toString() ?? '0',
          Icons.school,
          const Color(0xFF00B894),
          '+12%',
        ),
        _buildStatCard(
          'Total Faculty',
          analytics['total_faculties']?.toString() ?? '0',
          Icons.people,
          Colors.blue,
          '+5%',
        ),
        _buildStatCard(
          'Total Courses',
          analytics['total_courses_created']?.toString() ?? '0',
          Icons.book,
          Colors.orange,
          '+8%',
        ),
        _buildStatCard(
          'Rating',
          analytics['rating']?.toStringAsFixed(1) ?? 'N/A',
          Icons.star,
          Colors.amber,
          '4.5/5',
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String trend) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                Text(
                  trend,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
