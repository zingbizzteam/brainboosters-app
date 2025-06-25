// screens/coaching_center/faculty/widgets/edit_faculty_dialog.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditFacultyDialog extends StatefulWidget {
  final Map<String, dynamic> faculty;
  final VoidCallback onUpdated;

  const EditFacultyDialog({
    super.key,
    required this.faculty,
    required this.onUpdated,
  });

  @override
  State<EditFacultyDialog> createState() => _EditFacultyDialogState();
}

class _EditFacultyDialogState extends State<EditFacultyDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _titleController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.faculty['user_profiles'];
    _nameController = TextEditingController(text: profile?['name'] ?? '');
    _phoneController = TextEditingController(text: profile?['phone'] ?? '');
    _titleController = TextEditingController(text: widget.faculty['title'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.faculty['user_profiles'];
    
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Faculty Member',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: profile?['email'] ?? '',
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Email (Cannot be changed)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title/Position *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Title is required' : null,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _updateFaculty,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B894),
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateFaculty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final facultyId = widget.faculty['id'];

      // Update user profile
      await Supabase.instance.client.from('user_profiles').update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      }).eq('id', facultyId);

      // Update faculty record
      await Supabase.instance.client.from('faculties').update({
        'title': _titleController.text.trim(),
      }).eq('id', facultyId);

      widget.onUpdated();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faculty member updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating faculty: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
