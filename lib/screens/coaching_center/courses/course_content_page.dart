// screens/coaching_center/courses/course_content_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/chapter_card.dart';
import 'widgets/add_chapter_dialog.dart';
import 'widgets/lesson_management_dialog.dart';

class CourseContentPage extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const CourseContentPage({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<CourseContentPage> createState() => _CourseContentPageState();
}

class _CourseContentPageState extends State<CourseContentPage> {
  List<Map<String, dynamic>> _chapters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    try {
      final response = await Supabase.instance.client
          .from('chapters')
          .select('''
            *,
            lessons(*)
          ''')
          .eq('course_id', widget.courseId)
          .order('order_index');

      if (mounted) {
        setState(() {
          _chapters = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading chapters: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.courseTitle} - Content'),
        backgroundColor: const Color(0xFF00B894),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddChapterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chapters.isEmpty
              ? _buildEmptyState()
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _chapters.length,
                  onReorder: _reorderChapters,
                  itemBuilder: (context, index) {
                    final chapter = _chapters[index];
                    return ChapterCard(
                      key: ValueKey(chapter['id']),
                      chapter: chapter,
                      onEdit: () => _editChapter(chapter),
                      onDelete: () => _deleteChapter(chapter['id']),
                      onManageLessons: () => _manageLessons(chapter),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddChapterDialog,
        backgroundColor: const Color(0xFF00B894),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.book_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No chapters yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddChapterDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add First Chapter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B894),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddChapterDialog() {
    showDialog(
      context: context,
      builder: (context) => AddChapterDialog(
        courseId: widget.courseId,
        orderIndex: _chapters.length,
        onAdded: _loadChapters,
      ),
    );
  }

  void _editChapter(Map<String, dynamic> chapter) {
    showDialog(
      context: context,
      builder: (context) => AddChapterDialog(
        courseId: widget.courseId,
        chapter: chapter,
        orderIndex: chapter['order_index'],
        onAdded: _loadChapters,
      ),
    );
  }

  void _manageLessons(Map<String, dynamic> chapter) {
    showDialog(
      context: context,
      builder: (context) => LessonManagementDialog(
        chapter: chapter,
        onUpdated: _loadChapters,
      ),
    );
  }

  Future<void> _deleteChapter(String chapterId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chapter'),
        content: const Text('Are you sure you want to delete this chapter? This will also delete all lessons in this chapter.'),
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
            .from('chapters')
            .delete()
            .eq('id', chapterId);
        
        _loadChapters();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chapter deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting chapter: $e')),
          );
        }
      }
    }
  }

  void _reorderChapters(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final chapter = _chapters.removeAt(oldIndex);
      _chapters.insert(newIndex, chapter);
      
      // Update order indices
      for (int i = 0; i < _chapters.length; i++) {
        _chapters[i]['order_index'] = i;
      }
    });
    
    _updateChapterOrder();
  }

  Future<void> _updateChapterOrder() async {
    try {
      for (final chapter in _chapters) {
        await Supabase.instance.client
            .from('chapters')
            .update({'order_index': chapter['order_index']})
            .eq('id', chapter['id']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating chapter order: $e')),
        );
      }
    }
  }
}
