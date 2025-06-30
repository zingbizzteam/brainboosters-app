// screens/coaching_center/courses/course_details_page.dart
import 'package:brainboosters_app/screens/coaching_center/courses/course_details/widgets/video_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../edit_course/edit_course_page.dart'; // Import the edit course page

class CourseDetailsPage extends StatefulWidget {
  final String courseId;

  const CourseDetailsPage({super.key, required this.courseId});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  Map<String, dynamic>? _course;
  List<Map<String, dynamic>> _enrollments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourseDetails();
  }

  Future<void> _loadCourseDetails() async {
    try {
      // Load course details
      final courseResponse = await Supabase.instance.client
          .from('courses')
          .select('*')
          .eq('id', widget.courseId)
          .single();

      // Load enrollments
      final enrollmentsResponse = await Supabase.instance.client
          .from('enrollments')
          .select('''
            *,
            user_profiles!inner(name, email, avatar_url)
          ''')
          .eq('course_id', widget.courseId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _course = courseResponse;
          _enrollments = List<Map<String, dynamic>>.from(enrollmentsResponse);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading course details: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_course == null) {
      return const Scaffold(body: Center(child: Text('Course not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _course!['title'] ?? 'Course Details',
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: const Color(0xFF00B894),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditCourse(), // Fixed navigation
          ),
          PopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case 'content':
                  _navigateToContentManagement();
                  break;
                case 'faculty':
                  _navigateToAssignFaculty();
                  break;
                case 'analytics':
                  _navigateToCourseAnalytics();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'content',
                child: Row(
                  children: [
                    Icon(Icons.video_library, color: Color(0xFF00B894)),
                    SizedBox(width: 8),
                    Text('Manage Content'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'faculty',
                child: Row(
                  children: [
                    Icon(Icons.people, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Assign Faculty'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'analytics',
                child: Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.purple),
                    SizedBox(width: 8),
                    Text('Course Analytics'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: _loadCourseDetails,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(constraints.maxWidth > 600 ? 16 : 8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCourseHeader(constraints),
                      SizedBox(height: constraints.maxWidth > 600 ? 24 : 16),
                      _buildActionButtons(constraints), // Added action buttons
                      SizedBox(height: constraints.maxWidth > 600 ? 24 : 16),
                      _buildCourseStats(constraints),
                      SizedBox(height: constraints.maxWidth > 600 ? 24 : 16),
                      _buildEnrollmentsList(constraints),
                      SizedBox(height: constraints.maxWidth > 600 ? 32 : 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(BoxConstraints constraints) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(constraints.maxWidth > 600 ? 16 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: constraints.maxWidth > 600 ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: constraints.maxWidth > 600 ? 16 : 12),
            if (constraints.maxWidth > 600)
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Edit Course',
                      Icons.edit,
                      _navigateToEditCourse,
                      const Color(0xFF00B894),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      'Manage Content',
                      Icons.video_library,
                      _navigateToContentManagement,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      'Assign Faculty',
                      Icons.people,
                      _navigateToAssignFaculty,
                      Colors.purple,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildActionButton(
                    'Edit Course',
                    Icons.edit,
                    _navigateToEditCourse,
                    const Color(0xFF00B894),
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    'Manage Content',
                    Icons.video_library,
                    _navigateToContentManagement,
                    Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    'Assign Faculty',
                    Icons.people,
                    _navigateToAssignFaculty,
                    Colors.purple,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    VoidCallback onPressed,
    Color color,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Rest of your existing build methods remain the same...
  Widget _buildCourseHeader(BoxConstraints constraints) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(constraints.maxWidth > 600 ? 20 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image and Video Section
            if (_course!['course_image_url'] != null ||
                _course!['intro_video_url'] != null) ...[
              Container(
                height: constraints.maxWidth > 600 ? 250 : 200,
                width: double.infinity,
                child: _course!['intro_video_url'] != null
                    ? MediaKitVideoPlayer(url: _course!['intro_video_url'])
                    : _course!['course_image_url'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _course!['course_image_url'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No course image',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              SizedBox(height: constraints.maxWidth > 600 ? 16 : 12),
            ],

            // Title and Status Row
            Row(
              children: [
                Expanded(
                  child: Text(
                    _course!['title'] ?? 'Untitled Course',
                    style: TextStyle(
                      fontSize: constraints.maxWidth > 600 ? 24 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _course!['is_published']
                        ? Colors.green
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _course!['is_published'] ? 'PUBLISHED' : 'DRAFT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: constraints.maxWidth > 600 ? 12 : 10,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: constraints.maxWidth > 600 ? 12 : 8),

            // Description
            Text(
              _course!['description'] ?? 'No description available',
              style: TextStyle(
                fontSize: constraints.maxWidth > 600 ? 16 : 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: constraints.maxWidth > 600 ? 16 : 12),

            // Info Chips
            _buildInfoChips(constraints),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChips(BoxConstraints constraints) {
    final chipData = [
      {
        'label': 'Category',
        'value': _course!['category']?.toUpperCase() ?? 'N/A',
      },
      {'label': 'Level', 'value': _course!['level']?.toUpperCase() ?? 'N/A'},
      {'label': 'Duration', 'value': '${_course!['duration_hours'] ?? 0} hrs'},
      {'label': 'Price', 'value': '₹${_course!['price'] ?? 0}'},
    ];

    // Responsive layout for info chips
    if (constraints.maxWidth > 800) {
      // Wide screen: All in one row
      return Row(
        children: chipData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < chipData.length - 1 ? 8 : 0,
              ),
              child: _buildInfoChip(
                data['label']!,
                data['value']!,
                constraints,
              ),
            ),
          );
        }).toList(),
      );
    } else if (constraints.maxWidth > 600) {
      // Medium screen: 2x2 grid
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  chipData[0]['label']!,
                  chipData[0]['value']!,
                  constraints,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoChip(
                  chipData[1]['label']!,
                  chipData[1]['value']!,
                  constraints,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  chipData[2]['label']!,
                  chipData[2]['value']!,
                  constraints,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoChip(
                  chipData[3]['label']!,
                  chipData[3]['value']!,
                  constraints,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Small screen: Stacked layout
      return Column(
        children: chipData
            .map(
              (data) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildInfoChip(
                  data['label']!,
                  data['value']!,
                  constraints,
                ),
              ),
            )
            .toList(),
      );
    }
  }

  Widget _buildInfoChip(
    String label,
    String value,
    BoxConstraints constraints,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: constraints.maxWidth > 600 ? 12 : 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF00B894).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: constraints.maxWidth > 600 ? 12 : 11,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF00B894),
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildCourseStats(BoxConstraints constraints) {
    final stats = [
      {
        'title': 'Total Enrollments',
        'value': '${_enrollments.length}',
        'icon': Icons.people,
      },
      {
        'title': 'Active Students',
        'value': '${_enrollments.where((e) => e['status'] == 'active').length}',
        'icon': Icons.school,
      },
      {
        'title': 'Completion Rate',
        'value': '${_calculateCompletionRate()}%',
        'icon': Icons.trending_up,
      },
    ];

    if (constraints.maxWidth > 800) {
      // Wide screen: Row layout
      return Row(
        children: stats.asMap().entries.map((entry) {
          final index = entry.key;
          final stat = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < stats.length - 1 ? 16 : 0,
              ),
              child: _buildStatCard(
                stat['title'] as String,
                stat['value'] as String,
                stat['icon'] as IconData,
                constraints,
              ),
            ),
          );
        }).toList(),
      );
    } else {
      // Small/Medium screen: Column layout
      return Column(
        children: stats
            .map(
              (stat) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildStatCard(
                  stat['title'] as String,
                  stat['value'] as String,
                  stat['icon'] as IconData,
                  constraints,
                ),
              ),
            )
            .toList(),
      );
    }
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    BoxConstraints constraints,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(constraints.maxWidth > 600 ? 16 : 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: constraints.maxWidth > 600 ? 32 : 24,
              color: const Color(0xFF00B894),
            ),
            SizedBox(height: constraints.maxWidth > 600 ? 8 : 4),
            Text(
              value,
              style: TextStyle(
                fontSize: constraints.maxWidth > 600 ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00B894),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: constraints.maxWidth > 600 ? 12 : 10,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrollmentsList(BoxConstraints constraints) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(constraints.maxWidth > 600 ? 16 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enrolled Students',
              style: TextStyle(
                fontSize: constraints.maxWidth > 600 ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: constraints.maxWidth > 600 ? 16 : 12),

            if (_enrollments.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(constraints.maxWidth > 600 ? 32 : 16),
                child: const Column(
                  children: [
                    Icon(Icons.people_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No students enrolled yet',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _enrollments.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final enrollment = _enrollments[index];
                  final profile = enrollment['user_profiles'];
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth > 600 ? 16 : 8,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF00B894),
                      backgroundImage: profile?['avatar_url'] != null
                          ? NetworkImage(profile['avatar_url'])
                          : null,
                      child: profile?['avatar_url'] == null
                          ? Text(
                              (profile?['name'] ?? 'S')[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            )
                          : null,
                    ),
                    title: Text(
                      profile?['name'] ?? 'Unknown Student',
                      style: TextStyle(
                        fontSize: constraints.maxWidth > 600 ? 16 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      profile?['email'] ?? '',
                      style: TextStyle(
                        fontSize: constraints.maxWidth > 600 ? 14 : 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(enrollment['status']),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        enrollment['status']?.toUpperCase() ?? 'ACTIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: constraints.maxWidth > 600 ? 10 : 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'dropped':
        return Colors.red;
      case 'paused':
        return Colors.orange;
      default:
        return const Color(0xFF00B894);
    }
  }

  int _calculateCompletionRate() {
    if (_enrollments.isEmpty) return 0;
    final completed = _enrollments
        .where((e) => e['status'] == 'completed')
        .length;
    return ((completed / _enrollments.length) * 100).round();
  }

  // Navigation methods
  void _navigateToEditCourse() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditCoursePage(course: _course!)),
    ).then((_) {
      // Refresh course details when returning from edit page
      _loadCourseDetails();
    });
  }

  void _navigateToContentManagement() {
    // TODO: Navigate to course content management page
    Navigator.pushNamed(
      context,
      '/coaching-center/courses/content',
      arguments: {
        'courseId': widget.courseId,
        'courseTitle': _course!['title'],
      },
    );
  }

  void _navigateToAssignFaculty() {
    // TODO: Navigate to assign faculty page
    Navigator.pushNamed(
      context,
      '/coaching-center/courses/assign-faculty',
      arguments: {
        'courseId': widget.courseId,
        'courseTitle': _course!['title'],
      },
    );
  }

  void _navigateToCourseAnalytics() {
    // TODO: Navigate to course analytics page
    Navigator.pushNamed(
      context,
      '/coaching-center/courses/analytics',
      arguments: {
        'courseId': widget.courseId,
        'courseTitle': _course!['title'],
      },
    );
  }
}
