// screens/coaching_center/courses/widgets/add_chapter_dialog.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddChapterDialog extends StatefulWidget {
  final String courseId;
  final Map<String, dynamic>? chapter;
  final int orderIndex;
  final VoidCallback onAdded;

  const AddChapterDialog({
    super.key,
    required this.courseId,
    this.chapter,
    required this.orderIndex,
    required this.onAdded,
  });

  @override
  State<AddChapterDialog> createState() => _AddChapterDialogState();
}

class _AddChapterDialogState extends State<AddChapterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.chapter != null) {
      _titleController.text = widget.chapter!['title'] ?? '';
      _descriptionController.text = widget.chapter!['description'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.chapter != null;

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
              Text(
                isEditing ? 'Edit Chapter' : 'Add New Chapter',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Chapter Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Chapter Description',
                  border: OutlineInputBorder(),
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
                    onPressed: _isLoading ? null : _saveChapter,
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
                        : Text(isEditing ? 'Update' : 'Add Chapter'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveChapter() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final chapterData = {
        'course_id': widget.courseId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'order_index': widget.orderIndex,
      };

      if (widget.chapter != null) {
        // Update existing chapter
        await Supabase.instance.client
            .from('chapters')
            .update(chapterData)
            .eq('id', widget.chapter!['id']);
      } else {
        // Create new chapter
        await Supabase.instance.client
            .from('chapters')
            .insert(chapterData);
      }

      widget.onAdded();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chapter ${widget.chapter != null ? 'updated' : 'added'} successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving chapter: $e')),
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
    super.dispose();
  }
}
