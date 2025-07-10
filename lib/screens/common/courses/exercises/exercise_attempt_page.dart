import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'exercise_repository.dart';

class ExerciseAttemptPage extends StatefulWidget {
  final String exerciseId;

  const ExerciseAttemptPage({super.key, required this.exerciseId});

  @override
  State<ExerciseAttemptPage> createState() => _ExerciseAttemptPageState();
}

class _ExerciseAttemptPageState extends State<ExerciseAttemptPage> {
  Map<String, dynamic>? _exercise;
  List<Map<String, dynamic>> _questions = [];
  String? _attemptId;
  int _currentQuestionIndex = 0;
  final Map<String, dynamic> _answers = {};
  bool _isLoading = true;
  String? _error;
  Timer? _timer;
  int _timeRemainingSeconds = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadExerciseData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadExerciseData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        ExerciseRepository.getExerciseById(widget.exerciseId),
        ExerciseRepository.getExerciseQuestions(widget.exerciseId),
      ]);

      final exercise = results[0] as Map<String, dynamic>?;
      final questions = results[1] as List<Map<String, dynamic>>;

      if (exercise == null) {
        setState(() {
          _error = 'Exercise not found';
          _isLoading = false;
        });
        return;
      }

      // Start attempt
      final attemptId = await ExerciseRepository.startExerciseAttempt(
        widget.exerciseId,
      );

      setState(() {
        _exercise = exercise;
        _questions = questions;
        _attemptId = attemptId;
        _isLoading = false;
      });

      _startTimer();
    } catch (e) {
      setState(() {
        _error = 'Failed to load exercise: $e';
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    final timeLimitMinutes = _exercise?['time_limit_minutes'] as int?;
    if (timeLimitMinutes == null) return;

    _timeRemainingSeconds = timeLimitMinutes * 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemainingSeconds--;
      });

      if (_timeRemainingSeconds <= 0) {
        _timer?.cancel();
        _autoSubmitExercise();
      }
    });
  }

  Future<void> _saveAnswer(String questionId, dynamic answer) async {
    if (_attemptId == null) return;

    setState(() {
      _answers[questionId] = answer;
    });

    try {
      await ExerciseRepository.saveExerciseAnswer(
        _attemptId!,
        questionId,
        answer,
      );
    } catch (e) {
      debugPrint('Failed to save answer: $e');
      // Continue anyway - we have local state
    }
  }

  Future<void> _submitExercise() async {
    if (_attemptId == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      _timer?.cancel();

      final result = await ExerciseRepository.submitExerciseAttempt(
        _attemptId!,
      );

      if (result['success'] == true) {
        // Navigate to results page
         if (!mounted) return;
        context.go(
          '/exercise/${widget.exerciseId}/results?attemptId=$_attemptId',
        );
      } else {
        throw Exception('Submission failed');
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit exercise: $e')));
    }
  }

  Future<void> _autoSubmitExercise() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Time up! Auto-submitting exercise...'),
        backgroundColor: Colors.orange,
      ),
    );
    await _submitExercise();
  }

  @override
  Widget build(BuildContext context) {
    return  PopScope(
    canPop: false, // Prevent automatic popping
    onPopInvokedWithResult: (bool didPop, Object? result) async {
    if (!didPop) {
      final shouldPop = await _showExitConfirmation();
      if (shouldPop && context.mounted) {
        Navigator.of(context).pop();
      }
    }
  },

      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () async {
              
              final shouldExit = await _showExitConfirmation();

            // Make sure the widget is still in the tree
            if (!mounted) return;

            if (shouldExit && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            },
          ),
          title: Text(
            _exercise?['title'] ?? 'Exercise',
            style: const TextStyle(color: Colors.black),
          ),
          actions: [
            if (_timeRemainingSeconds > 0)
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _timeRemainingSeconds < 300 ? Colors.red : Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatTime(_timeRemainingSeconds),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_questions.isEmpty) {
      return const Center(
        child: Text('No questions available for this exercise'),
      );
    }

    return Column(
      children: [
        // Progress indicator
        _buildProgressIndicator(),

        // Question content
        Expanded(child: _buildQuestionContent()),

        // Navigation buttons
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_answers.length}/${_questions.length} answered',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation(Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent() {
    final question = _questions[_currentQuestionIndex];
    final questionId = question['id'];
    final currentAnswer = _answers[questionId];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Q${_currentQuestionIndex + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${question['marks'] ?? 1} mark${(question['marks'] ?? 1) > 1 ? 's' : ''}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  question['question_text'] ?? 'No question text',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Answer options
          _buildAnswerOptions(question, currentAnswer),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(
    Map<String, dynamic> question,
    dynamic currentAnswer,
  ) {
    final questionType = question['question_type'] ?? 'mcq';
    final options = question['options'] as List?;

    switch (questionType) {
      case 'mcq':
        return _buildMCQOptions(question['id'], options, currentAnswer);
      case 'multiple_select':
        return _buildMultipleSelectOptions(
          question['id'],
          options,
          currentAnswer,
        );
      case 'true_false':
        return _buildTrueFalseOptions(question['id'], currentAnswer);
      case 'short_answer':
        return _buildShortAnswerInput(question['id'], currentAnswer);
      default:
        return _buildMCQOptions(question['id'], options, currentAnswer);
    }
  }

  Widget _buildMCQOptions(
    String questionId,
    List? options,
    dynamic currentAnswer,
  ) {
    if (options == null || options.isEmpty) {
      return const Text('No options available');
    }

    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final optionText = option is Map
            ? option['text'] ?? option.toString()
            : option.toString();
        final optionValue = option is Map
            ? option['value'] ?? index.toString()
            : index.toString();
        final isSelected = currentAnswer == optionValue;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _saveAnswer(questionId, optionValue),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue.withValues(alpha: 0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.blue : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 12)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      optionText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected ? Colors.blue : Colors.black,
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

  Widget _buildMultipleSelectOptions(
    String questionId,
    List? options,
    dynamic currentAnswer,
  ) {
    if (options == null || options.isEmpty) {
      return const Text('No options available');
    }

    final selectedAnswers = Set<String>.from(
      currentAnswer is List ? currentAnswer.cast<String>() : [],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select all that apply:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final optionText = option is Map
              ? option['text'] ?? option.toString()
              : option.toString();
          final optionValue = option is Map
              ? option['value'] ?? index.toString()
              : index.toString();
          final isSelected = selectedAnswers.contains(optionValue);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                final newSelection = Set<String>.from(selectedAnswers);
                if (isSelected) {
                  newSelection.remove(optionValue);
                } else {
                  newSelection.add(optionValue);
                }
                _saveAnswer(questionId, newSelection.toList());
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        optionText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected ? Colors.blue : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTrueFalseOptions(String questionId, dynamic currentAnswer) {
    return Row(
      children: [
        Expanded(
          child: _buildTrueFalseOption(
            questionId,
            'true',
            'True',
            currentAnswer,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTrueFalseOption(
            questionId,
            'false',
            'False',
            currentAnswer,
          ),
        ),
      ],
    );
  }

  Widget _buildTrueFalseOption(
    String questionId,
    String value,
    String label,
    dynamic currentAnswer,
  ) {
    final isSelected = currentAnswer == value;

    return InkWell(
      onTap: () => _saveAnswer(questionId, value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.blue : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShortAnswerInput(String questionId, dynamic currentAnswer) {
    return TextFormField(
      initialValue: currentAnswer?.toString() ?? '',
      onChanged: (value) => _saveAnswer(questionId, value),
      decoration: InputDecoration(
        hintText: 'Type your answer here...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.all(16),
      ),
      maxLines: 3,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
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
            flex: _currentQuestionIndex == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      if (_currentQuestionIndex < _questions.length - 1) {
                        setState(() {
                          _currentQuestionIndex++;
                        });
                      } else {
                        _showSubmitConfirmation();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentQuestionIndex == _questions.length - 1
                    ? Colors.green
                    : Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _currentQuestionIndex == _questions.length - 1
                          ? 'Submit Exercise'
                          : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
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
            onPressed: _loadExerciseData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showExitConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Exercise?'),
            content: const Text(
              'Are you sure you want to exit? Your progress will be saved, but you may lose time.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showSubmitConfirmation() async {
    final unanswered = _questions.length - _answers.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Exercise?'),
        content: Text(
          unanswered > 0
              ? 'You have $unanswered unanswered questions. Are you sure you want to submit?'
              : 'Are you sure you want to submit your exercise?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _submitExercise();
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
