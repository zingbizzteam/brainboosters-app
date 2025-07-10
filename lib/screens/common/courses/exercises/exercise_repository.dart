import 'package:supabase_flutter/supabase_flutter.dart';

class ExerciseRepository {
  static final _supabase = Supabase.instance.client;

  static Future<Map<String, dynamic>?> getExerciseById(String testId) async {
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
          .eq('test_type', 'practice') // Filter for practice exercises
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to load exercise: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getExerciseQuestions(String testId) async {
    try {
      final response = await _supabase
          .from('test_questions')
          .select('*')
          .eq('test_id', testId)
          .order('question_order');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load exercise questions: $e');
    }
  }

  static Future<Map<String, dynamic>?> getStudentAttempt(String testId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final studentId = await _getStudentId();
      
      final response = await _supabase
          .from('test_attempts')
          .select('*')
          .eq('test_id', testId)
          .eq('student_id', studentId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> checkExerciseAccess(String testId) async {
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

  static Future<String> startExerciseAttempt(String testId) async {
    try {
      final studentId = await _getStudentId();
      
      // Check if there's an active attempt
      final activeAttempt = await _supabase
          .from('test_attempts')
          .select('id')
          .eq('test_id', testId)
          .eq('student_id', studentId)
          .eq('status', 'in_progress')
          .maybeSingle();

      if (activeAttempt != null) {
        return activeAttempt['id'];
      }

      // Create new attempt
      final response = await _supabase
          .from('test_attempts')
          .insert({
            'test_id': testId,
            'student_id': studentId,
            'started_at': DateTime.now().toIso8601String(),
            'status': 'in_progress',
            'answers': {},
          })
          .select('id')
          .single();

      return response['id'];
    } catch (e) {
      throw Exception('Failed to start exercise attempt: $e');
    }
  }

  static Future<void> saveExerciseAnswer(
    String attemptId,
    String questionId,
    dynamic answer,
  ) async {
    try {
      // Get current answers
      final currentAttempt = await _supabase
          .from('test_attempts')
          .select('answers')
          .eq('id', attemptId)
          .single();

      final currentAnswers = Map<String, dynamic>.from(currentAttempt['answers'] ?? {});
      currentAnswers[questionId] = answer;

      // Update answers
      await _supabase
          .from('test_attempts')
          .update({
            'answers': currentAnswers,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', attemptId);

    } catch (e) {
      throw Exception('Failed to save answer: $e');
    }
  }

  static Future<Map<String, dynamic>> submitExerciseAttempt(String attemptId) async {
    try {
      // Get attempt data
      final attempt = await _supabase
          .from('test_attempts')
          .select('''
            *,
            tests!inner(
              id, total_questions, total_marks, time_limit_minutes
            )
          ''')
          .eq('id', attemptId)
          .single();

      // Calculate score
      final scoreData = await _calculateExerciseScore(
        attempt['test_id'],
        attempt['answers'],
      );

      // Update attempt with results
      final updatedAttempt = await _supabase
          .from('test_attempts')
          .update({
            'completed_at': DateTime.now().toIso8601String(),
            'status': 'completed',
            'score': scoreData['score'],
            'total_marks': scoreData['totalMarks'],
            'percentage': scoreData['percentage'],
            'time_taken_minutes': _calculateTimeTaken(attempt['started_at']),
          })
          .eq('id', attemptId)
          .select()
          .single();

      return {
        'success': true,
        'attempt': updatedAttempt,
        'score': scoreData['score'],
        'totalMarks': scoreData['totalMarks'],
        'percentage': scoreData['percentage'],
      };

    } catch (e) {
      throw Exception('Failed to submit exercise: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getExerciseResults(String testId) async {
    try {
      final studentId = await _getStudentId();
      
      final response = await _supabase
          .from('test_attempts')
          .select('*')
          .eq('test_id', testId)
          .eq('student_id', studentId)
          .eq('status', 'completed')
          .order('completed_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load exercise results: $e');
    }
  }

  static Future<Map<String, dynamic>> getExerciseAnalytics(String attemptId) async {
    try {
      final attempt = await _supabase
          .from('test_attempts')
          .select('''
            *,
            tests!inner(id, title, total_questions)
          ''')
          .eq('id', attemptId)
          .single();

      final questions = await getExerciseQuestions(attempt['test_id']);
      final answers = Map<String, dynamic>.from(attempt['answers'] ?? {});

      List<Map<String, dynamic>> questionAnalysis = [];
      int correctAnswers = 0;

      for (final question in questions) {
        final questionId = question['id'];
        final studentAnswer = answers[questionId];
        final correctAnswer = question['correct_answer'];
        final isCorrect = _compareAnswers(studentAnswer, correctAnswer);
        
        if (isCorrect) correctAnswers++;

        questionAnalysis.add({
          'question': question,
          'studentAnswer': studentAnswer,
          'correctAnswer': correctAnswer,
          'isCorrect': isCorrect,
          'explanation': question['explanation'],
        });
      }

      return {
        'attempt': attempt,
        'questionAnalysis': questionAnalysis,
        'summary': {
          'totalQuestions': questions.length,
          'correctAnswers': correctAnswers,
          'incorrectAnswers': questions.length - correctAnswers,
          'accuracy': questions.isNotEmpty ? (correctAnswers / questions.length * 100) : 0,
        },
      };

    } catch (e) {
      throw Exception('Failed to load exercise analytics: $e');
    }
  }

  // Helper methods remain the same...
  static Future<Map<String, dynamic>> _calculateExerciseScore(
    String testId,
    Map<String, dynamic> answers,
  ) async {
    final questions = await getExerciseQuestions(testId);
    
    double totalScore = 0;
    double totalMarks = 0;

    for (final question in questions) {
      final questionId = question['id'];
      final marks = (question['marks'] as num?)?.toDouble() ?? 1.0;
      totalMarks += marks;

      final studentAnswer = answers[questionId];
      final correctAnswer = question['correct_answer'];

      if (_compareAnswers(studentAnswer, correctAnswer)) {
        totalScore += marks;
      }
    }

    final percentage = totalMarks > 0 ? (totalScore / totalMarks * 100) : 0.0;

    return {
      'score': totalScore,
      'totalMarks': totalMarks,
      'percentage': percentage.round(),
    };
  }

  static bool _compareAnswers(dynamic studentAnswer, dynamic correctAnswer) {
    if (studentAnswer == null || correctAnswer == null) return false;
    
    if (correctAnswer is List) {
      if (studentAnswer is List) {
        final studentSet = Set.from(studentAnswer);
        final correctSet = Set.from(correctAnswer);
        return studentSet.length == correctSet.length && 
               studentSet.every((element) => correctSet.contains(element));
      }
      return false;
    }
    
    return studentAnswer.toString().toLowerCase().trim() == 
           correctAnswer.toString().toLowerCase().trim();
  }

  static int _calculateTimeTaken(String startedAt) {
    final startTime = DateTime.parse(startedAt);
    final endTime = DateTime.now();
    return endTime.difference(startTime).inMinutes;
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
