// screens/coaching_center/courses/widgets/course_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourseFormDialog extends StatefulWidget {
  final Map<String, dynamic>? course;
  final VoidCallback onSaved;

  const CourseFormDialog({
    super.key,
    this.course,
    required this.onSaved,
  });

  @override
  State<CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  
  String _selectedCategory = 'programming';
  String _selectedLevel = 'beginner';
  bool _isPublished = false;
  bool _isLoading = false;

  final List<String> _categories = [
    'programming', 'mathematics', 'science', 'language', 'business'
  ];
  
  final List<String> _levels = [
    'beginner', 'intermediate', 'advanced'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final course = widget.course!;
    _titleController.text = course['title'] ?? '';
    _descriptionController.text = course['description'] ?? '';
    _priceController.text = course['price']?.toString() ?? '0';
    _durationController.text = course['duration_hours']?.toString() ?? '0';
    _selectedCategory = course['category'] ?? 'programming';
    _selectedLevel = course['level'] ?? 'beginner';
    _isPublished = course['is_published'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.course != null;
    
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 600 : MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Course' : 'Create New Course',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              Expanded(
                child: SingleChildScrollView(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        children: [
                          // Title Field
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Course Title *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value?.isEmpty == true ? 'Title is required' : null,
                          ),
                          const SizedBox(height: 16),
                          
                          // Description Field
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Description *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value?.isEmpty == true ? 'Description is required' : null,
                          ),
                          const SizedBox(height: 16),
                          
                          // Category and Level Row - Responsive
                          if (constraints.maxWidth > 400)
                            Row(
                              children: [
                                Expanded(child: _buildCategoryDropdown()),
                                const SizedBox(width: 16),
                                Expanded(child: _buildLevelDropdown()),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _buildCategoryDropdown(),
                                const SizedBox(height: 16),
                                _buildLevelDropdown(),
                              ],
                            ),
                          const SizedBox(height: 16),
                          
                          // Price and Duration Row - Responsive
                          if (constraints.maxWidth > 400)
                            Row(
                              children: [
                                Expanded(child: _buildPriceField()),
                                const SizedBox(width: 16),
                                Expanded(child: _buildDurationField()),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _buildPriceField(),
                                const SizedBox(height: 16),
                                _buildDurationField(),
                              ],
                            ),
                          const SizedBox(height: 16),
                          
                          // Publish Switch
                          SwitchListTile(
                            title: const Text('Publish Course'),
                            subtitle: Text(_isPublished ? 'Course will be visible to students' : 'Course will be saved as draft'),
                            value: _isPublished,
                            onChanged: (value) => setState(() => _isPublished = value),
                            activeColor: const Color(0xFF00B894),
                          ),
                        ],
                      );
                    },
                  ),
                ),
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
                    onPressed: _isLoading ? null : _saveCourse,
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
                        : Text(isEditing ? 'Update Course' : 'Create Course'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
        minWidth: 0,
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: const InputDecoration(
          labelText: 'Category',
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        isExpanded: true, // Critical: Prevents overflow
        items: _categories.map((category) => DropdownMenuItem(
          value: category,
          child: Text(
            category.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        )).toList(),
        onChanged: (value) => setState(() => _selectedCategory = value!),
      ),
    );
  }

  Widget _buildLevelDropdown() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
        minWidth: 0,
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedLevel,
        decoration: const InputDecoration(
          labelText: 'Level',
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        isExpanded: true, // Critical: Prevents overflow
        items: _levels.map((level) => DropdownMenuItem(
          value: level,
          child: Text(
            level.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        )).toList(),
        onChanged: (value) => setState(() => _selectedLevel = value!),
      ),
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Price (₹)',
        border: OutlineInputBorder(),
        prefixText: '₹ ',
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      validator: (value) {
        if (value?.isEmpty == true) return 'Price is required';
        if (double.tryParse(value!) == null) return 'Enter valid price';
        return null;
      },
    );
  }

  Widget _buildDurationField() {
    return TextFormField(
      controller: _durationController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Duration (Hours)',
        border: OutlineInputBorder(),
        suffixText: 'hrs',
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      validator: (value) {
        if (value?.isEmpty == true) return 'Duration is required';
        if (int.tryParse(value!) == null) return 'Enter valid duration';
        return null;
      },
    );
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw 'Not authenticated';

      final courseData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'level': _selectedLevel,
        'price': double.parse(_priceController.text),
        'duration_hours': int.parse(_durationController.text),
        'is_published': _isPublished,
        'instructor_id': userId,
        'instructor_type': 'coaching_center',
      };

      if (widget.course != null) {
        // Update existing course
        await Supabase.instance.client
            .from('courses')
            .update(courseData)
            .eq('id', widget.course!['id']);
      } else {
        // Create new course
        await Supabase.instance.client
            .from('courses')
            .insert(courseData);
      }

      widget.onSaved();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Course ${widget.course != null ? 'updated' : 'created'} successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving course: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
