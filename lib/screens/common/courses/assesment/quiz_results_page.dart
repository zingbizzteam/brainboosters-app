// Create new file: quiz_results_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'assessment_repository.dart';

class QuizResultsPage extends StatefulWidget {
  final String testId;
  final String? courseId;
  final String? lessonId;

  const QuizResultsPage({
    super.key,
    required this.testId,
    this.courseId,
    this.lessonId,
  });

  @override
  State<QuizResultsPage> createState() => _QuizResultsPageState();
}

class _QuizResultsPageState extends State<QuizResultsPage>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _test;
  Map<String, dynamic>? _result;
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadResultsData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadResultsData() async {
  try {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final results = await Future.wait([
      AssessmentRepository.getAssignmentById(widget.testId),
      AssessmentRepository.getStudentSubmission(widget.testId),
      _getTestQuestions(widget.testId),
    ]);

    final test = results[0] as Map<String, dynamic>?;
    final result = results[1] as Map<String, dynamic>?;
    final questions = results[2] as List<Map<String, dynamic>>;

    setState(() {
      _test = test;
      _result = result;
      _questions = questions;
      _isLoading = false;
    });

    // ADDED: Validate answer data structure
    if (result != null && !_validateAnswerData()) {
      debugPrint('Answer data validation failed - some answers may not display correctly');
    }

    // Start animations after data loads
    _animationController.forward();
  } catch (e) {
    setState(() {
      _error = 'Failed to load results: $e';
      _isLoading = false;
    });
  }
}

  Future<List<Map<String, dynamic>>> _getTestQuestions(String testId) async {
    try {
      final response = await AssessmentRepository.supabase
          .from('test_questions')
          .select('*')
          .eq('test_id', testId)
          .order('question_order');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load questions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => _navigateBack(),
        ),
        title: Text(
          _test?['title'] ?? 'Quiz Results',
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: _shareResults,
          ),
        ],
      ),
      body: _buildBody(isDesktop),
    );
  }

  Widget _buildBody(bool isDesktop) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading your results...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_result == null) {
      return _buildNoResultsState();
    }

    return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results summary
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildResultsContent(),
          ),
        ),
        // Question review
        Container(
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(left: BorderSide(color: Colors.grey[200]!)),
          ),
          child: _buildQuestionReview(),
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
                Tab(text: 'Results'),
                Tab(text: 'Review'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildResultsContent(),
                ),
                _buildQuestionReview(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsContent() {
    final result = _result!;
    final test = _test!;
    final score = result['score']?.toDouble() ?? 0.0;
    final totalMarks = result['total_marks']?.toDouble() ?? 0.0;
    final percentage = result['percentage']?.toDouble() ?? 0.0;
    final passed = result['passed'] ?? false;
    final timeTaken = result['time_taken_minutes'];
    final completedAt = result['completed_at'];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score Card
          ScaleTransition(
            scale: _scaleAnimation,
            child: _buildScoreCard(score, totalMarks, percentage, passed),
          ),
          const SizedBox(height: 24),

          // Performance Metrics
          _buildPerformanceMetrics(timeTaken, completedAt, test),
          const SizedBox(height: 24),

          // Score Breakdown
          _buildScoreBreakdown(score, totalMarks, test),
          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildScoreCard(
    double score,
    double totalMarks,
    double percentage,
    bool passed,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: passed
              ? [Colors.green[400]!, Colors.green[600]!]
              : [Colors.orange[400]!, Colors.orange[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (passed ? Colors.green : Colors.orange).withValues(
              alpha: 0.3,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            passed ? Icons.celebration : Icons.thumb_up,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            passed ? 'Congratulations!' : 'Good Effort!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            passed ? 'You passed the quiz!' : 'Keep practicing!',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScoreMetric(
                'Score',
                '${score.toStringAsFixed(1)}/${totalMarks.toStringAsFixed(1)}',
              ),
              _buildScoreMetric(
                'Percentage',
                '${percentage.toStringAsFixed(1)}%',
              ),
              _buildScoreMetric('Status', passed ? 'PASSED' : 'FAILED'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetrics(
    int? timeTaken,
    String? completedAt,
    Map<String, dynamic> test,
  ) {
    final timeLimit = test['time_limit_minutes'];
    final completionDate = completedAt != null
        ? DateTime.parse(completedAt)
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Metrics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  Icons.access_time,
                  'Time Taken',
                  timeTaken != null ? '$timeTaken minutes' : 'Not recorded',
                  timeLimit != null ? 'Limit: $timeLimit min' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  Icons.calendar_today,
                  'Completed',
                  completionDate != null
                      ? '${completionDate.day}/${completionDate.month}/${completionDate.year}'
                      : 'Date not available',
                  completionDate != null
                      ? '${completionDate.hour}:${completionDate.minute.toString().padLeft(2, '0')}'
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    IconData icon,
    String title,
    String value,
    String? subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ],
    );
  }

  Widget _buildScoreBreakdown(
    double score,
    double totalMarks,
    Map<String, dynamic> test,
  ) {
    final passingMarks = test['passing_marks']?.toDouble() ?? 0.0;
    final totalQuestions = test['total_questions'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Score Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildProgressBar('Your Score', score, totalMarks, Colors.blue),
          const SizedBox(height: 12),
          _buildProgressBar(
            'Passing Score',
            passingMarks,
            totalMarks,
            Colors.green,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Questions: $totalQuestions'),
              Text('Correct: ${_calculateCorrectAnswers()}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    String label,
    double value,
    double max,
    Color color,
  ) {
    final percentage = max > 0 ? (value / max) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              '${value.toStringAsFixed(1)}/${max.toStringAsFixed(1)}',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildQuestionReview() {
    if (_questions.isEmpty) {
      return const Center(child: Text('No questions to review'));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Question Review',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final question = _questions[index];
                return _buildQuestionReviewItem(question, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionReviewItem(
    Map<String, dynamic> question,
    int questionNumber,
  ) {
    final userAnswers = _result?['answers'] as Map<String, dynamic>? ?? {};
    final userAnswer = userAnswers[question['id']];
    final correctAnswers = question['correct_answers'];
    final isCorrect = _isAnswerCorrect(
      userAnswer,
      correctAnswers,
      question['question_type'],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect ? Colors.green[300]! : Colors.red[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
                child: Icon(
                  isCorrect ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Question $questionNumber',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                '${question['marks'] ?? 1} mark${(question['marks'] ?? 1) > 1 ? 's' : ''}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question['question_text'] ?? '',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          if (userAnswer != null) ...[
            Text(
              'Your Answer: ${_formatAnswer(userAnswer, question)}',
              style: TextStyle(
                color: isCorrect ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (!isCorrect) ...[
            const SizedBox(height: 4),
            Text(
              'Correct Answer: ${_formatAnswer(correctAnswers, question)}',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _retakeQuiz,
            icon: const Icon(Icons.refresh),
            label: const Text('Retake Quiz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _navigateBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Course'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
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
            onPressed: _loadResultsData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No Results Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'You haven\'t completed this quiz yet.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _startQuiz, child: const Text('Take Quiz')),
        ],
      ),
    );
  }

  // Helper methods
  int _calculateCorrectAnswers() {
    if (_result == null || _questions.isEmpty) return 0;

    final userAnswers = _result!['answers'] as Map<String, dynamic>? ?? {};
    int correct = 0;

    for (final question in _questions) {
      final userAnswer = userAnswers[question['id']];
      final correctAnswers = question['correct_answers'];
      if (_isAnswerCorrect(
        userAnswer,
        correctAnswers,
        question['question_type'],
      )) {
        correct++;
      }
    }

    return correct;
  }

  bool _isAnswerCorrect(
  dynamic userAnswer,
  dynamic correctAnswers,
  String? questionType,
) {
  if (userAnswer == null) return false;
  
  try {
    switch (questionType) {
      case 'mcq':
        return _compareMCQAnswer(userAnswer, correctAnswers);
      case 'true_false':
        return _compareTrueFalseAnswer(userAnswer, correctAnswers);
      case 'multiple_select':
        return _compareMultipleSelectAnswer(userAnswer, correctAnswers);
      default:
        return false; // Short answer and essay need manual grading
    }
  } catch (e) {
    debugPrint('Error comparing answers: $e');
    return false;
  }
}
bool _compareMCQAnswer(dynamic userAnswer, dynamic correctAnswer) {
  // Extract actual values from potentially complex objects
  final userValue = _extractAnswerValue(userAnswer);
  final correctValue = _extractAnswerValue(correctAnswer);
  
  return userValue == correctValue;
}

bool _compareTrueFalseAnswer(dynamic userAnswer, dynamic correctAnswer) {
  final userBool = _extractBooleanValue(userAnswer);
  final correctBool = _extractBooleanValue(correctAnswer);
  
  return userBool == correctBool;
}

bool _compareMultipleSelectAnswer(dynamic userAnswer, dynamic correctAnswer) {
  final userList = _extractListValue(userAnswer);
  final correctList = _extractListValue(correctAnswer);
  
  if (userList.length != correctList.length) return false;
  
  final sortedUser = List<int>.from(userList)..sort();
  final sortedCorrect = List<int>.from(correctList)..sort();
  
  for (int i = 0; i < sortedUser.length; i++) {
    if (sortedUser[i] != sortedCorrect[i]) return false;
  }
  
  return true;
}

// Helper methods to extract values from complex objects
dynamic _extractAnswerValue(dynamic answer) {
  if (answer is int || answer is String) return answer;
  if (answer is Map<String, dynamic>) {
    return answer['value'] ?? answer['answer'] ?? answer['selected_option'];
  }
  if (answer is List && answer.isNotEmpty) {
    return answer.first;
  }
  return answer;
}

bool? _extractBooleanValue(dynamic answer) {
  if (answer is bool) return answer;
  if (answer is String) {
    final lower = answer.toLowerCase();
    if (lower == 'true' || lower == '1') return true;
    if (lower == 'false' || lower == '0') return false;
  }
  if (answer is int) return answer == 1;
  if (answer is Map<String, dynamic>) {
    return _extractBooleanValue(answer['value'] ?? answer['answer']);
  }
  return null;
}

List<int> _extractListValue(dynamic answer) {
  if (answer is List<int>) return answer;
  if (answer is List) {
    return answer
        .map((item) => item is int ? item : int.tryParse(item.toString()))
        .where((item) => item != null)
        .cast<int>()
        .toList();
  }
  if (answer is Map<String, dynamic>) {
    final list = answer['values'] ?? answer['answers'] ?? answer['selected_options'];
    return _extractListValue(list);
  }
  if (answer is String) {
    try {
      return answer.split(',')
          .map((s) => int.tryParse(s.trim()))
          .where((item) => item != null)
          .cast<int>()
          .toList();
    } catch (e) {
      return [];
    }
  }
  return [];
}
bool _validateAnswerData() {
  if (_result == null) return false;
  
  final answers = _result!['answers'];
  if (answers == null) {
    debugPrint('No answers found in result data');
    return false;
  }
  
  if (answers is! Map<String, dynamic>) {
    debugPrint('Answers is not a Map: ${answers.runtimeType}');
    return false;
  }
  
  // Validate each answer
  bool hasValidationErrors = false;
  answers.forEach((questionId, answer) {
    if (answer == null) {
      debugPrint('Null answer for question: $questionId');
      return;
    }
    
    // Log answer structure for debugging
    debugPrint('Question $questionId: ${answer.runtimeType} = $answer');
    
    // Check for unexpected data types
    if (answer is Map && !answer.containsKey('value') && !answer.containsKey('answer')) {
      debugPrint('Warning: Complex answer object without expected keys for question $questionId');
      hasValidationErrors = true;
    }
  });
  
  return !hasValidationErrors;
}

  

  String _formatAnswer(dynamic answer, Map<String, dynamic> question) {
  if (answer == null) return 'Not answered';
  
  final questionType = question['question_type'] ?? 'mcq';
  final options = question['options'] as List<dynamic>? ?? [];
  
  // DEBUG: Log the actual answer structure
  debugPrint('Formatting answer: $answer (${answer.runtimeType}) for question type: $questionType');
  
  switch (questionType) {
    case 'mcq':
      return _formatMCQAnswer(answer, options);
    case 'multiple_select':
      return _formatMultipleSelectAnswer(answer, options);
    case 'true_false':
      return _formatTrueFalseAnswer(answer);
    case 'short_answer':
    case 'essay':
      return _formatTextAnswer(answer);
    default:
      return answer.toString();
  }
}
String _formatMCQAnswer(dynamic answer, List<dynamic> options) {
  try {
    int? index;
    
    // Handle different possible answer formats
    if (answer is int) {
      index = answer;
    } else if (answer is String) {
      index = int.tryParse(answer);
    } else if (answer is Map<String, dynamic>) {
      // Handle complex answer objects
      index = answer['selected_option'] as int? ?? 
             answer['answer'] as int? ?? 
             answer['value'] as int?;
    } else if (answer is List && answer.isNotEmpty) {
      // Handle array format [0] for single selection
      final firstItem = answer.first;
      if (firstItem is int) {
        index = firstItem;
      } else if (firstItem is String) {
        index = int.tryParse(firstItem);
      }
    }
    
    if (index != null && index >= 0 && index < options.length) {
      return options[index].toString();
    }
    
    // Fallback: try to match answer text directly
    final answerText = answer.toString().toLowerCase();
    for (int i = 0; i < options.length; i++) {
      if (options[i].toString().toLowerCase() == answerText) {
        return options[i].toString();
      }
    }
    
    return 'Invalid answer: $answer';
  } catch (e) {
    debugPrint('Error formatting MCQ answer: $e');
    return 'Error displaying answer';
  }
}

// FIXED: Robust multiple select answer formatting
String _formatMultipleSelectAnswer(dynamic answer, List<dynamic> options) {
  try {
    List<int> indices = [];
    
    if (answer is List<int>) {
      indices = answer;
    } else if (answer is List) {
      // Convert mixed list to integers
      indices = answer
          .map((item) => item is int ? item : int.tryParse(item.toString()))
          .where((item) => item != null)
          .cast<int>()
          .toList();
    } else if (answer is Map<String, dynamic>) {
      // Handle complex answer objects
      final selectedOptions = answer['selected_options'] ?? 
                             answer['answers'] ?? 
                             answer['values'];
      if (selectedOptions is List) {
        indices = selectedOptions
            .map((item) => item is int ? item : int.tryParse(item.toString()))
            .where((item) => item != null)
            .cast<int>()
            .toList();
      }
    } else if (answer is String) {
      // Handle comma-separated string "0,2,3"
      try {
        indices = answer.split(',')
            .map((s) => int.tryParse(s.trim()))
            .where((item) => item != null)
            .cast<int>()
            .toList();
      } catch (e) {
        debugPrint('Error parsing string answer: $e');
      }
    }
    
    final selectedOptions = indices
        .where((i) => i >= 0 && i < options.length)
        .map((i) => options[i].toString())
        .toList();
    
    return selectedOptions.isNotEmpty 
        ? selectedOptions.join(', ') 
        : 'No options selected';
  } catch (e) {
    debugPrint('Error formatting multiple select answer: $e');
    return 'Error displaying answer';
  }
}

// FIXED: Robust true/false answer formatting
String _formatTrueFalseAnswer(dynamic answer) {
  try {
    if (answer is bool) {
      return answer ? 'True' : 'False';
    } else if (answer is String) {
      final lowerAnswer = answer.toLowerCase();
      if (lowerAnswer == 'true' || lowerAnswer == '1') return 'True';
      if (lowerAnswer == 'false' || lowerAnswer == '0') return 'False';
    } else if (answer is int) {
      return answer == 1 ? 'True' : 'False';
    } else if (answer is Map<String, dynamic>) {
      final value = answer['value'] ?? answer['answer'] ?? answer['selected'];
      return _formatTrueFalseAnswer(value);
    }
    
    return answer.toString();
  } catch (e) {
    debugPrint('Error formatting true/false answer: $e');
    return 'Error displaying answer';
  }
}

// FIXED: Robust text answer formatting
String _formatTextAnswer(dynamic answer) {
  try {
    if (answer is String) {
      return answer.trim().isEmpty ? 'No answer provided' : answer;
    } else if (answer is Map<String, dynamic>) {
      final text = answer['text'] ?? answer['answer'] ?? answer['value'];
      return text?.toString() ?? 'No answer provided';
    }
    
    return answer.toString();
  } catch (e) {
    debugPrint('Error formatting text answer: $e');
    return 'Error displaying answer';
  }
}


  void _navigateBack() {
    if (widget.courseId != null && widget.lessonId != null) {
      context.go('/course/${widget.courseId}/lesson/${widget.lessonId}');
    } else if (widget.courseId != null) {
      context.go('/course/${widget.courseId}');
    } else {
      context.go('/courses');
    }
  }

  void _retakeQuiz() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retake Quiz'),
        content: const Text(
          'Are you sure you want to retake this quiz? Your current results will be replaced.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(
                '/quiz/${widget.testId}/attempt?courseId=${widget.courseId}&lessonId=${widget.lessonId}',
              );
            },
            child: const Text('Retake'),
          ),
        ],
      ),
    );
  }

  void _startQuiz() {
    context.go(
      '/quiz/${widget.testId}/attempt?courseId=${widget.courseId}&lessonId=${widget.lessonId}',
    );
  }

  void _shareResults() {
    final score = _result?['score']?.toDouble() ?? 0.0;
    final totalMarks = _result?['total_marks']?.toDouble() ?? 0.0;
    final percentage = _result?['percentage']?.toDouble() ?? 0.0;
    final testTitle = _test?['title'] ?? 'Quiz';

    final shareText =
        'I just completed "$testTitle" and scored ${score.toStringAsFixed(1)}/${totalMarks.toStringAsFixed(1)} (${percentage.toStringAsFixed(1)}%)!';

    // Implement sharing functionality here
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Share functionality: $shareText')));
  }
}
