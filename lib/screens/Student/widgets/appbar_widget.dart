// widgets/appbar_widget.dart
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:brainboosters_app/screens/common/search/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppBarWidget extends StatefulWidget {
  final String? title;
  final bool showBackButton;
  final List<Widget>? additionalActions;

  const AppBarWidget({
    super.key,
    this.title,
    this.showBackButton = false,
    this.additionalActions,
  });

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget>
    with TickerProviderStateMixin {
  String? name;
  String? avatarUrl;
  bool isLoading = true;
  int unreadNotificationCount = 3;
  bool isSearchExpanded = false;
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          name =
              data?['name'] ??
              user.userMetadata?['full_name'] ??
              user.email?.split('@').first ??
              'User';
          avatarUrl = data?['avatar_url'] ?? user.userMetadata?['avatar_url'];
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

  void _toggleSearch() {
    setState(() {
      isSearchExpanded = !isSearchExpanded;
    });

    if (isSearchExpanded) {
      _searchAnimationController.forward();
    } else {
      _searchAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      height: kToolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(color: Color(0xFFF9FBFD)),
      child: Row(
        children: [
          // Leading Widget: Hide logo on mobile when search is expanded
          if (widget.showBackButton)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4AA0E6)),
              onPressed: () => Navigator.of(context).pop(),
            )
          else if (!(isMobile && isSearchExpanded)) // <--- HIDE LOGO
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/images/Brain_Boosters_Logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF4AA0E6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

          // Title/Search Area
          Expanded(
            child: AnimatedBuilder(
              animation: _searchAnimation,
              builder: (context, child) {
                if (isSearchExpanded) {
                  return SearchBarWidget(
                    isExpanded: true,
                    autoFocus: true,
                    onSearchToggle: _toggleSearch,
                    hintText:
                        'Search courses, live classes, coaching centers...',
                  );
                }
                return widget.title != null
                    ? Center(
                        child: Text(
                          widget.title!,
                          style: const TextStyle(
                            color: Color(0xFF4AA0E6),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Additional actions if provided
              if (widget.additionalActions != null && !isSearchExpanded)
                ...widget.additionalActions!,

              // Search Button
              IconButton(
                onPressed: _toggleSearch,
                icon: Icon(
                  isSearchExpanded ? Icons.close : Icons.search,
                  color: const Color(0xFF4AA0E6),
                  size: 24,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  padding: const EdgeInsets.all(8),
                ),
              ),

              if (!isSearchExpanded) ...[
                // Notification Button
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Stack(
                    children: [
                      IconButton(
                        onPressed: () {
                          context.push(CommonRoutes.notifications);
                        },
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Color(0xFF4AA0E6),
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      // Notification badge
                      if (unreadNotificationCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              unreadNotificationCount > 99
                                  ? '99+'
                                  : unreadNotificationCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // User Avatar
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : UserAvatar(name: name, avatarUrl: avatarUrl),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String? name;
  final String? avatarUrl;

  const UserAvatar({super.key, this.name, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return GestureDetector(
        onTap: () {
          context.push('${CommonRoutes.settings}/profile');
        },
        child: CircleAvatar(
          backgroundImage: NetworkImage(avatarUrl!),
          radius: 18,
          onBackgroundImageError: (exception, stackTrace) {
            // Handle image loading error
          },
        ),
      );
    }

    // Fallback: Use initials
    final initials = (name != null && name!.isNotEmpty)
        ? name!.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : '?';

    return GestureDetector(
      onTap: () {
        context.push('${CommonRoutes.settings}/profile');
      },
      child: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        radius: 18,
        child: Text(
          initials,
          style: const TextStyle(
            color: Color(0xFF4AA0E6),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
