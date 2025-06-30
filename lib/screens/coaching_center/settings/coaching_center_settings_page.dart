// screens/coaching_center/settings/coaching_center_settings_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../ui/navigation/auth_routes.dart';
import 'package:go_router/go_router.dart';

class CoachingCenterSettingsPage extends StatefulWidget {
  const CoachingCenterSettingsPage({super.key});

  @override
  State<CoachingCenterSettingsPage> createState() =>
      _CoachingCenterSettingsPageState();
}

class _CoachingCenterSettingsPageState
    extends State<CoachingCenterSettingsPage> {
  Map<String, dynamic> _centerData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCenterData();
  }

  Future<void> _loadCenterData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('coaching_centers')
          .select('*')
          .eq('id', userId)
          .single();

      if (mounted) {
        setState(() {
          _centerData = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading center data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Center Profile Section
            _buildSection('Center Profile', [
              _buildListTile(
                'Center Information',
                'Update center details and description',
                Icons.business,
                () => _showCenterInfoDialog(),
              ),
              _buildListTile(
                'Contact Details',
                'Manage contact information',
                Icons.contact_phone,
                () => _showContactDialog(),
              ),
              _buildListTile(
                'Facilities',
                'Update available facilities',
                Icons.home_work,
                () => _showFacilitiesDialog(),
              ),
            ]),

            const SizedBox(height: 24),

            // Account Settings
            _buildSection('Account Settings', [
              _buildListTile(
                'Change Password',
                'Update your account password',
                Icons.lock,
                () => _showChangePasswordDialog(),
              ),
              _buildListTile(
                'Notification Preferences',
                'Manage notification settings',
                Icons.notifications,
                () => _showNotificationDialog(),
              ),
            ]),

            const SizedBox(height: 24),

            // Support Section
            _buildSection('Support', [
              _buildListTile(
                'Help Center',
                'Get help and support',
                Icons.help,
                () => _showHelpDialog(),
              ),
              _buildListTile(
                'Contact Support',
                'Reach out to our support team',
                Icons.support_agent,
                () => _showSupportDialog(),
              ),
            ]),

            const SizedBox(height: 40),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00B894),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00B894)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showCenterInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Center Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Center Name: ${_centerData['center_name'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text(
              'Description: ${_centerData['description'] ?? 'No description'}',
            ),
            const SizedBox(height: 8),
            Text('Established: ${_centerData['establishment_year'] ?? 'N/A'}'),
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

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${_centerData['contact_email'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Phone: ${_centerData['contact_phone'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Address: ${_centerData['address'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text(
              'City: ${_centerData['city'] ?? 'N/A'}, ${_centerData['state'] ?? 'N/A'}',
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

  void _showFacilitiesDialog() {
    final facilities = List<String>.from(_centerData['facilities'] ?? []);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Available Facilities'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: facilities.isEmpty
              ? [const Text('No facilities listed')]
              : facilities.map((facility) => Text('• $facility')).toList(),
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

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text(
          'Password change functionality would be implemented here.',
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

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Preferences'),
        content: const Text('Notification settings would be configured here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help Center'),
        content: const Text('Help articles and FAQs would be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text('Support contact form would be here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Supabase.instance.client.auth.signOut();
        if (mounted) {
          context.go(AuthRoutes.authSelection);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
        }
      }
    }
  }
}
