// screens/coaching_center/courses/widgets/lesson_management_dialog.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/video_upload_widget.dart';

class LessonManagementDialog extends StatefulWidget {
  final Map<String, dynamic> chapter;
  final VoidCallback onUpdated;

  const LessonManagementDialog({
    super.key,
    required this.chapter,
    required this.onUpdated,
  });

  @override
  State<LessonManagementDialog> createState() => _LessonManagementDialogState();
}

class _LessonManagementDialogState extends State<LessonManagementDialog> {
  List<Map<String, dynamic>> _lessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    try {
      final response = await Supabase.instance.client
          .from('lessons')
          .select('*')
          .eq('chapter_id', widget.chapter['id'])
          .order('order_index');

      if (mounted) {
        setState(() {
          _lessons = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading lessons: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Manage Lessons - ${widget.chapter['title']}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddLessonDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Lesson'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B894),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _lessons.isEmpty
                      ? _buildEmptyState()
                      : ReorderableListView.builder(
                          itemCount: _lessons.length,
                          onReorder: _reorderLessons,
                          itemBuilder: (context, index) {
                            final lesson = _lessons[index];
                            return _buildLessonCard(lesson, index);
                          },
                        ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    widget.onUpdated();
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.video_library_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No lessons yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddLessonDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add First Lesson'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B894),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(Map<String, dynamic> lesson, int index) {
    return Card(
      key: ValueKey(lesson['id']),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.drag_handle, color: Colors.grey),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: lesson['video_url'] != null ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                lesson['video_url'] != null ? Icons.play_arrow : Icons.video_library_outlined,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
        title: Text(lesson['title'] ?? 'Untitled Lesson'),
        subtitle: Row(
          children: [
            Text('${lesson['duration'] ?? 0} minutes'),
            if (lesson['is_preview'] == true) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PREVIEW',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditLessonDialog(lesson);
                break;
              case 'delete':
                _deleteLesson(lesson['id']);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Color(0xFF00B894)),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLessonDialog() {
    showDialog(
      context: context,
      builder: (context) => _LessonFormDialog(
        chapterId: widget.chapter['id'],
        orderIndex: _lessons.length,
        onSaved: _loadLessons,
      ),
    );
  }

  void _showEditLessonDialog(Map<String, dynamic> lesson) {
    showDialog(
      context: context,
      builder: (context) => _LessonFormDialog(
        chapterId: widget.chapter['id'],
        lesson: lesson,
        orderIndex: lesson['order_index'],
        onSaved: _loadLessons,
      ),
    );
  }

  Future<void> _deleteLesson(String lessonId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lesson'),
        content: const Text('Are you sure you want to delete this lesson?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Supabase.instance.client
            .from('lessons')
            .delete()
            .eq('id', lessonId);
        
        _loadLessons();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lesson deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting lesson: $e')),
          );
        }
      }
    }
  }

  void _reorderLessons(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final lesson = _lessons.removeAt(oldIndex);
      _lessons.insert(newIndex, lesson);
      
      // Update order indices
      for (int i = 0; i < _lessons.length; i++) {
        _lessons[i]['order_index'] = i;
      }
    });
    
    _updateLessonOrder();
  }

  Future<void> _updateLessonOrder() async {
    try {
      for (final lesson in _lessons) {
        await Supabase.instance.client
            .from('lessons')
            .update({'order_index': lesson['order_index']})
            .eq('id', lesson['id']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating lesson order: $e')),
        );
      }
    }
  }
}

class _LessonFormDialog extends StatefulWidget {
  final String chapterId;
  final Map<String, dynamic>? lesson;
  final int orderIndex;
  final VoidCallback onSaved;

  const _LessonFormDialog({
    required this.chapterId,
    this.lesson,
    required this.orderIndex,
    required this.onSaved,
  });

  @override
  State<_LessonFormDialog> createState() => _LessonFormDialogState();
}

class _LessonFormDialogState extends State<_LessonFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _durationController = TextEditingController();
  
  String? _videoUrl;
  bool _isPreview = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.lesson != null) {
      _titleController.text = widget.lesson!['title'] ?? '';
      _contentController.text = widget.lesson!['content'] ?? '';
      _durationController.text = widget.lesson!['duration']?.toString() ?? '';
      _videoUrl = widget.lesson!['video_url'];
      _isPreview = widget.lesson!['is_preview'] ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.lesson != null;

    return Dialog(
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 800),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Lesson' : 'Add New Lesson',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Lesson Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty == true ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contentController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Lesson Content/Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Duration (Minutes) *',
                          border: OutlineInputBorder(),
                          suffixText: 'min',
                        ),
                        validator: (value) {
                          if (value?.isEmpty == true) return 'Duration is required';
                          if (int.tryParse(value!) == null) return 'Enter valid duration';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      VideoUploadWidget(
                        initialVideoUrl: _videoUrl,
                        onVideoUploaded: (url) => _videoUrl = url,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Preview Lesson'),
                        subtitle: const Text('Allow students to preview this lesson for free'),
                        value: _isPreview,
                        onChanged: (value) => setState(() => _isPreview = value),
                        activeColor: const Color(0xFF00B894),
                      ),
                    ],
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
                    onPressed: _isLoading ? null : _saveLesson,
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
                        : Text(isEditing ? 'Update' : 'Add Lesson'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveLesson() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final lessonData = {
        'chapter_id': widget.chapterId,
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'duration': int.parse(_durationController.text),
        'video_url': _videoUrl,
        'is_preview': _isPreview,
        'order_index': widget.orderIndex,
      };

      if (widget.lesson != null) {
        // Update existing lesson
        await Supabase.instance.client
            .from('lessons')
            .update(lessonData)
            .eq('id', widget.lesson!['id']);
      } else {
        // Create new lesson
        await Supabase.instance.client
            .from('lessons')
            .insert(lessonData);
      }

      widget.onSaved();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lesson ${widget.lesson != null ? 'updated' : 'added'} successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving lesson: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
