import 'package:brainboosters_app/screens/common/live_class/live_class_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import '../../../ui/navigation/common_routes/common_routes.dart';
import 'widgets/live_class_hero_section.dart';
import 'widgets/live_class_categories_section.dart';
import 'widgets/featured_instructors_section.dart';
import 'widgets/live_class_card.dart';
import '../courses/widgets/app_promotion_section.dart';
import '../courses/widgets/course_footer_section.dart';

class LiveClassesPage extends StatefulWidget {
  const LiveClassesPage({super.key});

  @override
  State<LiveClassesPage> createState() => _LiveClassesPageState();
}

class _LiveClassesPageState extends State<LiveClassesPage> {
  List<Map<String, dynamic>> upcomingLiveClasses = [];
  List<Map<String, dynamic>> technologyLiveClasses = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadLiveClasses();
  }

  Future<void> _loadLiveClasses() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final results = await Future.wait([
        LiveClassRepository.getUpcomingLiveClasses(limit: 8),
        LiveClassRepository.getLiveClassesByCategory('Technology', limit: 8),
      ]);

      setState(() {
        upcomingLiveClasses = results[0];
        technologyLiveClasses = results[1];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load live classes: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadLiveClasses,
        child: SingleChildScrollView(
          child: Column(
            children: [
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
      ),
    );
  }

  Widget _buildUpcomingLiveClassesSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

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
          
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      error!,
                      style: TextStyle(color: Colors.red[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadLiveClasses,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (upcomingLiveClasses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.live_tv_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No upcoming live classes available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            _buildDynamicLiveClassGrid(
              context,
              upcomingLiveClasses,
              isMobile,
              isTablet,
            ),
        ],
      ),
    );
  }

  Widget _buildLiveClassesByCategorySection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

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
          
          if (technologyLiveClasses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  'No technology live classes available',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            _buildDynamicLiveClassGrid(
              context,
              technologyLiveClasses,
              isMobile,
              isTablet,
            ),
          
          const SizedBox(height: 32),
          
          // View All Button
          Center(
            child: OutlinedButton(
              onPressed: () {
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
    List<Map<String, dynamic>> liveClasses,
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
        return LiveClassCard(
          liveClass: liveClasses[index],
          onTap: () {
            context.push(CommonRoutes.getLiveClassDetailRoute(
              liveClasses[index]['id']
            ));
          },
        );
      },
    );
  }
}
