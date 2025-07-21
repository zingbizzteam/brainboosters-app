import 'package:brainboosters_app/screens/common/coaching_centers/coaching_center_repository.dart';
import 'package:brainboosters_app/screens/common/coaching_centers/teachers/teacher_repository.dart';
import 'package:brainboosters_app/screens/common/widgets/breadcrumb_widget.dart';
import 'package:brainboosters_app/screens/common/widgets/tab_section_widget.dart';
import 'package:brainboosters_app/ui/navigation/app_router.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/teacher_header_widget.dart';
import 'widgets/teacher_about_tab.dart';
import 'widgets/teacher_courses_tab.dart';
import 'widgets/teacher_reviews_tab.dart';

class TeacherDetailPage extends StatefulWidget {
  final String teacherId;
  final String? centerId; // NEW: Optional center context

  const TeacherDetailPage({super.key, required this.teacherId, this.centerId});

  @override
  State<TeacherDetailPage> createState() => _TeacherDetailPageState();
}

class _TeacherDetailPageState extends State<TeacherDetailPage>
    with TickerProviderStateMixin {
  Map<String, dynamic>? teacher;
  Map<String, dynamic>? coachingCenter;
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> reviews = [];
  bool isLoading = true;
  String? error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTeacherData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTeacherData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final futures = <Future>[
        TeacherRepository.getTeacherById(widget.teacherId),
        TeacherRepository.getCoursesByTeacher(widget.teacherId),
        TeacherRepository.getTeacherReviews(widget.teacherId),
      ];

      // Load coaching center data if centerId is provided
      if (widget.centerId != null) {
        futures.add(
          CoachingCenterRepository.getCoachingCenterById(widget.centerId!),
        );
      }

      final results = await Future.wait(futures);

      setState(() {
        teacher = results[0] as Map<String, dynamic>?;
        courses = results[1] as List<Map<String, dynamic>>;
        reviews = results[2] as List<Map<String, dynamic>>;

        if (widget.centerId != null && results.length > 3) {
          coachingCenter = results[3] as Map<String, dynamic>?;
        }

        isLoading = false;

        if (teacher == null) {
          error = 'Teacher not found';
        }
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load teacher data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.pop(),
            ),
            title: isMobile ? null : _buildBreadcrumb(),
          ),
          SliverToBoxAdapter(child: _buildContent(isMobile)),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb() {
    final items = <BreadcrumbItem>[
      BreadcrumbItem('Home', false, onTap: () => context.go(AppRouter.home)),
      BreadcrumbItem(
        'Coaching Centers',
        false,
        onTap: () => context.go(CommonRoutes.coachingCentersRoute),
      ),
    ];

    if (coachingCenter != null) {
      items.add(
        BreadcrumbItem(
          coachingCenter!['center_name'],
          false,
          onTap: () => context.go('/coaching-center/${widget.centerId}'),
        ),
      );
      items.add(
        BreadcrumbItem(
          'Teachers',
          false,
          onTap: () =>
              context.go('/coaching-center/${widget.centerId}/teachers'),
        ),
      );
    }

    items.add(
      BreadcrumbItem(
        teacher?['user_profiles']?['first_name'] ?? 'Teacher',
        true,
      ),
    );

    return BreadcrumbWidget(items: items);
  }

  Widget _buildContent(bool isMobile) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(100),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                error!,
                style: TextStyle(color: Colors.red[600], fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadTeacherData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (teacher == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('Teacher not found'),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Mobile breadcrumb
          if (isMobile) ...[_buildBreadcrumb(), const SizedBox(height: 20)],

          // Teacher header with coaching center context
          TeacherHeaderWidget(
            teacher: teacher!,
            coachingCenter: coachingCenter,
            isMobile: isMobile,
          ),

          const SizedBox(height: 32),

          // Tabs
          TabSectionWidget(
            tabController: _tabController,
            tabs: const ['About', 'Courses', 'Reviews'],
            tabViews: [
              TeacherAboutTab(teacher: teacher!, isMobile: isMobile),
              TeacherCoursesTab(
                teacher: teacher!,
                courses: courses,
                isMobile: isMobile,
              ),
              TeacherReviewsTab(
                teacher: teacher!,
                reviews: reviews,
                isMobile: isMobile,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
