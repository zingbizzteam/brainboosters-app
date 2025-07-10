// Create new file: assessment_navigation_helper.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'assessment_repository.dart';

class AssessmentNavigationHelper {
  /// Smart navigation that determines the correct action based on assessment status
  static Future<void> navigateToAssessment(
    BuildContext context,
    String assessmentId, {
    String? courseId,
    String? lessonId,
  }) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Get assessment details and submission status
      final results = await Future.wait([
        AssessmentRepository.getAssignmentById(assessmentId),
        AssessmentRepository.getStudentSubmission(assessmentId),
        AssessmentRepository.checkAssignmentAccess(assessmentId),
      ]);

      final assessment = results[0];
      final submission = results[1];
      final accessData = results[2] as Map<String, dynamic>;

      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();

      if (assessment == null) {
        _showError(context, 'Assessment not found');
        return;
      }

      if (!(accessData['hasAccess'] ?? false)) {
        _showError(context, 'You don\'t have access to this assessment');
        return;
      }

      // Determine navigation based on assessment type and status
      final testType = assessment['test_type'] ?? 'quiz';
      final hasSubmission = submission != null;

      if (hasSubmission) {
        // Student has completed the assessment - show results
        await _navigateToResults(
          context,
          assessmentId,
          testType,
          courseId,
          lessonId,
        );
      } else {
        // Student hasn't completed - show start/attempt page
        await _navigateToAttempt(
          context,
          assessmentId,
          testType,
          courseId,
          lessonId,
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) Navigator.of(context).pop();
      _showError(context, 'Failed to load assessment: $e');
    }
  }

  /// Navigate to results page
  static Future<void> _navigateToResults(
    BuildContext context,
    String assessmentId,
    String testType,
    String? courseId,
    String? lessonId,
  ) async {
    String route;

    switch (testType) {
      case 'assignment':
        route = '/assignment/$assessmentId';
        break;
      case 'quiz':
      case 'exam':
      case 'practice':
        route = '/quiz/$assessmentId/results';
        break;
      default:
        route = '/assignment/$assessmentId';
    }

    // Add query parameters
    final params = <String>[];
    if (courseId != null) params.add('courseId=$courseId');
    if (lessonId != null) params.add('lessonId=$lessonId');
    if (params.isNotEmpty) route += '?${params.join('&')}';

    context.go(route);
  }

  /// Navigate to attempt/start page
  static Future<void> _navigateToAttempt(
    BuildContext context,
    String assessmentId,
    String testType,
    String? courseId,
    String? lessonId,
  ) async {
    String route;

    switch (testType) {
      case 'assignment':
        route = '/assignment/$assessmentId';
        break;
      case 'quiz':
      case 'exam':
      case 'practice':
        route = '/quiz/$assessmentId/attempt';
        break;
      default:
        route = '/assignment/$assessmentId';
    }

    // Add query parameters
    final params = <String>[];
    if (courseId != null) params.add('courseId=$courseId');
    if (lessonId != null) params.add('lessonId=$lessonId');
    if (params.isNotEmpty) route += '?${params.join('&')}';

    context.go(route);
  }

  /// Show assessment options dialog
  static void showAssessmentOptions(
    BuildContext context,
    String assessmentId,
    Map<String, dynamic> assessment,
    Map<String, dynamic>? submission, {
    String? courseId,
    String? lessonId,
  }) {
    final testType = assessment['test_type'] ?? 'quiz';
    final hasSubmission = submission != null;
    final attemptsAllowed = assessment['attempts_allowed'] ?? 1;
    final canRetake =
        attemptsAllowed > 1 || attemptsAllowed == -1; // -1 = unlimited

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(assessment['title'] ?? 'Assessment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${testType.toUpperCase()}'),
            if (assessment['total_questions'] != null)
              Text('Questions: ${assessment['total_questions']}'),
            if (assessment['time_limit_minutes'] != null)
              Text('Time Limit: ${assessment['time_limit_minutes']} minutes'),
            Text('Total Marks: ${assessment['total_marks'] ?? 0}'),
            if (hasSubmission) ...[
              const SizedBox(height: 8),
              const Divider(),
              const Text(
                'Status: Completed',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (submission!['score'] != null)
                Text(
                  'Score: ${submission['score']}/${assessment['total_marks']}',
                ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (hasSubmission) ...[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToResults(
                  context,
                  assessmentId,
                  testType,
                  courseId,
                  lessonId,
                );
              },
              child: const Text('View Results'),
            ),
            if (canRetake) ...[
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showRetakeConfirmation(
                    context,
                    assessmentId,
                    testType,
                    courseId,
                    lessonId,
                  );
                },
                child: const Text('Retake'),
              ),
            ],
          ] else ...[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToAttempt(
                  context,
                  assessmentId,
                  testType,
                  courseId,
                  lessonId,
                );
              },
              child: Text(
                testType == 'assignment' ? 'Start Assignment' : 'Start Quiz',
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Show retake confirmation
  static void _showRetakeConfirmation(
    BuildContext context,
    String assessmentId,
    String testType,
    String? courseId,
    String? lessonId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retake Assessment'),
        content: const Text(
          'Are you sure you want to retake this assessment? Your previous results will be replaced.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToAttempt(
                context,
                assessmentId,
                testType,
                courseId,
                lessonId,
              );
            },
            child: const Text('Retake'),
          ),
        ],
      ),
    );
  }

  static void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
