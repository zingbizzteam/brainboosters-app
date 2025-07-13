import 'package:flutter/material.dart';
import 'service/settings_service.dart';

class LearningPreferencesPage extends StatefulWidget {
  const LearningPreferencesPage({super.key});

  @override
  State<LearningPreferencesPage> createState() => _LearningPreferencesPageState();
}

class _LearningPreferencesPageState extends State<LearningPreferencesPage> {
  final SettingsService _settingsService = SettingsService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Preferences'),
        backgroundColor: const Color(0xFF5DADE2),
        foregroundColor: Colors.white,
      ),
      body: ListenableBuilder(
        listenable: _settingsService,
        builder: (context, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('Video Playback'),
              _buildPreferencesCard([
                SwitchListTile(
                  title: const Text('Auto Play'),
                  subtitle: const Text('Automatically play next video'),
                  value: _settingsService.autoPlayEnabled,
                  onChanged: (value) {
                    _settingsService.updateLearningPreference('autoPlay', value);
                  },
                ),
                _buildPlaybackSpeedTile(),
                SwitchListTile(
                  title: const Text('Subtitles'),
                  subtitle: const Text('Show subtitles when available'),
                  value: _settingsService.subtitlesEnabled,
                  onChanged: (value) {
                    _settingsService.updateLearningPreference('subtitlesEnabled', value);
                  },
                ),
              ]),

              const SizedBox(height: 24),
              _buildSectionHeader('Downloads & Storage'),
              _buildPreferencesCard([
                _buildDownloadQualityTile(),
                SwitchListTile(
                  title: const Text('Download on WiFi Only'),
                  subtitle: const Text('Prevent mobile data usage for downloads'),
                  value: _settingsService.downloadOnWifiOnly,
                  onChanged: (value) {
                    _settingsService.updateStorageSetting('downloadOnWifiOnly', value);
                  },
                ),
                _buildCacheSizeTile(),
              ]),

              const SizedBox(height: 24),
              _buildSectionHeader('Study Reminders'),
              _buildPreferencesCard([
                _buildStudyRemindersSettings(),
              ]),

              const SizedBox(height: 24),
              _buildSectionHeader('Progress & Analytics'),
              _buildPreferencesCard([
                SwitchListTile(
                  title: const Text('Progress Tracking'),
                  subtitle: const Text('Track your learning progress'),
                  value: _settingsService.progressTrackingEnabled,
                  onChanged: (value) {
                    _settingsService.updateLearningPreference('progressTracking', value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Analytics Sharing'),
                  subtitle: const Text('Share anonymous usage data to improve the app'),
                  value: _settingsService.analyticsSharing,
                  onChanged: (value) {
                    _settingsService.updateLearningPreference('analyticsSharing', value);
                  },
                ),
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

  Widget _buildPreferencesCard(List<Widget> children) {
    return Card(
      elevation: 2,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildPlaybackSpeedTile() {
    return ListTile(
      title: const Text('Playback Speed'),
      subtitle: Text('${_settingsService.playbackSpeed}x'),
      trailing: DropdownButton<double>(
        value: _settingsService.playbackSpeed,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 0.5, child: Text('0.5x')),
          DropdownMenuItem(value: 0.75, child: Text('0.75x')),
          DropdownMenuItem(value: 1.0, child: Text('1.0x')),
          DropdownMenuItem(value: 1.25, child: Text('1.25x')),
          DropdownMenuItem(value: 1.5, child: Text('1.5x')),
          DropdownMenuItem(value: 2.0, child: Text('2.0x')),
        ],
        onChanged: (value) {
          if (value != null) {
            _settingsService.updateLearningPreference('playbackSpeed', value);
          }
        },
      ),
    );
  }

  Widget _buildDownloadQualityTile() {
    return ListTile(
      title: const Text('Download Quality'),
      subtitle: Text(_getQualityLabel(_settingsService.downloadQuality)),
      trailing: DropdownButton<String>(
        value: _settingsService.downloadQuality,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'low', child: Text('Low (360p)')),
          DropdownMenuItem(value: 'medium', child: Text('Medium (720p)')),
          DropdownMenuItem(value: 'high', child: Text('High (1080p)')),
        ],
        onChanged: (value) {
          if (value != null) {
            _settingsService.updateLearningPreference('downloadQuality', value);
          }
        },
      ),
    );
  }

  Widget _buildCacheSizeTile() {
    return ListTile(
      title: const Text('Max Cache Size'),
      subtitle: Text('${_settingsService.maxCacheSize}MB'),
      trailing: DropdownButton<int>(
        value: _settingsService.maxCacheSize,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 100, child: Text('100MB')),
          DropdownMenuItem(value: 250, child: Text('250MB')),
          DropdownMenuItem(value: 500, child: Text('500MB')),
          DropdownMenuItem(value: 1000, child: Text('1GB')),
          DropdownMenuItem(value: 2000, child: Text('2GB')),
        ],
        onChanged: (value) {
          if (value != null) {
            _settingsService.updateStorageSetting('maxCacheSize', value);
          }
        },
      ),
    );
  }

  Widget _buildStudyRemindersSettings() {
    final studyReminders = _settingsService.getStudyReminders();
    
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Study Reminders'),
          subtitle: const Text('Get reminded to study regularly'),
          value: studyReminders['enabled'] ?? true,
          onChanged: (value) {
            _settingsService.updateStudyReminders(enabled: value);
          },
        ),
        if (studyReminders['enabled'] == true) ...[
          ListTile(
            title: const Text('Frequency'),
            subtitle: Text(_getFrequencyLabel(studyReminders['frequency'] ?? 'daily')),
            trailing: DropdownButton<String>(
              value: studyReminders['frequency'] ?? 'daily',
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'custom', child: Text('Custom')),
              ],
              onChanged: (value) {
                if (value != null) {
                  _settingsService.updateStudyReminders(
                    enabled: studyReminders['enabled'] ?? true,
                    frequency: value,
                  );
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Reminder Time'),
            subtitle: Text(studyReminders['time'] ?? '19:00'),
            trailing: const Icon(Icons.access_time),
            onTap: () => _selectReminderTime(),
          ),
        ],
      ],
    );
  }

  String _getQualityLabel(String quality) {
    switch (quality) {
      case 'low':
        return 'Low quality (saves data)';
      case 'medium':
        return 'Medium quality (balanced)';
      case 'high':
        return 'High quality (best experience)';
      default:
        return 'Medium quality';
    }
  }

  String _getFrequencyLabel(String frequency) {
    switch (frequency) {
      case 'daily':
        return 'Every day';
      case 'weekly':
        return 'Once a week';
      case 'custom':
        return 'Custom schedule';
      default:
        return 'Daily';
    }
  }

  Future<void> _selectReminderTime() async {
    final studyReminders = _settingsService.getStudyReminders();
    final currentTime = studyReminders['time'] ?? '19:00';
    
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
      
      _settingsService.updateStudyReminders(
        enabled: studyReminders['enabled'] ?? true,
        time: timeString,
      );
    }
  }
}
