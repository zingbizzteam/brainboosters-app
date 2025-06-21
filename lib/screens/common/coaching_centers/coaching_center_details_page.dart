// screens/common/coaching_centers/coaching_center_detail_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'data/coaching_center_dummy_data.dart';
import 'models/coaching_center_model.dart';
import '../widgets/breadcrumb_widget.dart';
import '../widgets/tab_section_widget.dart';
import 'widgets/coaching_center_header_widget.dart';
import 'widgets/coaching_center_about_tab.dart';
import 'widgets/coaching_center_batches_tab.dart';
import 'widgets/coaching_center_faculty_tab.dart';
import 'widgets/coaching_center_analytics_tab.dart';

class CoachingCenterDetailPage extends StatefulWidget {
  final String centerId;

  const CoachingCenterDetailPage({super.key, required this.centerId});

  @override
  State<CoachingCenterDetailPage> createState() =>
      _CoachingCenterDetailPageState();
}

class _CoachingCenterDetailPageState extends State<CoachingCenterDetailPage>
    with TickerProviderStateMixin {
  CoachingCenter? coachingCenter;
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCoachingCenter();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadCoachingCenter() {
    try {
      final center = CoachingCenterDummyData.coachingCenters.firstWhere(
        (center) => center.id == widget.centerId,
      );
      setState(() {
        coachingCenter = center;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (coachingCenter == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text(
            'Coaching Center not found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Breadcrumb Navigation
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
                vertical: 16,
              ),
              child: BreadcrumbWidget(
                items: [
                  BreadcrumbItem('Home', false, onTap: () => context.go('/')),
                  BreadcrumbItem(
                    'Coaching Centers',
                    false,
                    onTap: () => context.go('/coaching-centers'),
                  ),
                  BreadcrumbItem(coachingCenter!.name, true),
                ],
              ),
            ),

            // Main Content
            Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  CoachingCenterHeaderWidget(
                    coachingCenter: coachingCenter!,
                    isMobile: isMobile,
                  ),

                  const SizedBox(height: 32),

                  // Tab Navigation
                  TabSectionWidget(
                    tabController: _tabController,
                    tabs: const ['About', 'Batches', 'Faculty', 'Analytics'],
                    tabViews: [
                      CoachingCenterAboutTab(
                        center: coachingCenter!,
                        isMobile: isMobile,
                      ),
                      CoachingCenterBatchesTab(
                        center: coachingCenter!,
                        isMobile: isMobile,
                      ),
                      CoachingCenterFacultyTab(
                        center: coachingCenter!,
                        isMobile: isMobile,
                      ),
                      CoachingCenterAnalyticsTab(
                        center: coachingCenter!,
                        isMobile: isMobile,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
