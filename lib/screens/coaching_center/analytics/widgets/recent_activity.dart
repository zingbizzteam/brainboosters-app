// screens/coaching_center/analytics/widgets/recent_activity.dart
import 'package:flutter/material.dart';

class RecentActivity extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const RecentActivity({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Color(0xFF00B894)),
                SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activities.isEmpty)
              const Center(
                child: Text(
                  'No recent activity',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length > 5 ? 5 : activities.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return _buildActivityItem(activity);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    IconData icon;
    Color color;
    
    switch (activity['type']) {
      case 'enrollment':
        icon = Icons.person_add;
        color = Colors.green;
        break;
      case 'course_created':
        icon = Icons.add_circle;
        color = Colors.blue;
        break;
      case 'faculty_added':
        icon = Icons.group_add;
        color = Colors.orange;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        activity['title'] ?? 'Activity',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        activity['description'] ?? '',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: Text(
        activity['time'] ?? '',
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
    );
  }
}
