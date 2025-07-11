import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AnalyticsChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> analyticsData;
  final List<Map<String, dynamic>> testData;

  const AnalyticsChartWidget({
    super.key,
    required this.analyticsData,
    required this.testData,
  });

  @override
  State<AnalyticsChartWidget> createState() => _AnalyticsChartWidgetState();
}

class _AnalyticsChartWidgetState extends State<AnalyticsChartWidget> {
  String _selectedChart = 'learning_time';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chart Type Selector
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text(
                'Chart Type:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'learning_time',
                      label: Text('Learning Time'),
                      icon: Icon(Icons.access_time, size: 16),
                    ),
                    ButtonSegment(
                      value: 'lessons_completed',
                      label: Text('Lessons'),
                      icon: Icon(Icons.check_circle, size: 16),
                    ),
                    ButtonSegment(
                      value: 'quiz_scores',
                      label: Text('Quiz Scores'),
                      icon: Icon(Icons.grade, size: 16),
                    ),
                  ],
                  selected: {_selectedChart},
                  onSelectionChanged: (Set<String> selection) {
                    setState(() {
                      _selectedChart = selection.first;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Chart Container
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildSelectedChart(),
          ),
        ),

        const SizedBox(height: 20),

        // Download Report Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _downloadReport,
            icon: const Icon(Icons.download),
            label: const Text('Download Analytics Report'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedChart() {
    switch (_selectedChart) {
      case 'learning_time':
        return _buildLearningTimeChart();
      case 'lessons_completed':
        return _buildLessonsChart();
      case 'quiz_scores':
        return _buildQuizScoresChart();
      default:
        return _buildLearningTimeChart();
    }
  }

  Widget _buildLearningTimeChart() {
    if (widget.analyticsData.isEmpty) {
      return const Center(child: Text('No learning time data available'));
    }

    final spots = widget.analyticsData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final data = entry.value;
      final timeSpent = (data['time_spent_minutes'] as int? ?? 0).toDouble();
      return FlSpot(index, timeSpent);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Learning Time (Minutes)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}m');
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < widget.analyticsData.length) {
                        final date = DateTime.parse(widget.analyticsData[index]['date']);
                        return Text(DateFormat('MM/dd').format(date));
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLessonsChart() {
    if (widget.analyticsData.isEmpty) {
      return const Center(child: Text('No lessons data available'));
    }

    final spots = widget.analyticsData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final data = entry.value;
      final lessonsCompleted = (data['lessons_completed'] as int? ?? 0).toDouble();
      return FlSpot(index, lessonsCompleted);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Lessons Completed',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: BarChart(
            BarChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(value.toInt().toString());
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < widget.analyticsData.length) {
                        final date = DateTime.parse(widget.analyticsData[index]['date']);
                        return Text(DateFormat('MM/dd').format(date));
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true),
              barGroups: spots.map((spot) {
                return BarChartGroupData(
                  x: spot.x.toInt(),
                  barRods: [
                    BarChartRodData(
                      toY: spot.y,
                      color: Colors.green,
                      width: 20,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizScoresChart() {
    if (widget.testData.isEmpty) {
      return const Center(child: Text('No quiz scores data available'));
    }

    final spots = widget.testData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final data = entry.value;
      final percentage = (data['percentage'] as double? ?? 0.0);
      return FlSpot(index, percentage);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quiz Scores Over Time (%)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}%');
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < widget.testData.length) {
                        final date = DateTime.parse(widget.testData[index]['created_at']);
                        return Text(DateFormat('MM/dd').format(date));
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true),
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.orange,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.orange.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _downloadReport() {
    // Implement report download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Analytics report download feature coming soon!'),
      ),
    );
  }
}
