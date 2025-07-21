// screens/student/dashboard/dashboard_page.dart - COMPLETELY REWRITTEN
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:brainboosters_app/screens/student/dashboard/widgets/dashboard_top_bar.dart';
import 'package:brainboosters_app/screens/student/dashboard/widgets/enrolled_course_list.dart';
import 'package:brainboosters_app/screens/student/dashboard/widgets/enrolled_live_class_list.dart';
import 'package:brainboosters_app/screens/student/dashboard/widgets/welcome_header_widget.dart';
import 'package:brainboosters_app/screens/student/dashboard/widgets/popular_courses_widget.dart';
import 'package:brainboosters_app/screens/student/dashboard/widgets/popular_live_classes_widget.dart';
import 'package:brainboosters_app/screens/student/dashboard/widgets/featured_categories_widget.dart';
import 'package:brainboosters_app/screens/student/dashboard/widgets/signup_cta_widget.dart';
import 'package:brainboosters_app/screens/student/dashboard/dashboard_skeleton.dart';
import 'package:brainboosters_app/screens/student/dashboard/dashboard_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboosters_app/ui/navigation/student_routes/student_routes.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _loading = true;
  String? _error;
  
  // User state
  Map<String, dynamic>? _studentStats;
  List<Map<String, dynamic>> _enrolledCourses = [];
  List<Map<String, dynamic>> _enrolledLiveClasses = [];
  
  // Popular content for all users
  List<Map<String, dynamic>> _popularCourses = [];
  List<Map<String, dynamic>> _popularLiveClasses = [];

  bool get _isLoggedIn => Supabase.instance.client.auth.currentUser != null;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      if (_isLoggedIn) {
        await _fetchLoggedInUserData();
      } else {
        await _fetchPopularContent();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to load dashboard: $e';
        });
      }
    }
  }

  Future<void> _fetchLoggedInUserData() async {
    final user = Supabase.instance.client.auth.currentUser!;
    
    // Check if user is enrolled as student
    final studentRes = await Supabase.instance.client
        .from('students')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (studentRes != null) {
      // Fetch enrolled user data
      await _fetchEnrolledUserData(studentRes);
    } else {
      // New user - show popular content
      await _fetchPopularContent();
    }
  }

  Future<void> _fetchEnrolledUserData(Map<String, dynamic> studentRes) async {
    // TODO: Implement enrolled user data fetching
    // This would include stats, enrolled courses, etc.
    await _fetchPopularContent(); // For now, show popular content
  }

  Future<void> _fetchPopularContent() async {
    try {
      final popularCourses = await DashboardRepository.getPopularCourses();
      final popularLiveClasses = await DashboardRepository.getPopularLiveClasses();

      if (mounted) {
        setState(() {
          _popularCourses = popularCourses;
          _popularLiveClasses = popularLiveClasses;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFD),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        color: const Color(0xFF4AA0E6),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 32 : 16,
            vertical: isWide ? 24 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar or welcome header
              if (_isLoggedIn)
                const DashboardTopBar()
              else
                const WelcomeHeaderWidget(),
              
              SizedBox(height: isWide ? 32 : 20),

              // Error handling
              if (_error != null && !_loading) ...[
                _buildErrorWidget(),
                const SizedBox(height: 16),
              ],

              // Loading state
              if (_loading)
                const DashboardSkeleton()
              else ...[
                // Stats section (logged in users only)
                if (_isLoggedIn && _studentStats != null) ...[
                  _buildStatsSection(isWide),
                  SizedBox(height: isWide ? 32 : 20),
                ],

                // Enrolled content (logged in users only)
                if (_isLoggedIn) ...[
                  if (_enrolledCourses.isNotEmpty) ...[
                    _buildEnrolledCoursesSection(),
                    SizedBox(height: isWide ? 24 : 16),
                  ],
                  if (_enrolledLiveClasses.isNotEmpty) ...[
                    _buildEnrolledLiveClassesSection(),
                    SizedBox(height: isWide ? 24 : 16),
                  ],
                ],

                // Popular live classes (all users)
                if (_popularLiveClasses.isNotEmpty) ...[
                  PopularLiveClassesWidget(
                    liveClasses: _popularLiveClasses,
                    title: _isLoggedIn ? "Suggested Live Classes" : "Popular Live Classes",
                  ),
                  SizedBox(height: isWide ? 24 : 16),
                ],

                // Popular courses (all users)
                if (_popularCourses.isNotEmpty) ...[
                  PopularCoursesWidget(
                    courses: _popularCourses,
                    title: _isLoggedIn ? "Recommended Courses" : "Popular Courses",
                  ),
                  SizedBox(height: isWide ? 24 : 16),
                ],

                // Featured categories (unlogged users only)
                if (!_isLoggedIn) ...[
                  const FeaturedCategoriesWidget(),
                  SizedBox(height: isWide ? 24 : 16),
                  const SizedBox(height: 32),
                  const SignUpCtaWidget(),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
          TextButton(
            onPressed: _refreshDashboard,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isWide) {
    // TODO: Implement stats section using DashboardStatCard
    return const SizedBox.shrink();
  }

  Widget _buildEnrolledCoursesSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Enrolled Courses",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            TextButton(
              onPressed: () => context.go(StudentRoutes.enrolledCourses),
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        EnrolledCourseList(
          enrolledCourses: _enrolledCourses,
          loading: false,
        ),
      ],
    );
  }

  Widget _buildEnrolledLiveClassesSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Enrolled Live Classes",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            TextButton(
              onPressed: () => context.go(StudentRoutes.enrolledLiveClasses),
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        EnrolledLiveClassList(
          liveClasses: _enrolledLiveClasses,
          loading: false,
        ),
      ],
    );
  }
}
