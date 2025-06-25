// screens/coaching_center/courses/coaching_center_courses_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/courses_header.dart';
import 'widgets/course_card.dart';
import 'widgets/course_stats.dart';
import 'widgets/course_filter.dart';
import 'course_details_page.dart';
import 'create_course_page.dart';
import 'edit_course_page.dart';

class CoachingCenterCoursesPage extends StatefulWidget {
  const CoachingCenterCoursesPage({super.key});

  @override
  State<CoachingCenterCoursesPage> createState() => _CoachingCenterCoursesPageState();
}

class _CoachingCenterCoursesPageState extends State<CoachingCenterCoursesPage> {
  List<Map<String, dynamic>> _courses = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _selectedCategory = 'all';
  String _selectedLevel = 'all';
  String _selectedSort = 'newest';

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('courses')
          .select('''
            *,
            course_analytics(enrolled_count, completed_count, view_count)
          ''')
          .eq('instructor_id', userId)
          .eq('instructor_type', 'coaching_center')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _courses = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
        _loadStats();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading courses: $e')),
        );
      }
    }
  }

  Future<void> _loadStats() async {
    try {
      final totalCourses = _courses.length;
      final publishedCourses = _courses.where((c) => c['is_published'] == true).length;
      final draftCourses = totalCourses - publishedCourses;
      final totalRevenue = _courses.fold<double>(0, (sum, course) => sum + (course['price'] ?? 0.0));
      final totalEnrollments = _courses.fold<int>(0, (sum, course) => sum + ((course['current_enrollments'] ?? 0) as int));

      setState(() {
        _stats = {
          'total_courses': totalCourses,
          'published_courses': publishedCourses,
          'draft_courses': draftCourses,
          'total_revenue': totalRevenue,
          'total_enrollments': totalEnrollments,
        };
      });
    } catch (e) {
      // Handle error silently for stats
    }
  }

  List<Map<String, dynamic>> get _filteredCourses {
    var filtered = _courses;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((course) {
        final title = course['title']?.toLowerCase() ?? '';
        final category = course['category']?.toLowerCase() ?? '';
        final description = course['description']?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return title.contains(query) ||
            category.contains(query) ||
            description.contains(query);
      }).toList();
    }

    // Status filter
    if (_selectedStatus != 'all') {
      final isPublished = _selectedStatus == 'published';
      filtered = filtered.where((course) => course['is_published'] == isPublished).toList();
    }

    // Category filter
    if (_selectedCategory != 'all') {
      filtered = filtered.where((course) => course['category'] == _selectedCategory).toList();
    }

    // Level filter
    if (_selectedLevel != 'all') {
      filtered = filtered.where((course) => course['level'] == _selectedLevel).toList();
    }

    // Sort
    switch (_selectedSort) {
      case 'oldest':
        filtered.sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
        break;
      case 'popular':
        filtered.sort((a, b) => (b['current_enrollments'] ?? 0).compareTo(a['current_enrollments'] ?? 0));
        break;
      case 'rating':
        filtered.sort((a, b) => (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0));
        break;
      case 'price_low':
        filtered.sort((a, b) => (a['price'] ?? 0.0).compareTo(b['price'] ?? 0.0));
        break;
      case 'price_high':
        filtered.sort((a, b) => (b['price'] ?? 0.0).compareTo(a['price'] ?? 0.0));
        break;
      default: // newest
        filtered.sort((a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CoursesHeader(
            coursesCount: _filteredCourses.length,
            onSearchChanged: (query) => setState(() => _searchQuery = query),
            selectedStatus: _selectedStatus,
            onStatusChanged: (status) => setState(() => _selectedStatus = status),
            onCourseCreated: _loadCourses,
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadCourses,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: EdgeInsets.all(constraints.maxWidth > 600 ? 16 : 8),
                          child: Column(
                            children: [
                              // Stats
                              CourseStats(stats: _stats),
                              SizedBox(height: constraints.maxWidth > 600 ? 16 : 8),
                              
                              // Filters
                              CourseFilter(
                                selectedCategory: _selectedCategory,
                                selectedLevel: _selectedLevel,
                                selectedSort: _selectedSort,
                                onCategoryChanged: (category) => setState(() => _selectedCategory = category),
                                onLevelChanged: (level) => setState(() => _selectedLevel = level),
                                onSortChanged: (sort) => setState(() => _selectedSort = sort),
                                onClearFilters: () => setState(() {
                                  _selectedCategory = 'all';
                                  _selectedLevel = 'all';
                                  _selectedSort = 'newest';
                                  _selectedStatus = 'all';
                                  _searchQuery = '';
                                }),
                              ),
                              SizedBox(height: constraints.maxWidth > 600 ? 16 : 8),
                              
                              // Courses Grid
                              if (_filteredCourses.isEmpty)
                                _buildEmptyState(constraints)
                              else
                                _buildCoursesGrid(constraints),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesGrid(BoxConstraints constraints) {
    // Responsive grid columns
    int crossAxisCount;
    double childAspectRatio;
    
    if (constraints.maxWidth > 1200) {
      crossAxisCount = 4;
      childAspectRatio = 0.75;
    } else if (constraints.maxWidth > 800) {
      crossAxisCount = 3;
      childAspectRatio = 0.8;
    } else if (constraints.maxWidth > 600) {
      crossAxisCount = 2;
      childAspectRatio = 0.85;
    } else {
      crossAxisCount = 1;
      childAspectRatio = 1.2;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: constraints.maxWidth > 600 ? 16 : 8,
        crossAxisSpacing: constraints.maxWidth > 600 ? 16 : 8,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: _filteredCourses.length,
      itemBuilder: (context, index) {
        final course = _filteredCourses[index];
        return CourseCard(
          course: course,
          onTap: () => _viewCourse(course),
          onEdit: () => _editCourse(course),
          onToggleStatus: () => _toggleCourseStatus(course),
        );
      },
    );
  }

  Widget _buildEmptyState(BoxConstraints constraints) {
    return Container(
      constraints: BoxConstraints(
        minHeight: constraints.maxHeight * 0.5,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined, 
              size: constraints.maxWidth > 600 ? 64 : 48, 
              color: Colors.grey
            ),
            SizedBox(height: constraints.maxWidth > 600 ? 16 : 12),
            Text(
              _searchQuery.isNotEmpty ? 'No courses match your search' : 'No courses found',
              style: TextStyle(
                fontSize: constraints.maxWidth > 600 ? 18 : 16, 
                color: Colors.grey
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: constraints.maxWidth > 600 ? 8 : 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _searchQuery.isNotEmpty 
                    ? 'Try adjusting your search or filters'
                    : 'Create your first course to get started',
                style: TextStyle(
                  fontSize: constraints.maxWidth > 600 ? 14 : 12, 
                  color: Colors.grey
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: constraints.maxWidth > 600 ? 16 : 12),
            ElevatedButton.icon(
              onPressed: () => _navigateToCreateCourse(),
              icon: const Icon(Icons.add),
              label: const Text('Create Course'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B894),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth > 600 ? 24 : 16,
                  vertical: constraints.maxWidth > 600 ? 12 : 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewCourse(Map<String, dynamic> course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsPage(courseId: course['id']),
      ),
    );
  }

  void _editCourse(Map<String, dynamic> course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCoursePage(course: course),
      ),
    ).then((_) {
      _loadCourses();
    });
  }

  void _navigateToCreateCourse() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateCoursePage(),
      ),
    ).then((_) {
      _loadCourses();
    });
  }

  Future<void> _toggleCourseStatus(Map<String, dynamic> course) async {
    try {
      final newStatus = !(course['is_published'] ?? false);
      
      if (newStatus) {
        final confirmed = await _showPublishConfirmation(course);
        if (!confirmed) return;
      }

      await Supabase.instance.client
          .from('courses')
          .update({
            'is_published': newStatus,
            'published_at': newStatus ? DateTime.now().toIso8601String() : null,
          })
          .eq('id', course['id']);
      
      _loadCourses();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Course ${newStatus ? 'published' : 'unpublished'} successfully'),
            backgroundColor: newStatus ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating course: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showPublishConfirmation(Map<String, dynamic> course) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publish Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to publish "${course['title']}"?'),
              const SizedBox(height: 16),
              const Text(
                'Once published, the course will be visible to students and they can enroll.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B894),
              foregroundColor: Colors.white,
            ),
            child: const Text('Publish'),
          ),
        ],
      ),
    ) ?? false;
  }
}
