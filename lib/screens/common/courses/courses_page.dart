// screens/common/courses/courses_page.dart
import 'package:brainboosters_app/screens/common/courses/widgets/course_footer_section.dart';
import 'package:brainboosters_app/screens/common/courses/widgets/course_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'data/course_dummy_data.dart';
import 'models/course_model.dart';
import '../../../ui/navigation/common_routes/common_routes.dart';
import 'widgets/course_hero_section.dart';
import 'widgets/course_categories_section.dart';
import 'widgets/coaching_centers_section.dart';
import 'widgets/app_promotion_section.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar
            const CourseSearchBar(),
            
            // Hero Section
            const CourseHeroSection(),
            
            // Course Categories
            const CourseCategoriesSection(),
            
            // Coaching Centers
            const CoachingCentersSection(),
            
            // Featured Courses (Dynamic)
            _buildFeaturedCoursesSection(context),
            
            // Top Rated Courses (Dynamic)
            _buildTopRatedCoursesSection(context),
            
            // App Promotion - Only on Web
            if (kIsWeb) const AppPromotionSection(),
            
            // Footer - Only on Web
            if (kIsWeb) const CourseFooterSection(),
            
            // Footer spacing for mobile
            if (!kIsWeb) const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

 Widget _buildFeaturedCoursesSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    // Get featured courses (first 8 courses)
    final featuredCourses = CourseDummyData.courses.take(8).toList();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
        vertical: 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Featured Courses in Python',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore a diverse landscape that caters to all learning preferences',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Dynamic Course Grid
          _buildDynamicCourseGrid(context, featuredCourses, isMobile, isTablet),
        ],
      ),
    );
  }

  Widget _buildTopRatedCoursesSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    // Get top rated courses (rating >= 4.5)
    final topRatedCourses = CourseDummyData.courses
        .where((course) => course.rating >= 4.5)
        .take(8)
        .toList();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
        vertical: 40,
      ),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Rated Courses in Python',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Highest rated courses by our students',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Dynamic Course Grid
          _buildDynamicCourseGrid(context, topRatedCourses, isMobile, isTablet),

          const SizedBox(height: 32),

          // View All Button
          Center(
            child: OutlinedButton(
              onPressed: () {
                // Navigate to all courses page
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View All Courses',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicCourseGrid(
    BuildContext context,
    List<Course> courses,
    bool isMobile,
    bool isTablet,
  ) {
    int crossAxisCount;
    if (isMobile) {
      crossAxisCount = 1;
    } else if (isTablet) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 4;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isMobile ? 1.2 : 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return _buildDynamicCourseCard(context, courses[index], isMobile);
      },
    );
  }

  Widget _buildDynamicCourseCard(
    BuildContext context,
    Course course,
    bool isMobile,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to course detail page
        context.push(CommonRoutes.getCourseDetailRoute(course.id));
      },
      child: Container(
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
            // Course Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  course.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.book,
                        color: Colors.grey,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Course Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Title
                    Text(
                      course.title,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Academy Name
                    Text(
                      course.academy,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ),

                    const Spacer(),

                    // Rating and Price Row
                    Row(
                      children: [
                        // Rating
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: isMobile ? 14 : 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          course.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const Spacer(),

                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (course.hasDiscount) ...[
                              Text(
                                '₹${course.originalPrice.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: isMobile ? 10 : 12,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                            Text(
                              course.isFree
                                  ? 'Free'
                                  : '₹${course.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                color: course.isFree
                                    ? Colors.green
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Course Duration and Lessons
                    const SizedBox(height: 4),
                    Text(
                      '${course.formattedDuration} • ${course.totalLessons} lessons',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}