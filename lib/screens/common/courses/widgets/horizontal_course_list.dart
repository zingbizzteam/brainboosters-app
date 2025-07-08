// screens/common/courses/widgets/horizontal_course_list.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'course_card.dart';

class HorizontalCourseList extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Map<String, dynamic>> courses;
  final bool loading;

  const HorizontalCourseList({
    super.key,
    required this.title,
    required this.subtitle,
    required this.courses,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
        vertical: 40,
      ),
      color: title.contains('Top Rated') ? Colors.grey[50] : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          _buildContent(isMobile, isTablet),
        ],
      ),
    );
  }

  Widget _buildContent(bool isMobile, bool isTablet) {
    if (loading) {
      return _buildLoadingState(isMobile, isTablet);
    }

    if (courses.isEmpty) {
      return _buildEmptyState(isMobile);
    }

    return _buildCoursesList();
  }

  Widget _buildLoadingState(bool isMobile, bool isTablet) {
    // Optimize skeleton count based on screen size
    int skeletonCount;
    if (isMobile) {
      skeletonCount = 3;
    } else if (isTablet) {
      skeletonCount = 4;
    } else {
      skeletonCount = 5;
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: skeletonCount,
        itemBuilder: (context, index) {
          return Container(
            width: isMobile ? 280 : 320,
            margin: const EdgeInsets.only(right: 16),
            child: _buildSkeletonCard(),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return SizedBox(
      height: 280,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: isMobile ? 48 : 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No courses available',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new courses',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          if (course == null) {
            return const SizedBox.shrink();
          }

          return SafeCourseCard(course: course);
        },
      ),
    );
  }
}

// Enhanced SafeCourseCard with shimmer for error states
class SafeCourseCard extends StatelessWidget {
  final Map<String, dynamic> course;

  const SafeCourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    try {
      if (!_isValidCourse(course)) {
        return _buildErrorCard();
      }

      return CourseCard(course: course);
    } catch (e) {
      debugPrint('Error rendering course card: $e');
      return _buildErrorCard();
    }
  }

  bool _isValidCourse(Map<String, dynamic> course) {
    return course['id'] != null &&
        course['title'] != null &&
        course['title'].toString().isNotEmpty;
  }

  Widget _buildErrorCard() {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[300], size: 32),
              const SizedBox(height: 8),
              Text(
                'Course data unavailable',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
