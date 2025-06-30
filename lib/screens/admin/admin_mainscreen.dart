// screens/admin/admin_mainscreen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../ui/navigation/auth_routes.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key, required this.shell});
  final StatefulNavigationShell shell;

  void _onNavTap(int index) {
    shell.goBranch(index);
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        context.go(AuthRoutes.authSelection);
      }
    } catch (e) {
      // Handle logout error
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final selectedIndex = shell.currentIndex;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFD), // Light background
      appBar: AppBar(
        title: const Text(
          'Admin Portal',
          style: TextStyle(
            color: Color(0xFF222B45), // Text Primary
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0xFFE9EDF2),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFF4AA0E6)),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              backgroundColor: Color(0xFF4AA0E6),
              child: Icon(Icons.admin_panel_settings, color: Colors.white),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Color(0xFF4AA0E6)),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(child: shell),
      bottomNavigationBar: isWide
          ? null
          : BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: _onNavTap,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF4AA0E6),
              unselectedItemColor: const Color(0xFF6E7A8A),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business),
                  label: 'Centers',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Users',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
    );
  }
}
