import 'package:flutter/material.dart';

class DashboardBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List items;
  final String? avatarUrl;

  const DashboardBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final safeSelectedIndex = selectedIndex == -1
        ? 0
        : selectedIndex.clamp(0, items.length - 1);
    final hasSelection = selectedIndex != -1;
    final hasProfileAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return BottomNavigationBar(
      currentIndex: safeSelectedIndex,
      onTap: (index) {
        debugPrint('Bottom nav tapped: $index');
        onItemSelected(index);
      },
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: List.generate(items.length, (i) {
        final item = items[i];
        final isSelected = hasSelection && safeSelectedIndex == i;

        // FIXED: Replace profile icon with avatar if it's the profile item and avatar exists
        Widget iconWidget;
        if (item.label == 'Profile' && hasProfileAvatar) {
          iconWidget = CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl!),
            radius: 12,
            backgroundColor: Colors.transparent,
            onBackgroundImageError: (exception, stackTrace) {
              // Fallback to default icon if image fails
            },
          );
        } else {
          iconWidget = Icon(
            item.icon,
            color: isSelected
                ? item.color
                : Color.lerp(item.color, Colors.white, 0.4),
          );
        }

        return BottomNavigationBarItem(icon: iconWidget, label: item.label);
      }),
      selectedItemColor: hasSelection
          ? items[safeSelectedIndex].color
          : Colors.grey[600],
      unselectedItemColor: Colors.grey[600],
      showUnselectedLabels: true,
      backgroundColor: Colors.white,
      elevation: 8,
    );
  }
}
