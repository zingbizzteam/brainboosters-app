import 'dart:convert';
import 'package:flutter/material.dart';
import 'course_detail_section.dart';
import 'learning_point_widget.dart';

class CourseAboutTab extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseAboutTab({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CourseDetailSection(course: course, isMobile: isMobile),
          const SizedBox(height: 24),
          _buildDescription(isMobile),
          if (course['what_you_learn'] != null) ...[
            const SizedBox(height: 24),
            _buildSection(
              'What you\'ll learn:',
              _parseJsonArray(course['what_you_learn']),
              isMobile,
            ),
          ],
          if (course['prerequisites'] != null &&
              _parseJsonArray(course['prerequisites']).isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSection(
              'Prerequisites:',
              _parseJsonArray(course['prerequisites']),
              isMobile,
            ),
          ],
          if (course['course_requirements'] != null) ...[
            const SizedBox(height: 24),
            _buildSection(
              'Requirements:',
              _parseJsonArray(course['course_requirements']),
              isMobile,
            ),
          ],
          if (course['target_audience'] != null) ...[
            const SizedBox(height: 24),
            _buildSection(
              'Who this course is for:',
              _parseJsonArray(course['target_audience']),
              isMobile,
            ),
          ],
          if (course['tags'] != null &&
              _parseJsonArray(course['tags']).isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildTagsSection(isMobile),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDescription(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          course['about']?.toString() ??
              course['description']?.toString() ??
              'No description available.',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: Colors.grey[700],
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<String> items, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => LearningPointWidget(text: item, isMobile: isMobile),
        ),
      ],
    );
  }

  Widget _buildTagsSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags:',
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _parseJsonArray(course['tags']).map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<String> _parseJsonArray(dynamic jsonData) {
    if (jsonData == null) return [];
    if (jsonData is List) {
      return jsonData.map((item) => item.toString()).toList();
    }
    if (jsonData is String) {
      try {
        final parsed = jsonDecode(jsonData);
        if (parsed is List) {
          return parsed.map((item) => item.toString()).toList();
        }
      } catch (e) {
        debugPrint('Error parsing JSON: $e');
      }
    }
    return [];
  }
}
