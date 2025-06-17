// screens/common/live_class/live_classes_page.dart
import 'package:brainboosters_app/screens/common/live_class/models/live_class_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'data/live_class_dummy_data.dart';
import '../../../ui/navigation/common_routes/common_routes.dart';
import 'widgets/live_class_hero_section.dart';
import 'widgets/live_class_categories_section.dart';
import 'widgets/featured_instructors_section.dart';
import '../courses/widgets/course_search_bar.dart';
import '../courses/widgets/app_promotion_section.dart';
import '../courses/widgets/course_footer_section.dart';

class LiveClassesPage extends StatelessWidget {
  const LiveClassesPage({super.key});

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
            const LiveClassHeroSection(),
            
            // Live Class Categories
            const LiveClassCategoriesSection(),
            
            // Upcoming Live Classes
            _buildUpcomingLiveClassesSection(context),
            
            // Featured Instructors
            const FeaturedInstructorsSection(),
            
            // Live Classes by Category
            _buildLiveClassesByCategorySection(context),
            
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

  Widget _buildUpcomingLiveClassesSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    // Get upcoming live classes
    final upcomingClasses = LiveClassDummyData.liveClasses
        .where((lc) => lc.status == 'upcoming')
        .take(8)
        .toList();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
        vertical: 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Live Classes',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join interactive sessions with expert instructors',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Dynamic Live Class Grid
          _buildDynamicLiveClassGrid(context, upcomingClasses, isMobile, isTablet),
        ],
      ),
    );
  }

  Widget _buildLiveClassesByCategorySection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    // Get live classes by category
    final categoryClasses = LiveClassDummyData.liveClasses
        .where((lc) => lc.category == 'Technology')
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
            'Technology Live Classes',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Master the latest in technology with live instruction',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Dynamic Live Class Grid
          _buildDynamicLiveClassGrid(context, categoryClasses, isMobile, isTablet),

          const SizedBox(height: 32),

          // View All Button
          Center(
            child: OutlinedButton(
              onPressed: () {
                // Navigate to search page with live class filter
                context.push(CommonRoutes.getSearchCoursesRoute(''));
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View All Live Classes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicLiveClassGrid(
    BuildContext context,
    List<LiveClass> liveClasses,
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
      itemCount: liveClasses.length,
      itemBuilder: (context, index) {
        return _buildDynamicLiveClassCard(context, liveClasses[index], isMobile);
      },
    );
  }

  Widget _buildDynamicLiveClassCard(
    BuildContext context,
    LiveClass liveClass,
    bool isMobile,
  ) {
    Color statusColor;
    switch (liveClass.status) {
      case 'live':
        statusColor = Colors.red;
        break;
      case 'upcoming':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        // Navigate to live class detail page
        context.push(CommonRoutes.getLiveClassDetailRoute(liveClass.id));
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
            // Live Class Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      liveClass.imageUrl,
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
                            Icons.live_tv,
                            color: Colors.grey,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                  // Status Badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            color: Colors.white,
                            size: 8,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            liveClass.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Live Class Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Live Class Title
                    Text(
                      liveClass.title,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Academy Name
                    Text(
                      liveClass.academy,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ),

                    const Spacer(),

                    // Time and Price Row
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.grey[500],
                          size: isMobile ? 14 : 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            liveClass.formattedTime,
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Text(
                          liveClass.price == 0.0 ? 'Free' : '₹${liveClass.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: liveClass.price == 0.0 ? Colors.green : Colors.black,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${liveClass.currentParticipants}/${liveClass.maxParticipants}',
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
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
