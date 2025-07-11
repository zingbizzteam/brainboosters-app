// lib/screens/student/profile/widgets/analytics_tab.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'profile_model.dart';
import './analytics_chart_widget.dart';

class AnalyticsTab extends StatelessWidget {
  final ProfileData profileData;

  const AnalyticsTab({
    super.key,
    required this.profileData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Analytics Charts
        Expanded(
          flex: 2,
          child: AnalyticsChartWidget(
            analyticsData: profileData.learningAnalytics,
            testData: profileData.testPerformance,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Recent Activity List
        Expanded(
          flex: 1,
          child: _buildRecentActivity(),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final recentActivity = [
      ...profileData.learningAnalytics.take(5),
      ...profileData.testPerformance.take(5),
    ];

    if (recentActivity.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No recent activity'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: recentActivity.length,
            itemBuilder: (context, index) {
              final activity = recentActivity[index];
              final isLearning = activity.containsKey('time_spent_minutes');
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isLearning ? Colors.blue[100] : Colors.green[100],
                      child: Icon(
                        isLearning ? Icons.play_circle : Icons.quiz,
                        size: 16,
                        color: isLearning ? Colors.blue[700] : Colors.green[700],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLearning ? 'Learning Session' : 'Quiz Completed',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            isLearning 
                              ? '${activity['time_spent_minutes']} minutes'
                              : '${activity['percentage']?.toStringAsFixed(1)}% score',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd').format(
                        DateTime.parse(activity['date'] ?? activity['created_at']),
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
