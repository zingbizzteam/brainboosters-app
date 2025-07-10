import 'dart:convert';

import 'package:brainboosters_app/screens/common/courses/assesment/assessment_repository.dart';
import 'package:flutter/material.dart';

class LessonContentWidget extends StatelessWidget {
  final Map<String, dynamic>? lesson;
  final Map<String, dynamic>? course;

  const LessonContentWidget({super.key, this.lesson, this.course});

  @override
  Widget build(BuildContext context) {
    if (lesson == null) {
      return const Center(child: Text('No lesson selected'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lesson title
          Text(
            lesson!['title'] ?? 'Untitled Lesson',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Lesson metadata
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${lesson!['video_duration'] ?? 0} min',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.play_lesson, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Lesson ${lesson!['lesson_number'] ?? 1}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Lesson description
          if (lesson!['description'] != null) ...[
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              lesson!['description'],
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 24),
          ],

          // UPDATED: Lesson attachments with download functionality
          if (lesson!['attachments'] != null) ...[
            const Text(
              'Attachments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildAttachmentsList(lesson!['attachments']),
            const SizedBox(height: 24),
          ],

          // Lesson notes
          if (lesson!['notes'] != null) ...[
            const Text(
              'Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Text(
                lesson!['notes'],
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // UPDATED: Enhanced attachments list with proper download functionality
  Widget _buildAttachmentsList(dynamic attachments) {
    if (attachments == null) return const SizedBox.shrink();

    List<dynamic> attachmentsList = [];
    if (attachments is List) {
      attachmentsList = attachments;
    } else if (attachments is String) {
      try {
        // Try to parse as JSON
        final parsed = jsonDecode(attachments);
        if (parsed is List) {
          attachmentsList = parsed;
        } else {
          // Single string attachment
          attachmentsList = [attachments];
        }
      } catch (e) {
        // Single string attachment
        attachmentsList = [attachments];
      }
    }

    if (attachmentsList.isEmpty) {
      return Text(
        'No attachments available',
        style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
      );
    }

    return Column(
      children: attachmentsList.map((attachment) {
        return _buildDownloadableAttachment(attachment);
      }).toList(),
    );
  }

  Widget _buildDownloadableAttachment(dynamic attachment) {
    String fileName;
    String fileUrl;

    if (attachment is Map) {
      fileName = attachment['name'] ?? attachment['filename'] ?? 'Unknown file';
      fileUrl = attachment['url'] ?? attachment['file_url'] ?? '';
    } else {
      fileUrl = attachment.toString();
      fileName = fileUrl.split('/').last;
    }

    if (fileUrl.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Invalid attachment: $fileName',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }

    final fileExtension = fileName.split('.').last.toLowerCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            _getFileIcon(fileExtension),
            color: _getFileColor(fileExtension),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  fileExtension.toUpperCase(),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadAttachment(fileUrl, fileName),
            tooltip: 'Download $fileName',
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
        return Icons.archive;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String extension) {
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'zip':
      case 'rar':
        return Colors.purple;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.pink;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Colors.indigo;
      case 'mp3':
      case 'wav':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Future<void> _downloadAttachment(String fileUrl, String fileName) async {
    try {
      await AssessmentRepository.downloadFile(fileUrl, fileName);
      // Note: ScaffoldMessenger needs context, so this would need to be handled
      // by the parent widget or through a callback
    } catch (e) {
      debugPrint('Download failed: $e');
      // Handle error appropriately
    }
  }
}
