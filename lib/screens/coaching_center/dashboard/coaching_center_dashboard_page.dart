// screens/coaching_center/dashboard/coaching_center_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/dashboard_widgets.dart';

class CoachingCenterDashboardPage extends StatefulWidget {
  const CoachingCenterDashboardPage({super.key});

  @override
  State<CoachingCenterDashboardPage> createState() => _CoachingCenterDashboardPageState();
}

class _CoachingCenterDashboardPageState extends State<CoachingCenterDashboardPage> {
  Map<String, dynamic> _centerData = {};
  Map<String, dynamic> _analytics = {};
  List<Map<String, dynamic>> _recentActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      // Load center data
      final centerResponse = await Supabase.instance.client
          .from('coaching_centers')
          .select('center_name, total_students, total_faculties, total_courses_created')
          .eq('id', userId)
          .single();

      // Load analytics data
      final analyticsResponse = await Supabase.instance.client
          .from('coaching_center_analytics')
          .select('*')
          .eq('coaching_center_id', userId)
          .maybeSingle();

      // Load recent enrollments as activities
      final activitiesResponse = await Supabase.instance.client
          .from('enrollments')
          .select('*, user_profiles(name)')
          .eq('enrollment_type', 'course')
          .order('created_at', ascending: false)
          .limit(5);

      if (mounted) {
        setState(() {
          _centerData = centerResponse;
          _analytics = analyticsResponse ?? {};
          _recentActivities = List<Map<String, dynamic>>.from(activitiesResponse);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00B894)));
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              WelcomeCard(centerName: _centerData['center_name'] ?? 'Your Center'),
              
              const SizedBox(height: 24),
              
              // Key Metrics
              MetricsGrid(
                totalStudents: _centerData['total_students'] ?? 0,
                totalFaculty: _centerData['total_faculties'] ?? 0,
                totalCourses: _centerData['total_courses_created'] ?? 0,
                successRate: _analytics['student_satisfaction_score'] ?? 0.0,
              ),
              
              const SizedBox(height: 24),
              
              // Quick Actions
              const QuickActionsSection(),
              
              const SizedBox(height: 24),
              
              // Recent Activities
              RecentActivitiesSection(activities: _recentActivities),
            ],
          ),
        ),
      ),
    );
  }
}
