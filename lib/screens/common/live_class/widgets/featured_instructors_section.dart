import 'package:brainboosters_app/screens/common/coaching_centers/teachers/teacher_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../ui/navigation/common_routes/common_routes.dart';

class FeaturedInstructorsSection extends StatefulWidget {
  final bool forceRefresh; // NEW: External refresh trigger
  final VoidCallback? onRefreshComplete; // NEW: Refresh completion callback

  const FeaturedInstructorsSection({
    super.key,
    this.forceRefresh = false,
    this.onRefreshComplete,
  });

  @override
  State<FeaturedInstructorsSection> createState() =>
      _FeaturedInstructorsSectionState();
}

class _FeaturedInstructorsSectionState
    extends State<FeaturedInstructorsSection> {
  List<Map<String, dynamic>> featuredTeachers = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadFeaturedTeachers();
    });
  }

  Future<void> _loadFeaturedTeachers() async {
    try {
      if (!isLoading) {
        setState(() {
          isLoading = true;
          error = null;
        });
      }

      final teachers = await TeacherRepository.getFeaturedTeachers(limit: 4);

      if (mounted) {
        setState(() {
          featuredTeachers = teachers;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Failed to load featured instructors: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    final isSmallMobile = screenWidth < 360;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
        vertical: 40,
      ),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Featured Instructors',
            style: TextStyle(
              fontSize: isSmallMobile ? 18 : (isMobile ? 20 : 24),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Learn from industry experts and experienced professionals',
            style: TextStyle(
              fontSize: isSmallMobile ? 13 : (isMobile ? 14 : 16),
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          if (isLoading)
            _buildLoadingState(isMobile, isTablet, isSmallMobile)
          else if (error != null)
            _buildErrorState()
          else if (featuredTeachers.isEmpty)
            _buildEmptyState()
          else
            _buildInstructorsGrid(isMobile, isTablet, isSmallMobile),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isMobile, bool isTablet, bool isSmallMobile) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(isMobile, isTablet),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: _getChildAspectRatio(isMobile, isSmallMobile),
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return _buildSkeletonCard(isMobile, isSmallMobile);
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              error!,
              style: TextStyle(color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFeaturedTeachers,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Text(
          'No featured instructors available at the moment.',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildInstructorsGrid(
    bool isMobile,
    bool isTablet,
    bool isSmallMobile,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(isMobile, isTablet),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: _getChildAspectRatio(isMobile, isSmallMobile),
      ),
      itemCount: featuredTeachers.length,
      itemBuilder: (context, index) {
        return _buildInstructorCard(
          featuredTeachers[index],
          isMobile,
          isSmallMobile,
        );
      },
    );
  }

  int _getCrossAxisCount(bool isMobile, bool isTablet) {
    if (isMobile) return 1;
    if (isTablet) return 2;
    return 4;
  }

  double _getChildAspectRatio(bool isMobile, bool isSmallMobile) {
    if (isMobile) {
      return isSmallMobile ? 2.5 : 3.0;
    }
    return 0.90;
  }

  Widget _buildSkeletonCard(bool isMobile, bool isSmallMobile) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.all(isSmallMobile ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isMobile
            ? _buildMobileSkeletonLayout(isSmallMobile)
            : _buildDesktopSkeletonLayout(),
      ),
    );
  }

  Widget _buildMobileSkeletonLayout(bool isSmallMobile) {
    final avatarSize = isSmallMobile ? 50.0 : 60.0;

    return Row(
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(avatarSize / 2),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: isSmallMobile ? 14 : 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: isSmallMobile ? 6 : 8),
              Container(
                height: isSmallMobile ? 12 : 14,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: isSmallMobile ? 6 : 8),
              Container(
                height: isSmallMobile ? 10 : 12,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopSkeletonLayout() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 16,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 14,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 12,
          width: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          width: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructorCard(
    Map<String, dynamic> teacher,
    bool isMobile,
    bool isSmallMobile,
  ) {
    return GestureDetector(
      onTap: () => _navigateToTeacher(teacher),
      child: Container(
        padding: EdgeInsets.all(isSmallMobile ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isMobile
            ? _buildMobileInstructorLayout(teacher, isSmallMobile)
            : _buildDesktopInstructorLayout(teacher),
      ),
    );
  }

  void _navigateToTeacher(Map<String, dynamic> teacher) {
    final teacherId = teacher['id']?.toString();
    final coachingCenterId = teacher['coaching_center_id']?.toString();

    if (teacherId != null && coachingCenterId != null) {
      context.push(
        CommonRoutes.getCoachingCenterTeacherDetailRoute(
          coachingCenterId,
          teacherId,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Teacher information not available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMobileInstructorLayout(
    Map<String, dynamic> teacher,
    bool isSmallMobile,
  ) {
    final avatarSize = isSmallMobile ? 45.0 : 55.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(avatarSize / 2),
            child: _buildTeacherAvatar(teacher, avatarSize),
          ),
          SizedBox(width: isSmallMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getTeacherName(teacher),
                  style: TextStyle(
                    fontSize: isSmallMobile ? 13 : 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isSmallMobile ? 2 : 3),
                Text(
                  _getTeacherExpertise(teacher),
                  style: TextStyle(
                    fontSize: isSmallMobile ? 11 : 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isSmallMobile ? 2 : 3),
                Text(
                  _getCoachingCenterName(teacher),
                  style: TextStyle(
                    fontSize: isSmallMobile ? 9 : 11,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isSmallMobile ? 4 : 6),
                Flexible(
                  child: _buildMobileBottomSection(teacher, isSmallMobile),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBottomSection(
    Map<String, dynamic> teacher,
    bool isSmallMobile,
  ) {
    return Wrap(
      spacing: 6,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              color: Colors.amber,
              size: isSmallMobile ? 12 : 14,
            ),
            const SizedBox(width: 2),
            Text(
              _getTeacherRating(teacher),
              style: TextStyle(
                fontSize: isSmallMobile ? 11 : 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (_isVerified(teacher) && !isSmallMobile)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Verified',
              style: TextStyle(
                color: Colors.white,
                fontSize: 7,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopInstructorLayout(Map<String, dynamic> teacher) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final baseSpacing = availableHeight < 200 ? 4.0 : 8.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: _buildTeacherAvatar(teacher, 80),
                ),
                if (_isVerified(teacher))
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: baseSpacing),
            Flexible(
              child: Text(
                _getTeacherName(teacher),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: baseSpacing * 0.5),
            Flexible(
              child: Text(
                _getTeacherExpertise(teacher),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: baseSpacing * 0.5),
            Flexible(
              child: Text(
                _getCoachingCenterName(teacher),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: baseSpacing * 0.5),
            Text(
              '${_getExperienceYears(teacher)}+ years exp',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _getTeacherRating(teacher),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_getTotalReviews(teacher)} reviews',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTeacherAvatar(Map<String, dynamic> teacher, double size) {
    final avatarUrl = teacher['user_profiles']?['avatar_url']?.toString();

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Image.network(
        avatarUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholderAvatar(size),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholderAvatar(size);
        },
      );
    }

    return _buildPlaceholderAvatar(size);
  }

  Widget _buildPlaceholderAvatar(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[300],
      child: Icon(Icons.person, size: size * 0.5, color: Colors.grey),
    );
  }

  // Helper methods for safe data extraction
  String _getTeacherName(Map<String, dynamic> teacher) {
    final userProfile = teacher['user_profiles'];
    if (userProfile == null) return 'Unknown Teacher';

    final firstName = userProfile['first_name']?.toString() ?? '';
    final lastName = userProfile['last_name']?.toString() ?? '';
    return '$firstName $lastName'.trim();
  }

  String _getTeacherExpertise(Map<String, dynamic> teacher) {
    final specializations = teacher['specializations'];
    if (specializations is List && specializations.isNotEmpty) {
      return specializations.first.toString();
    }
    return 'General Teaching';
  }

  String _getCoachingCenterName(Map<String, dynamic> teacher) {
    final coachingCenter = teacher['coaching_centers'];
    return coachingCenter?['center_name']?.toString() ?? 'Independent';
  }

  String _getTeacherRating(Map<String, dynamic> teacher) {
    final rating = teacher['rating'];
    if (rating is num) {
      return rating.toStringAsFixed(1);
    }
    return '0.0';
  }

  int _getExperienceYears(Map<String, dynamic> teacher) {
    return teacher['experience_years'] ?? 0;
  }

  int _getTotalReviews(Map<String, dynamic> teacher) {
    return teacher['total_reviews'] ?? 0;
  }

  bool _isVerified(Map<String, dynamic> teacher) {
    return teacher['is_verified'] == true;
  }
}
