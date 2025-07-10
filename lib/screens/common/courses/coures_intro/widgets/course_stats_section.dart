import 'package:brainboosters_app/screens/common/widgets/stats_widget.dart';
import 'package:flutter/material.dart';
import 'course_rating_widget.dart';

class CourseStatsSection extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseStatsSection({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return StatsWidget(
      items: [
        StatItem(
          icon: Icons.people_outline,
          text: '${course['enrollment_count'] ?? 0} Students',
        ),
        StatItem(
          icon: Icons.access_time,
          text: '${course['duration_hours']?.toStringAsFixed(1) ?? '0'} hr',
        ),
        StatItem(
          icon: Icons.play_circle_outline,
          text: '${course['total_lessons'] ?? 0} Lessons',
        ),
        StatItem(
          icon: Icons.calendar_today_outlined,
          text: 'Updated ${_formatDate(course['last_updated'])}',
        ),
      ],
      trailingWidget: CourseRatingWidget(course: course),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    try {
      final dateTime = date is DateTime ? date : DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
