import 'package:flutter/material.dart';

class DashboardSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List items;
  final Map<String, dynamic>? profile;
  final bool loading;

  const DashboardSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
    this.profile,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final safeSelectedIndex = selectedIndex.clamp(0, items.length - 1);

    return Container(
      width: 230,
      color: const Color(0xFFF9FBFD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile section
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                if (profile != null && profile!['avatar_url'] != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(profile!['avatar_url']),
                    radius: 22,
                  )
                else
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    radius: 22,
                    child: Text(
                      profile != null && profile!['first_name'] != null
                          ? profile!['first_name'][0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Color(0xFF4AA0E6),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          profile != null && profile!['first_name'] != null
                              ? '${profile!['first_name']} ${profile!['last_name'] ?? ''}'
                              : 'Student',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF4AA0E6),
                          ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
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
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: item.color.withValues(alpha: 0.08),
                    onTap: () => onItemSelected(i),
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
