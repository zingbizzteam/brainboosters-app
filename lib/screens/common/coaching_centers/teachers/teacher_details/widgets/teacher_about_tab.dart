import 'package:flutter/material.dart';

class TeacherAboutTab extends StatelessWidget {
  final Map<String, dynamic> teacher;
  final bool isMobile;

  const TeacherAboutTab({
    super.key,
    required this.teacher,
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
            'About ${_getTeacherName()}',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Bio
          Text(
            _getBio(),
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),

          // Qualifications
          if (_getQualifications().isNotEmpty) ...[
            Text(
              'Qualifications',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._getQualifications().map((qual) => _buildQualificationCard(qual)),
            const SizedBox(height: 32),
          ],

          // Teaching Capabilities
          _buildCapabilitiesSection(),
        ],
      ),
    );
  }

  Widget _buildQualificationCard(Map<String, dynamic> qualification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            qualification['degree']?.toString() ?? 'Unknown Degree',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            qualification['institution']?.toString() ?? 'Unknown Institution',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          if (qualification['year'] != null) ...[
            const SizedBox(height: 4),
            Text(
              'Year: ${qualification['year']}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCapabilitiesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Teaching Capabilities',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildCapabilityRow(
            Icons.school,
            'Create Courses',
            _canCreateCourses(),
          ),
          const SizedBox(height: 12),
          _buildCapabilityRow(
            Icons.live_tv,
            'Conduct Live Classes',
            _canConductLiveClasses(),
          ),
          const SizedBox(height: 12),
          _buildCapabilityRow(
            Icons.verified,
            'Verified Teacher',
            _isVerified(),
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilityRow(IconData icon, String title, bool enabled) {
    return Row(
      children: [
        Icon(
          icon,
          color: enabled ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: enabled ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
        Icon(
          enabled ? Icons.check_circle : Icons.cancel,
          color: enabled ? Colors.green : Colors.grey,
          size: 16,
        ),
      ],
    );
  }

  // Helper methods
  String _getTeacherName() {
    final userProfile = teacher['user_profiles'];
    if (userProfile == null) return 'Unknown Teacher';
    
    final firstName = userProfile['first_name']?.toString() ?? '';
    final lastName = userProfile['last_name']?.toString() ?? '';
    return '$firstName $lastName'.trim();
  }

  String _getBio() {
    return teacher['bio']?.toString() ?? 'No bio available';
  }

  List<Map<String, dynamic>> _getQualifications() {
    final qualifications = teacher['qualifications'];
    if (qualifications is List) {
      return qualifications.cast<Map<String, dynamic>>();
    }
    return [];
  }

  bool _canCreateCourses() {
    return teacher['can_create_courses'] == true;
  }

  bool _canConductLiveClasses() {
    return teacher['can_conduct_live_classes'] == true;
  }

  bool _isVerified() {
    return teacher['is_verified'] == true;
  }
}
