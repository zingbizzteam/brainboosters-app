import 'package:flutter/material.dart';

class CoachingCenterHeroSection extends StatelessWidget {
  const CoachingCenterHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
        vertical: isMobile ? 40 : 60,
      ),
      
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[50]!,
            Colors.indigo[50]!,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find the Perfect Coaching Center',
            style: TextStyle(
              fontSize: isMobile ? 28 : (isTablet ? 36 : 42),
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Discover top-rated coaching centers near you. Compare courses, read reviews, and find the perfect match for your learning goals.',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          // Search bar section removed completely
        ],
      ),
    );
  }
}
