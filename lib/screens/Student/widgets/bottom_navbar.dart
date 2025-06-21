// Fixed DashboardBottomNavBar (bottom_navbar.dart)
import 'package:flutter/material.dart';

class DashboardBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List items; // Accepts list of _NavItem

  const DashboardBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure selectedIndex is within bounds
    final safeSelectedIndex = selectedIndex.clamp(0, items.length - 1);

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
        return BottomNavigationBarItem(
          icon: Icon(
            item.icon,
            color: safeSelectedIndex == i
                ? item.color
                : item.color.withValues(alpha: 0.6),
          ),
          label: item.label,
        );
      }),
      selectedItemColor: items[safeSelectedIndex].color,
      unselectedItemColor: Colors.grey[400],
      showUnselectedLabels: true,
      backgroundColor: Colors.white,
      elevation: 8,
    );
  }
}
