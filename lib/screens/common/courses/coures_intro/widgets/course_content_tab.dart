// screens/common/courses/widgets/course_content_tab.dart

import 'package:flutter/material.dart';

class CourseContentTab extends StatefulWidget {
  final List<Map<String, dynamic>> chapters;

  const CourseContentTab({super.key, required this.chapters});

  @override
  State<CourseContentTab> createState() => _CourseContentTabState();
}

class _CourseContentTabState extends State<CourseContentTab> {
  final Set<int> _expandedChapters = {};

  @override
  void initState() {
    super.initState();
    // Expand first chapter by default
    if (widget.chapters.isNotEmpty) {
      _expandedChapters.add(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;

    if (widget.chapters.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'No content available yet.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    final totalLessons = widget.chapters.fold<int>(
      0,
      (sum, chapter) => sum + ((chapter['lessons'] as List?)?.length ?? 0),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course Content',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.chapters.length} chapters • $totalLessons lessons • ${_getTotalDuration()}',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          ...widget.chapters.asMap().entries.map((entry) {
            final index = entry.key;
            final chapter = entry.value;
            final isExpanded = _expandedChapters.contains(index);
            return _buildChapterCard(chapter, index, isExpanded, isMobile);
          }),
        ],
      ),
    );
  }

  Widget _buildChapterCard(
    Map<String, dynamic> chapter,
    int index,
    bool isExpanded,
    bool isMobile,
  ) {
    final lessons = (chapter['lessons'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final chapterDuration = _getChapterDuration(lessons);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedChapters.remove(index);
                } else {
                  _expandedChapters.add(index);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${chapter['chapter_number'] ?? index + 1}',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter['title']?.toString() ?? 'Untitled Chapter',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${lessons.length} lessons • $chapterDuration',
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded && lessons.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Column(
                children: lessons.map((lesson) {
                  return _buildLessonItem(lesson, isMobile);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLessonItem(Map<String, dynamic> lesson, bool isMobile) {
    final isCompleted = lesson['is_completed'] == true;
    final isPreview = lesson['is_free'] == true || lesson['is_preview'] == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check
                  : _getLessonIcon(lesson['lesson_type']?.toString() ?? 'video'),
              size: 16,
              color: isCompleted ? Colors.white : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson['title']?.toString() ?? 'Untitled Lesson',
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 15,
                    fontWeight: FontWeight.w500,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? Colors.grey[600] : Colors.black,
                  ),
                ),
                if (lesson['description'] != null &&
                    lesson['description'].toString().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    lesson['description'].toString(),
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (lesson['video_duration'] != null)
                Text(
                  _formatDuration((lesson['video_duration'] as num).toInt()),
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (isPreview) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'PREVIEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 8 : 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  IconData _getLessonIcon(String lessonType) {
    switch (lessonType.toLowerCase()) {
      case 'video':
        return Icons.play_circle_outline;
      case 'text':
        return Icons.article_outlined;
      case 'quiz':
        return Icons.quiz_outlined;
      case 'assignment':
        return Icons.assignment_outlined;
      case 'live':
        return Icons.live_tv_outlined;
      default:
        return Icons.play_circle_outline;
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '${seconds}s';
    }
  }

  String _getChapterDuration(List<Map<String, dynamic>> lessons) {
    final totalSeconds = lessons.fold<int>(0, (total, lesson) {
      final videoDuration = lesson['video_duration'];
      if (videoDuration is num) {
        return total + videoDuration.toInt();
      }
      return total;
    });

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${totalSeconds}s';
    }
  }

  String _getTotalDuration() {
    final totalSeconds = widget.chapters.fold<int>(0, (total, chapter) {
      final lessons = (chapter['lessons'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      return total +
          lessons.fold<int>(0, (sum, lesson) {
            final videoDuration = lesson['video_duration'];
            if (videoDuration is num) {
              return sum + videoDuration.toInt();
            }
            return sum;
          });
    });

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${totalSeconds}s';
    }
  }
}
