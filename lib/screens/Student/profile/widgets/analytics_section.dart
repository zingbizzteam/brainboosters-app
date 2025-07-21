import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsSection extends StatefulWidget {
  final String studentId;
  final Map<String, dynamic> analyticsData;

  const AnalyticsSection({
    super.key,
    required this.studentId,
    required this.analyticsData,
  });

  @override
  State<AnalyticsSection> createState() => _AnalyticsSectionState();
}

class _AnalyticsSectionState extends State<AnalyticsSection> {
  String _selectedPeriod = '30 days';
  List<Map<String, dynamic>> _chartData = [];
  List<Map<String, dynamic>> _testResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);
    
    try {
      final days = _selectedPeriod == '7 days' ? 7 : 
                   _selectedPeriod == '30 days' ? 30 : 90;
      
      // Load learning analytics
      final analyticsResponse = await Supabase.instance.client
          .from('learning_analytics')
          .select()
          .eq('student_id', widget.studentId)
          .gte('date', DateTime.now().subtract(Duration(days: days)).toIso8601String())
          .order('date', ascending: true);

      // Load test results
      final testResponse = await Supabase.instance.client
          .from('test_results')
          .select('''
            *,
            tests(title, total_marks)
          ''')
          .eq('student_id', widget.studentId)
          .gte('created_at', DateTime.now().subtract(Duration(days: days)).toIso8601String())
          .order('created_at', ascending: false);

      setState(() {
        _chartData = List<Map<String, dynamic>>.from(analyticsResponse);
        _testResults = List<Map<String, dynamic>>.from(testResponse);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            _buildLearningTimeChart(),
            const SizedBox(height: 24),
            _buildProgressChart(),
            const SizedBox(height: 24),
            _buildTestPerformanceChart(),
            const SizedBox(height: 24),
            _buildTestResultsList(),
          ],
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['7 days', '30 days', '90 days'].map((period) {
            return ChoiceChip(
              label: Text(period),
              selected: _selectedPeriod == period,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedPeriod = period);
                  _loadAnalyticsData();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLearningTimeChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Learning Time (Minutes)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < _chartData.length) {
                            final date = DateTime.parse(_chartData[value.toInt()]['date']);
                            return Text('${date.day}/${date.month}');
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
                      spots: _chartData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          (entry.value['time_spent_minutes'] ?? 0).toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: const Color(0xFF5DADE2),
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Learning Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: widget.analyticsData['completed_courses'].toDouble(),
                      title: 'Completed',
                      color: const Color(0xFF27AE60),
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: (widget.analyticsData['total_courses'] - 
                              widget.analyticsData['completed_courses']).toDouble(),
                      title: 'In Progress',
                      color: const Color(0xFF3498DB),
                      radius: 60,
                    ),
                  ],
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestPerformanceChart() {
    if (_testResults.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Test Performance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('No test results available'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: true),
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
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < _testResults.length) {
                            return Text('Test ${value.toInt() + 1}');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: _testResults.take(10).toList().asMap().entries.map((entry) {
                    final percentage = entry.value['percentage'] ?? 0.0;
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: percentage.toDouble(),
                          color: percentage >= 70 
                              ? const Color(0xFF27AE60)
                              : percentage >= 50
                                  ? const Color(0xFFE67E22)
                                  : const Color(0xFFE74C3C),
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResultsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Test Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_testResults.isEmpty)
              const Center(child: Text('No test results available'))
            else
              ...(_testResults.take(5).map((result) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: result['passed'] == true
                      ? const Color(0xFF27AE60)
                      : const Color(0xFFE74C3C),
                  child: Icon(
                    result['passed'] == true ? Icons.check : Icons.close,
                    color: Colors.white,
                  ),
                ),
                title: Text(result['tests']['title']),
                subtitle: Text(
                  'Score: ${result['score']}/${result['total_marks']} (${result['percentage']?.toStringAsFixed(1)}%)',
                ),
                trailing: Text(
                  DateTime.parse(result['created_at']).toString().split(' ')[0],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ))),
          ],
        ),
      ),
    );
  }
}
