import 'package:flutter/material.dart';

class CoachingCenterAnalyticsTab extends StatelessWidget {
  final Map<String, dynamic> center;
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
              _buildMetricRow('Total Courses', '${_getTotalCourses()}'),
              _buildMetricRow('Total Students', '${_getTotalStudents()}+'),
              _buildMetricRow('Subscription Plan', _getSubscriptionPlan()),
              _buildMetricRow('Max Faculty Limit', '${_getMaxFacultyLimit()}'),
            ],
          ),
          const SizedBox(height: 20),

          // Center Information
          _buildAnalyticsCard(
            'Center Information',
            [
              _buildMetricRow('Center Code', _getCenterCode()),
              _buildMetricRow('Registration Number', _getRegistrationNumber()),
              _buildMetricRow('Approval Status', _getApprovalStatus()),
              _buildMetricRow('Max Courses Limit', '${_getMaxCoursesLimit()}'),
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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

  // Helper methods
  int _getTotalCourses() {
    return center['total_courses'] ?? 0;
  }

  int _getTotalStudents() {
    return center['total_students'] ?? 0;
  }

  String _getSubscriptionPlan() {
    final plan = center['subscription_plan']?.toString() ?? 'basic';
    return plan.toUpperCase();
  }

  int _getMaxFacultyLimit() {
    return center['max_faculty_limit'] ?? 0;
  }

  String _getCenterCode() {
    return center['center_code']?.toString() ?? 'N/A';
  }

  String _getRegistrationNumber() {
    return center['registration_number']?.toString() ?? 'N/A';
  }

  String _getApprovalStatus() {
    final status = center['approval_status']?.toString() ?? 'pending';
    return status.toUpperCase();
  }

  int _getMaxCoursesLimit() {
    return center['max_courses_limit'] ?? 0;
  }
}
