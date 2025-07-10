import 'dart:convert';

import 'package:brainboosters_app/screens/common/courses/assesment/assessment_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AssignmentPage extends StatefulWidget {
  final String assignmentId;
  final String? courseId;
  final String? lessonId;

  const AssignmentPage({
    super.key,
    required this.assignmentId,
    this.courseId,
    this.lessonId,
  });

  @override
  State<AssignmentPage> createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  Map<String, dynamic>? _assignment;
  Map<String, dynamic>? _submission;
  bool _isLoading = true;
  String? _error;
  bool _hasAccess = false;

  @override
  void initState() {
    super.initState();
    _loadAssignmentData();
  }

  Future<void> _loadAssignmentData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        AssessmentRepository.getAssignmentById(widget.assignmentId),
        AssessmentRepository.getStudentSubmission(widget.assignmentId),
        AssessmentRepository.checkAssignmentAccess(widget.assignmentId),
      ]);

      final assignment = results[0];
      final submission = results[1];
      final accessData = results[2] as Map<String, dynamic>;

      setState(() {
        _assignment = assignment;
        _submission = submission;
        _hasAccess = accessData['hasAccess'] ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load assignment: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // FIXED: Safe navigation with fallback
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              // Fallback navigation based on context
              if (widget.courseId != null) {
                context.go('/course/${widget.courseId}');
              } else {
                context.go('/courses');
              }
            }
          },
        ),
        title: Text(
          _assignment?['title'] ?? 'Assignment',
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: _buildBody(isDesktop),
    );
  }

  Widget _buildBody(bool isDesktop) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (!_hasAccess) {
      return _buildAccessDeniedState();
    }

    return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Assignment content
        Expanded(
          flex: 7,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildAssignmentContent(),
          ),
        ),
        // Submission panel
        Container(
          width: 400,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(left: BorderSide(color: Colors.grey[200]!)),
          ),
          child: _buildSubmissionPanel(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              tabs: [
                Tab(text: 'Assignment'),
                Tab(text: 'Submission'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildAssignmentContent(),
                ),
                _buildSubmissionPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentContent() {
    final assignment = _assignment!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Assignment header
        _buildAssignmentHeader(assignment),
        const SizedBox(height: 24),

        // Assignment description
        _buildSection(
          'Description',
          Text(
            assignment['description'] ?? 'No description provided',
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
        ),

        // Instructions
        if (assignment['instructions'] != null) ...[
          const SizedBox(height: 24),
          _buildSection(
            'Instructions',
            Text(
              assignment['instructions'],
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ),
        ],

        // Resources and attachments
        if (assignment['resources'] != null) ...[
          const SizedBox(height: 24),
          _buildResourcesSection(assignment['resources']),
        ],

        // Rubric
        if (assignment['rubric'] != null) ...[
          const SizedBox(height: 24),
          _buildRubricSection(assignment['rubric']),
        ],
      ],
    );
  }

  Widget _buildAssignmentHeader(Map<String, dynamic> assignment) {
    final dueDate = assignment['due_date'] != null
        ? DateTime.parse(assignment['due_date'])
        : null;
    final isOverdue = dueDate != null && DateTime.now().isAfter(dueDate);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            assignment['title'] ?? 'Untitled Assignment',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                Icons.assignment,
                assignment['assignment_type'] ?? 'Assignment',
                Colors.blue,
              ),
              _buildInfoChip(
                Icons.grade,
                '${assignment['total_marks'] ?? 0} marks',
                Colors.green,
              ),
              if (dueDate != null)
                _buildInfoChip(
                  Icons.schedule,
                  'Due: ${_formatDate(dueDate)}',
                  isOverdue ? Colors.red : Colors.orange,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildResourcesSection(dynamic resources) {
    final resourceList = _parseJsonArray(resources);
    if (resourceList.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      'Resources & Attachments',
      Column(
        children: resourceList.map((resource) {
          return _buildDownloadableItem(resource);
        }).toList(),
      ),
    );
  }

  Widget _buildDownloadableItem(String resourceUrl) {
    final fileName = resourceUrl.split('/').last;
    final fileExtension = fileName.split('.').last.toLowerCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
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
            onPressed: () => _downloadFile(resourceUrl, fileName),
            tooltip: 'Download',
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionPanel() {
  return Container(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _assignment!['test_type'] == 'assignment' 
              ? 'Your Submission'
              : 'Assessment Status',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        if (_submission == null) ...[
          // Show appropriate form based on test type
          if (_assignment!['test_type'] == 'assignment')
            _buildSubmissionForm()
          else
            _buildQuizStartForm(),
        ] else ...[
          _buildSubmissionStatus(),
        ],
      ],
    ),
  );
}
Widget _buildQuizStartForm() {
  final test = _assignment!;
  final totalQuestions = test['total_questions'] ?? 0;
  final timeLimit = test['time_limit_minutes'];
  final totalMarks = test['total_marks'] ?? 0;

  return Column(
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue[300]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.blue.withValues(alpha: 0.05),
        ),
        child: Column(
          children: [
            Icon(Icons.quiz, size: 48, color: Colors.blue[600]),
            const SizedBox(height: 16),
            Text(
              'Ready to start?',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '$totalQuestions questions • $totalMarks marks',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (timeLimit != null) ...[
              const SizedBox(height: 4),
              Text(
                'Time limit: $timeLimit minutes',
                style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _startQuiz,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Start Assessment'),
        ),
      ),
    ],
  );
}

// NEW: Start quiz method
Future<void> _startQuiz() async {
  try {
    await AssessmentRepository.startQuizAttempt(widget.assignmentId);
    
    if (!mounted) return;
    
    // Navigate to quiz attempt page
    context.go('/quiz/${widget.assignmentId}/attempt?courseId=${widget.courseId}&lessonId=${widget.lessonId}');
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to start quiz: $e')),
    );
  }
}
  Widget _buildSubmissionForm() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(Icons.cloud_upload, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Upload your assignment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Drag and drop files here or click to browse',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitAssignment,
            child: const Text('Submit Assignment'),
          ),
        ),
      ],
    );
  }

  // Update _buildSubmissionStatus method in AssignmentPage
Widget _buildSubmissionStatus() {
  final submission = _submission!;
  final assignment = _assignment!;
  
  // FIXED: Handle both assignment submissions and test results
  if (assignment['test_type'] == 'assignment') {
    return _buildAssignmentSubmissionStatus(submission);
  } else {
    return _buildTestResultsStatus(submission);
  }
}

Widget _buildAssignmentSubmissionStatus(Map<String, dynamic> submission) {
  final isGraded = submission['grade'] != null;
  final submittedAt = submission['submitted_at'];
  final submissionDate = submittedAt != null ? _parseDateTime(submittedAt) : null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assignment Submitted',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    submissionDate != null 
                        ? 'Submitted on ${_formatDate(submissionDate)}'
                        : 'Submission date unavailable',
                    style: TextStyle(
                      fontSize: 12, 
                      color: Colors.grey[600],
                      fontStyle: submissionDate == null ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      if (isGraded) ...[
        const SizedBox(height: 16),
        _buildGradeDisplay(submission),
      ],
    ],
  );
}

// NEW: Handle test results display
Widget _buildTestResultsStatus(Map<String, dynamic> result) {
  final completedAt = result['completed_at'];
  final completionDate = completedAt != null ? _parseDateTime(completedAt) : null;
  final score = result['score']?.toDouble() ?? 0.0;
  final totalMarks = result['total_marks']?.toDouble() ?? 0.0;
  final percentage = result['percentage']?.toDouble() ?? 0.0;
  final passed = result['passed'] ?? false;
  final timeTaken = result['time_taken_minutes'];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Completion Status
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: passed ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: passed ? Colors.green.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3)
          ),
        ),
        child: Row(
          children: [
            Icon(
              passed ? Icons.check_circle : Icons.info_outline,
              color: passed ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    passed ? 'Assessment Passed' : 'Assessment Completed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: passed ? Colors.green : Colors.orange,
                    ),
                  ),
                  Text(
                    completionDate != null 
                        ? 'Completed on ${_formatDate(completionDate)}'
                        : 'Completion date unavailable',
                    style: TextStyle(
                      fontSize: 12, 
                      color: Colors.grey[600],
                      fontStyle: completionDate == null ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      const SizedBox(height: 16),
      
      // Score Display
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Score',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${score.toStringAsFixed(1)}/${totalMarks.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Percentage: ${percentage.toStringAsFixed(1)}%'),
                if (timeTaken != null)
                  Text('Time: $timeTaken minutes'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: totalMarks > 0 ? score / totalMarks : 0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                passed ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildGradeDisplay(Map<String, dynamic> submission) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.blue.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.grade, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              'Grade: ${submission['grade'] ?? 'Not graded'}/${_assignment!['total_marks'] ?? 0}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        if (submission['feedback'] != null && submission['feedback'].toString().isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Feedback:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(submission['feedback'].toString()),
        ],
      ],
    ),
  );
}


  Widget _buildRubricSection(dynamic rubric) {
    // Implementation for rubric display
    return _buildSection(
      'Grading Rubric',
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: const Text('Rubric details will be displayed here'),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: TextStyle(color: Colors.red[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadAssignmentData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessDeniedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Access Denied',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'You need to be enrolled in this course to access assignments.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
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
        return Colors.indigo;
      case 'mp3':
      case 'wav':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _downloadFile(String url, String fileName) async {
    try {
      // Implement secure file download
      await AssessmentRepository.downloadFile(url, fileName);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Downloaded $fileName')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to download: $e')));
    }
  }

  Future<void> _submitAssignment() async {
    try {
      // Implement assignment submission
      await AssessmentRepository.submitAssignment(widget.assignmentId);
      await _loadAssignmentData(); // Refresh data
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment submitted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
    }
  }
}

DateTime? _parseDateTime(dynamic dateValue) {
  if (dateValue == null) return null;

  try {
    if (dateValue is String) {
      if (dateValue.isEmpty) return null;
      return DateTime.parse(dateValue);
    } else if (dateValue is DateTime) {
      return dateValue;
    } else {
      // Handle other potential formats
      return DateTime.parse(dateValue.toString());
    }
  } catch (e) {
    debugPrint('Error parsing date: $dateValue, Error: $e');
    return null;
  }
}
