import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class TeacherCoursesTab extends StatelessWidget {
  final Map<String, dynamic> teacher;
  final List<Map<String, dynamic>> courses;
  final bool isMobile;

  const TeacherCoursesTab({
    super.key,
    required this.teacher,
    required this.courses,
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
            'Courses by ${_getTeacherName()}',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          if (courses.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No courses available yet.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...courses.map((course) => _buildCourseCard(context, course)),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Map<String, dynamic> course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course thumbnail
            Container(
              width: 80,
              height: 60,
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
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.play_circle_outline, color: Colors.grey[400]),
                      )
                    : Icon(Icons.play_circle_outline, color: Colors.grey[400]),
              ),
            ),
            const SizedBox(width: 16),
            
            // Course details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['title'] ?? 'Untitled Course',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course['short_description'] ?? course['description'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Course stats
                  Row(
                    children: [
                      _buildStatChip(
                        Icons.people_outline,
                        '${course['enrollment_count'] ?? 0}',
                        Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        Icons.star_outline,
                        '${course['rating']?.toStringAsFixed(1) ?? '0.0'}',
                        Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        Icons.access_time,
                        '${course['duration_hours']?.toStringAsFixed(0) ?? '0'}h',
                        Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _getFormattedPrice(course),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isFree(course) ? Colors.green : Colors.black,
                  ),
                ),
                if (!_isFree(course) && course['original_price'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '₹${course['original_price'].toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
