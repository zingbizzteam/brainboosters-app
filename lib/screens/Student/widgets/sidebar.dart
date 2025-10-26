import 'package:brainboosters_app/screens/student/widgets/navigation_item.dart';
import 'package:flutter/material.dart';

class DashboardSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<NavigationItem> items;
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
    final isMobile = MediaQuery.of(context).size.width < 768;

    // ✅ CRITICAL FIX: Wrap in LayoutBuilder to handle constraints properly
    return LayoutBuilder(
      builder: (context, constraints) {
        // If parent gives insufficient width, provide minimum
        final effectiveWidth = constraints.maxWidth < 100 
            ? (isMobile ? 280.0 : 280.0)  
            : (isMobile ? constraints.maxWidth : 280.0);

        return Container(
          width: effectiveWidth,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile section (only for logged-in users on desktop)
              if (profile != null && !isMobile) ...[
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      if (profile!['avatar_url'] != null)
                        CircleAvatar(
                          backgroundImage: NetworkImage(profile!['avatar_url']),
                          radius: 22,
                        )
                      else
                        CircleAvatar(
                          backgroundColor: const Color(0xFF4AA0E6).withOpacity(0.1),
                          radius: 22,
                          child: Text(
                            profile!['first_name'] != null
                                ? profile!['first_name'][0].toUpperCase()
                                : 'U',
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
                                profile!['first_name'] != null
                                    ? '${profile!['first_name']} ${profile!['last_name'] ?? ''}'
                                    : 'Student',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF4AA0E6),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Mobile profile section
              if (profile != null && isMobile) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F8FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      if (profile!['avatar_url'] != null)
                        CircleAvatar(
                          backgroundImage: NetworkImage(profile!['avatar_url']),
                          radius: 20,
                        )
                      else
                        CircleAvatar(
                          backgroundColor: const Color(0xFF4AA0E6),
                          radius: 20,
                          child: Text(
                            profile!['first_name'] != null
                                ? profile!['first_name'][0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile!['first_name'] != null
                                  ? '${profile!['first_name']} ${profile!['last_name'] ?? ''}'
                                  : 'Student',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'Student Account',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 24),
              ],

              // Navigation items
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    final isSelected = safeSelectedIndex == i;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: ListTile(
                        // ✅ CRITICAL: Constrain icon width
                        minLeadingWidth: 24,
                        leading: Icon(
                          item.icon,
                          color: isSelected ? item.color : Colors.grey[600],
                          size: 22,
                        ),
                        title: Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected ? item.color : Colors.black87,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        selected: isSelected,
                        selectedTileColor: item.color.withOpacity(0.1),
                        onTap: () => onItemSelected(i),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        horizontalTitleGap: 12,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
