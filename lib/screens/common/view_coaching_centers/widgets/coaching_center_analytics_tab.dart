// screens/common/coaching_centers/widgets/coaching_center_analytics_tab.dart
import 'package:flutter/material.dart';
import '../models/coaching_center_model.dart';

class CoachingCenterAnalyticsTab extends StatelessWidget {
  final CoachingCenter center;
  final bool isMobile;

  const CoachingCenterAnalyticsTab({
    super.key,
    required this.center,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Center Analytics',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Key Metrics
          _buildAnalyticsCard(
            'Key Metrics',
            [
              _buildMetricRow('Total Enquiries', '${center.analytics.totalEnquiries}'),
              _buildMetricRow('Active Students', '${center.analytics.activeStudents}'),
              _buildMetricRow('Average Attendance', '${center.analytics.averageAttendance.toStringAsFixed(1)}%'),
              _buildMetricRow('Student Satisfaction', '${center.analytics.studentSatisfactionScore.toStringAsFixed(1)}/5.0'),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Performance Metrics
          _buildAnalyticsCard(
            'Performance',
            [
              _buildMetricRow('Successful Placements', '${center.analytics.successfulPlacements}'),
              _buildMetricRow('Website Visits', '${center.analytics.websiteVisits}'),
              _buildMetricRow('Brochure Downloads', '${center.analytics.brochureDownloads}'),
              _buildMetricRow('This Month Admissions', '${center.analytics.admissionsThisMonth}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, List<Widget> metrics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...metrics,
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
