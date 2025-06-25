// screens/common/coaching_centers/widgets/coaching_center_faculty_tab.dart
import 'package:flutter/material.dart';
import '../models/coaching_center_model.dart';

class CoachingCenterFacultyTab extends StatelessWidget {
  final CoachingCenter center;
  final bool isMobile;

  const CoachingCenterFacultyTab({
    super.key,
    required this.center,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Faculty',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          if (center.faculty.isEmpty)
            const Center(
              child: Text(
                'Faculty information will be updated soon.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...center.faculty.map((faculty) => _buildFacultyCard(faculty)),
        ],
      ),
    );
  }

  Widget _buildFacultyCard(CoachingCenterFaculty faculty) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: faculty.imageUrl.isNotEmpty 
                ? NetworkImage(faculty.imageUrl)
                : null,
            onBackgroundImageError: (exception, stackTrace) {},
            child: faculty.imageUrl.isEmpty
                ? const Icon(Icons.person, size: 30)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faculty.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  faculty.designation,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  faculty.qualification,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${faculty.experienceYears} years experience',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Subjects: ${faculty.subjects.join(', ')}',
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (faculty.rating > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        faculty.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
