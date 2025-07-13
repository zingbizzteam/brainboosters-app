import 'package:flutter/material.dart';
import 'service/settings_service.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final SettingsService _settingsService = SettingsService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: const Color(0xFF5DADE2),
        foregroundColor: Colors.white,
      ),
      body: ListenableBuilder(
        listenable: _settingsService,
        builder: (context, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('Language & Region'),
              _buildAccountCard([
                _buildLanguageTile(),
                _buildTimezoneTile(),
                _buildCurrencyTile(),
              ]),

              const SizedBox(height: 24),
              _buildSectionHeader('Security'),
              _buildAccountCard([
                ListTile(
                  title: const Text('Change Password'),
                  subtitle: const Text('Update your account password'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showChangePasswordDialog(),
                ),
                SwitchListTile(
                  title: const Text('Two-Factor Authentication'),
                  subtitle: const Text('Add an extra layer of security'),
                  value: _settingsService.twoFactorEnabled,
                  onChanged: (value) {
                    _showTwoFactorDialog(value);
                  },
                ),
                ListTile(
                  title: const Text('Login Sessions'),
                  subtitle: const Text('Manage your active sessions'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showLoginSessions(),
                ),
              ]),

              // REMOVED: Subscription section completely

              const SizedBox(height: 24),
              _buildSectionHeader('Purchased Courses'),
              _buildAccountCard([
                ListTile(
                  title: const Text('My Courses'),
                  subtitle: const Text('View your purchased courses'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showPurchasedCourses(),
                ),
                ListTile(
                  title: const Text('Purchase History'),
                  subtitle: const Text('View your payment history'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showPurchaseHistory(),
                ),
              ]),

              const SizedBox(height: 24),
              _buildSectionHeader('Data Export'),
              _buildAccountCard([
                ListTile(
                  title: const Text('Export Learning Data'),
                  subtitle: const Text('Download your progress and achievements'),
                  trailing: const Icon(Icons.download),
                  onTap: () => _exportLearningData(),
                ),
                ListTile(
                  title: const Text('Export Settings'),
                  subtitle: const Text('Backup your app preferences'),
                  trailing: const Icon(Icons.download),
                  onTap: () => _exportSettings(),
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

  Widget _buildAccountCard(List<Widget> children) {
    return Card(
      elevation: 2,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildLanguageTile() {
    return ListTile(
      title: const Text('Language'),
      subtitle: Text(_getLanguageLabel(_settingsService.language)),
      trailing: DropdownButton<String>(
        value: _settingsService.language,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'en', child: Text('English')),
          DropdownMenuItem(value: 'es', child: Text('Spanish')),
          DropdownMenuItem(value: 'fr', child: Text('French')),
          DropdownMenuItem(value: 'de', child: Text('German')),
          DropdownMenuItem(value: 'hi', child: Text('Hindi')),
        ],
        onChanged: (value) {
          if (value != null) {
            _settingsService.updateAccountSetting('language', value);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Language updated successfully')),
            );
          }
        },
      ),
    );
  }

  Widget _buildTimezoneTile() {
    return ListTile(
      title: const Text('Timezone'),
      subtitle: Text(_settingsService.timezone == 'auto' ? 'Automatic' : _settingsService.timezone),
      trailing: DropdownButton<String>(
        value: _settingsService.timezone,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'auto', child: Text('Automatic')),
          DropdownMenuItem(value: 'UTC', child: Text('UTC')),
          DropdownMenuItem(value: 'EST', child: Text('Eastern')),
          DropdownMenuItem(value: 'PST', child: Text('Pacific')),
          DropdownMenuItem(value: 'IST', child: Text('India')),
        ],
        onChanged: (value) {
          if (value != null) {
            _settingsService.updateAccountSetting('timezone', value);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Timezone updated successfully')),
            );
          }
        },
      ),
    );
  }

  Widget _buildCurrencyTile() {
    return ListTile(
      title: const Text('Currency'),
      subtitle: Text(_settingsService.currency),
      trailing: DropdownButton<String>(
        value: _settingsService.currency,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
          DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
          DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),
          DropdownMenuItem(value: 'INR', child: Text('INR (₹)')),
        ],
        onChanged: (value) {
          if (value != null) {
            _settingsService.updateAccountSetting('currency', value);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Currency updated successfully')),
            );
          }
        },
      ),
    );
  }

  String _getLanguageLabel(String language) {
    switch (language) {
      case 'en': return 'English';
      case 'es': return 'Spanish';
      case 'fr': return 'French';
      case 'de': return 'German';
      case 'hi': return 'Hindi';
      default: return 'English';
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
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
              if (newPasswordController.text == confirmPasswordController.text) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorDialog(bool enable) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(enable ? 'Enable 2FA' : 'Disable 2FA'),
        content: Text(
          enable 
            ? 'Two-factor authentication adds an extra layer of security to your account.'
            : 'Are you sure you want to disable two-factor authentication?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _settingsService.updateAccountSetting('twoFactorEnabled', enable);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(enable ? '2FA enabled successfully' : '2FA disabled successfully'),
                ),
              );
            },
            child: Text(enable ? 'Enable' : 'Disable'),
          ),
        ],
      ),
    );
  }

  void _showLoginSessions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Active Sessions'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.phone_android),
              title: Text('Current Device'),
              subtitle: Text('Active now'),
              trailing: Text('Current'),
            ),
            ListTile(
              leading: Icon(Icons.computer),
              title: Text('Chrome on Windows'),
              subtitle: Text('2 hours ago'),
              trailing: TextButton(
                onPressed: null,
                child: Text('Revoke'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPurchasedCourses() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('My Courses'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.book),
              title: Text('Flutter Development'),
              subtitle: Text('Progress: 75%'),
              trailing: Text('₹2,999'),
            ),
            ListTile(
              leading: Icon(Icons.code),
              title: Text('React Native Basics'),
              subtitle: Text('Progress: 45%'),
              trailing: Text('₹1,999'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPurchaseHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase History'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Flutter Development'),
              subtitle: Text('Purchased on 15 Dec 2024'),
              trailing: Text('₹2,999'),
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('React Native Basics'),
              subtitle: Text('Purchased on 10 Dec 2024'),
              trailing: Text('₹1,999'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportLearningData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Learning Data'),
        content: const Text(
          'Your learning data will be prepared and sent to your email address. This includes progress, achievements, and course history.',
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
                const SnackBar(content: Text('Export request submitted')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _exportSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Settings'),
        content: const Text(
          'This will create a backup file of all your app preferences and settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final settings = _settingsService.getAllSettings();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings exported successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Export failed: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }
}
