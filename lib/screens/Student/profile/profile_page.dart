import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stats_grid.dart';
import 'widgets/analytics_section.dart';
import 'widgets/reports_section.dart';
import '../../../ui/navigation/student_routes/student_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _studentData;
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? _analyticsData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Load profile data
      final profileResponse = await Supabase.instance.client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();

      // Load student data
      final studentResponse = await Supabase.instance.client
          .from('students')
          .select('''
            *,
            course_enrollments!inner(
              id,
              course_id,
              progress_percentage,
              enrolled_at,
              completed_at,
              courses(title, thumbnail_url)
            )
          ''')
          .eq('user_id', user.id)
          .single();

      // Load analytics summary
      final analyticsResponse = await Supabase.instance.client
          .from('learning_analytics')
          .select('''
            date,
            time_spent_minutes,
            lessons_completed,
            quizzes_attempted,
            quizzes_passed,
            average_quiz_score,
            points_earned
          ''')
          .eq('student_id', studentResponse['id'])
          .gte(
            'date',
            DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
          )
          .order('date', ascending: false);

      setState(() {
        _profileData = profileResponse;
        _studentData = studentResponse;
        _analyticsData = {
          'recent_activity': analyticsResponse,
          'total_courses': studentResponse['total_courses_enrolled'] ?? 0,
          'completed_courses': studentResponse['total_courses_completed'] ?? 0,
          'total_hours': studentResponse['total_hours_learned'] ?? 0.0,
          'current_streak': studentResponse['current_streak_days'] ?? 0,
          'total_points': studentResponse['total_points'] ?? 0,
          'level': studentResponse['level'] ?? 1,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFD),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $_error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProfileData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          expandedHeight: 280,
          floating: false,
          pinned: true,
          backgroundColor: const Color(0xFF5DADE2),
          flexibleSpace: FlexibleSpaceBar(
            background: ProfileHeader(
              profileData: _profileData!,
              studentData: _studentData!,
              onEditPressed: () => context.push('/profile/edit'),
              onSettingsPressed: () => context.push(StudentRoutes.settings),
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Analytics'),
              Tab(text: 'Reports'),
            ],
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildAnalyticsTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ProfileStatsGrid(
            analyticsData: _analyticsData!,
            studentData: _studentData!,
          ),
          const SizedBox(height: 24),
          _buildRecentActivity(),
          const SizedBox(height: 24),
          _buildEnrolledCourses(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return AnalyticsSection(
      studentId: _studentData!['id'],
      analyticsData: _analyticsData!,
    );
  }

  Widget _buildReportsTab() {
    return ReportsSection(
      studentId: _studentData!['id'],
      studentData: _studentData!,
      profileData: _profileData!,
    );
  }

  Widget _buildRecentActivity() {
    final recentActivity = _analyticsData!['recent_activity'] as List;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (recentActivity.isEmpty)
              const Center(child: Text('No recent activity'))
            else
              ...recentActivity
                  .take(5)
                  .map(
                    (activity) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF5DADE2),
                        child: Text(
                          '${activity['lessons_completed'] ?? 0}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        '${activity['time_spent_minutes']} minutes studied',
                      ),
                      subtitle: Text(
                        DateTime.parse(
                          activity['date'],
                        ).toString().split(' ')[0],
                      ),
                      trailing: Text(
                        '${activity['points_earned']} pts',
                        style: const TextStyle(
                          color: Color(0xFFD4845C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrolledCourses() {
    final enrollments = _studentData!['course_enrollments'] as List;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Enrolled Courses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.push(StudentRoutes.enrolledCourses),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (enrollments.isEmpty)
              const Center(child: Text('No courses enrolled'))
            else
              ...enrollments
                  .take(3)
                  .map(
                    (enrollment) => ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          enrollment['courses']['thumbnail_url'] ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[300],
                                child: const Icon(Icons.book),
                              ),
                        ),
                      ),
                      title: Text(enrollment['courses']['title']),
                      subtitle: LinearProgressIndicator(
                        value: (enrollment['progress_percentage'] ?? 0) / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF5DADE2),
                        ),
                      ),
                      trailing: Text(
                        '${enrollment['progress_percentage']?.toInt() ?? 0}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
