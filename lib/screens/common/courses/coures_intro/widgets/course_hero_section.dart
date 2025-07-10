import 'package:brainboosters_app/screens/common/widgets/hero_image_widget.dart';
import 'package:flutter/material.dart';
import 'course_info_widget.dart';
import 'course_trailer_modal.dart';

class CourseHeroSection extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isEnrolled;
  final VoidCallback? onEnrollmentChanged;
  final bool isDesktop;
  final bool isTablet;

  const CourseHeroSection({
    super.key,
    required this.course,
    required this.isEnrolled,
    this.onEnrollmentChanged,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return isDesktop || isTablet ? _buildDesktopLayout() : _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: _buildVideoOrImage()),
        const SizedBox(width: 40),
        Expanded(
          flex: 6,
          child: CourseInfoWidget(
            course: course,
            isEnrolled: isEnrolled,
            onEnrollmentChanged: onEnrollmentChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVideoOrImage(),
        const SizedBox(height: 20),
        CourseInfoWidget(
          course: course,
          isEnrolled: isEnrolled,
          onEnrollmentChanged: onEnrollmentChanged,
        ),
      ],
    );
  }

  Widget _buildVideoOrImage() {
    final hasTrailer = course['trailer_video_url'] != null;

    // FIXED: Wrap both video and image in AspectRatio widget
    return AspectRatio(
      aspectRatio: 16 / 9, // Enforce 16:9 aspect ratio
      child: hasTrailer
          ? CourseVideoPlayer(course: course)
          : HeroImageWidget(
              imageUrl: course['thumbnail_url']?.toString() ?? '',
              title: course['title']?.toString() ?? '',
              subtitle: course['short_description']?.toString() ?? '',
              badge: DateTime.now().year.toString(),
              badgeColor: Colors.orange,
              overlayContent: CourseImageOverlay(course: course),
            ),
    );
  }
}

class CourseVideoPlayer extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseVideoPlayer({super.key, required this.course});

  @override
  State<CourseVideoPlayer> createState() => _CourseVideoPlayerState();
}

class _CourseVideoPlayerState extends State<CourseVideoPlayer> {
  bool _showVideo = false;

  @override
  Widget build(BuildContext context) {
    // FIXED: Remove fixed height and let AspectRatio handle sizing
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Background image - FIXED: Use Positioned.fill for proper aspect ratio
            Positioned.fill(
              child: Image.network(
                widget.course['thumbnail_url']?.toString() ?? '',
                fit: BoxFit.cover, // This will crop to maintain 16:9
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),

            // Video player overlay
            if (_showVideo)
              Positioned.fill(
                child: CourseTrailerModal(
                  trailerUrl: widget.course['trailer_video_url'],
                  courseTitle:
                      widget.course['title']?.toString() ?? 'Course Trailer',
                  isEmbedded: true,
                  onClose: () => setState(() => _showVideo = false),
                ),
              ),

            // Overlay elements
            if (!_showVideo) CourseImageOverlay(course: widget.course),

            // Play button
            if (!_showVideo)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _showVideo = true),
                  child: Container(
                    color: Colors.transparent,
                    child: Center(child: _buildPlayButton()),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // FIXED: Responsive play button that adapts to container size
  Widget _buildPlayButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate button size based on container size
        final buttonSize = (constraints.maxWidth * 0.15).clamp(50.0, 100.0);
        final iconSize = buttonSize * 0.5;

        return Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(Icons.play_arrow, size: iconSize, color: Colors.black87),
        );
      },
    );
  }
}

class CourseImageOverlay extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseImageOverlay({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final hasTrailer = course['trailer_video_url'] != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        // FIXED: Make overlay elements responsive to container size
        final isSmallContainer = constraints.maxWidth < 400;
        final iconSize = isSmallContainer ? 40.0 : 60.0;
        final badgeFontSize = isSmallContainer ? 10.0 : 14.0;
        final badgePadding = isSmallContainer ? 8.0 : 16.0;

        return Stack(
          children: [
            // School icon in top-left
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.school,
                  color: Colors.white,
                  size: iconSize * 0.5,
                ),
              ),
            ),

            // FIXED: Show "Watch Trailer" instead of year when trailer exists
            Positioned(
              left: 20,
              bottom: 20,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: badgePadding,
                  vertical: badgePadding * 0.5,
                ),
                decoration: BoxDecoration(
                  color: hasTrailer ? Colors.red : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasTrailer) ...[
                      Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: badgeFontSize + 2,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      hasTrailer
                          ? 'Watch Trailer'
                          : DateTime.now().year.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: badgeFontSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Instructor image - FIXED: Only show on larger containers
            if (constraints.maxWidth > 500) _buildInstructorImage(constraints),
          ],
        );
      },
    );
  }

  Widget _buildInstructorImage(BoxConstraints constraints) {
    final teachers = _getTeachers();
    if (teachers.isEmpty) return const SizedBox.shrink();

    // FIXED: Scale instructor image based on container size
    final imageWidth = (constraints.maxWidth * 0.2).clamp(80.0, 120.0);
    final imageHeight = imageWidth * 1.5; // Maintain aspect ratio

    return Positioned(
      right: 20,
      bottom: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          teachers.first['avatar_url'] ??
              'https://picsum.photos/120/180?random=instructor',
          width: imageWidth,
          height: imageHeight,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: imageWidth,
              height: imageHeight,
              color: Colors.grey[300],
              child: Icon(Icons.person, size: imageWidth * 0.3),
            );
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getTeachers() {
    final courseTeachers = course['course_teachers'] as List?;
    if (courseTeachers == null) return [];

    return courseTeachers.map((ct) {
      final teacher = ct['teachers'] as Map<String, dynamic>?;
      final userProfile = teacher?['user_profiles'] as Map<String, dynamic>?;

      return {
        'id': teacher?['id'],
        'name':
            '${userProfile?['first_name'] ?? ''} ${userProfile?['last_name'] ?? ''}'
                .trim(),
        'avatar_url': userProfile?['avatar_url'],
        'role': ct['role'],
        'is_primary': ct['is_primary'],
      };
    }).toList();
  }
}
