// screens/student/live_classes/enrolled_live_classes_page.dart
import 'package:brainboosters_app/ui/navigation/app_router.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:brainboosters_app/screens/student/dashboard/widgets/enrolled_live_class_list.dart';

class EnrolledLiveClassesPage extends StatefulWidget {
  const EnrolledLiveClassesPage({super.key});

  @override
  State<EnrolledLiveClassesPage> createState() =>
      _EnrolledLiveClassesPageState();
}

class _EnrolledLiveClassesPageState extends State<EnrolledLiveClassesPage> {
  List<Map<String, dynamic>> _enrolledLiveClasses = [];
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _fetchEnrolledLiveClasses();
  }

  Future<void> _fetchEnrolledLiveClasses() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Please log in to view enrolled live classes';
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

      // Get enrolled live classes
      final response = await Supabase.instance.client
          .from('live_class_enrollments')
          .select('''
            *,
            live_classes(
              id,
              title,
              description,
              scheduled_at,
              duration_minutes,
              status,
              max_participants,
              current_participants,
              price,
              is_free,
              thumbnail_url,
              coaching_centers(
                center_name,
                logo_url
              ),
              teachers(
                user_profiles(
                  first_name,
                  last_name
                )
              )
            )
          ''')
          .eq('student_id', studentId)
          .order('enrolled_at', ascending: false);

      if (mounted) {
        setState(() {
          _enrolledLiveClasses = List<Map<String, dynamic>>.from(response);
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching enrolled live classes: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load enrolled live classes: ${e.toString()}';
          _loading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredLiveClasses {
    return _enrolledLiveClasses.where((enrollment) {
      final liveClass = enrollment['live_classes'];
      if (liveClass == null) return false;

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final title = liveClass['title']?.toString().toLowerCase() ?? '';
        final centerName =
            liveClass['coaching_centers']?['center_name']
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
        final status = liveClass['status']?.toString() ?? '';
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
          'My Live Classes',
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
                    hintText: 'Search live classes...',
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
                          _buildFilterChip('Upcoming', 'scheduled'),
                          _buildFilterChip('Live', 'live'),
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
                : _filteredLiveClasses.isEmpty
                ? _buildEmptyState()
                : _buildLiveClassesList(),
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
            Text('Loading your live classes...'),
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
              onPressed: _fetchEnrolledLiveClasses,
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
            Icon(Icons.live_tv_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              _searchQuery.isNotEmpty || _filterStatus != 'all'
                  ? 'No live classes found'
                  : 'No enrolled live classes yet',
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
                  : 'Start learning by enrolling in live classes',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(CommonRoutes.liveClassesRoute),
              icon: const Icon(Icons.explore),
              label: const Text('Explore Live Classes'),
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

  Widget _buildLiveClassesList() {
    return RefreshIndicator(
      onRefresh: _fetchEnrolledLiveClasses,
      color: const Color(0xFF4AA0E6),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_filteredLiveClasses.length} Live Class${_filteredLiveClasses.length != 1 ? 'es' : ''} Enrolled',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            // Use your existing EnrolledLiveClassList component
            EnrolledLiveClassList(
              liveClasses: _filteredLiveClasses,
              loading: false,
            ),
          ],
        ),
      ),
    );
  }
}
