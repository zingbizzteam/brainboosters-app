import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'exercise_repository.dart';

class ExerciseResultsPage extends StatefulWidget {
  final String exerciseId;

  const ExerciseResultsPage({super.key, required this.exerciseId});

  @override
  State<ExerciseResultsPage> createState() => _ExerciseResultsPageState();
}

class _ExerciseResultsPageState extends State<ExerciseResultsPage> {
  List<Map<String, dynamic>> _results = [];
  Map<String, dynamic>? _selectedAttempt;
  Map<String, dynamic>? _analytics;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await ExerciseRepository.getExerciseResults(
        widget.exerciseId,
      );

      setState(() {
        _results = results;
        _selectedAttempt = results.isNotEmpty ? results.first : null;
        _isLoading = false;
      });

      if (_selectedAttempt != null) {
        await _loadAnalytics(_selectedAttempt!['id']);
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load results: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAnalytics(String attemptId) async {
    try {
      final analytics = await ExerciseRepository.getExerciseAnalytics(
        attemptId,
      );
      setState(() {
        _analytics = analytics;
      });
    } catch (e) {
      debugPrint('Failed to load analytics: $e');
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
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Exercise Results',
          style: TextStyle(color: Colors.black),
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

    if (_results.isEmpty) {
      return _buildNoResultsState();
    }

    return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results summary
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(right: BorderSide(color: Colors.grey[200]!)),
          ),
          child: _buildResultsList(),
        ),
        // Detailed analysis
        Expanded(child: _buildDetailedAnalysis()),
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
                Tab(text: 'Summary'),
                Tab(text: 'Analysis'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [_buildResultsList(), _buildDetailedAnalysis()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Attempts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ..._results.asMap().entries.map((entry) {
            final index = entry.key;
            final result = entry.value;
            final isSelected = _selectedAttempt?['id'] == result['id'];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedAttempt = result;
                  });
                  _loadAnalytics(result['id']);
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Attempt ${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.blue : Colors.black,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getScoreColor(result['percentage']),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${result['percentage']}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Score: ${result['score']}/${result['total_marks']}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        'Time: ${result['time_taken_minutes']} minutes',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        'Completed: ${_formatDate(result['completed_at'])}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailedAnalysis() {
    if (_selectedAttempt == null) {
      return const Center(
        child: Text('Select an attempt to view detailed analysis'),
      );
    }

    if (_analytics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final summary = _analytics!['summary'] as Map<String, dynamic>;
    final questionAnalysis = _analytics!['questionAnalysis'] as List<dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance summary
          _buildPerformanceSummary(summary),

          const SizedBox(height: 32),

          // Question-by-question analysis
          const Text(
            'Question Analysis',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ...questionAnalysis.asMap().entries.map((entry) {
            final index = entry.key;
            final analysis = entry.value as Map<String, dynamic>;
            return _buildQuestionAnalysis(index + 1, analysis);
          }),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummary(Map<String, dynamic> summary) {
    final percentage = _selectedAttempt!['percentage'] as int;
    final totalQuestions = summary['totalQuestions'] as int;
    final correctAnswers = summary['correctAnswers'] as int;
    final incorrectAnswers = summary['incorrectAnswers'] as int;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getScoreColor(percentage),
            _getScoreColor(percentage).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$percentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Performance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPerformanceMessage(percentage),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Correct',
                  correctAnswers.toString(),
                  '$totalQuestions',
                  Colors.white.withValues(alpha: 0.2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Incorrect',
                  incorrectAnswers.toString(),
                  '$totalQuestions',
                  Colors.white.withValues(alpha: 0.2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Time Taken',
                  '${_selectedAttempt!['time_taken_minutes']}',
                  'minutes',
                  Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String suffix,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: '/$suffix',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionAnalysis(
    int questionNumber,
    Map<String, dynamic> analysis,
  ) {
    final question = analysis['question'] as Map<String, dynamic>;
    final isCorrect = analysis['isCorrect'] as bool;
    final studentAnswer = analysis['studentAnswer'];
    final correctAnswer = analysis['correctAnswer'];
    final explanation = analysis['explanation'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withValues(alpha: 0.05)
            : Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Q$questionNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Correct' : 'Incorrect',
                style: TextStyle(
                  color: isCorrect ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            question['question_text'] ?? 'No question text',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 12),

          if (studentAnswer != null) ...[
            Text(
              'Your Answer: ${_formatAnswer(studentAnswer)}',
              style: TextStyle(
                color: isCorrect ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
          ],

          Text(
            'Correct Answer: ${_formatAnswer(correctAnswer)}',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
            ),
          ),

          if (explanation != null && explanation.toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.blue[600],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Explanation',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    explanation.toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
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
          ElevatedButton(onPressed: _loadResults, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete the exercise to see your results here.',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/exercise/${widget.exerciseId}'),
            child: const Text('Take Exercise'),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getPerformanceMessage(int percentage) {
    if (percentage >= 90) return 'Excellent work!';
    if (percentage >= 80) return 'Great job!';
    if (percentage >= 70) return 'Good effort!';
    if (percentage >= 60) return 'Keep practicing!';
    return 'Need more practice';
  }

  String _formatAnswer(dynamic answer) {
    if (answer == null) return 'No answer';
    if (answer is List) {
      return answer.join(', ');
    }
    return answer.toString();
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
