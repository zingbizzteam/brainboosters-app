import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EnrolledLiveClassList extends StatelessWidget {
  final List<Map<String, dynamic>> liveClasses;
  final bool loading;

  const EnrolledLiveClassList({
    super.key,
    required this.liveClasses,
    this.loading = false,
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

  String _formatTime(String? scheduledAt) {
    if (scheduledAt == null) return '';
    try {
      final dt = DateTime.parse(scheduledAt).toLocal();
      return DateFormat('MMM d, h:mm a').format(dt);
    } catch (_) {
      return scheduledAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (liveClasses.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: liveClasses.map((lc) {
        final classData = lc['live_classes'] ?? {};
        final status = (classData['status'] ?? '').toString();
        final scheduledAt = classData['scheduled_at'];
        final duration = classData['duration_minutes'] != null
            ? "${classData['duration_minutes']} min"
            : '';
        final attended = lc['attended'] == true;
        final attendanceDuration = lc['attendance_duration'] ?? 0;
        final rating = lc['rating'];
        final feedback = lc['feedback'];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              context.go(
                CommonRoutes.getLiveClassDetailRoute(
                  lc['live_class_id'] ?? classData['id'],
                ),
              );
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    classData['thumbnail_url'] ?? '',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey[400],
                      child: const Icon(
                        Icons.live_tv,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title, status badge
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: _getStatusColor(status),
                            size: 10,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              classData['title'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
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
                              status.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Time and duration
                      Row(
                        children: [
                          Text(
                            _formatTime(scheduledAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
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
                        ],
                      ),
                      // Description
                      if ((classData['description'] ?? '')
                          .toString()
                          .isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            classData['description'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      // Attendance/rating/feedback (optional, minimal)
                      if (attended ||
                          (rating != null && rating > 0) ||
                          (feedback != null && feedback != ''))
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Row(
                            children: [
                              if (attended)
                                Text(
                                  "Attended (${attendanceDuration} min)",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                  ),
                                ),
                              if (rating != null && rating > 0) ...[
                                const SizedBox(width: 8),
                                Icon(Icons.star, color: Colors.amber, size: 13),
                                Text(
                                  rating.toString(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                              if (feedback != null && feedback != '') ...[
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    feedback,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
