import 'package:brainboosters_app/ui/navigation/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'service/settings_service.dart';
import '../../../ui/navigation/student_routes/student_routes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsService _settingsService = SettingsService.instance;

  // In settings_page.dart - update the build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF5DADE2),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Notifications'),
          _buildSettingsCard([
            _buildSettingsTile(
              'Notification Settings',
              'Manage push notifications and alerts',
              Icons.notifications,
              () => context.push(StudentRoutes.notificationSettings),
            ),
          ]),

          const SizedBox(height: 24),

          _buildSectionHeader('Learning'),
          _buildSettingsCard([
            _buildSettingsTile(
              'Learning Preferences',
              'Customize your learning experience',
              Icons.school,
              () => context.push(StudentRoutes.learningPreferences),
            ),
          ]),

          const SizedBox(height: 24),

          _buildSectionHeader('Privacy & Security'),
          _buildSettingsCard([
            _buildSettingsTile(
              'Privacy Settings',
              'Control your data and privacy',
              Icons.privacy_tip,
              () => context.push(StudentRoutes.privacySettings),
            ),
          ]),

          const SizedBox(height: 24),

          _buildSectionHeader('Account'),
          _buildSettingsCard([
            _buildSettingsTile(
              'Account Settings',
              'Manage your account and profile',
              Icons.account_circle,
              () => context.push(StudentRoutes.accountSettings),
            ),
          ]),

          const SizedBox(height: 24),

          _buildSectionHeader('Support'),
          _buildSettingsCard([
            _buildSettingsTile(
              'Help & Support',
              'Get help and contact support',
              Icons.help,
              () {
                _showHelpDialog();
              },
            ),
            _buildSettingsTile(
              'About',
              'App version and information',
              Icons.info,
              () {
                _showAboutDialog();
              },
            ),
          ]),

          const SizedBox(height: 32),

          _buildDangerZone(),

          const SizedBox(height: 24),

          // NEW: Logout Section
          _buildLogoutSection(),
        ],
      ),
    );
  }

  // Add this new method
  Widget _buildLogoutSection() {
    return Card(
      color: Colors.red[50],
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text(
          'Sign Out',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Sign out from your account'),
        onTap: () => _showLogoutDialog(),
      ),
    );
  }

  // Add this new method
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out? You will need to sign in again to access your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performLogout();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Add this new method
  Future<void> _performLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Sign out from Supabase
      await Supabase.instance.client.auth.signOut();

      // Clear settings service data
      await _settingsService.clearAllData();

      // Hide loading indicator
      if (mounted) {
        Navigator.pop(context);

        // Navigate to onboarding/auth screen
        context.go(AppRouter.home); // or your auth route

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully signed out'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Hide loading indicator
      if (mounted) {
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(elevation: 2, child: Column(children: children));
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF5DADE2)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDangerZone() {
    return Card(
      color: Colors.red[50],
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.warning, color: Colors.red),
            title: const Text(
              'Reset All Settings',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('This will reset all settings to default'),
            onTap: () => _showResetDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Clear All Data',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('This will delete all local app data'),
            onTap: () => _showClearDataDialog(),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact us:'),
            SizedBox(height: 16),
            Text('📧 Email: support@brainboosters.com'),
            Text('📞 Phone: +1-800-BRAIN-01'),
            Text('💬 Live Chat: Available 24/7'),
            SizedBox(height: 16),
            Text('You can also visit our FAQ section in the app.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening contact form...')),
              );
            },
            child: const Text('Contact Us'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'BrainBoosters',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.school,
        size: 48,
        color: Color(0xFF5DADE2),
      ),
      children: const [
        Text('A comprehensive e-learning platform for students.'),
        SizedBox(height: 16),
        Text('© 2024 BrainBoosters Inc. All rights reserved.'),
      ],
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to default? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _settingsService.clearAllData();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings reset successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error resetting settings: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will delete all local app data including downloaded courses, cache, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _settingsService.clearAllData();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data cleared successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error clearing data: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
