// screens/coaching_center/faculty/coaching_center_faculty_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/faculty_header.dart';
import 'widgets/faculty_card.dart';
import 'widgets/add_faculty_dialog.dart';
import 'widgets/edit_faculty_dialog.dart';

class CoachingCenterFacultyPage extends StatefulWidget {
  const CoachingCenterFacultyPage({super.key});

  @override
  State<CoachingCenterFacultyPage> createState() => _CoachingCenterFacultyPageState();
}

class _CoachingCenterFacultyPageState extends State<CoachingCenterFacultyPage> {
  List<Map<String, dynamic>> _faculty = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFaculty();
  }

  Future<void> _loadFaculty() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('faculties')
          .select('''
            *,
            user_profiles!inner(name, email, phone, is_active, avatar_url)
          ''')
          .eq('coaching_center_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _faculty = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading faculty: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredFaculty {
    if (_searchQuery.isEmpty) return _faculty;
    
    return _faculty.where((faculty) {
      final profile = faculty['user_profiles'];
      final name = profile?['name']?.toLowerCase() ?? '';
      final email = profile?['email']?.toLowerCase() ?? '';
      final title = faculty['title']?.toLowerCase() ?? '';
      
      return name.contains(_searchQuery.toLowerCase()) ||
          email.contains(_searchQuery.toLowerCase()) ||
          title.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _toggleFacultyStatus(String facultyId, bool isActive) async {
    try {
      await Supabase.instance.client
          .from('user_profiles')
          .update({'is_active': !isActive})
          .eq('id', facultyId);
      
      _loadFaculty();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Faculty ${!isActive ? 'enabled' : 'disabled'}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating faculty status: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FacultyHeader(
            facultyCount: _filteredFaculty.length,
            onSearchChanged: (query) => setState(() => _searchQuery = query),
            onAddPressed: () => _showAddFacultyDialog(),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredFaculty.isEmpty
                    ? const Center(child: Text('No faculty members found'))
                    : RefreshIndicator(
                        onRefresh: _loadFaculty,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredFaculty.length,
                          itemBuilder: (context, index) {
                            final faculty = _filteredFaculty[index];
                            return FacultyCard(
                              faculty: faculty,
                              onEdit: () => _showEditFacultyDialog(faculty),
                              onToggleStatus: () => _toggleFacultyStatus(
                                faculty['id'],
                                faculty['user_profiles']['is_active'],
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

  void _showAddFacultyDialog() {
    showDialog(
      context: context,
      builder: (context) => AddFacultyDialog(onAdded: _loadFaculty),
    );
  }

  void _showEditFacultyDialog(Map<String, dynamic> faculty) {
    showDialog(
      context: context,
      builder: (context) => EditFacultyDialog(
        faculty: faculty,
        onUpdated: _loadFaculty,
      ),
    );
  }
}
