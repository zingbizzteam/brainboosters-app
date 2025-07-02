import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardTopBar extends StatefulWidget {
  const DashboardTopBar({super.key});

  @override
  State<DashboardTopBar> createState() => _DashboardTopBarState();
}

class _DashboardTopBarState extends State<DashboardTopBar> {
  String? name;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Use user_profiles table (the new model)
    final data = await Supabase.instance.client
        .from('user_profiles')
        .select('first_name, last_name')
        .eq('id', user.id)
        .maybeSingle();

    setState(() {
      name = (data != null && data['first_name'] != null)
          ? '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'.trim()
          : user.userMetadata?['full_name'] ??
                user.email?.split('@').first ??
                'User';
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
      return const DashboardTopBarSkeleton();
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
                  style: const TextStyle(fontSize: 20, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DashboardTopBarSkeleton extends StatelessWidget {
  const DashboardTopBarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Container with grey color to simulate skeleton loading
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 180,
                height: 36,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 120,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
