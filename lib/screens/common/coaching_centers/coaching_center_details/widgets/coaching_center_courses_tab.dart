import 'package:brainboosters_app/screens/common/coaching_centers/coaching_center_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // ADD THIS IMPORT
import 'package:go_router/go_router.dart';
import '../../../../../ui/navigation/common_routes/common_routes.dart';

class CoachingCenterCoursesTab extends StatefulWidget {
  final Map<String, dynamic> center;
  final bool isMobile;

  const CoachingCenterCoursesTab({
    super.key,
    required this.center,
    required this.isMobile,
  });

  @override
  State<CoachingCenterCoursesTab> createState() =>
      _CoachingCenterCoursesTabState();
}

class _CoachingCenterCoursesTabState extends State<CoachingCenterCoursesTab> {
  List<Map<String, dynamic>> courses = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    // FIXED: Schedule data loading after the first frame is built
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadCourses();
    });
  }

  Future<void> _loadCourses() async {
    try {
      // Only set loading state if we're not already loading
      if (!isLoading) {
        setState(() {
          isLoading = true;
          error = null;
        });
      }

      final result = await CoachingCenterRepository.getCoursesByCoachingCenter(
        widget.center['id'],
        limit: 20,
      );

      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          courses = result;
          isLoading = false;
        });
      }
    } catch (e) {
      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          error = 'Failed to load courses: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 360;
    final isMobile = screenWidth < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Courses',
            style: TextStyle(
              fontSize: isSmallMobile ? 16 : (isMobile ? 18 : 20),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isSmallMobile ? 16 : 20),

          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (error != null)
            Center(
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
                      onPressed: _loadCourses,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (courses.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No courses available at the moment.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...courses.map(
              (course) => _buildCourseCard(course, isSmallMobile, isMobile),
            ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(
    Map<String, dynamic> course,
    bool isSmallMobile,
    bool isMobile,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallMobile ? 12 : 16),
      padding: EdgeInsets.all(isSmallMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          context.push(CommonRoutes.getCourseDetailRoute(course['id']));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isSmallMobile)
              _buildVerticalLayout(course, isSmallMobile, isMobile)
            else
              _buildHorizontalLayout(course, isSmallMobile, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalLayout(
    Map<String, dynamic> course,
    bool isSmallMobile,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail and price row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course thumbnail
            Container(
              width: 60,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: course['thumbnail_url'] != null
                    ? Image.network(
                        course['thumbnail_url'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.play_circle_outline,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      )
                    : Icon(
                        Icons.play_circle_outline,
                        color: Colors.grey[400],
                        size: 20,
                      ),
              ),
            ),
            const Spacer(),
            // Price
            _buildPriceSection(course, isSmallMobile, isMobile),
          ],
        ),
        const SizedBox(height: 12),

        // Course title
        Text(
          course['title'] ?? 'Untitled Course',
          style: TextStyle(
            fontSize: isSmallMobile ? 14 : 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),

        // Description
        Text(
          course['short_description'] ?? course['description'] ?? '',
          style: TextStyle(
            fontSize: isSmallMobile ? 12 : 14,
            color: Colors.grey[600],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),

        // Stats - Vertical layout for small screens
        _buildStatsSection(course, isSmallMobile, isMobile),
      ],
    );
  }

  Widget _buildHorizontalLayout(
    Map<String, dynamic> course,
    bool isSmallMobile,
    bool isMobile,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Course thumbnail
        Container(
          width: isMobile ? 70 : 80,
          height: isMobile ? 52 : 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: course['thumbnail_url'] != null
                ? Image.network(
                    course['thumbnail_url'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.play_circle_outline,
                      color: Colors.grey[400],
                    ),
                  )
                : Icon(Icons.play_circle_outline, color: Colors.grey[400]),
          ),
        ),
        SizedBox(width: isMobile ? 12 : 16),

        // Course details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and price row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      course['title'] ?? 'Untitled Course',
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildPriceSection(course, isSmallMobile, isMobile),
                ],
              ),
              const SizedBox(height: 6),

              // Description
              Text(
                course['short_description'] ?? course['description'] ?? '',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),

              // Stats
              _buildStatsSection(course, isSmallMobile, isMobile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(
    Map<String, dynamic> course,
    bool isSmallMobile,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _getFormattedPrice(course),
          style: TextStyle(
            fontSize: isSmallMobile ? 14 : (isMobile ? 15 : 16),
            fontWeight: FontWeight.bold,
            color: _isFree(course) ? Colors.green : Colors.black,
          ),
        ),
        if (!_isFree(course) && course['original_price'] != null) ...[
          const SizedBox(height: 2),
          Text(
            '₹${course['original_price'].toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: isSmallMobile ? 10 : 12,
              color: Colors.grey[500],
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsSection(
    Map<String, dynamic> course,
    bool isSmallMobile,
    bool isMobile,
  ) {
    final stats = [
      _buildStatChip(
        Icons.people_outline,
        '${course['enrollment_count'] ?? 0}',
        Colors.blue,
        isSmallMobile,
        isMobile,
      ),
      _buildStatChip(
        Icons.star_outline,
        '${course['rating']?.toStringAsFixed(1) ?? '0.0'}',
        Colors.orange,
        isSmallMobile,
        isMobile,
      ),
      _buildStatChip(
        Icons.access_time,
        '${course['duration_hours']?.toStringAsFixed(0) ?? '0'}h',
        Colors.green,
        isSmallMobile,
        isMobile,
      ),
    ];

    if (isSmallMobile) {
      // Stack vertically on very small screens
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [stats[0], const SizedBox(width: 6), stats[1]]),
          const SizedBox(height: 6),
          stats[2],
        ],
      );
    } else {
      // Use Wrap for larger screens to handle overflow gracefully
      return Wrap(spacing: isMobile ? 6 : 8, runSpacing: 4, children: stats);
    }
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
        horizontal: isSmallMobile ? 4 : 6,
        vertical: isSmallMobile ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmallMobile ? 10 : 12, color: color),
          SizedBox(width: isSmallMobile ? 2 : 3),
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

  String _getFormattedPrice(Map<String, dynamic> course) {
    if (_isFree(course)) return 'FREE';

    final price = course['price'];
    if (price is num) {
      return '₹${price.toStringAsFixed(0)}';
    }
    return 'FREE';
  }

  bool _isFree(Map<String, dynamic> course) {
    final price = course['price'];
    return price == null || price == 0;
  }
}
