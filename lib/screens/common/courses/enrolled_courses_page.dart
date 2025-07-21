// screens/student/courses/enrolled_courses_page.dart
import 'package:brainboosters_app/ui/navigation/app_router.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:brainboosters_app/screens/student/dashboard/widgets/enrolled_course_list.dart';

class EnrolledCoursesPage extends StatefulWidget {
  const EnrolledCoursesPage({super.key});

  @override
  State<EnrolledCoursesPage> createState() => _EnrolledCoursesPageState();
}

class _EnrolledCoursesPageState extends State<EnrolledCoursesPage> {
  List<Map<String, dynamic>> _enrolledCourses = [];
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _fetchEnrolledCourses();
  }

  Future<void> _fetchEnrolledCourses() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Please log in to view enrolled courses';
          _loading = false;
        });
        return;
      }

      // First get student ID
      final studentResponse = await Supabase.instance.client
          .from('students')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (studentResponse == null) {
        setState(() {
          _error = 'Student profile not found';
          _loading = false;
        });
        return;
      }

      final studentId = studentResponse['id'];

      // Get enrolled courses with proper joins
      final response = await Supabase.instance.client
          .from('course_enrollments')
          .select('''
            *,
            courses(
              id,
              title,
              thumbnail_url,
              category,
              level,
              price,
              original_price,
              rating,
              total_reviews,
              total_lessons,
              duration_hours,
              enrollment_count,
              coaching_centers(
                center_name,
                logo_url
              )
            )
          ''')
          .eq('student_id', studentId)
          .eq('is_active', true)
          .order('enrolled_at', ascending: false);

      if (mounted) {
        setState(() {
          _enrolledCourses = List<Map<String, dynamic>>.from(response);
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching enrolled courses: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load enrolled courses: ${e.toString()}';
          _loading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredCourses {
    return _enrolledCourses.where((enrollment) {
      final course = enrollment['courses'];
      if (course == null) return false;

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final title = course['title']?.toString().toLowerCase() ?? '';
        final centerName =
            course['coaching_centers']?['center_name']
                ?.toString()
                .toLowerCase() ??
            '';
        if (!title.contains(_searchQuery.toLowerCase()) &&
            !centerName.contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

      // Status filter
      if (_filterStatus != 'all') {
        final status =
            enrollment['completion_status']?.toString() ?? 'in_progress';
        if (_filterStatus != status) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFD),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouter.home);
            }
          },
        ),
        title: const Text(
          'My Courses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Chips
                Row(
                  children: [
                    const Text(
                      'Filter: ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: [
                          _buildFilterChip('All', 'all'),
                          _buildFilterChip('In Progress', 'in_progress'),
                          _buildFilterChip('Completed', 'completed'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _loading
                ? _buildLoadingState()
                : _error != null
                ? _buildErrorState()
                : _filteredCourses.isEmpty
                ? _buildEmptyState()
                : _buildCoursesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterStatus = value);
      },
      selectedColor: const Color(0xFF4AA0E6).withValues(alpha: 0.2),
      checkmarkColor: const Color(0xFF4AA0E6),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF4AA0E6)),
            SizedBox(height: 16),
            Text('Loading your courses...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchEnrolledCourses,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4AA0E6),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              _searchQuery.isNotEmpty || _filterStatus != 'all'
                  ? 'No courses found'
                  : 'No enrolled courses yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _filterStatus != 'all'
                  ? 'Try adjusting your search or filters'
                  : 'Start learning by enrolling in courses',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(CommonRoutes.coursesRoute),
              icon: const Icon(Icons.explore),
              label: const Text('Explore Courses'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4AA0E6),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList() {
    return RefreshIndicator(
      onRefresh: _fetchEnrolledCourses,
      color: const Color(0xFF4AA0E6),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_filteredCourses.length} Course${_filteredCourses.length != 1 ? 's' : ''} Enrolled',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            // Use your existing EnrolledCourseList component
            EnrolledCourseList(
              enrolledCourses: _filteredCourses,
              loading: false,
            ),
          ],
        ),
      ),
    );
  }
}
