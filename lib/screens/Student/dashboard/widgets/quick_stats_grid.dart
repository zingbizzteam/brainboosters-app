import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentStats {
  final int enrolledCourses;
  final int completedLessons;
  final int totalLessons;
  final double studyHours;
  final int achievementPoints;
  final int streakDays;

  StudentStats({
    required this.enrolledCourses,
    required this.completedLessons,
    required this.totalLessons,
    required this.studyHours,
    required this.achievementPoints,
    required this.streakDays,
  });

  double get completionRate =>
      totalLessons > 0 ? (completedLessons / totalLessons) * 100 : 0;

  factory StudentStats.empty() {
    return StudentStats(
      enrolledCourses: 0,
      completedLessons: 0,
      totalLessons: 0,
      studyHours: 0.0,
      achievementPoints: 0,
      streakDays: 0,
    );
  }
}

class QuickStatsGrid extends StatelessWidget {
  final StudentStats stats;
  final bool isLoading;

  const QuickStatsGrid({
    super.key,
    required this.stats,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    // Responsive grid columns
    int crossAxisCount = isMobile ? 2 : (isTablet ? 4 : 4);
    double childAspectRatio = isMobile ? 1.4 : (isTablet ? 1.3 : 1.5);

    if (isLoading) {
      return _buildLoadingSkeleton(crossAxisCount, childAspectRatio);
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(
          icon: Icons.school_outlined,
          iconColor: const Color(0xFF4AA0E6),
          iconBgColor: const Color(0xFF4AA0E6).withOpacity(0.1),
          title: 'Courses',
          value: stats.enrolledCourses.toString(),
          subtitle: 'Enrolled',
          trend: stats.enrolledCourses > 0 ? '+${stats.enrolledCourses}' : null,
        ),
        _StatCard(
          icon: Icons.task_alt_outlined,
          iconColor: const Color(0xFF66BB6A),
          iconBgColor: const Color(0xFF66BB6A).withOpacity(0.1),
          title: 'Lessons',
          value: stats.completedLessons.toString(),
          subtitle: 'Completed',
          trend: stats.completionRate > 0
              ? '${stats.completionRate.toStringAsFixed(0)}%'
              : null,
        ),
        _StatCard(
          icon: Icons.access_time_outlined,
          iconColor: const Color(0xFFFFA726),
          iconBgColor: const Color(0xFFFFA726).withOpacity(0.1),
          title: 'Study Time',
          value: _formatHours(stats.studyHours),
          subtitle: 'This week',
          trend: stats.studyHours > 0 ? '↗' : null,
        ),
        _StatCard(
          icon: Icons.emoji_events_outlined,
          iconColor: const Color(0xFFD4845C),
          iconBgColor: const Color(0xFFD4845C).withOpacity(0.1),
          title: 'Points',
          value: _formatNumber(stats.achievementPoints),
          subtitle: 'Achievement',
          trend: stats.streakDays > 0 ? '🔥 ${stats.streakDays}' : null,
        ),
      ],
    );
  }

  Widget _buildLoadingSkeleton(int crossAxisCount, double childAspectRatio) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(
        4,
        (index) => Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 40,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatHours(double hours) {
    if (hours < 1) {
      return '${(hours * 60).toInt()}m';
    } else if (hours < 10) {
      return '${hours.toStringAsFixed(1)}h';
    } else {
      return '${hours.toInt()}h';
    }
  }

  String _formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 10000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    } else {
      return '${(number / 1000).toInt()}k';
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String value;
  final String subtitle;
  final String? trend;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.value,
    required this.subtitle,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                if (trend != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      trend!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: iconColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
