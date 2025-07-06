import 'package:brainboosters_app/screens/common/comming_soon_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBarWidget extends StatelessWidget {
  final String? name;
  final String? avatarUrl;

  const AppBarWidget({super.key, this.name, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(color: Color(0xFFF9FBFD)),
      child: Row(
        children: [
          // Logo on the left
          GestureDetector(
            onTap: () => context.go('/'),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/images/bb-icon.png',
                fit: BoxFit.cover,
                height: 32,
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
          ),

          const Spacer(), // Pushes avatar to the right
          // Avatar/profile on the right
          GestureDetector(
            onTap: () => showComingSoonDialog("View Profile", context),
            child: avatarUrl != null && avatarUrl!.isNotEmpty
                ? CircleAvatar(
                    backgroundImage: NetworkImage(avatarUrl!),
                    radius: 18,
                    onBackgroundImageError: (exception, stackTrace) {},
                  )
                : CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    radius: 18,
                    child: name != null && name!.trim().isNotEmpty
                        ? Text(
                            name!
                                .trim()
                                .split(' ')
                                .map((e) => e[0])
                                .take(2)
                                .join()
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF4AA0E6),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          )
                        : const Icon(Icons.person, color: Color(0xFF4AA0E6)),
                  ),
          ),
        ],
      ),
    );
  }
}
