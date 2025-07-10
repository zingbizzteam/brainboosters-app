// Create new file: quiz_attempt_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'assessment_repository.dart';

class QuizAttemptPage extends StatefulWidget {
  final String testId;
  final String? courseId;
  final String? lessonId;

  const QuizAttemptPage({
    super.key,
    required this.testId,
    this.courseId,
    this.lessonId,
  });

  @override
  State<QuizAttemptPage> createState() => _QuizAttemptPageState();
}

class _QuizAttemptPageState extends State<QuizAttemptPage> {
  Map<String, dynamic>? _test;
  List<Map<String, dynamic>> _questions = [];
  final Map<String, dynamic> _answers = {};
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  String? _error;
  DateTime? _startTime;
  int? _timeLimit;

  @override
  void initState() {
    super.initState();
    _loadTestData();
  }

  Future<void> _loadTestData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final test = await AssessmentRepository.getAssignmentById(widget.testId);
      final questions = await _getTestQuestions(widget.testId);

      setState(() {
        _test = test;
        _questions = questions;
        _timeLimit = test?['time_limit_minutes'];
        _startTime = DateTime.now();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load test: $e';
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              ElevatedButton(
                onPressed: _loadTestData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_test?['title'] ?? 'Quiz'),
        actions: [
          if (_timeLimit != null) _buildTimer(),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _showQuestionOverview,
          ),
        ],
      ),
      body: _buildQuizBody(),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  Widget _buildTimer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: StreamBuilder<int>(
        stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
        builder: (context, snapshot) {
          if (_startTime == null || _timeLimit == null) return const SizedBox();
          
          final elapsed = DateTime.now().difference(_startTime!).inMinutes;
          final remaining = _timeLimit! - elapsed;
          
          if (remaining <= 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _submitTest());
            return const Text('Time Up!', style: TextStyle(color: Colors.red));
          }
          
          return Text(
            '${remaining}m remaining',
            style: TextStyle(
              color: remaining <= 5 ? Colors.red : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuizBody() {
    if (_questions.isEmpty) {
      return const Center(child: Text('No questions available'));
    }

    final question = _questions[_currentQuestionIndex];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question progress
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          
          // Question number and text
          Text(
            'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            question['question_text'] ?? '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          
          // Answer options based on question type
          _buildAnswerOptions(question),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(Map<String, dynamic> question) {
    final questionType = question['question_type'] ?? 'mcq';
    final options = question['options'] as List<dynamic>? ?? [];
    final questionId = question['id'];

    switch (questionType) {
      case 'mcq':
        return _buildMCQOptions(questionId, options);
      case 'multiple_select':
        return _buildMultipleSelectOptions(questionId, options);
      case 'true_false':
        return _buildTrueFalseOptions(questionId);
      case 'short_answer':
        return _buildShortAnswerInput(questionId);
      case 'essay':
        return _buildEssayInput(questionId);
      default:
        return const Text('Unsupported question type');
    }
  }

  Widget _buildMCQOptions(String questionId, List<dynamic> options) {
    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = _answers[questionId] == index;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() {
                _answers[questionId] = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey,
                        width: 2,
                      ),
                      color: isSelected ? Colors.blue : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultipleSelectOptions(String questionId, List<dynamic> options) {
    final selectedAnswers = _answers[questionId] as List<int>? ?? [];

    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = selectedAnswers.contains(index);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() {
                final currentAnswers = List<int>.from(selectedAnswers);
                if (isSelected) {
                  currentAnswers.remove(index);
                } else {
                  currentAnswers.add(index);
                }
                _answers[questionId] = currentAnswers;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey,
                        width: 2,
                      ),
                      color: isSelected ? Colors.blue : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalseOptions(String questionId) {
    final selectedAnswer = _answers[questionId] as bool?;

    return Column(
      children: [
        _buildTrueFalseOption(questionId, true, 'True', selectedAnswer),
        const SizedBox(height: 12),
        _buildTrueFalseOption(questionId, false, 'False', selectedAnswer),
      ],
    );
  }

  Widget _buildTrueFalseOption(String questionId, bool value, String label, bool? selectedAnswer) {
    final isSelected = selectedAnswer == value;

    return InkWell(
      onTap: () {
        setState(() {
          _answers[questionId] = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? Colors.blue : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortAnswerInput(String questionId) {
    return TextField(
      onChanged: (value) {
        _answers[questionId] = value;
      },
      decoration: const InputDecoration(
        hintText: 'Enter your answer...',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildEssayInput(String questionId) {
    return TextField(
      onChanged: (value) {
        _answers[questionId] = value;
      },
      decoration: const InputDecoration(
        hintText: 'Write your essay here...',
        border: OutlineInputBorder(),
      ),
      maxLines: 10,
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentQuestionIndex--;
                  });
                },
                child: const Text('Previous'),
              ),
            ),
          if (_currentQuestionIndex > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentQuestionIndex < _questions.length - 1
                  ? () {
                      setState(() {
                        _currentQuestionIndex++;
                      });
                    }
                  : _submitTest,
              child: Text(
                _currentQuestionIndex < _questions.length - 1
                    ? 'Next'
                    : 'Submit Test',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuestionOverview() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Question Overview'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              final question = _questions[index];
              final isAnswered = _answers.containsKey(question['id']);
              final isCurrent = index == _currentQuestionIndex;

              return ListTile(
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrent
                        ? Colors.blue
                        : (isAnswered ? Colors.green : Colors.grey[300]),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isCurrent || isAnswered ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text('Question ${index + 1}'),
                subtitle: Text(isAnswered ? 'Answered' : 'Not answered'),
                onTap: () {
                  setState(() {
                    _currentQuestionIndex = index;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTest() async {
    try {
      // Calculate score
      final score = await _calculateScore();
      final totalMarks = _test?['total_marks']?.toDouble() ?? 0.0;
      final passingMarks = _test?['passing_marks']?.toDouble() ?? 0.0;
      final passed = score >= passingMarks;
      final timeTaken = _startTime != null 
          ? DateTime.now().difference(_startTime!).inMinutes
          : null;

      // Submit results
      await AssessmentRepository.supabase
          .from('test_results')
          .insert({
            'test_id': widget.testId,
            'student_id': await AssessmentRepository.getStudentId(),
            'score': score,
            'total_marks': totalMarks,
            'passed': passed,
            'time_taken_minutes': timeTaken,
            'answers': _answers,
            'completed_at': DateTime.now().toIso8601String(),
          });

      if (!mounted) return;

      // Navigate to results page
      context.go('/quiz/${widget.testId}/results');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit test: $e')),
      );
    }
  }

  Future<double> _calculateScore() async {
    double totalScore = 0.0;

    for (final question in _questions) {
      final questionId = question['id'];
      final userAnswer = _answers[questionId];
      final correctAnswers = question['correct_answers'];
      final marks = question['marks']?.toDouble() ?? 1.0;

      if (userAnswer == null) continue;

      // Score based on question type
      final questionType = question['question_type'] ?? 'mcq';
      switch (questionType) {
        case 'mcq':
        case 'true_false':
          if (userAnswer == correctAnswers) {
            totalScore += marks;
          }
          break;
        case 'multiple_select':
          final userAnswerList = userAnswer as List<int>;
          final correctAnswerList = correctAnswers as List<int>;
          if (_listsEqual(userAnswerList, correctAnswerList)) {
            totalScore += marks;
          }
          break;
        case 'short_answer':
        case 'essay':
          // These need manual grading, so don't add to automatic score
          break;
      }
    }

    return totalScore;
  }

  bool _listsEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    final sortedA = List<int>.from(a)..sort();
    final sortedB = List<int>.from(b)..sort();
    for (int i = 0; i < sortedA.length; i++) {
      if (sortedA[i] != sortedB[i]) return false;
    }
    return true;
  }
}
