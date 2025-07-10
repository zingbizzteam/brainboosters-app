import 'package:flutter/material.dart';

class CoachingCenterHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> coachingCenter;
  final bool isMobile;
  final bool showTeachersCount; // NEW: Add this parameter

  const CoachingCenterHeaderWidget({
    super.key,
    required this.coachingCenter,
    required this.isMobile,
    this.showTeachersCount = false, // NEW: Optional with default false
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Image
        Container(
          width: isMobile ? 80 : 120,
          height: isMobile ? 80 : 120,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(child: _buildLogo()),
        ),
        SizedBox(width: isMobile ? 16 : 24),

        // Title and Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name and Verification
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _getCenterName(),
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

              // Description
              Text(
                _getDescription(),
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.grey[600],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Stats Row
              if (isMobile) _buildMobileStats() else _buildDesktopStats(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    final logoUrl = coachingCenter['logo_url']?.toString();

    if (logoUrl != null && logoUrl.isNotEmpty) {
      return Image.network(
        logoUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderLogo(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholderLogo();
        },
      );
    }

    return _buildPlaceholderLogo();
  }

  Widget _buildPlaceholderLogo() {
    return Container(
      color: Colors.grey[100],
      child: Icon(
        Icons.school,
        size: isMobile ? 40 : 60,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildMobileStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First row
        Row(
          children: [
            const Icon(Icons.school, color: Colors.blue, size: 18),
            const SizedBox(width: 4),
            Text(
              '${_getTotalCourses()} courses',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${_getTotalStudents()}+ students',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // NEW: Conditionally show teachers count
        if (showTeachersCount) ...[
          Row(
            children: [
              const Icon(Icons.person, color: Colors.green, size: 18),
              const SizedBox(width: 4),
              Text(
                '${_getTotalTeachers()} teachers',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],

        // Location row
        Text(
          _getLocation(),
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDesktopStats() {
    final statsWidgets = <Widget>[
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.school, color: Colors.blue, size: 20),
          const SizedBox(width: 4),
          Text(
            '${_getTotalCourses()} courses',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      Container(
        width: 4,
        height: 4,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
      Text(
        '${_getTotalStudents()}+ students',
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
      ),
    ];

    // NEW: Conditionally add teachers count
    if (showTeachersCount) {
      statsWidgets.addAll([
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person, color: Colors.green, size: 20),
            const SizedBox(width: 4),
            Text(
              '${_getTotalTeachers()} teachers',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ]);
    }

    statsWidgets.addAll([
      Container(
        width: 4,
        height: 4,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
      Text(
        _getLocation(),
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
      ),
    ]);

    return Wrap(spacing: 8, runSpacing: 4, children: statsWidgets);
  }

  // Helper methods
  String _getCenterName() {
    return coachingCenter['center_name']?.toString() ?? 'Unknown Center';
  }

  String _getDescription() {
    return coachingCenter['description']?.toString() ??
        'No description available';
  }

  int _getTotalCourses() {
    return coachingCenter['total_courses'] ?? 0;
  }

  int _getTotalStudents() {
    return coachingCenter['total_students'] ?? 0;
  }

  // NEW: Helper method for teachers count
  int _getTotalTeachers() {
    return coachingCenter['total_teachers'] ?? 0;
  }

  String _getLocation() {
    final address = coachingCenter['address'];
    if (address is Map) {
      final city = address['city']?.toString() ?? '';
      final state = address['state']?.toString() ?? '';
      if (city.isNotEmpty && state.isNotEmpty) {
        return '$city, $state';
      } else if (city.isNotEmpty) {
        return city;
      } else if (state.isNotEmpty) {
        return state;
      }
    }
    return 'Location not specified';
  }

  bool _isVerified() {
    return coachingCenter['approval_status']?.toString() == 'approved';
  }
}
