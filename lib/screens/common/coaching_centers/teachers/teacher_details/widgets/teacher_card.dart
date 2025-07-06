import 'package:flutter/material.dart';

class TeacherCard extends StatelessWidget {
  final Map<String, dynamic> teacher;
  final VoidCallback onTap;

  const TeacherCard({
    super.key,
    required this.teacher,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isMobile),
            _buildContent(isMobile),
            _buildFooter(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      height: isMobile ? 80 : 100,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo[400]!,
            Colors.indigo[600]!,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Avatar
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              width: isMobile ? 48 : 60,
              height: isMobile ? 48 : 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildAvatar(isMobile),
              ),
            ),
          ),
          // Verification badge
          if (_isVerified())
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.verified, color: Colors.white, size: 10),
                    SizedBox(width: 3),
                    Text(
                      'Verified',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isMobile) {
    final avatarUrl = teacher['user_profiles']?['avatar_url']?.toString();
    
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderAvatar(isMobile),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholderAvatar(isMobile);
        },
      );
    }
    
    return _buildPlaceholderAvatar(isMobile);
  }

  Widget _buildPlaceholderAvatar(bool isMobile) {
    return Container(
      color: Colors.grey[100],
      child: Icon(
        Icons.person,
        size: isMobile ? 24 : 30,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher name
            Text(
              _getTeacherName(),
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            
            // Experience
            Row(
              children: [
                Icon(Icons.work_outline, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${_getExperienceYears()} years experience',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Specializations
            if (_getSpecializations().isNotEmpty) ...[
              Text(
                'Specializations:',
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: _getSpecializations().take(3).map((spec) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      spec,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
            
            // Rating
            if (_getRating() > 0) ...[
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    _getRating().toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${_getTotalReviews()} reviews)',
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Teaching capabilities
          Row(
            children: [
              if (_canCreateCourses())
                _buildCapabilityIcon(Icons.school, Colors.blue, 'Courses'),
              if (_canConductLiveClasses()) ...[
                if (_canCreateCourses()) const SizedBox(width: 8),
                _buildCapabilityIcon(Icons.live_tv, Colors.green, 'Live Classes'),
              ],
            ],
          ),
          
          // View profile button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'View Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 10 : 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilityIcon(IconData icon, Color color, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
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

  int _getExperienceYears() {
    return teacher['experience_years'] ?? 0;
  }

  List<String> _getSpecializations() {
    final specializations = teacher['specializations'];
    if (specializations is List) {
      return specializations.map((e) => e.toString()).toList();
    }
    return [];
  }

  double _getRating() {
    final rating = teacher['rating'];
    if (rating is num) return rating.toDouble();
    return 0.0;
  }

  int _getTotalReviews() {
    return teacher['total_reviews'] ?? 0;
  }

  bool _isVerified() {
    return teacher['is_verified'] == true;
  }

  bool _canCreateCourses() {
    return teacher['can_create_courses'] == true;
  }

  bool _canConductLiveClasses() {
    return teacher['can_conduct_live_classes'] == true;
  }
}
