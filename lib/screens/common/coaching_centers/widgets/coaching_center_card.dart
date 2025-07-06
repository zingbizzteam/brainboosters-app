import 'package:flutter/material.dart';

class CoachingCenterCard extends StatelessWidget {
  final Map<String, dynamic> coachingCenter;
  final VoidCallback onTap;

  const CoachingCenterCard({
    super.key,
    required this.coachingCenter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isSmallMobile = screenWidth < 360;

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
            _buildHeader(isSmallMobile, isMobile),
            _buildContent(isSmallMobile, isMobile),
            _buildFooter(isSmallMobile, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallMobile, bool isMobile) {
    return Container(
      height: isSmallMobile ? 100 : (isMobile ? 110 : 120),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[400]!, Colors.blue[600]!],
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
                  colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                ),
              ),
            ),
          ),
          // Logo
          Positioned(
            top: isSmallMobile ? 12 : 16,
            left: isSmallMobile ? 12 : 16,
            child: Container(
              width: isSmallMobile ? 50 : (isMobile ? 55 : 60),
              height: isSmallMobile ? 50 : (isMobile ? 55 : 60),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildLogo(isSmallMobile, isMobile),
              ),
            ),
          ),
          // Verified badge
          if (_isVerified())
            Positioned(
              top: isSmallMobile ? 12 : 16,
              right: isSmallMobile ? 8 : 16,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallMobile ? 6 : 8,
                  vertical: isSmallMobile ? 3 : 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: isSmallMobile ? 10 : 12,
                    ),
                    SizedBox(width: isSmallMobile ? 2 : 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallMobile ? 8 : 10,
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

  Widget _buildLogo(bool isSmallMobile, bool isMobile) {
    final logoUrl = coachingCenter['logo_url']?.toString();

    if (logoUrl != null && logoUrl.isNotEmpty) {
      return Image.network(
        logoUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholderLogo(isSmallMobile, isMobile),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholderLogo(isSmallMobile, isMobile);
        },
      );
    }

    return _buildPlaceholderLogo(isSmallMobile, isMobile);
  }

  Widget _buildPlaceholderLogo(bool isSmallMobile, bool isMobile) {
    return Container(
      color: Colors.grey[100],
      child: Icon(
        Icons.school,
        size: isSmallMobile ? 25 : (isMobile ? 28 : 30),
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildContent(bool isSmallMobile, bool isMobile) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(isSmallMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Center name
            Text(
              _getCenterName(),
              style: TextStyle(
                fontSize: isSmallMobile ? 14 : (isMobile ? 16 : 18),
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isSmallMobile ? 6 : 8),

            // Description
            Flexible(
              child: Text(
                _getDescription(),
                style: TextStyle(
                  fontSize: isSmallMobile ? 11 : (isMobile ? 13 : 14),
                  color: Colors.grey[600],
                  height: 1.3,
                ),
                maxLines: isSmallMobile ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: isSmallMobile ? 8 : 12),

            // Stats - Make them wrap on small screens
            _buildStatsSection(isSmallMobile, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(bool isSmallMobile, bool isMobile) {
    if (isSmallMobile) {
      // Stack stats vertically on very small screens
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatChip(
            Icons.book_outlined,
            '${_getTotalCourses()} Courses',
            Colors.blue,
            isSmallMobile,
            isMobile,
          ),
          const SizedBox(height: 4),
          _buildStatChip(
            Icons.people_outline,
            '${_getTotalStudents()}+ Students',
            Colors.green,
            isSmallMobile,
            isMobile,
          ),
        ],
      );
    } else {
      // Side by side on larger screens
      return Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          _buildStatChip(
            Icons.book_outlined,
            '${_getTotalCourses()} Courses',
            Colors.blue,
            isSmallMobile,
            isMobile,
          ),
          _buildStatChip(
            Icons.people_outline,
            '${_getTotalStudents()}+ Students',
            Colors.green,
            isSmallMobile,
            isMobile,
          ),
        ],
      );
    }
  }

  Widget _buildFooter(bool isSmallMobile, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isSmallMobile ? 12 : 16),
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
          Expanded(
            flex: isSmallMobile ? 2 : 3,
            child: Text(
              _getLocation(),
              style: TextStyle(
                fontSize: isSmallMobile ? 10 : (isMobile ? 12 : 13),
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: isSmallMobile ? 8 : 12),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallMobile ? 8 : 12,
              vertical: isSmallMobile ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              isSmallMobile ? 'View' : 'View Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallMobile ? 9 : (isMobile ? 11 : 12),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    IconData icon,
    String text,
    Color color,
    bool isSmallMobile,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallMobile ? 6 : 8,
        vertical: isSmallMobile ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmallMobile ? 10 : 12, color: color),
          SizedBox(width: isSmallMobile ? 3 : 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isSmallMobile ? 8 : 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
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
