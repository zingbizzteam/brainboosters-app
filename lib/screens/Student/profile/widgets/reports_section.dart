import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/pdf_generator_service.dart';

class ReportsSection extends StatefulWidget {
  final String studentId;
  final Map<String, dynamic> studentData;
  final Map<String, dynamic> profileData;

  const ReportsSection({
    super.key,
    required this.studentId,
    required this.studentData,
    required this.profileData,
  });

  @override
  State<ReportsSection> createState() => _ReportsSectionState();
}

class _ReportsSectionState extends State<ReportsSection> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedReportType = 'progress';
  bool _isGenerating = false;

  final List<Map<String, dynamic>> _reportTypes = [
    {
      'id': 'progress',
      'title': 'Progress Report',
      'description': 'Overall learning progress and course completion',
      'icon': Icons.trending_up,
    },
    {
      'id': 'performance',
      'title': 'Performance Report',
      'description': 'Test scores and quiz performance analysis',
      'icon': Icons.assessment,
    },
    {
      'id': 'activity',
      'title': 'Activity Report',
      'description': 'Daily learning activities and time spent',
      'icon': Icons.access_time,
    },
    {
      'id': 'detailed',
      'title': 'Detailed Report',
      'description': 'Comprehensive report with all metrics',
      'icon': Icons.description,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateFilter(),
          const SizedBox(height: 24),
          _buildReportTypeSelector(),
          const SizedBox(height: 24),
          _buildGenerateButton(),
          const SizedBox(height: 24),
          _buildRecentReports(),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Date Range',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(true),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                        ],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('to'),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(false),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text('${_endDate.day}/${_endDate.month}/${_endDate.year}'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildQuickDateButton('Last 7 days', 7),
                _buildQuickDateButton('Last 30 days', 30),
                _buildQuickDateButton('Last 90 days', 90),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateButton(String label, int days) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _endDate = DateTime.now();
          _startDate = _endDate.subtract(Duration(days: days));
        });
      },
      child: Text(label),
    );
  }

  Widget _buildReportTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...(_reportTypes.map((type) => RadioListTile<String>(
              value: type['id'],
              groupValue: _selectedReportType,
              onChanged: (value) {
                setState(() => _selectedReportType = value!);
              },
              title: Row(
                children: [
                  Icon(type['icon'], size: 20),
                  const SizedBox(width: 8),
                  Text(type['title']),
                ],
              ),
              subtitle: Text(type['description']),
            ))),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isGenerating ? null : _generateReport,
        icon: _isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.file_download),
        label: Text(_isGenerating ? 'Generating...' : 'Generate Report'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5DADE2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildRecentReports() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Reports',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // This would be populated from a reports history table
            const Center(
              child: Text('No recent reports available'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = date;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate.subtract(const Duration(days: 1));
          }
        }
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);

    try {
      // Load data for the selected date range
      final reportData = await _loadReportData();
      
      // Generate PDF
      final pdfService = PdfGeneratorService();
      await pdfService.generateReport(
        reportType: _selectedReportType,
        studentData: widget.studentData,
        profileData: widget.profileData,
        reportData: reportData,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<Map<String, dynamic>> _loadReportData() async {
    // Load analytics data
    final analyticsResponse = await Supabase.instance.client
        .from('learning_analytics')
        .select()
        .eq('student_id', widget.studentId)
        .gte('date', _startDate.toIso8601String())
        .lte('date', _endDate.toIso8601String())
        .order('date', ascending: true);

    // Load test results
    final testResponse = await Supabase.instance.client
        .from('test_results')
        .select('''
          *,
          tests(title, total_marks, test_type)
        ''')
        .eq('student_id', widget.studentId)
        .gte('created_at', _startDate.toIso8601String())
        .lte('created_at', _endDate.toIso8601String())
        .order('created_at', ascending: false);

    // Load course progress
    final progressResponse = await Supabase.instance.client
        .from('course_enrollments')
        .select('''
          *,
          courses(title, category, level)
        ''')
        .eq('student_id', widget.studentId);

    return {
      'analytics': analyticsResponse,
      'test_results': testResponse,
      'course_progress': progressResponse,
    };
  }
}
