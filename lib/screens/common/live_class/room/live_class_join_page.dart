import 'package:brainboosters_app/screens/common/live_class/room/live_class_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class LiveClassJoinPage extends StatefulWidget {
  final String liveClassId;

  // The 'isTeacher' flag has been removed as requested.
  const LiveClassJoinPage({
    super.key,
    required this.liveClassId,
  });

  @override
  State<LiveClassJoinPage> createState() => _LiveClassJoinPageState();
}

class _LiveClassJoinPageState extends State<LiveClassJoinPage> {
  Map<String, dynamic>? _accessResult;
  bool _isLoading = true;
  bool _isJoining = false;
  bool _isInMeeting = false;
  String? _error;
  DateTime? _joinTime;

  // A listener is defined in the state to handle meeting events.
  late JitsiMeetEventListener _jitsiListener;

  @override
  void initState() {
    super.initState();
    _initializeListener();
    _checkAccess();
  }

  /// Initializes the Jitsi listener to handle conference events.
  void _initializeListener() {
    _jitsiListener = JitsiMeetEventListener(
      conferenceJoined: (url) {
        if (!mounted) return;
        setState(() {
          _isInMeeting = true;
          _isJoining = false;
          _joinTime = DateTime.now();
        });
      },
      conferenceTerminated: (url, error) {
        if (!mounted) return;
        setState(() {
          _isInMeeting = false;
          _isJoining = false;
        });

        // If the meeting terminated with an error, display it.
        if (error != null) {
          setState(() {
            _error = "The meeting ended unexpectedly: ${error.toString()}";
          });
        }
        
        _handleMeetingEnd();
      },
      // You can add other listeners like participantJoined, etc. here if needed
    );
  }

  Future<void> _checkAccess() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await LiveClassService.verifyLiveClassAccess(widget.liveClassId);
      if (mounted) {
        setState(() {
          _accessResult = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to verify access: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  /// Joins the live class by calling the service and passing the listener.
  Future<void> _joinLiveClass() async {
    if (!mounted) return;
    setState(() {
      _isJoining = true;
      _error = null;
    });

    try {
      final liveClassData = _accessResult!['liveClass'];
      
      // The teacher-specific logic is removed.
      // The listener created in this page's state is passed directly.
      await LiveClassService.joinLiveClass(
        liveClassId: widget.liveClassId,
        liveClassData: liveClassData,
        listener: _jitsiListener,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isJoining = false;
        });
      }
    }
  }

  Future<void> _enrollInLiveClass() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await LiveClassService.enrollInLiveClass(widget.liveClassId);
      
      if (result['success']) {
        // Refresh access details after successful enrollment.
        await _checkAccess();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _error = result['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _handleMeetingEnd() {
    if (_joinTime != null) {
      final duration = DateTime.now().difference(_joinTime!).inMinutes;
      debugPrint("Meeting duration: $duration minutes");
    }
    
    // Show a feedback dialog after the meeting ends.
    if(mounted) {
      _showPostMeetingDialog();
    }
  }

  void _showPostMeetingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must interact with the dialog.
      builder: (context) => AlertDialog(
        title: const Text('Live Class Ended'),
        content: const Text('Thank you for attending! How was your experience?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss dialog
              context.pop(); // Go back to the previous screen
            },
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss dialog
              _showFeedbackForm();
            },
            child: const Text('Give Feedback'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Class Feedback'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rate your live class experience:'),
            // TODO: Add a rating widget here (e.g., star rating)
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss dialog
              context.pop(); // Go back to the previous screen
            },
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement feedback submission logic
              Navigator.of(context).pop(); // Dismiss dialog
              context.pop(); // Go back to the previous screen
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Join Live Class'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Verifying class details...'),
          ],
        ),
      );
    }

    if (_error != null && !_isJoining) {
      return _buildErrorState();
    }

    if (_accessResult == null) {
      return const Center(child: Text('Unable to load live class information.'));
    }

    // The Jitsi meeting view is an overlay, so we show a custom screen
    // while the meeting is active to prevent interaction with the page behind it.
    if (_isInMeeting) {
      return _buildInMeetingState();
    }

    if (!_accessResult!['hasAccess']) {
      return _buildAccessDeniedState();
    }

    return _buildJoinState();
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('An Error Occurred', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red[700])),
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Colors.red[600]), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _checkAccess, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessDeniedState() {
    final reason = _accessResult!['reason'] ?? 'Access denied';
    final liveClass = _accessResult!['liveClass'];
    final requiresEnrollment = _accessResult!['requiresEnrollment'] ?? false;
    final requiresPayment = _accessResult!['requiresPayment'] ?? false;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(requiresPayment ? Icons.payment : Icons.lock_outline, size: 64, color: Colors.orange[400]),
            const SizedBox(height: 16),
            Text(requiresPayment ? 'Payment Required' : (requiresEnrollment ? 'Enrollment Required' : 'Access Denied'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(reason, style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
            if (liveClass != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    Text(liveClass['title'] ?? 'Live Class', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    if (liveClass['price'] != null && liveClass['price'] > 0) ...[
                      const SizedBox(height: 8),
                      Text('₹${liveClass['price']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (requiresEnrollment && !requiresPayment)
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _enrollInLiveClass, child: const Text('Enroll Now (Free)')))
            else if (requiresPayment)
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => context.push('/payment/live-class/${widget.liveClassId}'), child: const Text('Proceed to Payment'))),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinState() {
    final liveClass = _accessResult!['liveClass'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_call, size: 80, color: Colors.blue[700]),
          const SizedBox(height: 24),
          Text(liveClass['title'] ?? 'Live Class', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          if (liveClass['teachers'] != null) ...[
            Text('with ${_getInstructorName(liveClass['teachers'])}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
          ],
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _buildDetailRow('Status', liveClass['status']?.toString().toUpperCase() ?? 'UNKNOWN'),
                const SizedBox(height: 8),
                _buildDetailRow('Duration', '${liveClass['duration_minutes']} minutes'),
                const SizedBox(height: 8),
                _buildDetailRow('Participants', '${liveClass['current_participants']}/${liveClass['max_participants']}'),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: TextStyle(color: Colors.red[700]))),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isJoining ? null : _joinLiveClass,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: Colors.grey[400],
              ),
              child: _isJoining
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                        SizedBox(width: 12),
                        Text('Joining...'),
                      ],
                    )
                  : const Text('Join Live Class', style: TextStyle(fontSize: 18)),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Before joining:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800])),
                const SizedBox(height: 8),
                _buildChecklistItem('Ensure a stable internet connection.'),
                _buildChecklistItem('Use headphones for the best audio experience.'),
                _buildChecklistItem('Find a quiet, distraction-free environment.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInMeetingState() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_call, color: Colors.white, size: 64),
            const SizedBox(height: 16),
            const Text('You are in the live class', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('The meeting interface is active.', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildChecklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 18, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  String _getInstructorName(Map? teachers) {
    if (teachers == null) return 'N/A';
    final userProfiles = teachers['user_profiles'];
    if (userProfiles is Map) {
      final firstName = userProfiles['first_name']?.toString() ?? '';
      final lastName = userProfiles['last_name']?.toString() ?? '';
      return '$firstName $lastName'.trim();
    }
    return 'N/A';
  }

  @override
  void dispose() {
    // No need to call removeAllEventListeners anymore, as it's been removed from the service.
    super.dispose();
  }
}