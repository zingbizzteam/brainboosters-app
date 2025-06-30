// screens/coaching_center/coaching_center_mainscreen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CoachingCenterMainScreen extends StatefulWidget {
  const CoachingCenterMainScreen({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  State<CoachingCenterMainScreen> createState() => _CoachingCenterMainScreenState();
}

class _CoachingCenterMainScreenState extends State<CoachingCenterMainScreen> {
  Map<String, dynamic>? _centerProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCenterProfile();
  }

  Future<void> _loadCenterProfile() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('coaching_centers')
          .select('center_name, verification_status, total_students, total_faculties')
          .eq('id', userId)
          .single();

      if (mounted) {
        setState(() {
          _centerProfile = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onNavTap(int index) {
    widget.shell.goBranch(index);
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        context.go('/auth/selection');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final selectedIndex = widget.shell.currentIndex;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFD),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Coaching Center Portal',
              style: TextStyle(
                color: Color(0xFF00B894),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (!_isLoading && _centerProfile != null)
              Text(
                _centerProfile!['center_name'] ?? 'Center',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        backgroundColor: const Color(0xFFF9FBFD),
        elevation: 0,
        actions: [
          // Verification Status Badge
          if (!_isLoading && _centerProfile != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getVerificationColor(_centerProfile!['verification_status']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _centerProfile!['verification_status']?.toUpperCase() ?? 'PENDING',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFF00B894)),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          PopupMenuButton(
            icon: const CircleAvatar(
              backgroundColor: Color(0xFF00B894),
              child: Icon(Icons.business, color: Colors.white),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              } else if (value == 'profile') {
                // Navigate to profile (this will be outside the shell)
                context.push('/coaching-center/profile');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Color(0xFF00B894)),
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
      body: SafeArea(child: widget.shell),
      bottomNavigationBar: isWide
          ? null
          : BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: _onNavTap,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF00B894),
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
                BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Faculty'),
                BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Students'),
                BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Courses'),
                BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
              ],
            ),
    );
  }

  Color _getVerificationColor(String? status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'suspended':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
