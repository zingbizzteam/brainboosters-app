// screens/coaching_center/analytics/widgets/performance_metrics.dart
import 'package:flutter/material.dart';

class PerformanceMetrics extends StatelessWidget {
  final Map<String, dynamic> metrics;

  const PerformanceMetrics({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.speed, color: Color(0xFF00B894)),
                SizedBox(width: 8),
                Text(
                  'Performance Metrics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricRow('Course Completion Rate', '78%', 0.78),
            const SizedBox(height: 12),
            _buildMetricRow('Student Satisfaction', '4.2/5', 0.84),
            const SizedBox(height: 12),
            _buildMetricRow('Faculty Utilization', '85%', 0.85),
            const SizedBox(height: 12),
            _buildMetricRow('Revenue Growth', '+15%', 0.65),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String title, String value, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00B894),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation(Color(0xFF00B894)),
        ),
      ],
    );
  }
}
