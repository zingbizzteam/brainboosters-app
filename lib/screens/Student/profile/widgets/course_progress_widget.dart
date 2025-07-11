import 'package:flutter/material.dart';

class CourseProgressWidget extends StatelessWidget {
  final List<Map<String, dynamic>> courseData;

  const CourseProgressWidget({
    super.key,
    required this.courseData,
  });

  @override
  Widget build(BuildContext context) {
    if (courseData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No courses enrolled yet'),
            SizedBox(height: 8),
            Text(
              'Start learning by enrolling in courses!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: courseData.length,
      itemBuilder: (context, index) {
        final course = courseData[index];
        return _buildCourseCard(course);
      },
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> enrollment) {
    final course = enrollment['courses'] as Map<String, dynamic>;
    final progress = (enrollment['progress_percentage'] as double? ?? 0.0);
    final isCompleted = enrollment['completed_at'] != null;
    final lessonsCompleted = enrollment['lessons_completed'] ?? 0;
    final totalLessons = enrollment['total_lessons_in_course'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Course Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: course['thumbnail_url'] != null
                    ? Image.network(
                        course['thumbnail_url'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.school, color: Colors.grey[400]);
                        },
                      )
                    : Icon(Icons.school, color: Colors.grey[400]),
              ),
            ),
            const SizedBox(width: 16),

            // Course Details
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
                    course['category'] ?? 'General',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$lessonsCompleted/$totalLessons lessons',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '${progress.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? Colors.green : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isCompleted ? 'Completed' : 'In Progress',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
