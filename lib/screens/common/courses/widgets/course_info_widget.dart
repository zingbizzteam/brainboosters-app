// screens/common/courses/widgets/course_info_widget.dart
import 'package:brainboosters_app/screens/common/courses/models/course_model.dart';
import 'package:brainboosters_app/screens/common/widgets/pricing_action_widget.dart';
import 'package:flutter/material.dart';

class CourseInfoWidget extends StatelessWidget {
  final Course course;

  const CourseInfoWidget({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Academy name
        Text(
          course.academy,
          style: TextStyle(
            color: Colors.teal,
            fontSize: isMobile ? 12 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          course.title,
          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          course.description,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        PricingActionWidget(
          price: course.formattedPrice,
          originalPrice: course.hasDiscount
              ? '₹${course.originalPrice.toStringAsFixed(0)}'
              : null,
          buttonText: course.isEnrolled ? 'Continue Learning' : 'Enroll Now',
          buttonColor: Colors.blue,
          onPressed: () {
            // Handle enrollment or continue
          },
          isMobile: isMobile,
        ),
        const SizedBox(height: 16),
        // Analytics
        Row(
          children: [
            Icon(Icons.people, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text('${course.analytics.enrolledCount} enrolled'),
            const SizedBox(width: 16),
            Icon(Icons.visibility, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text('${course.analytics.viewCount} views'),
          ],
        ),
      ],
    );
  }
}
