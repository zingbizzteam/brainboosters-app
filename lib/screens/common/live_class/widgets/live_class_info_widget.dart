// screens/common/live_class/widgets/live_class_info_widget.dart
import 'package:brainboosters_app/screens/common/live_class/models/live_class_model.dart';
import 'package:brainboosters_app/screens/common/widgets/pricing_action_widget.dart';
import 'package:flutter/material.dart';

class LiveClassInfoWidget extends StatelessWidget {
  final LiveClass liveClass;
  
  const LiveClassInfoWidget({super.key, required this.liveClass});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Academy name with Live Class badge
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Live Class',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'The Leaders Academy',
              style: TextStyle(
                color: Colors.teal,
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Live Class title
        Text(
          'The 10 weeks Python Bootcamp',
          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.2,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Live Class description
        Text(
          'Learn Python like a Professional! Start from the basics and go all the way to creating your own applications and games',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Price and Enroll button
        PricingActionWidget(
          price: '₹6899',
          originalPrice: '₹12999',
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
