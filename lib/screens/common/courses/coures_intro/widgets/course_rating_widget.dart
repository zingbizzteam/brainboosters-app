import 'package:flutter/material.dart';

class CourseRatingWidget extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseRatingWidget({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final rating = (course['rating'] as num?)?.toDouble() ?? 0.0;
    final totalReviews = course['total_reviews'] as int? ?? 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Icon(
              Icons.star,
              size: 16,
              color: index < rating.floor() ? Colors.amber : Colors.grey[300],
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 4),
        Text(
          '($totalReviews ratings)',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
