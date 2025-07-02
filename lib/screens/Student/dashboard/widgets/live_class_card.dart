import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LiveClassCard extends StatelessWidget {
  final Map liveClass;
  final VoidCallback onTap;
  const LiveClassCard({
    super.key,
    required this.liveClass,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return Colors.red;
      case 'scheduled':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dt = liveClass['scheduled_at'] != null
        ? DateTime.tryParse(liveClass['scheduled_at'])
        : null;
    final timeStr = dt != null
        ? DateFormat('MMM d, h:mm a').format(dt.toLocal())
        : '';
    final status = (liveClass['status'] ?? '').toString().toUpperCase();
    final duration = liveClass['duration_minutes'] != null
        ? "${liveClass['duration_minutes']} min"
        : '';

    return SizedBox(
      width: 220,
      height: 230, // Match CourseCard height
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              child: Image.network(
                liveClass['thumbnail_url'] ?? '',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.live_tv,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Force exactly 2 lines for title
                    Text(
                      liveClass['title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if ((liveClass['description'] ?? '').toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          liveClass['description'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        if (duration.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            duration,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
