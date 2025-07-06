import 'package:brainboosters_app/screens/common/live_class/live_class_repository.dart';
import 'package:brainboosters_app/screens/common/widgets/pricing_action_widget.dart';
import 'package:flutter/material.dart';

class LiveClassInfoWidget extends StatefulWidget {
  final Map<String, dynamic> liveClass;

  const LiveClassInfoWidget({super.key, required this.liveClass});

  @override
  State<LiveClassInfoWidget> createState() => _LiveClassInfoWidgetState();
}

class _LiveClassInfoWidgetState extends State<LiveClassInfoWidget> {
  bool isEnrolling = false;

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
                color: _getStatusColor(widget.liveClass['status']),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.liveClass['status'].toString().toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _getAcademyName(),
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
          widget.liveClass['title'] ?? 'Untitled Live Class',
          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),

        // Participants info
        Row(
          children: [
            Icon(Icons.people, color: Colors.grey[600], size: 16),
            const SizedBox(width: 4),
            Text(
              '${widget.liveClass['current_participants']}/${widget.liveClass['max_participants']} enrolled',
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
          widget.liveClass['description'] ?? 'No description available',
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
                    'Instructor: ${_getInstructorName()}',
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
                    _getFormattedTime(),
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
                    'Duration: ${widget.liveClass['duration_minutes']} minutes',
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
          price: _getFormattedPrice(),
          originalPrice: null,
          buttonText: _getButtonText(),
          buttonColor: _getButtonColor(),
          onPressed: _canEnroll() ? _handleEnrollment : null,
          isMobile: isMobile,
          isLoading: isEnrolling,
        ),

                if (_isStartingSoon()) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Starting soon! Join now to not miss out.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getAcademyName() {
    final coachingCenters = widget.liveClass['coaching_centers'];
    if (coachingCenters is Map) {
      return coachingCenters['center_name']?.toString() ?? 'Unknown Academy';
    }
    return 'Unknown Academy';
  }

  String _getInstructorName() {
    final teachers = widget.liveClass['teachers'];
    if (teachers is Map) {
      final userProfiles = teachers['user_profiles'];
      if (userProfiles is Map) {
        final firstName = userProfiles['first_name']?.toString() ?? '';
        final lastName = userProfiles['last_name']?.toString() ?? '';
        return '$firstName $lastName'.trim();
      }
    }
    return 'Unknown Instructor';
  }

  String _getFormattedTime() {
    final scheduledAt = widget.liveClass['scheduled_at'];
    if (scheduledAt == null) return 'Not scheduled';
    
    final dt = DateTime.tryParse(scheduledAt.toString());
    if (dt == null) return 'Invalid date';
    
    final now = DateTime.now();
    final difference = dt.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days from now';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours from now';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes from now';
    } else if (difference.inMinutes > -60) {
      return 'Live now!';
    } else {
      return 'Completed';
    }
  }

  String _getFormattedPrice() {
    final isFree = widget.liveClass['is_free'] ?? false;
    if (isFree) return 'FREE';
    
    final price = widget.liveClass['price'];
    if (price is num) {
      return '₹${price.toStringAsFixed(0)}';
    }
    return 'FREE';
  }

  String _getButtonText() {
    final status = widget.liveClass['status']?.toString().toLowerCase() ?? '';
    final isEnrolled = widget.liveClass['is_enrolled'] ?? false;
    
    if (isEnrolled) {
      switch (status) {
        case 'live':
          return 'JOIN NOW';
        case 'scheduled':
          return 'ENROLLED';
        case 'completed':
          return 'VIEW RECORDING';
        default:
          return 'ENROLLED';
      }
    } else {
      switch (status) {
        case 'live':
          return 'JOIN LIVE';
        case 'scheduled':
          return 'ENROLL NOW';
        case 'completed':
          return 'VIEW RECORDING';
        case 'cancelled':
          return 'CANCELLED';
        default:
          return 'ENROLL';
      }
    }
  }

  Color _getButtonColor() {
    final status = widget.liveClass['status']?.toString().toLowerCase() ?? '';
    
    switch (status) {
      case 'live':
        return Colors.red;
      case 'scheduled':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'live':
        return Colors.red;
      case 'scheduled':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  bool _canEnroll() {
    final status = widget.liveClass['status']?.toString().toLowerCase() ?? '';
    final isEnrolled = widget.liveClass['is_enrolled'] ?? false;
    final currentParticipants = widget.liveClass['current_participants'] ?? 0;
    final maxParticipants = widget.liveClass['max_participants'] ?? 0;
    
    if (status == 'cancelled') return false;
    if (isEnrolled && status != 'live') return false;
    if (currentParticipants >= maxParticipants && !isEnrolled) return false;
    
    return true;
  }

  bool _isStartingSoon() {
    final scheduledAt = widget.liveClass['scheduled_at'];
    if (scheduledAt == null) return false;
    
    final dt = DateTime.tryParse(scheduledAt.toString());
    if (dt == null) return false;
    
    final now = DateTime.now();
    final difference = dt.difference(now);
    
    return difference.inMinutes > 0 && difference.inMinutes <= 30;
  }

  Future<void> _handleEnrollment() async {
    if (isEnrolling) return;
    
    setState(() {
      isEnrolling = true;
    });

    try {
      final success = await LiveClassRepository.enrollInLiveClass(
        widget.liveClass['id']
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully enrolled in live class!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Update the local state
        setState(() {
          widget.liveClass['is_enrolled'] = true;
          widget.liveClass['current_participants'] = 
              (widget.liveClass['current_participants'] ?? 0) + 1;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to enroll. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isEnrolling = false;
      });
    }
  }
}

