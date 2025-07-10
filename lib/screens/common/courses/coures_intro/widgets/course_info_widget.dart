import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../course_intro_repository.dart';
import '../../../widgets/pricing_action_widget.dart';

class CourseInfoWidget extends StatefulWidget {
  final Map<String, dynamic> course;
  final bool isEnrolled;
  final VoidCallback? onEnrollmentChanged;

  const CourseInfoWidget({
    super.key,
    required this.course,
    required this.isEnrolled,
    this.onEnrollmentChanged,
  });

  @override
  State<CourseInfoWidget> createState() => _CourseInfoWidgetState();
}

class _CourseInfoWidgetState extends State<CourseInfoWidget> {
  bool _isEnrolling = false;
  static final SupabaseClient _client = Supabase.instance.client;
  static bool get isAuthenticated => _client.auth.currentUser != null;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;
    final course = widget.course;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Academy/Coaching Center name
        Text(
          _getCoachingCenterName(course),
          style: TextStyle(
            color: Colors.teal,
            fontSize: isMobile ? 12 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // Course title
        Text(
          course['title']?.toString() ?? 'Untitled Course',
          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),

        // Course description
        Text(
          course['short_description']?.toString() ??
              course['description']?.toString() ??
              '',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 24),

        // Enrollment status and progress
        if (widget.isEnrolled && course['enrollment'] != null) ...[
          _buildEnrollmentStatus(course['enrollment'], isMobile),
          const SizedBox(height: 16),
        ],

        // Smart action button based on enrollment status and progress
        _buildSmartActionButton(course, isMobile),
        const SizedBox(height: 16),

        // Analytics
        Row(
          children: [
            Icon(Icons.people, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text('${course['enrollment_count'] ?? 0} enrolled'),
            const SizedBox(width: 16),
            Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              '${(course['rating'] as num?)?.toStringAsFixed(1) ?? '0.0'} rating',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmartActionButton(Map<String, dynamic> course, bool isMobile) {
    if (widget.isEnrolled) {
      final enrollment = course['enrollment'] as Map<String, dynamic>?;
      final progressPercentage =
          (enrollment?['progress_percentage'] as num?)?.toDouble() ?? 0.0;
      final hasStarted = progressPercentage > 0;

      String buttonText;
      IconData buttonIcon;
      Color buttonColor;

      if (progressPercentage >= 100) {
        buttonText = 'Review Course';
        buttonIcon = Icons.replay;
        buttonColor = Colors.amber;
      } else if (hasStarted) {
        buttonText = 'Continue Learning';
        buttonIcon = Icons.play_arrow;
        buttonColor = Colors.green;
      } else {
        buttonText = 'Start Learning';
        buttonIcon = Icons.play_arrow;
        buttonColor = Colors.blue;
      }

      return SizedBox(
        width: double.infinity,
        height: isMobile ? 48 : 56,
        child: ElevatedButton.icon(
          onPressed: _isEnrolling
              ? null
              : () => _navigateToCoursePlayer(course),
          icon: Icon(buttonIcon, color: Colors.white),
          label: Text(
            buttonText,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    } else {
      return PricingActionWidget(
        price: _getFormattedPrice(course),
        originalPrice: _hasDiscount(course)
            ? '₹${(course['original_price'] as num?)?.toStringAsFixed(0) ?? '0'}'
            : null,
        buttonText: 'Enroll Now',
        buttonColor: Colors.blue,
        onPressed: _isEnrolling ? null : () => _handleEnrollment(course),
        isMobile: isMobile,
        isLoading: _isEnrolling,
      );
    }
  }

  Widget _buildEnrollmentStatus(
    Map<String, dynamic> enrollment,
    bool isMobile,
  ) {
    final progressPercentage =
        (enrollment['progress_percentage'] as num?)?.toDouble() ?? 0.0;
    final totalTimeSpent = enrollment['total_time_spent'] as int? ?? 0;
    final lessonsCompleted = enrollment['lessons_completed'] as int? ?? 0;
    final totalLessons = enrollment['total_lessons_in_course'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                progressPercentage == 0 ? 'Just Enrolled!' : 'Enrolled',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
            ],
          ),

          if (progressPercentage > 0) ...[
            const SizedBox(height: 12),
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${progressPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progressPercentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation(Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lessons progress
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lessons',
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '$lessonsCompleted / $totalLessons',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time Spent',
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${(totalTimeSpent / 60).toStringAsFixed(1)} hrs',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Ready to start your learning journey!',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          if (progressPercentage >= 100) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Course Completed! 🎉',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleEnrollment(Map<String, dynamic> course) async {
    if (!isAuthenticated) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login to enroll')));
      return;
    }

    setState(() => _isEnrolling = true);
    try {
      final success = await CourseIntroRepository.enrollInCourse(course['id']);
      if (success) {
         if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully enrolled! Ready to start learning?'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onEnrollmentChanged?.call();
      } else {
         if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to enroll. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isEnrolling = false);
    }
  }

  void _navigateToCoursePlayer(Map<String, dynamic> course) {
    final courseId = course['id'];

    try {
      // Navigate to the course player using the correct route structure
      context.go('/courses/$courseId/player');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Navigation error: $e')));
    }
  }

  // Helper methods remain the same...
  String _getCoachingCenterName(Map<String, dynamic> course) {
    final coachingCenters = course['coaching_centers'] as Map<String, dynamic>?;
    return coachingCenters?['center_name']?.toString() ?? 'Unknown Academy';
  }

  String _getFormattedPrice(Map<String, dynamic> course) {
    final price = (course['price'] as num?)?.toDouble() ?? 0.0;
    if (price == 0) return 'FREE';
    return '₹${price.toStringAsFixed(0)}';
  }

  bool _hasDiscount(Map<String, dynamic> course) {
    final price = (course['price'] as num?)?.toDouble() ?? 0.0;
    final originalPrice = (course['original_price'] as num?)?.toDouble() ?? 0.0;
    return originalPrice > price && originalPrice > 0;
  }
}
