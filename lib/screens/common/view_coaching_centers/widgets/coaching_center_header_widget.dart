// screens/common/coaching_centers/widgets/coaching_center_header_widget.dart
import 'package:flutter/material.dart';
import '../models/coaching_center_model.dart';

class CoachingCenterHeaderWidget extends StatelessWidget {
  final CoachingCenter coachingCenter;
  final bool isMobile;

  const CoachingCenterHeaderWidget({
    super.key,
    required this.coachingCenter,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Image
        Container(
          width: isMobile ? 80 : 120,
          height: isMobile ? 80 : 120,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.network(
              coachingCenter.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.school,
                size: isMobile ? 40 : 60,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),

        SizedBox(width: isMobile ? 16 : 24),

        // Title and Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name and Verification
              Row(
                children: [
                  Expanded(
                    child: Text(
                      coachingCenter.name,
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (coachingCenter.isVerified)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Verified',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Description
              Text(
                coachingCenter.description,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.grey[600],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Stats Row - Fixed overflow issue
              if (isMobile)
                _buildMobileStats()
              else
                _buildDesktopStats(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First row
        Row(
          children: [
            const Icon(Icons.star, color: Colors.orange, size: 18),
            const SizedBox(width: 4),
            Text(
              coachingCenter.formattedRating,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${coachingCenter.formattedStudents} students',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Second row
        Text(
          coachingCenter.successRateText,
          style: TextStyle(
            fontSize: 14,
            color: Colors.green[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopStats() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.orange, size: 20),
            const SizedBox(width: 4),
            Text(
              coachingCenter.formattedRating,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        Text(
          '${coachingCenter.formattedStudents} students',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        Text(
          coachingCenter.successRateText,
          style: TextStyle(
            fontSize: 16,
            color: Colors.green[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
