// screens/student/dashboard/widgets/popular_courses_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboosters_app/screens/common/courses/widgets/course_card.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';

class PopularCoursesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final String title;

  const PopularCoursesWidget({
    super.key,
    required this.courses,
    this.title = "Popular Courses",
  });

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            TextButton(
              onPressed: () => context.go(CommonRoutes.coursesRoute),
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: courses.length,
            itemBuilder: (context, idx) {
              final course = courses[idx];
              return Padding(
                padding: EdgeInsets.only(left: idx == 0 ? 0 : 8, right: 8),
                child: CourseCard(
                  course: course,
                  width: 280,
                  height: 320,
                  onTap: () {
                    final courseSlug = course['id']?.toString();
                    if (courseSlug != null && courseSlug.isNotEmpty) {
                      context.go('/course/$courseSlug');
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
