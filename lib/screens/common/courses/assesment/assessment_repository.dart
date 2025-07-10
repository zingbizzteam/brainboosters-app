// assessment_repository.dart - COMPLETE UNIFIED VERSION
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AssessmentRepository {
  static final _supabase = Supabase.instance.client;
  static SupabaseClient get supabase => _supabase;
  static Future<String> getStudentId() => _getStudentId();
  static Future<String> startQuizAttempt(String testId) async {
    try {
      final studentId = await _getStudentId();

      // Check if student already has an attempt
      final existingResult = await _supabase
          .from('test_results')
          .select('id')
          .eq('test_id', testId)
          .eq('student_id', studentId)
          .maybeSingle();

      if (existingResult != null) {
        throw Exception('You have already attempted this assessment');
      }

      // Check attempts allowed
      final test = await _supabase
          .from('tests')
          .select('attempts_allowed')
          .eq('id', testId)
          .single();

      final attemptsAllowed = test['attempts_allowed'] ?? 1;
      if (attemptsAllowed <= 0) {
        throw Exception('No attempts remaining for this assessment');
      }

      return testId; // Return test ID to start attempt
    } catch (e) {
      throw Exception('Failed to start assessment: $e');
    }
  }

  // UNIFIED: Get all assessments (assignments, quizzes, exams) for a lesson
  static Future<List<Map<String, dynamic>>> getAssignmentsForLesson(
    String lessonId,
  ) async {
    try {
      // First get lesson details to find chapter and course
      final lesson = await _supabase
          .from('lessons')
          .select('id, chapter_id, course_id')
          .eq('id', lessonId)
          .single();

      // Get ALL test types for this lesson, its chapter, and the course
      final response = await _supabase
          .from('tests')
          .select('''
            *,
            courses!inner(id, title),
            chapters(id, title),
            lessons(id, title),
            teachers!inner(
              id,
              user_profiles!inner(first_name, last_name)
            )
          ''')
          .eq('is_published', true)
          .or(
            'lesson_id.eq.${lesson['id']},chapter_id.eq.${lesson['chapter_id']},course_id.eq.${lesson['course_id']}',
          )
          .order('created_at');

      return await _enrichWithSubmissionStatus(response);
    } catch (e) {
      throw Exception('Failed to load assignments: $e');
    }
  }

  // UNIFIED: Get assessments for a chapter (including chapter-level tests)
  static Future<List<Map<String, dynamic>>> getAssessmentsForChapter(
    String chapterId,
  ) async {
    try {
      final response = await _supabase
          .from('tests')
          .select('''
            *,
            courses!inner(id, title),
            chapters!inner(id, title),
            lessons(id, title),
            teachers!inner(
              id,
              user_profiles!inner(first_name, last_name)
            )
          ''')
          .eq('chapter_id', chapterId)
          .eq('is_published', true)
          .isFilter('lesson_id', null)
          .order('created_at');

      return await _enrichWithSubmissionStatus(response);
    } catch (e) {
      throw Exception('Failed to load chapter assessments: $e');
    }
  }

  // UNIFIED: Get specific assessment by ID (works for all types)
  static Future<Map<String, dynamic>?> getAssignmentById(String testId) async {
    try {
      final response = await _supabase
          .from('tests')
          .select('''
            *,
            courses!inner(id, title),
            chapters(id, title),
            lessons(id, title),
            teachers!inner(
              id,
              user_profiles!inner(first_name, last_name)
            )
          ''')
          .eq('id', testId)
          .eq('is_published', true)
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to load assignment: $e');
    }
  }

  // UNIFIED: Get student submission (works for all types)
  static Future<Map<String, dynamic>?> getStudentSubmission(
    String testId,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final studentId = await _getStudentId();

      // First check what type of test this is
      final test = await _supabase
          .from('tests')
          .select('test_type')
          .eq('id', testId)
          .single();

      if (test['test_type'] == 'assignment') {
        // For assignments, check assignment_submissions table
        final response = await _supabase
            .from('assignment_submissions')
            .select('*')
            .eq('assignment_id', testId)
            .eq('student_id', studentId)
            .maybeSingle();
        return response;
      } else {
        // For quizzes/exams, check test_results table
        final response = await _supabase
            .from('test_results')
            .select('*')
            .eq('test_id', testId)
            .eq('student_id', studentId)
            .maybeSingle();
        return response;
      }
    } catch (e) {
      return null;
    }
  }

  // UNIFIED: Check access (works for all types)
  static Future<Map<String, dynamic>> checkAssignmentAccess(
    String testId,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {'hasAccess': false, 'reason': 'Not authenticated'};
      }

      final test = await _supabase
          .from('tests')
          .select('course_id')
          .eq('id', testId)
          .single();

      final studentId = await _getStudentId();

      final enrollment = await _supabase
          .from('course_enrollments')
          .select('id')
          .eq('course_id', test['course_id'])
          .eq('student_id', studentId)
          .eq('is_active', true)
          .maybeSingle();

      return {
        'hasAccess': enrollment != null,
        'reason': enrollment == null ? 'Not enrolled in course' : null,
      };
    } catch (e) {
      return {'hasAccess': false, 'reason': 'Error checking access: $e'};
    }
  }

  // UNIFIED: Submit assignment or start quiz
  static Future<void> submitAssignment(
    String testId, {
    String? submissionText,
    String? submissionUrl,
    List<String>? fileUrls,
  }) async {
    try {
      final studentId = await _getStudentId();

      // Check test type to determine submission method
      final test = await _supabase
          .from('tests')
          .select('test_type')
          .eq('id', testId)
          .single();

      if (test['test_type'] == 'assignment') {
        // Submit assignment
        await _supabase.from('assignment_submissions').insert({
          'assignment_id': testId,
          'student_id': studentId,
          'submission_text': submissionText,
          'submission_url': submissionUrl,
          'submission_files': fileUrls ?? [],
          'submission_status': 'submitted',
        });
      } else {
        // For quizzes/exams, create test result entry
        await _supabase.from('test_results').insert({
          'test_id': testId,
          'student_id': studentId,
          'score': 0,
          'total_marks': 0,
          'is_submitted': false,
        });
      }
    } catch (e) {
      throw Exception('Failed to submit: $e');
    }
  }

  // UNIFIED: Download functionality
  static Future<void> downloadFile(String url, String fileName) async {
    try {
      final validatedUrl = await _validateDownloadUrl(url);

      if (validatedUrl == null) {
        throw Exception('Invalid or unauthorized file URL');
      }

      if (await canLaunchUrl(Uri.parse(validatedUrl))) {
        await launchUrl(Uri.parse(validatedUrl));
      } else {
        throw Exception('Cannot open download URL');
      }
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }

  // PRIVATE: Enrich assessments with submission status
  static Future<List<Map<String, dynamic>>> _enrichWithSubmissionStatus(
    List<dynamic> assessments,
  ) async {
    final studentId = await _getStudentId();
    final enrichedAssessments = List<Map<String, dynamic>>.from(assessments);

    for (var assessment in enrichedAssessments) {
      if (assessment['test_type'] == 'assignment') {
        // For assignments, check assignment_submissions table
        final submission = await _supabase
            .from('assignment_submissions')
            .select('id, submitted_at, grade, submission_status')
            .eq('assignment_id', assessment['id'])
            .eq('student_id', studentId)
            .maybeSingle();

        assessment['submission'] = submission;
        assessment['status'] = submission != null ? 'completed' : 'pending';
        assessment['score'] = submission?['grade'];
      } else {
        // For quizzes/exams, check test_results table
        final result = await _supabase
            .from('test_results')
            .select('id, completed_at, score, total_marks, percentage, passed')
            .eq('test_id', assessment['id'])
            .eq('student_id', studentId)
            .maybeSingle();

        assessment['result'] = result;
        assessment['status'] = result != null ? 'completed' : 'pending';
        assessment['score'] = result?['score'];
        assessment['percentage'] = result?['percentage'];
      }
    }

    return enrichedAssessments;
  }

  static Future<String?> _validateDownloadUrl(String url) async {
    try {
      final response = await _supabase.functions.invoke(
        'validate-download',
        body: {'file_url': url},
      );

      return response.data['signed_url'];
    } catch (e) {
      debugPrint('URL validation failed: $e');
      return null;
    }
  }

  static Future<String> _getStudentId() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final student = await _supabase
        .from('students')
        .select('id')
        .eq('user_id', user.id)
        .single();

    return student['id'];
  }
}
