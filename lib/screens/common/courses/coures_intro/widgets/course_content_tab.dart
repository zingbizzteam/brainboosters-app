// screens/common/courses/widgets/course_content_tab.dart

import 'package:flutter/material.dart';

class CourseContentTab extends StatelessWidget {
  final List<Map<String, dynamic>> chapters;

  const CourseContentTab({super.key, required this.chapters});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;

    if (chapters.isEmpty) {
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
            '${chapters.length} chapters • ${_getTotalLessons()} lessons • ${_getTotalDuration()}',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          ...chapters.asMap().entries.map((entry) {
            final index = entry.key;
            final chapter = entry.value;
            return _buildChapterCard(chapter, index, isMobile);
          }),
        ],
      ),
    );
  }

  Widget _buildChapterCard(Map<String, dynamic> chapter, int index, bool isMobile) {
    final lessons = (chapter['lessons'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: index == 0,
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            chapter['title']?.toString() ?? 'Untitled Chapter',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (chapter['description'] != null && chapter['description'].toString().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  chapter['description'].toString(),
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              _buildChapterMetadata(chapter, isMobile),
            ],
          ),
          children: lessons.map((lesson) => _buildLessonTile(lesson, isMobile)).toList(),
        ),
      ),
    );
  }

  Widget _buildChapterMetadata(Map<String, dynamic> chapter, bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final shouldWrap = availableWidth < 300;
        
        if (shouldWrap) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetadataRow(chapter, isMobile),
              if (_isChapterFree(chapter)) ...[
                const SizedBox(height: 4),
                _buildFreeTag(isMobile),
              ],
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(child: _buildMetadataRow(chapter, isMobile)),
              if (_isChapterFree(chapter)) ...[
                const SizedBox(width: 8),
                _buildFreeTag(isMobile),
              ],
            ],
          );
        }
      },
    );
  }

  Widget _buildMetadataRow(Map<String, dynamic> chapter, bool isMobile) {
    final totalLessons = _getChapterTotalLessons(chapter);
    final durationMinutes = _getChapterDuration(chapter);
    
    return Row(
      children: [
        Icon(Icons.play_circle_outline, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '$totalLessons lessons',
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 16),
        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '$durationMinutes min',
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFreeTag(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'FREE',
        style: TextStyle(
          color: Colors.white,
          fontSize: isMobile ? 10 : 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLessonTile(Map<String, dynamic> lesson, bool isMobile) {
    final isCompleted = lesson['is_completed'] == true;
    final isPreview = lesson['is_free'] == true || lesson['is_preview'] == true;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              isCompleted ? Icons.check : _getLessonIcon(lesson['lesson_type']?.toString() ?? 'video'),
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
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w500,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? Colors.grey[600] : Colors.black,
                  ),
                ),
                if (lesson['description'] != null && lesson['description'].toString().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    lesson['description'].toString(),
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
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
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.grey[600],
                  ),
                ),
              if (isPreview) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'PREVIEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 8 : 10,
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
      return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '${seconds}s';
    }
  }

  int _getTotalLessons() {
    return chapters.fold(0, (total, chapter) {
      return total + _getChapterTotalLessons(chapter);
    });
  }

  int _getChapterTotalLessons(Map<String, dynamic> chapter) {
    final lessons = chapter['lessons'] as List?;
    return lessons?.length ?? (chapter['total_lessons'] as num?)?.toInt() ?? 0;
  }

  int _getChapterDuration(Map<String, dynamic> chapter) {
    final durationMinutes = chapter['duration_minutes'];
    if (durationMinutes is num) return durationMinutes.toInt();
    
    // Calculate from lessons if not available
    final lessons = (chapter['lessons'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return lessons.fold(0, (total, lesson) {
      final videoDuration = lesson['video_duration'];
      if (videoDuration is num) {
        return total + (videoDuration.toInt() ~/ 60); // Convert seconds to minutes
      }
      return total;
    });
  }

  bool _isChapterFree(Map<String, dynamic> chapter) {
    return chapter['is_free'] == true;
  }

  String _getTotalDuration() {
    final totalMinutes = chapters.fold(0, (total, chapter) {
      return total + _getChapterDuration(chapter);
    });
    
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
