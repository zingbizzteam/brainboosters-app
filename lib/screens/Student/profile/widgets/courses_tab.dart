// lib/screens/student/profile/widgets/courses_tab.dart
import 'package:flutter/material.dart';
import 'profile_model.dart';
import './course_progress_widget.dart';

class CoursesTab extends StatelessWidget {
  final ProfileData profileData;

  const CoursesTab({
    super.key,
    required this.profileData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Course Statistics
        _buildCourseStats(),
        const SizedBox(height: 20),
        
        // Course Progress List
        const Text(
          'Your Courses',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        Expanded(
          child: CourseProgressWidget(
            courseData: profileData.courseProgress,
          ),
        ),
      ],
    );
  }

  Widget _buildCourseStats() {
    final totalCourses = profileData.courseProgress.length;
    final completedCourses = profileData.courseProgress
        .where((course) => course['completed_at'] != null)
        .length;
    final inProgressCourses = totalCourses - completedCourses;

    return Container(
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
          Expanded(
            child: _buildStatColumn(
              'Total Courses',
              totalCourses.toString(),
              Icons.school,
              Colors.blue,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildStatColumn(
              'Completed',
              completedCourses.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildStatColumn(
              'In Progress',
              inProgressCourses.toString(),
              Icons.play_circle,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
