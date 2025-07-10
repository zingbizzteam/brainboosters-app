import 'package:brainboosters_app/screens/common/courses/assesment/assessment_repository.dart';
import 'package:flutter/material.dart';

class LessonNavigationWidget extends StatefulWidget {
  final List<Map<String, dynamic>> chapters;
  final String? currentLessonId;
  final Function(String) onLessonSelected;
  final Function(String) onAssessmentSelected;
  final bool hasAccess;

  const LessonNavigationWidget({
    super.key,
    required this.chapters,
    this.currentLessonId,
    required this.onLessonSelected,
    required this.onAssessmentSelected,
    required this.hasAccess,
  });

  @override
  State<LessonNavigationWidget> createState() => _LessonNavigationWidgetState();
}

class _LessonNavigationWidgetState extends State<LessonNavigationWidget> {
  String? _expandedChapterId;
  final Map<String, List<Map<String, dynamic>>> _chapterAssessments = {};

  @override
  void initState() {
    super.initState();
    _findAndExpandCurrentChapter();
    _loadChapterAssessments();
  }

  @override
  void didUpdateWidget(LessonNavigationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentLessonId != oldWidget.currentLessonId) {
      _findAndExpandCurrentChapter();
    }
  }

  void _findAndExpandCurrentChapter() {
    if (widget.currentLessonId == null) return;

    for (final chapter in widget.chapters) {
      final lessons =
          (chapter['lessons'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (final lesson in lessons) {
        if (lesson['id'] == widget.currentLessonId) {
          setState(() {
            _expandedChapterId = chapter['id'];
          });
          return;
        }
      }
    }
  }

  void _loadChapterAssessments() async {
    for (final chapter in widget.chapters) {
      try {
        final assessments = await AssessmentRepository.getAssessmentsForChapter(
          chapter['id'],
        );
        setState(() {
          _chapterAssessments[chapter['id']] = assessments;
        });
      } catch (e) {
        debugPrint(
          'Failed to load assessments for chapter ${chapter['id']}: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with back button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              const Icon(Icons.list_alt),
              const SizedBox(width: 8),
              const Text(
                'Course Content',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${_getTotalLessons()} lessons',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
        // Chapters list
        Expanded(
          child: ListView.builder(
            itemCount: widget.chapters.length,
            itemBuilder: (context, index) {
              final chapter = widget.chapters[index];
              return _buildChapterTile(chapter);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChapterTile(Map<String, dynamic> chapter) {
    final lessons =
        (chapter['lessons'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final chapterAssessments = _chapterAssessments[chapter['id']] ?? [];
    final isCurrentChapter = _expandedChapterId == chapter['id'];
    final hasCurrentLesson = _chapterHasCurrentLesson(chapter);

    return Container(
      decoration: BoxDecoration(
        color: hasCurrentLesson ? Colors.blue.withValues(alpha: 0.05) : null,
        border: hasCurrentLesson
            ? Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: ExpansionTile(
        key: Key(chapter['id']),
        initiallyExpanded: isCurrentChapter,
        onExpansionChanged: (expanded) {
          setState(() {
            _expandedChapterId = expanded ? chapter['id'] : null;
          });
        },
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: hasCurrentLesson
                ? Colors.blue
                : Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.folder,
            color: hasCurrentLesson ? Colors.white : Colors.grey[600],
            size: 16,
          ),
        ),
        title: Text(
          chapter['title'] ?? 'Untitled Chapter',
          style: TextStyle(
            fontWeight: hasCurrentLesson ? FontWeight.bold : FontWeight.w600,
            fontSize: 16,
            color: hasCurrentLesson ? Colors.blue : Colors.black,
          ),
        ),
        subtitle: Text(
          '${lessons.length} lessons${chapterAssessments.isNotEmpty ? ' • ${chapterAssessments.length} assessments' : ''}',
          style: TextStyle(
            color: hasCurrentLesson ? Colors.blue[700] : Colors.grey[600],
            fontSize: 14,
          ),
        ),
        children: [
          // Lessons
          ...lessons.map((lesson) => _buildLessonTile(lesson)),
          // Chapter-level assessments (shown at the end)
          ...chapterAssessments
              .map((assessment) => _buildAssessmentTile(assessment))
        ],
      ),
    );
  }

  bool _chapterHasCurrentLesson(Map<String, dynamic> chapter) {
    if (widget.currentLessonId == null) return false;

    final lessons =
        (chapter['lessons'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return lessons.any((lesson) => lesson['id'] == widget.currentLessonId);
  }

  Widget _buildLessonTile(Map<String, dynamic> lesson) {
    final isCurrentLesson = lesson['id'] == widget.currentLessonId;
    final isFree = lesson['is_free'] ?? false;
    final canAccess = widget.hasAccess || isFree;

    return Container(
      margin: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: isCurrentLesson ? Colors.blue.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCurrentLesson
                ? Colors.blue
                : (canAccess
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(16),
            border: isCurrentLesson
                ? Border.all(color: Colors.blue, width: 2)
                : null,
          ),
          child: Icon(
            canAccess ? Icons.play_arrow : Icons.lock,
            color: isCurrentLesson
                ? Colors.white
                : (canAccess ? Colors.green : Colors.grey),
            size: 16,
          ),
        ),
        title: Text(
          lesson['title'] ?? 'Untitled Lesson',
          style: TextStyle(
            fontWeight: isCurrentLesson ? FontWeight.bold : FontWeight.normal,
            color: isCurrentLesson
                ? Colors.blue
                : (canAccess ? Colors.black : Colors.grey),
          ),
        ),
        subtitle: Row(
          children: [
            if (lesson['video_duration'] != null) ...[
              Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${lesson['video_duration']} min',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
            if (isFree) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'FREE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: canAccess ? () => widget.onLessonSelected(lesson['id']) : null,
        selected: isCurrentLesson,
      ),
    );
  }

  Widget _buildAssessmentTile(Map<String, dynamic> assessment) {
    final testType = assessment['test_type'] ?? 'quiz';
    final status = assessment['status'] ?? 'pending';
    final canAccess = widget.hasAccess;

    IconData getTestIcon() {
      switch (testType) {
        case 'quiz':
          return Icons.quiz;
        case 'assignment':
          return Icons.assignment;
        case 'exam':
          return Icons.school;
        default:
          return Icons.assessment;
      }
    }

    Color getStatusColor() {
      switch (status) {
        case 'completed':
          return Colors.green;
        case 'pending':
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }

    return Container(
      margin: const EdgeInsets.only(left: 16),
      child: ListTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: canAccess
                ? getStatusColor().withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            canAccess ? getTestIcon() : Icons.lock,
            color: canAccess ? getStatusColor() : Colors.grey,
            size: 16,
          ),
        ),
        title: Text(
          assessment['title'] ?? 'Untitled Assessment',
          style: TextStyle(
            fontWeight: FontWeight.normal,
            color: canAccess ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: getStatusColor(),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                testType.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (assessment['total_marks'] != null) ...[
              Icon(Icons.star, size: 12, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${assessment['total_marks']} marks',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ],
        ),
        onTap: canAccess
            ? () => widget.onAssessmentSelected(assessment['id'])
            : null,
      ),
    );
  }

  int _getTotalLessons() {
    return widget.chapters.fold(0, (total, chapter) {
      final lessons = chapter['lessons'] as List?;
      return total + (lessons?.length ?? 0);
    });
  }
}
