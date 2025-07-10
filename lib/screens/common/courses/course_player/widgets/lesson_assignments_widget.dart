import 'dart:convert';
import 'package:brainboosters_app/screens/common/courses/assesment/assessment_repository.dart';
import 'package:brainboosters_app/screens/common/courses/assesment/assessment_navigation_helper.dart';
import 'package:flutter/material.dart';

class LessonAssignmentsWidget extends StatefulWidget {
  final String? lessonId;
  final String? courseId; // Added courseId parameter

  const LessonAssignmentsWidget({super.key, this.lessonId, this.courseId});

  @override
  State<LessonAssignmentsWidget> createState() =>
      _LessonAssignmentsWidgetState();
}

class _LessonAssignmentsWidgetState extends State<LessonAssignmentsWidget> {
  List<Map<String, dynamic>> _assignments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  @override
  void didUpdateWidget(LessonAssignmentsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lessonId != oldWidget.lessonId) {
      _loadAssignments();
    }
  }

  Future<void> _loadAssignments() async {
    if (widget.lessonId == null) return;

    setState(() => _isLoading = true);

    try {
      final assignments = await AssessmentRepository.getAssignmentsForLesson(
        widget.lessonId!,
      );

      if (mounted) {
        setState(() {
          _assignments = assignments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _assignments = [];
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load assignments: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lessonId == null) {
      return const Center(child: Text('No lesson selected'));
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No assignments for this lesson',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _assignments.length,
      itemBuilder: (context, index) {
        final assignment = _assignments[index];
        return _buildAssignmentCard(assignment);
      },
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    final isCompleted = assignment['status'] == 'completed';
    final testType = assignment['test_type'] ?? 'assignment';

    // FIXED: Robust date parsing that handles both DateTime objects and strings
    DateTime? dueDate;
    try {
      final dueDateValue = assignment['due_date'];
      if (dueDateValue != null) {
        if (dueDateValue is DateTime) {
          dueDate = dueDateValue;
        } else if (dueDateValue is String) {
          dueDate = DateTime.parse(dueDateValue);
        }
      }
    } catch (e) {
      debugPrint('Error parsing due date: $e');
      dueDate = null;
    }

    final isOverdue = dueDate != null && DateTime.now().isAfter(dueDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with icon, title, and status
            Row(
              children: [
                Icon(
                  _getAssignmentIcon(testType),
                  color: isCompleted
                      ? Colors.green
                      : (isOverdue ? Colors.red : Colors.orange),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    assignment['title'] ?? 'Untitled Assignment',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green
                        : (isOverdue ? Colors.red : Colors.orange),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCompleted
                        ? 'Completed'
                        : (isOverdue ? 'Overdue' : 'Pending'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              assignment['description'] ?? 'No description available',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),

            // Assignment details
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (assignment['total_questions'] != null)
                  _buildInfoChip(
                    Icons.quiz,
                    '${assignment['total_questions']} questions',
                    Colors.blue,
                  ),
                if (assignment['total_marks'] != null)
                  _buildInfoChip(
                    Icons.grade,
                    '${assignment['total_marks']} marks',
                    Colors.green,
                  ),
                if (assignment['time_limit_minutes'] != null)
                  _buildInfoChip(
                    Icons.timer,
                    '${assignment['time_limit_minutes']} min',
                    Colors.orange,
                  ),
              ],
            ),

            // Resources and attachments section
            if (assignment['resources'] != null) ...[
              const SizedBox(height: 16),
              _buildResourcesSection(assignment['resources']),
            ],

            // FIXED: Safe due date display
            if (dueDate != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: isOverdue ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${_formatDate(dueDate)}',
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.grey[600],
                      fontSize: 14,
                      fontWeight: isOverdue
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (isOverdue) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'OVERDUE',
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
            ],

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Info button to show details
                OutlinedButton.icon(
                  onPressed: () => _showAssignmentDetails(assignment),
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('Details'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Smart primary action button
                ElevatedButton.icon(
                  onPressed: () => _handleAssignmentAction(assignment),
                  icon: Icon(_getActionIcon(assignment)),
                  label: Text(_getActionLabel(assignment)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getActionColor(assignment),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Smart action handling
  void _handleAssignmentAction(Map<String, dynamic> assignment) {
    final submission = assignment['submission'] ?? assignment['result'];

    if (submission != null) {
      // Has submission - show options dialog
      AssessmentNavigationHelper.showAssessmentOptions(
        context,
        assignment['id'],
        assignment,
        submission,
        courseId: widget.courseId,
        lessonId: widget.lessonId,
      );
    } else {
      // No submission - navigate to attempt
      AssessmentNavigationHelper.navigateToAssessment(
        context,
        assignment['id'],
        courseId: widget.courseId,
        lessonId: widget.lessonId,
      );
    }
  }

  // NEW: Show detailed assignment information
  void _showAssignmentDetails(Map<String, dynamic> assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(assignment['title'] ?? 'Assignment Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                'Type',
                assignment['test_type']?.toString().toUpperCase() ??
                    'ASSIGNMENT',
              ),
              if (assignment['total_questions'] != null)
                _buildDetailRow(
                  'Questions',
                  assignment['total_questions'].toString(),
                ),
              if (assignment['total_marks'] != null)
                _buildDetailRow(
                  'Total Marks',
                  assignment['total_marks'].toString(),
                ),
              if (assignment['passing_marks'] != null)
                _buildDetailRow(
                  'Passing Marks',
                  assignment['passing_marks'].toString(),
                ),
              if (assignment['time_limit_minutes'] != null)
                _buildDetailRow(
                  'Time Limit',
                  '${assignment['time_limit_minutes']} minutes',
                ),
              if (assignment['attempts_allowed'] != null)
                _buildDetailRow(
                  'Attempts Allowed',
                  assignment['attempts_allowed'].toString(),
                ),
              if (assignment['description'] != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(assignment['description']),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleAssignmentAction(assignment);
            },
            child: Text(_getActionLabel(assignment)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Helper methods for dynamic button appearance
  IconData _getActionIcon(Map<String, dynamic> assignment) {
    final isCompleted = assignment['status'] == 'completed';
    final testType = assignment['test_type'] ?? 'assignment';

    if (isCompleted) {
      return Icons.visibility;
    } else {
      switch (testType) {
        case 'quiz':
        case 'exam':
          return Icons.quiz;
        case 'assignment':
          return Icons.assignment;
        default:
          return Icons.play_arrow;
      }
    }
  }

  String _getActionLabel(Map<String, dynamic> assignment) {
    final isCompleted = assignment['status'] == 'completed';
    final testType = assignment['test_type'] ?? 'assignment';

    if (isCompleted) {
      return 'View Results';
    } else {
      switch (testType) {
        case 'quiz':
        case 'exam':
          return 'Start Quiz';
        case 'assignment':
          return 'Start Assignment';
        default:
          return 'Start';
      }
    }
  }

  Color _getActionColor(Map<String, dynamic> assignment) {
    final isCompleted = assignment['status'] == 'completed';

    if (isCompleted) {
      return Colors.green;
    } else {
      final dueDate = assignment['due_date'];
      if (dueDate != null) {
        try {
          final due = DateTime.parse(dueDate.toString());
          final isOverdue = DateTime.now().isAfter(due);
          return isOverdue ? Colors.red : Colors.blue;
        } catch (e) {
          return Colors.blue;
        }
      }
      return Colors.blue;
    }
  }

  // NEW: Resources section with downloadable files
  Widget _buildResourcesSection(dynamic resources) {
    final resourceList = _parseJsonArray(resources);
    if (resourceList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resources:',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        ...resourceList.map((resource) => _buildDownloadableItem(resource)),
      ],
    );
  }

  Widget _buildDownloadableItem(String resourceUrl) {
    final fileName = resourceUrl.split('/').last;
    final fileExtension = fileName.split('.').last.toLowerCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            _getFileIcon(fileExtension),
            color: _getFileColor(fileExtension),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download, size: 16),
            onPressed: () => _downloadFile(resourceUrl, fileName),
            tooltip: 'Download',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  List<String> _parseJsonArray(dynamic jsonData) {
    if (jsonData == null) return [];
    if (jsonData is List) {
      return jsonData.map((item) => item.toString()).toList();
    }
    if (jsonData is String) {
      try {
        final parsed = jsonDecode(jsonData);
        if (parsed is List) {
          return parsed.map((item) => item.toString()).toList();
        }
      } catch (e) {
        debugPrint('Error parsing JSON: $e');
      }
    }
    return [];
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
        return Colors.deepPurple;
      case 'mp3':
      case 'wav':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getAssignmentIcon(String? type) {
    switch (type) {
      case 'quiz':
        return Icons.quiz;
      case 'coding':
        return Icons.code;
      case 'essay':
        return Icons.edit;
      case 'project':
        return Icons.work;
      case 'presentation':
        return Icons.slideshow;
      default:
        return Icons.assignment;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _downloadFile(String url, String fileName) async {
    try {
      await AssessmentRepository.downloadFile(url, fileName);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Downloaded $fileName')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
  }
}
