import 'package:flutter/material.dart';

class CoachingCenterAboutTab extends StatelessWidget {
  final Map<String, dynamic> center;
  final bool isMobile;

  const CoachingCenterAboutTab({
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
            'About ${_getCenterName()}',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getDescription(),
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),

          // Info Cards
          _buildInfoCards(),
          const SizedBox(height: 32),

          // Contact Information
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    if (isMobile) {
      return Column(
        children: [
          _buildInfoCard('Center Code', _getCenterCode()),
          const SizedBox(height: 16),
          _buildInfoCard('Total Courses', '${_getTotalCourses()}'),
          const SizedBox(height: 16),
          _buildInfoCard('Total Students', '${_getTotalStudents()}+'),
          const SizedBox(height: 16),
          _buildInfoCard('Subscription Plan', _getSubscriptionPlan()),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildInfoCard('Center Code', _getCenterCode()),
                const SizedBox(height: 16),
                _buildInfoCard('Total Students', '${_getTotalStudents()}+'),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              children: [
                _buildInfoCard('Total Courses', '${_getTotalCourses()}'),
                const SizedBox(height: 16),
                _buildInfoCard('Subscription Plan', _getSubscriptionPlan()),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildContactSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactRow(Icons.location_on, _getFullAddress()),
          const SizedBox(height: 12),
          _buildContactRow(Icons.phone, _getContactPhone()),
          const SizedBox(height: 12),
          _buildContactRow(Icons.email, _getContactEmail()),
          if (_getWebsiteUrl().isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildContactRow(Icons.web, _getWebsiteUrl()),
          ],
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getCenterName() {
    return center['center_name']?.toString() ?? 'Unknown Center';
  }

  String _getDescription() {
    return center['description']?.toString() ?? 'No description available';
  }

  String _getCenterCode() {
    return center['center_code']?.toString() ?? 'N/A';
  }

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

  String _getContactPhone() {
    return center['contact_phone']?.toString() ?? 'Not provided';
  }

  String _getContactEmail() {
    return center['contact_email']?.toString() ?? 'Not provided';
  }

  String _getWebsiteUrl() {
    return center['website_url']?.toString() ?? '';
  }

  String _getFullAddress() {
    final address = center['address'];
    if (address is Map) {
      final parts = <String>[];
      
      if (address['street'] != null) parts.add(address['street'].toString());
      if (address['city'] != null) parts.add(address['city'].toString());
      if (address['state'] != null) parts.add(address['state'].toString());
      if (address['zip'] != null) parts.add(address['zip'].toString());
      if (address['country'] != null) parts.add(address['country'].toString());
      
      return parts.isNotEmpty ? parts.join(', ') : 'Address not provided';
    }
    return 'Address not provided';
  }
}
