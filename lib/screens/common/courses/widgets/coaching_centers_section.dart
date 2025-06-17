// screens/common/courses/widgets/coaching_centers_section.dart
import 'package:flutter/material.dart';

class CoachingCentersSection extends StatelessWidget {
  const CoachingCentersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    
    final coachingCenters = [
      {
        'name': 'The Leaders Academy',
        'rating': 4.8,
        'reviews': 10000,
        'description': 'Best in class learning experience with expert instructors',
      },
      {
        'name': 'Expert Academy',
        'rating': 4.7,
        'reviews': 8500,
        'description': 'Professional courses with industry experts',
      },
      {
        'name': 'SkillHive Training',
        'rating': 4.6,
        'reviews': 7200,
        'description': 'Hands-on training with real-world projects',
      },
      {
        'name': 'GoCorp Solutions',
        'rating': 4.5,
        'reviews': 6800,
        'description': 'Corporate training and skill development',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
        vertical: 40,
      ),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Coaching Centers for Python',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Show All',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Some of the top coaching centers in the country partner with us to provide you with the best learning experience',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Coaching Centers List
          ...coachingCenters.map((center) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildCoachingCenterCard(center, isMobile),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachingCenterCard(Map<String, dynamic> center, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.school,
              color: Colors.grey,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          
          // Center info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  center['name'],
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: isMobile ? 16 : 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${center['rating']}',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${center['reviews']} reviews)',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  center['description'],
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
