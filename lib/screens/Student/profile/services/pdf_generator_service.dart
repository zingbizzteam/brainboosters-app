import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../templates/pdf_templates.dart';

class PdfGeneratorService {
  Future<void> generateReport({
    required String reportType,
    required Map<String, dynamic> studentData,
    required Map<String, dynamic> profileData,
    required Map<String, dynamic> reportData,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();
    
    // Load fonts
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final font = pw.Font.ttf(fontData);
    
    final boldFontData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    final boldFont = pw.Font.ttf(boldFontData);

    // Generate pages based on report type
    switch (reportType) {
      case 'progress':
        pdf.addPage(
          PdfTemplates.buildProgressReportPage(
            studentData: studentData,
            profileData: profileData,
            reportData: reportData,
            startDate: startDate,
            endDate: endDate,
            font: font,
            boldFont: boldFont,
          ),
        );
        break;
        
      case 'performance':
        pdf.addPage(
          PdfTemplates.buildPerformanceReportPage(
            studentData: studentData,
            profileData: profileData,
            reportData: reportData,
            startDate: startDate,
            endDate: endDate,
            font: font,
            boldFont: boldFont,
          ),
        );
        break;
        
      case 'activity':
        pdf.addPage(
          PdfTemplates.buildActivityReportPage(
            studentData: studentData,
            profileData: profileData,
            reportData: reportData,
            startDate: startDate,
            endDate: endDate,
            font: font,
            boldFont: boldFont,
          ),
        );
        break;
        
      case 'detailed':
        // Add multiple pages for detailed report
        pdf.addPage(
          PdfTemplates.buildProgressReportPage(
            studentData: studentData,
            profileData: profileData,
            reportData: reportData,
            startDate: startDate,
            endDate: endDate,
            font: font,
            boldFont: boldFont,
          ),
        );
        pdf.addPage(
          PdfTemplates.buildPerformanceReportPage(
            studentData: studentData,
            profileData: profileData,
            reportData: reportData,
            startDate: startDate,
            endDate: endDate,
            font: font,
            boldFont: boldFont,
          ),
        );
        pdf.addPage(
          PdfTemplates.buildActivityReportPage(
            studentData: studentData,
            profileData: profileData,
            reportData: reportData,
            startDate: startDate,
            endDate: endDate,
            font: font,
            boldFont: boldFont,
          ),
        );
        break;
    }

    // Save and share the PDF
    await _savePdf(pdf, reportType, studentData['student_id']);
  }

  Future<void> _savePdf(pw.Document pdf, String reportType, String studentId) async {
    final output = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${reportType}_report_${studentId}_$timestamp.pdf';
    final file = File('${output.path}/$fileName');
    
    await file.writeAsBytes(await pdf.save());
    
    // Share the PDF
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Student Report - $reportType',
    );
  }
}
