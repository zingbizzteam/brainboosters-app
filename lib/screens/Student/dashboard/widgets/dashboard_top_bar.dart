import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';

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
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          name = 'Guest';
          isLoading = false;
        });
        return;
      }

      // Use user_profiles table (the new model)
      final data = await Supabase.instance.client
          .from('user_profiles')
          .select('first_name, last_name')
          .eq('id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          name = (data != null && data['first_name'] != null)
              ? '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'.trim()
              : user.userMetadata?['full_name'] ??
                    user.email?.split('@').first ??
                    'User';
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          name = 'User';
          isLoading = false;
        });
      }
    }
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
                alignment: Alignment.centerLeft,
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
                alignment: Alignment.centerLeft,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isSmallMobile = screenWidth < 360;

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name skeleton - responsive width
                Container(
                  width: _getNameSkeletonWidth(isMobile, isSmallMobile),
                  height: _getNameSkeletonHeight(isMobile, isSmallMobile),
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 4),

                // Greeting skeleton - responsive width
                Container(
                  width: _getGreetingSkeletonWidth(isMobile, isSmallMobile),
                  height: _getGreetingSkeletonHeight(isMobile, isSmallMobile),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Responsive width for name skeleton
  double _getNameSkeletonWidth(bool isMobile, bool isSmallMobile) {
    if (isSmallMobile) return 140.0;
    if (isMobile) return 180.0;
    return 220.0;
  }

  // Responsive height for name skeleton
  double _getNameSkeletonHeight(bool isMobile, bool isSmallMobile) {
    if (isSmallMobile) return 24.0;
    if (isMobile) return 28.0;
    return 36.0;
  }

  // Responsive width for greeting skeleton
  double _getGreetingSkeletonWidth(bool isMobile, bool isSmallMobile) {
    if (isSmallMobile) return 100.0;
    if (isMobile) return 120.0;
    return 140.0;
  }

  // Responsive height for greeting skeleton
  double _getGreetingSkeletonHeight(bool isMobile, bool isSmallMobile) {
    if (isSmallMobile) return 16.0;
    if (isMobile) return 20.0;
    return 24.0;
  }
}
