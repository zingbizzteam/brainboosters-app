// screens/common/live_class/widgets/live_class_info_widget.dart
import 'package:brainboosters_app/screens/common/live_class/models/live_class_model.dart';
import 'package:brainboosters_app/screens/common/widgets/pricing_action_widget.dart';
import 'package:flutter/material.dart';

class LiveClassInfoWidget extends StatelessWidget {
  final LiveClass liveClass;

  const LiveClassInfoWidget({super.key, required this.liveClass});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Academy name with Live Class badge
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(liveClass.status),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                liveClass.status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              liveClass.academy,
              style: TextStyle(
                color: Colors.teal,
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Live Class title
        Text(
          liveClass.title,
          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),

        // Rating and participants
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              '${liveClass.rating} (${liveClass.totalRatings} reviews)',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 16),
            Icon(Icons.people, color: Colors.grey[600], size: 16),
            const SizedBox(width: 4),
            Text(
              '${liveClass.currentParticipants}/${liveClass.maxParticipants} enrolled',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Live Class description
        Text(
          liveClass.description,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),

        // Instructor and timing info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Instructor: ${liveClass.instructor}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    liveClass.formattedTime,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Duration: ${liveClass.duration} minutes',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Price and Enroll button
        PricingActionWidget(
          price: liveClass.formattedPrice,
          originalPrice: null, // Live classes typically don't have original prices
          buttonText: liveClass.canJoin ? 'Join Live Class' : 'Class Full',
          buttonColor: liveClass.canJoin ? Colors.blue : Colors.grey,
          onPressed: liveClass.canJoin ? () {
  // Handle enrollment
  print('Joining live class: ${liveClass.title}');
} : () {},
          isMobile: isMobile,
        ),

        if (liveClass.isStartingSoon) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Starting soon! Join now.',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'live':
        return Colors.red;
      case 'upcoming':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
