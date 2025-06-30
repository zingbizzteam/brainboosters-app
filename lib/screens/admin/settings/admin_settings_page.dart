// screens/admin/settings/admin_settings_page.dart
import 'package:flutter/material.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  bool _emailNotifications = true;
  bool _systemAlerts = true;
  bool _maintenanceMode = false;
  String _selectedTheme = 'Light';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFD),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222B45),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // System Settings
            _buildSection(
              'System Settings',
              [
                _buildSwitchTile(
                  'Maintenance Mode',
                  'Enable maintenance mode for the platform',
                  Icons.build,
                  _maintenanceMode,
                  (value) => setState(() => _maintenanceMode = value),
                ),
             
                _buildListTile(
                  'Database Backup',
                  'Manage database backups',
                  Icons.backup,
                  () => _showBackupDialog(),
                ),
                _buildListTile(
                  'System Logs',
                  'View system activity logs',
                  Icons.list_alt,
                  () => _showLogsDialog(),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Notification Settings
            _buildSection(
              'Notifications',
              [
                _buildSwitchTile(
                  'Email Notifications',
                  'Receive admin alerts via email',
                  Icons.email,
                  _emailNotifications,
                  (value) => setState(() => _emailNotifications = value),
                ),
                _buildSwitchTile(
                  'System Alerts',
                  'Show system alerts in dashboard',
                  Icons.notifications,
                  _systemAlerts,
                  (value) => setState(() => _systemAlerts = value),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Security Settings
            _buildSection(
              'Security',
              [
                _buildListTile(
                  'Change Password',
                  'Update admin password',
                  Icons.lock,
                  () => _showChangePasswordDialog(),
                ),
                _buildListTile(
                  'Two-Factor Authentication',
                  'Manage 2FA settings',
                  Icons.security,
                  () => _show2FADialog(),
                ),
                _buildListTile(
                  'Active Sessions',
                  'View and manage active sessions',
                  Icons.devices,
                  () => _showSessionsDialog(),
                ),
                _buildListTile(
                  'API Keys',
                  'Manage API keys and tokens',
                  Icons.key,
                  () => _showAPIKeysDialog(),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Platform Management
            _buildSection(
              'Platform Management',
              [
                _buildListTile(
                  'User Roles',
                  'Manage user roles and permissions',
                  Icons.admin_panel_settings,
                  () => _showRolesDialog(),
                ),
                _buildListTile(
                  'Content Moderation',
                  'Manage content moderation settings',
                  Icons.gavel,
                  () => _showModerationDialog(),
                ),
                _buildListTile(
                  'System Analytics',
                  'View detailed system analytics',
                  Icons.analytics,
                  () => _showAnalyticsDialog(),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Danger Zone
            _buildSection(
              'Danger Zone',
              [
                _buildListTile(
                  'Reset Platform',
                  'Reset platform to default settings',
                  Icons.refresh,
                  () => _showResetDialog(),
                  isDestructive: true,
                ),
                _buildListTile(
                  'Emergency Shutdown',
                  'Emergency platform shutdown',
                  Icons.power_off,
                  () => _showShutdownDialog(),
                  isDestructive: true,
                ),
              ],
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
            color: Color(0xFF4AA0E6),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE9EDF2).withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFF4AA0E6),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : const Color(0xFF222B45),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF6E7A8A)),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF6E7A8A)),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4AA0E6)),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Color(0xFF222B45),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF6E7A8A)),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF4AA0E6),
      ),
    );
  }

  Widget _buildDropdownTile(String title, String subtitle, IconData icon, String value, List<String> items, ValueChanged<String?> onChanged) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4AA0E6)),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Color(0xFF222B45),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF6E7A8A)),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F4FB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<String>(
          value: value,
          dropdownColor: Colors.white,
          style: const TextStyle(color: Color(0xFF222B45)),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          )).toList(),
          onChanged: onChanged,
          underline: Container(),
        ),
      ),
    );
  }

  // All dialog methods with light theme colors
  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Database Backup', style: TextStyle(color: Color(0xFF222B45))),
        content: const Text('Database backup management would be implemented here.', style: TextStyle(color: Color(0xFF6E7A8A))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF4AA0E6))),
          ),
        ],
      ),
    );
  }

  void _showLogsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('System Logs', style: TextStyle(color: Color(0xFF222B45))),
        content: const Text('System logs viewer would be implemented here.', style: TextStyle(color: Color(0xFF6E7A8A))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF4AA0E6))),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Change Password', style: TextStyle(color: Color(0xFF222B45))),
        content: const Text('Password change form would be implemented here.', style: TextStyle(color: Color(0xFF6E7A8A))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6E7A8A))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save', style: TextStyle(color: Color(0xFF4AA0E6))),
          ),
        ],
      ),
    );
  }

  void _show2FADialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Two-Factor Authentication', style: TextStyle(color: Color(0xFF222B45))),
        content: const Text('2FA setup would be implemented here.', style: TextStyle(color: Color(0xFF6E7A8A))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF4AA0E6))),
          ),
        ],
      ),
    );
  }

  void _showSessionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Active Sessions', style: TextStyle(color: Color(0xFF222B45))),
        content: const Text('Active sessions management would be implemented here.', style: TextStyle(color: Color(0xFF6E7A8A))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF4AA0E6))),
          ),
        ],
      ),
    );
  }

  void _showAPIKeysDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('API Keys', style: TextStyle(color: Color(0xFF222B45))),
        content: const Text('API key management would be implemented here.', style: TextStyle(color: Color(0xFF6E7A8A))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF4AA0E6))),
          ),
        ],
      ),
    );
  }

  void _showRolesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('User Roles', style: TextStyle(color: Color(0xFF222B45))),
        content: const Text('User roles management would be implemented here.', style: TextStyle(color: Color(0xFF6E7A8A))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF4AA0E6))),
          ),
        ],
      ),
    );
  }

  void _showModerationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Content Moderation', style: TextStyle(color: Color(0xFF222B45))),
        content: const Text('Content moderation settings would be implemented here.', style: TextStyle(color: Color(0xFF6E7A8A))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF4AA0E6))),
          ),
        ],
      ),
    );
  }

  void _showAnalyticsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('System Analytics', style: TextStyle(color: Color(0xFF222B45))),
        content: const Text('Detailed analytics would be implemented here.', style: TextStyle(color: Color(0xFF6E7A8A))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF4AA0E6))),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Reset Platform', style: TextStyle(color: Color(0xFF222B45))),
        content: const Text('⚠️ This will reset the platform to default settings. Are you sure?', style: TextStyle(color: Color(0xFF6E7A8A))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6E7A8A))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showShutdownDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Emergency Shutdown', style: TextStyle(color: Color(0xFF222B45))),
        content: const Text('⚠️ This will immediately shut down the platform. Are you absolutely sure?', style: TextStyle(color: Color(0xFF6E7A8A))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6E7A8A))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Shutdown', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
