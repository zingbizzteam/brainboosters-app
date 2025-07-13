import 'package:flutter/material.dart';
import 'service/settings_service.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  final SettingsService _settingsService = SettingsService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
        backgroundColor: const Color(0xFF5DADE2),
        foregroundColor: Colors.white,
      ),
      body: ListenableBuilder(
        listenable: _settingsService,
        builder: (context, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('Profile Privacy'),
              _buildPrivacyCard([
                _buildProfileVisibilityTile(),
                SwitchListTile(
                  title: const Text('Show Online Status'),
                  subtitle: const Text('Let others see when you\'re online'),
                  value: _settingsService.showOnlineStatus,
                  onChanged: (value) {
                    _settingsService.updatePrivacySetting('showOnlineStatus', value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Share Progress'),
                  subtitle: const Text('Allow others to see your learning progress'),
                  value: _settingsService.shareProgress,
                  onChanged: (value) {
                    _settingsService.updatePrivacySetting('shareProgress', value);
                  },
                ),
              ]),

              const SizedBox(height: 24),
              _buildSectionHeader('Data & Analytics'),
              _buildPrivacyCard([
                SwitchListTile(
                  title: const Text('Data Collection'),
                  subtitle: const Text('Allow collection of usage data for app improvement'),
                  value: _settingsService.dataCollection,
                  onChanged: (value) {
                    _settingsService.updatePrivacySetting('dataCollection', value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Crash Reporting'),
                  subtitle: const Text('Send crash reports to help fix bugs'),
                  value: _settingsService.crashReporting,
                  onChanged: (value) {
                    _settingsService.updatePrivacySetting('crashReporting', value);
                  },
                ),
              ]),

              const SizedBox(height: 24),
              _buildSectionHeader('Data Management'),
              _buildPrivacyCard([
                ListTile(
                  title: const Text('Download My Data'),
                  subtitle: const Text('Get a copy of your data'),
                  trailing: const Icon(Icons.download),
                  onTap: () => _downloadUserData(),
                ),
                ListTile(
                  title: const Text('Delete My Account'),
                  subtitle: const Text('Permanently delete your account and data'),
                  trailing: const Icon(Icons.delete_forever, color: Colors.red),
                  onTap: () => _showDeleteAccountDialog(),
                ),
              ]),

              const SizedBox(height: 24),
              _buildSectionHeader('Legal'),
              _buildPrivacyCard([
                ListTile(
                  title: const Text('Privacy Policy'),
                  subtitle: const Text('Read our privacy policy'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openPrivacyPolicy(),
                ),
                ListTile(
                  title: const Text('Terms of Service'),
                  subtitle: const Text('Read our terms of service'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openTermsOfService(),
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

  Widget _buildPrivacyCard(List<Widget> children) {
    return Card(
      elevation: 2,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildProfileVisibilityTile() {
    return ListTile(
      title: const Text('Profile Visibility'),
      subtitle: Text(_getVisibilityLabel(_settingsService.profileVisibility)),
      trailing: DropdownButton<String>(
        value: _settingsService.profileVisibility,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'public', child: Text('Public')),
          DropdownMenuItem(value: 'friends', child: Text('Friends Only')),
          DropdownMenuItem(value: 'private', child: Text('Private')),
        ],
        onChanged: (value) {
          if (value != null) {
            _settingsService.updatePrivacySetting('profileVisibility', value);
          }
        },
      ),
    );
  }

  String _getVisibilityLabel(String visibility) {
    switch (visibility) {
      case 'public':
        return 'Anyone can see your profile';
      case 'friends':
        return 'Only friends can see your profile';
      case 'private':
        return 'Only you can see your profile';
      default:
        return 'Private';
    }
  }

  void _downloadUserData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Data'),
        content: const Text(
          'We\'ll prepare your data and send a download link to your email address. This may take a few minutes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data download request submitted. Check your email.'),
                ),
              );
            },
            child: const Text('Request Download'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteConfirmationDialog();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    final TextEditingController confirmController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type "DELETE" to confirm account deletion:'),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              decoration: const InputDecoration(
                hintText: 'Type DELETE here',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (confirmController.text == 'DELETE') {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deletion initiated. You will be logged out.'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please type DELETE to confirm'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete Account', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening privacy policy...')),
    );
  }

  void _openTermsOfService() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening terms of service...')),
    );
  }
}
