// screens/coaching_center/faculty/widgets/faculty_header.dart
import 'package:flutter/material.dart';

class FacultyHeader extends StatelessWidget {
  final int facultyCount;
  final Function(String) onSearchChanged;
  final VoidCallback onAddPressed;

  const FacultyHeader({
    super.key,
    required this.facultyCount,
    required this.onSearchChanged,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Faculty Management',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B894),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$facultyCount Total',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add),
                label: const Text('Add Faculty'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B894),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search faculty...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ],
      ),
    );
  }
}
