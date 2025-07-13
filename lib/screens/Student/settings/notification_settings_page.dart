import 'package:flutter/material.dart';
import 'service/settings_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final SettingsService _settingsService = SettingsService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: const Color(0xFF5DADE2),
        foregroundColor: Colors.white,
      ),
      body: ListenableBuilder(
        listenable: _settingsService,
        builder: (context, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('General Notifications'),
              _buildNotificationCard([
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive notifications on your device'),
                  value: _settingsService.pushNotificationsEnabled,
                  onChanged: (value) {
                    _settingsService.updateNotificationSetting('pushEnabled', value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive notifications via email'),
                  value: _settingsService.emailNotificationsEnabled,
                  onChanged: (value) {
                    _settingsService.updateNotificationSetting('emailEnabled', value);
                  },
                ),
              ]),

              const SizedBox(height: 24),
              _buildSectionHeader('Learning Notifications'),
              _buildNotificationCard([
                SwitchListTile(
                  title: const Text('Course Reminders'),
                  subtitle: const Text('Reminders about your enrolled courses'),
                  value: _settingsService.courseRemindersEnabled,
                  onChanged: (value) {
                    _settingsService.updateNotificationSetting('courseReminders', value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Live Class Reminders'),
                  subtitle: const Text('Notifications before live classes start'),
                  value: _settingsService.liveClassRemindersEnabled,
                  onChanged: (value) {
                    _settingsService.updateNotificationSetting('liveClassReminders', value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Assignment Deadlines'),
                  subtitle: const Text('Reminders about upcoming deadlines'),
                  value: _settingsService.assignmentDeadlinesEnabled,
                  onChanged: (value) {
                    _settingsService.updateNotificationSetting('assignmentDeadlines', value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Achievement Notifications'),
                  subtitle: const Text('Celebrate your learning milestones'),
                  value: _settingsService.achievementNotificationsEnabled,
                  onChanged: (value) {
                    _settingsService.updateNotificationSetting('achievementNotifications', value);
                  },
                ),
              ]),

              const SizedBox(height: 24),
              _buildSectionHeader('Quiet Hours'),
              _buildNotificationCard([
                _buildQuietHoursSettings(),
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C3E50),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(List<Widget> children) {
    return Card(
      elevation: 2,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildQuietHoursSettings() {
    final quietHours = _settingsService.getQuietHours();
    
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Enable Quiet Hours'),
          subtitle: const Text('Disable notifications during specified hours'),
          value: quietHours['enabled'] ?? false,
          onChanged: (value) {
            _settingsService.updateQuietHours(enabled: value);
          },
        ),
        if (quietHours['enabled'] == true) ...[
          ListTile(
            title: const Text('Start Time'),
            subtitle: Text(quietHours['startTime'] ?? '22:00'),
            trailing: const Icon(Icons.access_time),
            onTap: () => _selectTime(true),
          ),
          ListTile(
            title: const Text('End Time'),
            subtitle: Text(quietHours['endTime'] ?? '08:00'),
            trailing: const Icon(Icons.access_time),
            onTap: () => _selectTime(false),
          ),
        ],
      ],
    );
  }

  Future<void> _selectTime(bool isStartTime) async {
    final quietHours = _settingsService.getQuietHours();
    final currentTime = isStartTime 
        ? (quietHours['startTime'] ?? '22:00') 
        : (quietHours['endTime'] ?? '08:00');
    
    final timeParts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime != null) {
      final timeString = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      
      if (isStartTime) {
        _settingsService.updateQuietHours(
          enabled: quietHours['enabled'] ?? false,
          startTime: timeString,
        );
      } else {
        _settingsService.updateQuietHours(
          enabled: quietHours['enabled'] ?? false,
          endTime: timeString,
        );
      }
    }
  }
}
