// screens/common/live_class/widgets/live_class_categories_section.dart
import 'package:flutter/material.dart';

class LiveClassCategoriesSection extends StatelessWidget {
  const LiveClassCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    
    final categories = [
      {
        'title': 'Programming',
        'subtitle': 'Live coding sessions',
        'icon': Icons.code,
        'color': Colors.blue,
        'count': '25+ Classes',
      },
      {
        'title': 'Data Science',
        'subtitle': 'Interactive data analysis',
        'icon': Icons.analytics,
        'color': Colors.green,
        'count': '18+ Classes',
      },
      {
        'title': 'Design',
        'subtitle': 'Creative design workshops',
        'icon': Icons.design_services,
        'color': Colors.purple,
        'count': '15+ Classes',
      },
      {
        'title': 'Business',
        'subtitle': 'Live business sessions',
        'icon': Icons.business,
        'color': Colors.orange,
        'count': '12+ Classes',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
        vertical: 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Class Categories',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose from various interactive learning categories',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          isMobile 
            ? Column(
                children: categories.map((category) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildCategoryCard(category, true),
                  ),
                ).toList(),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 2 : 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) => _buildCategoryCard(categories[index], false),
              ),
        ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              if (!isMobile) const Spacer(),
              if (!isMobile)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: category['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category['count'],
                    style: TextStyle(
                      fontSize: 12,
                      color: category['color'],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
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
          if (isMobile) ...[
            const SizedBox(height: 12),
            Text(
              category['count'],
              style: TextStyle(
                fontSize: 12,
                color: category['color'],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
