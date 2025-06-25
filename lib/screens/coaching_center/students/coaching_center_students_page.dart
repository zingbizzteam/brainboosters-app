// screens/coaching_center/students/coaching_center_students_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CoachingCenterStudentsPage extends StatefulWidget {
  const CoachingCenterStudentsPage({super.key});

  @override
  State<CoachingCenterStudentsPage> createState() => _CoachingCenterStudentsPageState();
}

class _CoachingCenterStudentsPageState extends State<CoachingCenterStudentsPage> {
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      // Get students enrolled in this center's courses
      final response = await Supabase.instance.client
          .from('enrollments')
          .select('''
            *,
            user_profiles!inner(name, email, avatar_url),
            courses!inner(title, instructor_id)
          ''')
          .eq('user_type', 'student')
          .eq('courses.instructor_id', userId)
          .eq('courses.instructor_type', 'coaching_center')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _students = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading students: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredStudents {
    var filtered = _students;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((student) {
        final name = student['user_profiles']?['name']?.toLowerCase() ?? '';
        final email = student['user_profiles']?['email']?.toLowerCase() ?? '';
        final course = student['courses']?['title']?.toLowerCase() ?? '';
        return name.contains(_searchQuery.toLowerCase()) ||
            email.contains(_searchQuery.toLowerCase()) ||
            course.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by status
    if (_selectedStatus != 'all') {
      filtered = filtered.where((student) => student['status'] == _selectedStatus).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Students',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B894),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_filteredStudents.length} Total',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Search students...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        onChanged: (value) => setState(() => _selectedStatus = value!),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Status')),
                          DropdownMenuItem(value: 'active', child: Text('Active')),
                          DropdownMenuItem(value: 'completed', child: Text('Completed')),
                          DropdownMenuItem(value: 'paused', child: Text('Paused')),
                          DropdownMenuItem(value: 'dropped', child: Text('Dropped')),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Students List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No students found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadStudents,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = _filteredStudents[index];
                            return StudentCard(
                              student: student,
                              onTap: () => _showStudentDetails(student),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showStudentDetails(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (context) => StudentDetailsDialog(student: student),
    );
  }
}

class StudentCard extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback? onTap;

  const StudentCard({super.key, required this.student, this.onTap});

  @override
  Widget build(BuildContext context) {
    final profile = student['user_profiles'];
    final course = student['courses'];
    final progress = (student['progress'] ?? 0.0).toDouble();
    final enrollmentDate = DateTime.parse(student['enrollment_date']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF00B894),
                backgroundImage: profile?['avatar_url'] != null 
                    ? NetworkImage(profile['avatar_url']) 
                    : null,
                child: profile?['avatar_url'] == null
                    ? Text(
                        (profile?['name'] ?? 'S')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?['name'] ?? 'Unknown Student',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      course?['title'] ?? 'No course',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      profile?['email'] ?? '',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enrolled: ${enrollmentDate.day}/${enrollmentDate.month}/${enrollmentDate.year}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF00B894)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Progress: ${progress.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(student['status']),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  student['status']?.toUpperCase() ?? 'ACTIVE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
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
}

class StudentDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentDetailsDialog({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final profile = student['user_profiles'];
    final course = student['courses'];
    final progress = (student['progress'] ?? 0.0).toDouble();
    final enrollmentDate = DateTime.parse(student['enrollment_date']);

    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF00B894),
                  backgroundImage: profile?['avatar_url'] != null 
                      ? NetworkImage(profile['avatar_url']) 
                      : null,
                  child: profile?['avatar_url'] == null
                      ? Text(
                          (profile?['name'] ?? 'S')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?['name'] ?? 'Unknown Student',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        profile?['email'] ?? '',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Course: ${course?['title'] ?? 'No course'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Enrolled: ${enrollmentDate.day}/${enrollmentDate.month}/${enrollmentDate.year}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Progress:', style: TextStyle(fontWeight: FontWeight.w500)),
                Text('${progress.toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation(Color(0xFF00B894)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status:', style: TextStyle(fontWeight: FontWeight.w500)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(student['status']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    student['status']?.toUpperCase() ?? 'ACTIVE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
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
}
