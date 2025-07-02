import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EnrolledCourseList extends StatelessWidget {
  final List<Map<String, dynamic>> enrolledCourses;
  final bool loading;

  const EnrolledCourseList({
    super.key,
    required this.enrolledCourses,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (enrolledCourses.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: enrolledCourses.map((course) {
        final courseData = course['courses'] ?? {};
        // Accept int or double, but always use integer for display
        final progressRaw = course['progress_percentage'] ?? 0;
        final progress = (progressRaw is int)
            ? progressRaw.clamp(0, 100)
            : (progressRaw is double)
            ? progressRaw.round().clamp(0, 100)
            : 0;
        final totalLessons = courseData['total_lessons'] ?? 0;
        final duration = courseData['duration_hours'] != null
            ? "${courseData['duration_hours']} hrs"
            : '';
        final category = courseData['category'] ?? '';
        final level = courseData['level'] ?? '';
        final totalTimeSpent = course['total_time_spent'] ?? 0; // in minutes

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () {
              context.go(
                CommonRoutes.getCourseDetailRoute(course['course_id']),
              );
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    courseData['thumbnail_url'] ?? '',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey,
                        child: const Icon(
                          Icons.book,
                          color: Colors.white,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        courseData['title'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$category • $level",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "$progress% Complete",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "$duration • $totalLessons lessons",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Progress bar: always show full gray, blue overlay only if >0%
                      Stack(
                        children: [
                          Container(
                            height: 4,
                            margin: const EdgeInsets.only(right: 60),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          if (progress > 0)
                            Container(
                              height: 4,
                              margin: const EdgeInsets.only(right: 60),
                              width:
                                  ((progress / 100) *
                                          (MediaQuery.of(context).size.width -
                                              120))
                                      .clamp(0.0, double.infinity),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4AA0E6),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                        ],
                      ),
                      if (totalTimeSpent > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            "Time spent: ${totalTimeSpent ~/ 60}h ${totalTimeSpent % 60}m",
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
