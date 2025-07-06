import 'package:flutter/material.dart';

class TeacherHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> teacher;
  final Map<String, dynamic>? coachingCenter; // NEW: Add this parameter
  final bool isMobile;

  const TeacherHeaderWidget({
    super.key,
    required this.teacher,
    this.coachingCenter, // NEW: Optional coaching center context
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Image
        Container(
          width: isMobile ? 100 : 140,
          height: isMobile ? 100 : 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: _buildAvatar(),
          ),
        ),
        SizedBox(width: isMobile ? 16 : 24),

        // Teacher Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name and Verification
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _getTeacherName(),
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (_isVerified())
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Verified',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Coaching Center - NEW: Show coaching center if provided
              Text(
                _getCoachingCenterName(),
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Stats Row
              if (isMobile)
                _buildMobileStats()
              else
                _buildDesktopStats(),

              const SizedBox(height: 16),

              // Specializations
              if (_getSpecializations().isNotEmpty) ...[
                Text(
                  'Specializations:',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _getSpecializations().take(5).map((spec) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Text(
                        spec,
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    final avatarUrl = teacher['user_profiles']?['avatar_url']?.toString();
    
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderAvatar(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholderAvatar();
        },
      );
    }
    
    return _buildPlaceholderAvatar();
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.person,
        size: isMobile ? 50 : 70,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildMobileStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.work_outline, color: Colors.grey[600], size: 16),
            const SizedBox(width: 4),
            Text(
              '${_getExperienceYears()} years experience',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (_getRating() > 0) ...[
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '${_getRating().toStringAsFixed(1)} (${_getTotalReviews()} reviews)',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopStats() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.work_outline, color: Colors.grey[600], size: 20),
            const SizedBox(width: 6),
            Text(
              '${_getExperienceYears()} years experience',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        if (_getRating() > 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 6),
              Text(
                '${_getRating().toStringAsFixed(1)} (${_getTotalReviews()} reviews)',
                style: const TextStyle(fontSize: 16),
              ),
            ],
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

  String _getCoachingCenterName() {
    // NEW: Use provided coaching center or fall back to teacher's coaching center
    if (coachingCenter != null) {
      return coachingCenter!['center_name']?.toString() ?? 'Unknown Center';
    }
    
    final teacherCoachingCenter = teacher['coaching_centers'];
    return teacherCoachingCenter?['center_name']?.toString() ?? 'Independent Teacher';
  }

  int _getExperienceYears() {
    return teacher['experience_years'] ?? 0;
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

  List<String> _getSpecializations() {
    final specializations = teacher['specializations'];
    if (specializations is List) {
      return specializations.map((e) => e.toString()).toList();
    }
    return [];
  }
}
