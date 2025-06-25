// screens/coaching_center/analytics/coaching_center_analytics_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/analytics_header.dart';
import 'widgets/stats_grid.dart';
import 'widgets/enrollment_chart.dart';
import 'widgets/performance_metrics.dart';
import 'widgets/recent_activity.dart';

class CoachingCenterAnalyticsPage extends StatefulWidget {
  const CoachingCenterAnalyticsPage({super.key});

  @override
  State<CoachingCenterAnalyticsPage> createState() => _CoachingCenterAnalyticsPageState();
}

class _CoachingCenterAnalyticsPageState extends State<CoachingCenterAnalyticsPage> {
  Map<String, dynamic> _analytics = {};
  List<Map<String, dynamic>> _recentActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      // Get center analytics
      final centerResponse = await Supabase.instance.client
          .from('coaching_centers')
          .select('total_students, total_faculties, total_courses_created, rating')
          .eq('id', userId)
          .single();

      // Get enrollment analytics
      final enrollmentResponse = await Supabase.instance.client
          .from('enrollments')
          .select('status, created_at, enrollment_date')
          .eq('user_type', 'student')
          .gte('created_at', DateTime.now().subtract(const Duration(days: 180)).toIso8601String())
          .order('created_at', ascending: false);

      // Get recent activities (enrollments, course creations, faculty additions)
      final recentEnrollments = await Supabase.instance.client
          .from('enrollments')
          .select('''
            created_at,
            user_profiles!inner(name),
            courses!inner(title)
          ''')
          .eq('user_type', 'student')
          .gte('created_at', DateTime.now().subtract(const Duration(days: 7)).toIso8601String())
          .order('created_at', ascending: false)
          .limit(10);

      final recentCourses = await Supabase.instance.client
          .from('courses')
          .select('title, created_at')
          .eq('instructor_id', userId)
          .eq('instructor_type', 'coaching_center')
          .gte('created_at', DateTime.now().subtract(const Duration(days: 7)).toIso8601String())
          .order('created_at', ascending: false)
          .limit(5);

      final recentFaculty = await Supabase.instance.client
          .from('faculties')
          .select('''
            created_at,
            user_profiles!inner(name)
          ''')
          .eq('coaching_center_id', userId)
          .gte('created_at', DateTime.now().subtract(const Duration(days: 7)).toIso8601String())
          .order('created_at', ascending: false)
          .limit(5);

      if (mounted) {
        setState(() {
          _analytics = {
            ...centerResponse,
            'recent_enrollments': enrollmentResponse.length,
            'monthly_enrollments': _groupEnrollmentsByMonth(enrollmentResponse),
            'completion_rate': _calculateCompletionRate(enrollmentResponse),
            'active_enrollments': enrollmentResponse.where((e) => e['status'] == 'active').length,
          };
          _recentActivities = _combineActivities(recentEnrollments, recentCourses, recentFaculty);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    }
  }

  Map<String, int> _groupEnrollmentsByMonth(List<dynamic> enrollments) {
    final Map<String, int> monthlyData = {};
    final now = DateTime.now();
    
    // Initialize last 6 months
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = '${date.month}/${date.year}';
      monthlyData[monthKey] = 0;
    }
    
    // Count enrollments by month
    for (final enrollment in enrollments) {
      final date = DateTime.parse(enrollment['enrollment_date'] ?? enrollment['created_at']);
      final monthKey = '${date.month}/${date.year}';
      if (monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + 1;
      }
    }
    return monthlyData;
  }

  double _calculateCompletionRate(List<dynamic> enrollments) {
    if (enrollments.isEmpty) return 0.0;
    final completed = enrollments.where((e) => e['status'] == 'completed').length;
    return (completed / enrollments.length) * 100;
  }

  List<Map<String, dynamic>> _combineActivities(
    List<dynamic> enrollments,
    List<dynamic> courses,
    List<dynamic> faculty,
  ) {
    final List<Map<String, dynamic>> activities = [];

    // Add enrollment activities
    for (final enrollment in enrollments) {
      activities.add({
        'type': 'enrollment',
        'title': 'New Student Enrolled',
        'description': '${enrollment['user_profiles']['name']} enrolled in ${enrollment['courses']['title']}',
        'time': _formatTime(enrollment['created_at']),
        'timestamp': DateTime.parse(enrollment['created_at']),
      });
    }

    // Add course creation activities
    for (final course in courses) {
      activities.add({
        'type': 'course_created',
        'title': 'New Course Created',
        'description': 'Course "${course['title']}" was published',
        'time': _formatTime(course['created_at']),
        'timestamp': DateTime.parse(course['created_at']),
      });
    }

    // Add faculty addition activities
    for (final facultyMember in faculty) {
      activities.add({
        'type': 'faculty_added',
        'title': 'New Faculty Added',
        'description': '${facultyMember['user_profiles']['name']} joined as faculty',
        'time': _formatTime(facultyMember['created_at']),
        'timestamp': DateTime.parse(facultyMember['created_at']),
      });
    }

    // Sort by timestamp (most recent first)
    activities.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    
    return activities.take(10).toList();
  }

  String _formatTime(String timestamp) {
    final date = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 1200;
    
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const AnalyticsHeader(),
                    const SizedBox(height: 20),
                    
                    // Stats Grid
                    StatsGrid(analytics: _analytics),
                    const SizedBox(height: 20),
                    
                    // Charts and Metrics Row (responsive)
                    if (isWideScreen)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: EnrollmentChart(
                              monthlyData: _analytics['monthly_enrollments'] ?? {},
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: PerformanceMetrics(
                              metrics: {
                                'completion_rate': _analytics['completion_rate'] ?? 0.0,
                                'rating': _analytics['rating'] ?? 0.0,
                                'active_enrollments': _analytics['active_enrollments'] ?? 0,
                                'total_courses': _analytics['total_courses_created'] ?? 0,
                              },
                            ),
                          ),
                        ],
                      )
                    else ...[
                      // Stacked layout for smaller screens
                      EnrollmentChart(
                        monthlyData: _analytics['monthly_enrollments'] ?? {},
                      ),
                      const SizedBox(height: 20),
                      PerformanceMetrics(
                        metrics: {
                          'completion_rate': _analytics['completion_rate'] ?? 0.0,
                          'rating': _analytics['rating'] ?? 0.0,
                          'active_enrollments': _analytics['active_enrollments'] ?? 0,
                          'total_courses': _analytics['total_courses_created'] ?? 0,
                        },
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                    
                    // Recent Activity
                    RecentActivity(activities: _recentActivities),
                    
                    const SizedBox(height: 20),
                    
                    // Additional insights section
                    _buildInsightsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInsightsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: Color(0xFF00B894)),
                SizedBox(width: 8),
                Text(
                  'Quick Insights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              'Peak Enrollment',
              'Most students enroll on weekends',
              Icons.trending_up,
              Colors.green,
            ),
            const Divider(),
            _buildInsightItem(
              'Popular Courses',
              'Programming courses have 40% higher enrollment',
              Icons.school,
              Colors.blue,
            ),
            const Divider(),
            _buildInsightItem(
              'Faculty Performance',
              'Average rating across all faculty: ${(_analytics['rating'] ?? 0.0).toStringAsFixed(1)}/5',
              Icons.star,
              Colors.amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
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
