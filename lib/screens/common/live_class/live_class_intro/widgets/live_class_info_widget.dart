// lib/widgets/live_class_info_widget.dart
import 'package:brainboosters_app/screens/common/live_class/room/live_class_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LiveClassInfoWidget extends StatefulWidget {
  final Map<String, dynamic> liveClass;

  const LiveClassInfoWidget({
    super.key,
    required this.liveClass,
  });

  @override
  State<LiveClassInfoWidget> createState() => _LiveClassInfoWidgetState();
}

class _LiveClassInfoWidgetState extends State<LiveClassInfoWidget> {
  bool _isEnrolling = false;
  bool _isCheckingAccess = false;
  Map<String, dynamic>? _accessResult;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    setState(() => _isCheckingAccess = true);
    
    try {
      final result = await LiveClassService.verifyLiveClassAccess(widget.liveClass['id']);
      setState(() {
        _accessResult = result;
        _isCheckingAccess = false;
      });
    } catch (e) {
      setState(() => _isCheckingAccess = false);
    }
  }

  Future<void> _handleEnrollment() async {
    setState(() => _isEnrolling = true);

    try {
      final result = await LiveClassService.enrollInLiveClass(widget.liveClass['id']);
      
      if (result['success']) {
        await _checkAccess(); // Refresh access status
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isEnrolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and basic info
          Text(
            widget.liveClass['title'] ?? 'Live Class',
            style: TextStyle(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          
          // Instructor info
          if (widget.liveClass['teachers'] != null) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    widget.liveClass['teachers']['user_profiles']?['avatar_url'] ??
                    'https://api.dicebear.com/7.x/initials/svg?seed=Teacher',
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getInstructorName(widget.liveClass['teachers']),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'Instructor',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Price and enrollment info
          Row(
            children: [
              if (widget.liveClass['is_free'] == true) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'FREE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ] else if (widget.liveClass['price'] != null) ...[
                Text(
                  '₹${widget.liveClass['price']}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
              const Spacer(),
              Text(
                '${widget.liveClass['current_participants']}/${widget.liveClass['max_participants']} enrolled',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          // Description
          if (widget.liveClass['description'] != null) ...[
            Text(
              widget.liveClass['description'],
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isCheckingAccess) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_accessResult == null) {
      return const SizedBox.shrink();
    }

    final hasAccess = _accessResult!['hasAccess'] ?? false;
    final requiresEnrollment = _accessResult!['requiresEnrollment'] ?? false;
    final requiresPayment = _accessResult!['requiresPayment'] ?? false;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: hasAccess
                ? () => context.push('/live-class/${widget.liveClass['id']}/join')
                : (requiresEnrollment && !requiresPayment)
                    ? (_isEnrolling ? null : _handleEnrollment)
                    : requiresPayment
                        ? () => context.push('/payment/live-class/${widget.liveClass['id']}')
                        : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: hasAccess ? Colors.green : Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              disabledBackgroundColor: Colors.grey[400],
            ),
            child: _isEnrolling
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Enrolling...'),
                    ],
                  )
                : Text(
                    hasAccess
                        ? 'Join Live Class'
                        : requiresPayment
                            ? 'Make Payment'
                            : 'Enroll Now',
                    style: const TextStyle(fontSize: 18),
                  ),
          ),
        ),
        
        if (!hasAccess && !requiresEnrollment && !requiresPayment) ...[
          const SizedBox(height: 12),
          Text(
            _accessResult!['reason'] ?? 'Access denied',
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  String _getInstructorName(Map? teachers) {
    if (teachers == null) return 'Unknown Instructor';
    final userProfiles = teachers['user_profiles'];
    if (userProfiles is Map) {
      final firstName = userProfiles['first_name']?.toString() ?? '';
      final lastName = userProfiles['last_name']?.toString() ?? '';
      return '$firstName $lastName'.trim();
    }
    return 'Unknown Instructor';
  }
}
