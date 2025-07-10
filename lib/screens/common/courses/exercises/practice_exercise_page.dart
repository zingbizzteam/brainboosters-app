// ignore_for_file: unnecessary_cast

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'exercise_repository.dart';

class PracticeExercisePage extends StatefulWidget {
  final String exerciseId;
  final String? courseId;
  final String? lessonId;

  const PracticeExercisePage({
    super.key,
    required this.exerciseId,
    this.courseId,
    this.lessonId,
  });

  @override
  State<PracticeExercisePage> createState() => _PracticeExercisePageState();
}

class _PracticeExercisePageState extends State<PracticeExercisePage> {
  Map<String, dynamic>? _exercise;
  Map<String, dynamic>? _attempt;
  bool _isLoading = true;
  String? _error;
  bool _hasAccess = false;

  @override
  void initState() {
    super.initState();
    _loadExerciseData();
  }

  Future<void> _loadExerciseData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        ExerciseRepository.getExerciseById(widget.exerciseId),
        ExerciseRepository.getStudentAttempt(widget.exerciseId),
        ExerciseRepository.checkExerciseAccess(widget.exerciseId),
      ]);

      setState(() {
        _exercise = results[0];
        _attempt = results[1] as Map<String, dynamic>?;
        _hasAccess = (results[2] as Map<String, dynamic>)['hasAccess'] ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load exercise: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _exercise?['title'] ?? 'Practice Exercise',
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (!_hasAccess) {
      return _buildAccessDeniedState();
    }

    return _buildExerciseContent();
  }

  Widget _buildExerciseContent() {
    final exercise = _exercise!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.fitness_center, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Practice Exercise',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  exercise['title'] ?? 'Untitled Exercise',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Exercise description
          Text(
            'Instructions',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            exercise['description'] ?? 'No instructions provided',
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),

          const SizedBox(height: 24),

          // Exercise content/questions
          if (exercise['questions'] != null) ...[
            Text(
              'Questions',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildQuestionsList(exercise['questions']),
          ],

          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _startExercise,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _attempt == null ? 'Start Exercise' : 'Continue Exercise',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (_attempt != null) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _viewResults,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'View Results',
                      style: TextStyle(fontSize: 16),
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

  Widget _buildQuestionsList(dynamic questions) {
    final questionList = questions is List ? questions : [];

    return Column(
      children: questionList.asMap().entries.map((entry) {
        final index = entry.key;
        final question = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                question['question_text'] ?? 'No question text',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      }).toList(),
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
            'You need to be enrolled in this course to access exercises.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _startExercise() async {
    // Navigate to exercise attempt page
    context.go('/exercise/${widget.exerciseId}/attempt');
  }

  Future<void> _viewResults() async {
    // Navigate to results page
    context.go('/exercise/${widget.exerciseId}/results');
  }
}
