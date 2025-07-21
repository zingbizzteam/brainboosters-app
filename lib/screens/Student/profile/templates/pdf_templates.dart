import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfTemplates {
  static pw.Page buildProgressReportPage({
    required Map<String, dynamic> studentData,
    required Map<String, dynamic> profileData,
    required Map<String, dynamic> reportData,
    required DateTime startDate,
    required DateTime endDate,
    required pw.Font font,
    required pw.Font boldFont,
  }) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(profileData, studentData, boldFont),
            pw.SizedBox(height: 20),
            _buildReportTitle('Progress Report', startDate, endDate, boldFont, font),
            pw.SizedBox(height: 20),
            _buildProgressSummary(studentData, reportData, font, boldFont),
            pw.SizedBox(height: 20),
            _buildCourseProgress(reportData['course_progress'], font, boldFont),
            pw.Spacer(),
            _buildFooter(font),
          ],
        );
      },
    );
  }

  static pw.Page buildPerformanceReportPage({
    required Map<String, dynamic> studentData,
    required Map<String, dynamic> profileData,
    required Map<String, dynamic> reportData,
    required DateTime startDate,
    required DateTime endDate,
    required pw.Font font,
    required pw.Font boldFont,
  }) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(profileData, studentData, boldFont),
            pw.SizedBox(height: 20),
            _buildReportTitle('Performance Report', startDate, endDate, boldFont, font),
            pw.SizedBox(height: 20),
            _buildTestPerformance(reportData['test_results'], font, boldFont),
            pw.SizedBox(height: 20),
            _buildPerformanceAnalysis(reportData['test_results'], font, boldFont),
            pw.Spacer(),
            _buildFooter(font),
          ],
        );
      },
    );
  }

  static pw.Page buildActivityReportPage({
    required Map<String, dynamic> studentData,
    required Map<String, dynamic> profileData,
    required Map<String, dynamic> reportData,
    required DateTime startDate,
    required DateTime endDate,
    required pw.Font font,
    required pw.Font boldFont,
  }) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(profileData, studentData, boldFont),
            pw.SizedBox(height: 20),
            _buildReportTitle('Activity Report', startDate, endDate, boldFont, font),
            pw.SizedBox(height: 20),
            _buildActivitySummary(reportData['analytics'], font, boldFont),
            pw.SizedBox(height: 20),
            _buildDailyActivity(reportData['analytics'], font, boldFont),
            pw.Spacer(),
            _buildFooter(font),
          ],
        );
      },
    );
  }

  static pw.Widget _buildHeader(
    Map<String, dynamic> profileData,
    Map<String, dynamic> studentData,
    pw.Font boldFont,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'BrainBoosters Learning Platform',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 18,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Student Report',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 14,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                '${profileData['first_name']} ${profileData['last_name']}',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 16,
                  color: PdfColors.white,
                ),
              ),
              pw.Text(
                'ID: ${studentData['student_id']}',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 12,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildReportTitle(
    String title,
    DateTime startDate,
    DateTime endDate,
    pw.Font boldFont,
    pw.Font font,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(font: boldFont, fontSize: 24),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'Period: ${_formatDate(startDate)} to ${_formatDate(endDate)}',
          style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey),
        ),
        pw.Text(
          'Generated on: ${_formatDate(DateTime.now())}',
          style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey),
        ),
      ],
    );
  }

  static pw.Widget _buildProgressSummary(
    Map<String, dynamic> studentData,
    Map<String, dynamic> reportData,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Progress Summary',
            style: pw.TextStyle(font: boldFont, fontSize: 16),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildStatBox(
                'Total Courses',
                '${studentData['total_courses_enrolled'] ?? 0}',
                font,
                boldFont,
              ),
              _buildStatBox(
                'Completed',
                '${studentData['total_courses_completed'] ?? 0}',
                font,
                boldFont,
              ),
              _buildStatBox(
                'Hours Learned',
                '${(studentData['total_hours_learned'] ?? 0.0).toStringAsFixed(1)}h',
                font,
                boldFont,
              ),
              _buildStatBox(
                'Current Streak',
                '${studentData['current_streak_days'] ?? 0} days',
                font,
                boldFont,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStatBox(
    String label,
    String value,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(font: boldFont, fontSize: 18, color: PdfColors.blue),
        ),
        pw.Text(
          label,
          style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey),
        ),
      ],
    );
  }

  static pw.Widget _buildCourseProgress(
    List<dynamic> courseProgress,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Course Progress',
          style: pw.TextStyle(font: boldFont, fontSize: 16),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableCell('Course', boldFont),
                _buildTableCell('Category', boldFont),
                _buildTableCell('Progress', boldFont),
                _buildTableCell('Status', boldFont),
              ],
            ),
            ...courseProgress.take(10).map((course) => pw.TableRow(
              children: [
                _buildTableCell(course['courses']['title'], font),
                _buildTableCell(course['courses']['category'] ?? 'N/A', font),
                _buildTableCell('${course['progress_percentage']?.toInt() ?? 0}%', font),
                _buildTableCell(
                  course['completed_at'] != null ? 'Completed' : 'In Progress',
                  font,
                ),
              ],
            )),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTestPerformance(
    List<dynamic> testResults,
    pw.Font font,
    pw.Font boldFont,
  ) {
    if (testResults.isEmpty) {
      return pw.Text(
        'No test results available for this period.',
        style: pw.TextStyle(font: font, fontSize: 14),
      );
    }

    final totalTests = testResults.length;
    final passedTests = testResults.where((test) => test['passed'] == true).length;
    final averageScore = testResults.fold<double>(
      0.0,
      (sum, test) => sum + (test['percentage'] ?? 0.0),
    ) / totalTests;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Test Performance Summary',
          style: pw.TextStyle(font: boldFont, fontSize: 16),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            _buildStatBox('Total Tests', '$totalTests', font, boldFont),
            _buildStatBox('Passed', '$passedTests', font, boldFont),
            _buildStatBox('Pass Rate', '${((passedTests / totalTests) * 100).toInt()}%', font, boldFont),
            _buildStatBox('Avg Score', '${averageScore.toStringAsFixed(1)}%', font, boldFont),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildPerformanceAnalysis(
    List<dynamic> testResults,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Recent Test Results',
          style: pw.TextStyle(font: boldFont, fontSize: 16),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableCell('Test', boldFont),
                _buildTableCell('Score', boldFont),
                _buildTableCell('Percentage', boldFont),
                _buildTableCell('Result', boldFont),
                _buildTableCell('Date', boldFont),
              ],
            ),
            ...testResults.take(10).map((test) => pw.TableRow(
              children: [
                _buildTableCell(test['tests']['title'], font),
                _buildTableCell('${test['score']}/${test['total_marks']}', font),
                _buildTableCell('${test['percentage']?.toStringAsFixed(1)}%', font),
                _buildTableCell(test['passed'] ? 'Pass' : 'Fail', font),
                _buildTableCell(
                  _formatDate(DateTime.parse(test['created_at'])),
                  font,
                ),
              ],
            )),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildActivitySummary(
    List<dynamic> analytics,
    pw.Font font,
    pw.Font boldFont,
  ) {
    if (analytics.isEmpty) {
      return pw.Text(
        'No activity data available for this period.',
        style: pw.TextStyle(font: font, fontSize: 14),
      );
    }

    final totalMinutes = analytics.fold<int>(
      0,
      (sum, day) => sum + ((day['time_spent_minutes'] ?? 0) as int),
    );
    final totalLessons = analytics.fold<int>(
      0,
      (sum, day) => sum + ((day['lessons_completed'] ?? 0) as int),
    );
    final activeDays = analytics.where((day) => (day['time_spent_minutes'] ?? 0) > 0).length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Activity Summary',
            style: pw.TextStyle(font: boldFont, fontSize: 16),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildStatBox(
                'Total Time',
                '${(totalMinutes / 60).toStringAsFixed(1)}h',
                font,
                boldFont,
              ),
              _buildStatBox(
                'Lessons Completed',
                '$totalLessons',
                font,
                boldFont,
              ),
              _buildStatBox(
                'Active Days',
                '$activeDays',
                font,
                boldFont,
              ),
              _buildStatBox(
                'Avg/Day',
                '${(totalMinutes / analytics.length).toInt()}min',
                font,
                boldFont,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDailyActivity(
    List<dynamic> analytics,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Daily Activity Breakdown',
          style: pw.TextStyle(font: boldFont, fontSize: 16),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableCell('Date', boldFont),
                _buildTableCell('Time (min)', boldFont),
                _buildTableCell('Lessons', boldFont),
                _buildTableCell('Quizzes', boldFont),
                _buildTableCell('Points', boldFont),
              ],
            ),
            ...analytics.take(15).map((day) => pw.TableRow(
              children: [
                               _buildTableCell(
                  _formatDate(DateTime.parse(day['date'])),
                  font,
                ),
                _buildTableCell('${day['time_spent_minutes'] ?? 0}', font),
                _buildTableCell('${day['lessons_completed'] ?? 0}', font),
                _buildTableCell('${day['quizzes_attempted'] ?? 0}', font),
                _buildTableCell('${day['points_earned'] ?? 0}', font),
              ],
            )),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 10),
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Font font) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated by BrainBoosters Learning Platform',
            style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey),
          ),
          pw.Text(
            'Page 1',
            style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
