// screens/coaching_center/courses/assign_faculty_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssignFacultyPage extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const AssignFacultyPage({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<AssignFacultyPage> createState() => _AssignFacultyPageState();
}

class _AssignFacultyPageState extends State<AssignFacultyPage> {
  List<Map<String, dynamic>> _availableFaculty = [];
  List<Map<String, dynamic>> _assignedFaculty = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFacultyData();
  }

  Future<void> _loadFacultyData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      // Load all faculty members of this coaching center
      final allFacultyResponse = await Supabase.instance.client
          .from('faculties')
          .select('''
            *,
            user_profiles!inner(name, email, avatar_url, is_active)
          ''')
          .eq('coaching_center_id', userId)
          .eq('user_profiles.is_active', true);

      // Load currently assigned faculty for this course
      final courseResponse = await Supabase.instance.client
          .from('courses')
          .select('instructors')
          .eq('id', widget.courseId)
          .single();

      final assignedInstructorIds = List<String>.from(courseResponse['instructors'] ?? []);
      
      if (mounted) {
        setState(() {
          _availableFaculty = List<Map<String, dynamic>>.from(allFacultyResponse)
              .where((faculty) => !assignedInstructorIds.contains(faculty['id']))
              .toList();
          
          _assignedFaculty = List<Map<String, dynamic>>.from(allFacultyResponse)
              .where((faculty) => assignedInstructorIds.contains(faculty['id']))
              .toList();
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading faculty data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Faculty - ${widget.courseTitle}'),
        backgroundColor: const Color(0xFF00B894),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveAssignments,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAssignedFacultySection(),
                  const SizedBox(height: 24),
                  _buildAvailableFacultySection(),
                ],
              ),
            ),
    );
  }

  Widget _buildAssignedFacultySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment_ind, color: Color(0xFF00B894)),
                const SizedBox(width: 8),
                const Text(
                  'Assigned Faculty',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B894),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_assignedFaculty.length} Assigned',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_assignedFaculty.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No faculty assigned yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _assignedFaculty.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final faculty = _assignedFaculty[index];
                  return _buildFacultyTile(faculty, isAssigned: true);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableFacultySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Available Faculty',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_availableFaculty.length} Available',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_availableFaculty.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'All faculty members are already assigned',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _availableFaculty.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final faculty = _availableFaculty[index];
                  return _buildFacultyTile(faculty, isAssigned: false);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacultyTile(Map<String, dynamic> faculty, {required bool isAssigned}) {
    final profile = faculty['user_profiles'];
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF00B894),
        backgroundImage: profile?['avatar_url'] != null 
            ? NetworkImage(profile['avatar_url']) 
            : null,
        child: profile?['avatar_url'] == null
            ? Text(
                (profile?['name'] ?? 'F')[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Text(profile?['name'] ?? 'Unknown Faculty'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(faculty['title'] ?? 'Faculty'),
          Text(profile?['email'] ?? '', style: const TextStyle(fontSize: 12)),
        ],
      ),
      trailing: ElevatedButton(
        onPressed: () => isAssigned ? _unassignFaculty(faculty) : _assignFaculty(faculty),
        style: ElevatedButton.styleFrom(
          backgroundColor: isAssigned ? Colors.red : const Color(0xFF00B894),
          foregroundColor: Colors.white,
        ),
        child: Text(isAssigned ? 'Remove' : 'Assign'),
      ),
    );
  }

  void _assignFaculty(Map<String, dynamic> faculty) {
    setState(() {
      _availableFaculty.remove(faculty);
      _assignedFaculty.add(faculty);
    });
  }

  void _unassignFaculty(Map<String, dynamic> faculty) {
    setState(() {
      _assignedFaculty.remove(faculty);
      _availableFaculty.add(faculty);
    });
  }

  Future<void> _saveAssignments() async {
    try {
      final assignedIds = _assignedFaculty.map((faculty) => faculty['id']).toList();
      
      await Supabase.instance.client
          .from('courses')
          .update({'instructors': assignedIds})
          .eq('id', widget.courseId);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faculty assignments saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving assignments: $e')),
        );
      }
    }
  }
}
