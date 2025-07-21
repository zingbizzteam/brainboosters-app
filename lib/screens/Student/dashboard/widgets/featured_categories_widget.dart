// screens/student/dashboard/widgets/featured_categories_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';

class FeaturedCategoriesWidget extends StatelessWidget {
  const FeaturedCategoriesWidget({super.key});

  static const List<Map<String, dynamic>> _categories = [
    {
      'name': 'Engineering',
      'icon': Icons.engineering,
      'color': Color(0xFF4AA0E6),
      'description': 'Technical & Engineering Courses',
    },
    {
      'name': 'Medical',
      'icon': Icons.medical_services,
      'color': Color(0xFFE74C3C),
      'description': 'Medical Entrance Preparation',
    },
    {
      'name': 'Competitive',
      'icon': Icons.quiz,
      'color': Color(0xFF27AE60),
      'description': 'Competitive Exam Preparation',
    },
    {
      'name': 'Skill Development',
      'icon': Icons.build,
      'color': Color(0xFFF39C12),
      'description': 'Professional Skill Enhancement',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Popular Categories',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            TextButton(
              onPressed: () => context.go(CommonRoutes.coursesRoute),
              child: const Text('Browse all'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width >= 900 ? 4 : 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return GestureDetector(
              onTap: () => context.go(
                CommonRoutes.getCoursesByCategoryRoute(
                  category['name'] as String,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (category['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        category['icon'] as IconData,
                        color: category['color'] as Color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category['description'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
