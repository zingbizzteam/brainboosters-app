// screens/coaching_center/faculty/widgets/faculty_card.dart
import 'package:flutter/material.dart';

class FacultyCard extends StatelessWidget {
  final Map<String, dynamic> faculty;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;

  const FacultyCard({
    super.key,
    required this.faculty,
    required this.onEdit,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final profile = faculty['user_profiles'];
    final isActive = profile?['is_active'] ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isActive ? const Color(0xFF00B894) : Colors.grey,
              backgroundImage: profile?['avatar_url'] != null 
                  ? NetworkImage(profile['avatar_url']) 
                  : null,
              child: profile?['avatar_url'] == null
                  ? Text(
                      (profile?['name'] ?? 'F')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          profile?['name'] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isActive ? 'ACTIVE' : 'DISABLED',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    faculty['title'] ?? 'Faculty',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    profile?['email'] ?? '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  if (profile?['phone'] != null)
                    Text(
                      profile['phone'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                ],
              ),
            ),
            PopupMenuButton(
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'toggle') onToggleStatus();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Color(0xFF00B894)),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        isActive ? Icons.block : Icons.check_circle,
                        color: isActive ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(isActive ? 'Disable' : 'Enable'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
