import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardTopBar extends StatefulWidget {
  const DashboardTopBar({super.key});

  @override
  State<DashboardTopBar> createState() => _DashboardTopBarState();
}

class _DashboardTopBarState extends State<DashboardTopBar> {
  String? name;
  String? avatarUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    // Try to get from profiles table first
    final data = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    setState(() {
      name = data?['name'] ??
          user.userMetadata?['full_name'] ??
          user.email?.split('@').first ??
          'User';
      avatarUrl = data?['avatar_url'] ?? user.userMetadata?['avatar_url'];
      isLoading = false;
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: CircularProgressIndicator(),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Hi ${name ?? ''},",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Color(0xFF4AA0E6),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _getGreeting(),
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      
            _UserAvatar(name: name, avatarUrl: avatarUrl),
         
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String? name;
  final String? avatarUrl;
  const _UserAvatar({this.name, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl!),
        radius: 20,
      );
    }
    // Fallback: Use initials
    final initials = (name != null && name!.isNotEmpty)
        ? name!.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : '?';
    return CircleAvatar(
      backgroundColor: Colors.blue.shade100,
      radius: 20,
      child: Text(
        initials,
        style: const TextStyle(
          color: Color(0xFF4AA0E6),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
