// screens/common/settings/common_settings_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            subtitle: const Text('Manage your profile information'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.push('/settings/profile');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Coaching Centers'),
            subtitle: const Text('Browse coaching centers'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.push(CommonRoutes.coachingCenters);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification Settings'),
            subtitle: const Text('Manage notification preferences'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Add navigation to notification settings
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Privacy & Security'),
            subtitle: const Text('Manage your privacy settings'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Add navigation to privacy settings
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            subtitle: const Text('Get help and support'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Add navigation to help page
            },
          ),
        ],
      ),
    );
  }
}
