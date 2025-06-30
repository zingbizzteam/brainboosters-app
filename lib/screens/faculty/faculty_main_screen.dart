// screens/faculty/faculty_mainscreen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FacultyMainScreen extends StatelessWidget {
  const FacultyMainScreen({super.key, required this.shell});
  final StatefulNavigationShell shell;

  void _onNavTap(int index) {
    shell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final selectedIndex = shell.currentIndex;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFD),
      appBar: AppBar(
        title: const Text(
          'Faculty Portal',
          style: TextStyle(
            color: Color(0xFF6C5CE7),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF9FBFD),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFF6C5CE7)),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Color(0xFF6C5CE7),
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(child: shell),
      bottomNavigationBar: isWide ? null : BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6C5CE7),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
