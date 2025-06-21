// Fixed DashboardSidebar (sidebar.dart)
import 'package:flutter/material.dart';

class DashboardSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List items; // Accepts list of _NavItem

  const DashboardSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure selectedIndex is within bounds
    final safeSelectedIndex = selectedIndex.clamp(0, items.length - 1);

    return Container(
      width: 230,
      color: const Color(0xFFF9FBFD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/brain_boosters_logo.png',
                  height: 40,
                ),
                const SizedBox(width: 12),
                const Text(
                  "BRAIN BOOSTERS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF4AA0E6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                final isSelected = safeSelectedIndex == i;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 2.0,
                  ),
                  child: ListTile(
                    leading: Icon(
                      item.icon,
                      color: isSelected ? item.color : Colors.grey[400],
                      size: 30,
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected ? item.color : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: item.color.withValues(alpha: 0.08),
                    onTap: () {
                      print('Sidebar tapped: $i');
                      onItemSelected(i);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
