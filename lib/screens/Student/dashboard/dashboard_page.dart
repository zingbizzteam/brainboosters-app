import 'package:brainboosters_app/screens/student/dashboard/widgets/enrolled_live_class_list.dart';
import 'package:brainboosters_app/screens/common/live_class/widgets/live_class_card.dart';
import 'package:brainboosters_app/screens/common/courses/widgets/course_card.dart';
import 'package:brainboosters_app/screens/student/dashboard/widgets/dashboard_top_bar.dart';
import 'package:brainboosters_app/screens/student/dashboard/widgets/enrolled_course_list.dart';
import 'package:brainboosters_app/screens/student/dashboard/widgets/stat_card.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_skeleton.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _studentStats;
  List<Map<String, dynamic>> _enrolledCourses = [];
  List<Map<String, dynamic>> _liveClasses = [];
  List<Map<String, dynamic>> _suggestedCourses = [];
  List<Map<String, dynamic>> _suggestedLiveClasses = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // FIXED: Simplified refresh method that shows skeleton
  Future<void> _refreshDashboard() async {
    // Clear error state and show skeleton during refresh
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _fetchDashboardData();
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to refresh dashboard: $e';
        });
        
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _refreshDashboard,
            ),
          ),
        );
      }
    }
  }

  // SIMPLIFIED: Removed isRefresh parameter - always show skeleton when loading
  Future<void> _fetchDashboardData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() {
            _loading = false;
            _error = 'User not authenticated';
          });
        }
        return;
      }

      final studentRes = await Supabase.instance.client
          .from('students')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (studentRes == null) {
        // Not enrolled, show suggestions only (only ongoing/upcoming)
        final allCourses = await Supabase.instance.client
            .from('courses')
            .select('''
              id,
              title,
              thumbnail_url,
              category,
              level,
              price,
              original_price,
              is_published,
              rating,
              total_lessons,
              duration_hours,
              enrollment_count,
              total_reviews,
              coaching_centers(center_name)
            ''')
            .eq('is_published', true)
            .order('enrollment_count', ascending: false)
            .limit(5);

        final allLive = await Supabase.instance.client
            .from('live_classes')
            .select('''
              id,
              title,
              description,
              scheduled_at,
              status,
              price,
              thumbnail_url,
              duration_minutes,
              teachers(
                user_id,
                user_profiles(first_name, last_name)
              ),
              coaching_centers(center_name)
            ''')
            .inFilter('status', ['scheduled', 'live'])
            .order('scheduled_at', ascending: true)
            .limit(5);

        if (mounted) {
          setState(() {
            _studentStats = null;
            _enrolledCourses = [];
            _liveClasses = [];
            _suggestedCourses = List<Map<String, dynamic>>.from(allCourses??[]);
            _suggestedLiveClasses = List<Map<String, dynamic>>.from(allLive);
            _loading = false;
            _error = null;
          });
        }
        return;
      }

      final studentId = studentRes['id'];

      // Enrolled courses - FIXED QUERY
      final coursesRes = await Supabase.instance.client
          .from('course_enrollments')
          .select('''
            course_id,
            progress_percentage,
            total_time_spent,
            lessons_completed,
            total_lessons_in_course,
            last_accessed_at,
            enrolled_at,
            courses(
              id,
              title,
              thumbnail_url,
              category,
              level,
              price,
              original_price,
              total_lessons,
              duration_hours,
              rating,
              enrollment_count,
              total_reviews,
              coaching_centers(center_name)
            )
          ''')
          .eq('student_id', studentId)
          .eq('is_active', true);

      // Enrolled live classes (only ongoing/upcoming)
      final liveRes = await Supabase.instance.client
          .from('live_class_enrollments')
          .select('''
            live_class_id,
            attended,
            attendance_duration,
            rating,
            feedback,
            live_classes(
              id,
              title,
              description,
              scheduled_at,
              status,
              price,
              thumbnail_url,
              duration_minutes,
              teachers(
                user_id,
                user_profiles(first_name, last_name)
              ),
              coaching_centers(center_name)
            )
          ''')
          .eq('student_id', studentId)
          .inFilter('live_classes.status', ['scheduled', 'live']);

      final enrolledCourseIds = (coursesRes )
          .map((e) => e['course_id'])
          .toSet();

      final enrolledLiveIds = (liveRes )
          .map((e) => e['live_class_id'])
          .toSet();

      // SUGGESTED COURSES LOGIC - FIXED QUERIES
      List<Map<String, dynamic>> suggestedCourses = [];
      final goals = List.from(studentRes['learning_goals'] );

      if (goals.isNotEmpty) {
        final goalCourses = await Supabase.instance.client
            .from('courses')
            .select('''
              id,
              title,
              thumbnail_url,
              category,
              level,
              price,
              original_price,
              is_published,
              rating,
              total_lessons,
              duration_hours,
              enrollment_count,
              total_reviews,
              coaching_centers(center_name)
            ''')
            .contains('tags', goals)
            .eq('is_published', true)
            .order('enrollment_count', ascending: false)
            .limit(15);

        suggestedCourses = List<Map<String, dynamic>>.from(goalCourses );
      }

      suggestedCourses = suggestedCourses
          .where((c) => !enrolledCourseIds.contains(c['id']))
          .take(5)
          .toList();

      if (suggestedCourses.length < 5) {
        final excludeIds = {
          ...enrolledCourseIds,
          ...suggestedCourses.map((c) => c['id']),
        };

        final fillCourses = await Supabase.instance.client
            .from('courses')
            .select('''
              id,
              title,
              thumbnail_url,
              category,
              level,
              price,
              original_price,
              is_published,
              rating,
              total_lessons,
              duration_hours,
              enrollment_count,
              total_reviews,
              coaching_centers(center_name)
            ''')
            .eq('is_published', true)
            .order('enrollment_count', ascending: false)
            .limit(15);

        final fillList = List<Map<String, dynamic>>.from(fillCourses )
            .where((c) => !excludeIds.contains(c['id']))
            .take(5 - suggestedCourses.length)
            .toList();

        suggestedCourses.addAll(fillList);
      }

      // SUGGESTED LIVE CLASSES LOGIC (only ongoing/upcoming)
      List<Map<String, dynamic>> suggestedLive = [];
      if (goals.isNotEmpty) {
        final goalLive = await Supabase.instance.client
            .from('live_classes')
            .select('''
              id,
              title,
              description,
              scheduled_at,
              status,
              price,
              thumbnail_url,
              course_id,
              duration_minutes,
              teachers(
                user_id,
                user_profiles(first_name, last_name)
              ),
              coaching_centers(center_name)
            ''')
            .inFilter('status', ['scheduled', 'live'])
            .order('scheduled_at', ascending: true)
            .limit(15);

        suggestedLive = List<Map<String, dynamic>>.from(goalLive ).where((l) {
          if (l['course_id'] != null) return true;
          return goals.any(
            (g) => (l['title'] ?? '').toString().toLowerCase().contains(
                  g.toLowerCase(),
                ),
          );
        }).toList();
      }

      suggestedLive = suggestedLive
          .where((l) => !enrolledLiveIds.contains(l['id']))
          .take(5)
          .toList();

      if (suggestedLive.length < 5) {
        final excludeIds = {
          ...enrolledLiveIds,
          ...suggestedLive.map((l) => l['id']),
        };

        final fillLive = await Supabase.instance.client
            .from('live_classes')
            .select('''
              id,
              title,
              description,
              scheduled_at,
              status,
              price,
              thumbnail_url,
              duration_minutes,
              teachers(
                user_id,
                user_profiles(first_name, last_name)
              ),
              coaching_centers(center_name)
            ''')
            .inFilter('status', ['scheduled', 'live'])
            .order('scheduled_at', ascending: true)
            .limit(15);

        final fillList = List<Map<String, dynamic>>.from(fillLive )
            .where((l) => !excludeIds.contains(l['id']))
            .take(5 - suggestedLive.length)
            .toList();

        suggestedLive.addAll(fillList);
      }

      if (mounted) {
        setState(() {
          _studentStats = studentRes;
          _enrolledCourses = List<Map<String, dynamic>>.from(coursesRes );
          _liveClasses = List<Map<String, dynamic>>.from(liveRes );
          _suggestedCourses = suggestedCourses;
          _suggestedLiveClasses = suggestedLive;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to load dashboard: $e';
        });
      }
      rethrow; // Re-throw for refresh error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    // Only show ongoing/upcoming live classes
    final filteredLiveClasses = _liveClasses.where((lc) {
      final status = lc['live_classes']?['status']?.toLowerCase();
      return status == 'scheduled' || status == 'live';
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFD),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return RefreshIndicator(
                    onRefresh: _refreshDashboard,
                    color: const Color(0xFF4AA0E6),
                    backgroundColor: Colors.white,
                    strokeWidth: 2.5,
                    displacement: 40.0,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 32 : 8,
                        vertical: isWide ? 24 : 8,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const DashboardTopBar(),
                            SizedBox(height: isWide ? 32 : 20),

                            // FIXED: Show error state with retry option (only when not loading)
                            if (_error != null && !_loading)
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red[600],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style: TextStyle(
                                          color: Colors.red[700],
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _refreshDashboard,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),

                            // FIXED: Show skeleton during both initial load AND refresh
                            if (_loading)
                              const DashboardSkeleton()
                            else ...[
                              // Stats
                              if (_studentStats != null)
                                isWide
                                    ? Row(
                                        children: [
                                          Flexible(
                                            child: DashboardStatCard(
                                              title: "Learning Streak",
                                              subtitle: "Watch 5 mins a day to obtain a streak.",
                                              icon: Icons.local_fire_department,
                                              iconColor: Colors.blue,
                                              stats: [
                                                StatItem(
                                                  "${_studentStats?['current_streak_days'] ?? 0}",
                                                  "Current",
                                                ),
                                                StatItem(
                                                  "${_studentStats?['longest_streak_days'] ?? 0}",
                                                  "Longest",
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Flexible(
                                            child: DashboardStatCard(
                                              title: "",
                                              subtitle: "Total Watch Hours",
                                              icon: Icons.play_circle_fill,
                                              iconColor: Colors.blue,
                                              stats: [
                                                StatItem(
                                                  "${_studentStats?['total_hours_learned'] ?? 0}",
                                                  "",
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Flexible(
                                            child: DashboardStatCard(
                                              title: "",
                                              subtitle: "Courses Enrolled",
                                              icon: Icons.bar_chart,
                                              iconColor: Colors.blue,
                                              stats: [
                                                StatItem(
                                                  "${_studentStats?['total_courses_enrolled'] ?? 0}",
                                                  "",
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          DashboardStatCard(
                                            title: "Learning Streak",
                                            subtitle: "Watch 5 mins a day to obtain a streak.",
                                            icon: Icons.local_fire_department,
                                            iconColor: Colors.blue,
                                            stats: [
                                              StatItem(
                                                "${_studentStats?['current_streak_days'] ?? 0}",
                                                "Current",
                                              ),
                                              StatItem(
                                                "${_studentStats?['longest_streak_days'] ?? 0}",
                                                "Longest",
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: DashboardStatCard(
                                                  title: "",
                                                  subtitle: "Total Watch Hours",
                                                  icon: Icons.play_circle_fill,
                                                  iconColor: Colors.blue,
                                                  stats: [
                                                    StatItem(
                                                      "${_studentStats?['total_hours_learned'] ?? 0}",
                                                      "",
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: DashboardStatCard(
                                                  title: "",
                                                  subtitle: "Courses Enrolled",
                                                  icon: Icons.bar_chart,
                                                  iconColor: Colors.blue,
                                                  stats: [
                                                    StatItem(
                                                      "${_studentStats?['total_courses_enrolled'] ?? 0}",
                                                      "",
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                              SizedBox(height: isWide ? 32 : 20),

                              if (_enrolledCourses.isNotEmpty) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Enrolled Courses",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => context.go('/courses'),
                                      child: const Text('See all'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                EnrolledCourseList(
                                  enrolledCourses: _enrolledCourses,
                                  loading: _loading,
                                ),
                                SizedBox(height: isWide ? 24 : 16),
                              ],

                              // Enrolled Live Classes (only ongoing/upcoming)
                              if (filteredLiveClasses.isNotEmpty) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Enrolled Live Classes",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => context.go('/live-classes'),
                                      child: const Text('See all'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                EnrolledLiveClassList(
                                  liveClasses: filteredLiveClasses,
                                  loading: _loading,
                                ),
                                SizedBox(height: isWide ? 24 : 16),
                              ],

                              // Suggested Live Classes (horizontal scroll)
                              if (_suggestedLiveClasses.isNotEmpty) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Suggested Live Classes",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => context.go('/live-classes'),
                                      child: const Text('See all'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 200,
                                    maxHeight: 300,
                                  ),
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _suggestedLiveClasses.length,
                                    itemBuilder: (context, idx) {
                                      final liveClass = _suggestedLiveClasses[idx];
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          left: idx == 0 ? 0 : 8,
                                          right: 8,
                                        ),
                                        child: LiveClassCard(
                                          liveClass: liveClass,
                                          onTap: () => context.go(
                                            CommonRoutes.getLiveClassDetailRoute(
                                              liveClass['id'],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: isWide ? 24 : 16),
                              ],

                              // Suggested Courses (horizontal scroll)
                              if (_suggestedCourses.isNotEmpty) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Recommended Courses",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => context.go('/courses'),
                                      child: const Text('See all'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 200,
                                    maxHeight: 300,
                                  ),
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _suggestedCourses.length,
                                    itemBuilder: (context, idx) {
                                      final course = _suggestedCourses[idx];
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          left: idx == 0 ? 0 : 8,
                                          right: 8,
                                        ),
                                        child: CourseCard(
                                          course: course,
                                          onTap: () {
                                            final courseSlug = course['id']?.toString();
                                            if (courseSlug != null && courseSlug.isNotEmpty) {
                                              context.go('/course/$courseSlug');
                                            }
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
