// screens/common/courses/widgets/course_info_widget.dart
import 'package:brainboosters_app/screens/Student/dashboard/data/models/course_model.dart';
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
          'The Leaders Academy',
          style: TextStyle(
            color: Colors.teal,
            fontSize: isMobile ? 12 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Course title
        Text(
          'The Complete Python Course: From Zero to Hero in Python',
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
          'Learn Python like a Professional! Start from the basics and go all the way to creating your own applications and games',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Price and Enroll button using common widget
        PricingActionWidget(
          price: '₹599',
          originalPrice: '₹3109',
          buttonText: 'Enroll Now',
          buttonColor: Colors.blue,
          onPressed: () {
            // Handle enrollment
          },
          isMobile: isMobile,
        ),
      ],
    );
  }
}
