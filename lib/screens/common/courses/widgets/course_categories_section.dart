// screens/common/courses/widgets/course_categories_section.dart
import 'package:flutter/material.dart';

class CourseCategoriesSection extends StatelessWidget {
  const CourseCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    
    final categories = [
      {
        'title': 'Live Classes',
        'subtitle': 'Join live interactive sessions',
        'icon': Icons.live_tv,
        'color': Colors.red,
      },
      {
        'title': 'Top Coaching Centers',
        'subtitle': 'Premium coaching centers',
        'icon': Icons.school,
        'color': Colors.green,
      },
      {
        'title': 'Courses',
        'subtitle': 'Comprehensive course library',
        'icon': Icons.book,
        'color': Colors.purple,
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
        vertical: 40,
      ),
      child: isMobile 
        ? Column(
            children: categories.map((category) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildCategoryCard(category, true),
              ),
            ).toList(),
          )
        : Row(
            children: categories.map((category) => 
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildCategoryCard(category, false),
                ),
              ),
            ).toList(),
          ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: category['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              category['icon'],
              color: category['color'],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['title'],
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category['subtitle'],
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
