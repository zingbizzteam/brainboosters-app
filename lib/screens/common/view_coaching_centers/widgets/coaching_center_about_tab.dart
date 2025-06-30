// screens/common/coaching_centers/widgets/coaching_center_about_tab.dart
import 'package:flutter/material.dart';
import '../models/coaching_center_model.dart';

class CoachingCenterAboutTab extends StatelessWidget {
  final CoachingCenter center;
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
            'About ${center.name}',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            center.description,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),

          // Specializations
          _buildSpecializationsSection(),
          const SizedBox(height: 20),

          // Facilities
          _buildFacilitiesSection(),
          const SizedBox(height: 20),

          // Class Modes
          _buildClassModesSection(),
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

  Widget _buildSpecializationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Specializations:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: center.specializations.map((specialization) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                specialization,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFacilitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Facilities & Features:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...center.allFacilities.map((facility) => _buildBulletPoint(facility)),
      ],
    );
  }

  Widget _buildClassModesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Class Modes:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          center.classModesText,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    if (isMobile) {
      return Column(
        children: [
          _buildInfoCard('Established', center.establishedYear),
          const SizedBox(height: 16),
          _buildInfoCard('Experience', center.experienceText),
          const SizedBox(height: 16),
          _buildInfoCard('Faculty', center.facultyCountText),
          const SizedBox(height: 16),
          _buildInfoCard('Success Rate', center.successRateText),
          const SizedBox(height: 16),
          _buildInfoCard('Starting Fees', center.formattedFees),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildInfoCard('Established', center.establishedYear),
                const SizedBox(height: 16),
                _buildInfoCard('Faculty', center.facultyCountText),
                const SizedBox(height: 16),
                _buildInfoCard('Starting Fees', center.formattedFees),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              children: [
                _buildInfoCard('Experience', center.experienceText),
                const SizedBox(height: 16),
                _buildInfoCard('Success Rate', center.successRateText),
                const SizedBox(height: 16),
                _buildInfoCard('Admission Status', center.admissionStatus),
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
          _buildContactRow(Icons.location_on, center.address),
          const SizedBox(height: 12),
          _buildContactRow(Icons.phone, center.contactPhone),
          const SizedBox(height: 12),
          _buildContactRow(Icons.email, center.contactEmail),
          if (center.website.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildContactRow(Icons.web, center.website),
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

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
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
}
