// lib/screens/common/live_class/widgets/live_class_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

enum LiveClassStatus { scheduled, live, ended, cancelled, starting_soon }

class LiveClassCard extends StatefulWidget {
  final Map<String, dynamic>? liveClass;
  final bool isLoading;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool enableNavigation;
  final bool showEnrollButton;

  const LiveClassCard({
    super.key,
    this.liveClass,
    this.isLoading = false,
    this.onTap,
    this.width,
    this.height,
    this.enableNavigation = true,
    this.showEnrollButton = true,
  });

  @override
  State<LiveClassCard> createState() => _LiveClassCardState();
}

class _LiveClassCardState extends State<LiveClassCard> {
  Timer? _statusTimer;
  LiveClassStatus _currentStatus = LiveClassStatus.scheduled;
  Duration? _timeUntilStart;
  bool _isNearCapacity = false;

  @override
  void initState() {
    super.initState();
    if (widget.liveClass != null) {
      _calculateStatus();
      _startStatusTimer();
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  void _startStatusTimer() {
    _statusTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _calculateStatus();
      }
    });
  }

  void _calculateStatus() {
    if (widget.liveClass == null) return;

    final scheduledAtStr = widget.liveClass!['scheduled_at']?.toString();
    final rawStatus = widget.liveClass!['status']?.toString().toLowerCase();

    if (scheduledAtStr == null) {
      setState(() => _currentStatus = LiveClassStatus.scheduled);
      return;
    }

    try {
      final scheduledAt = DateTime.parse(scheduledAtStr);
      final now = DateTime.now();
      final difference = scheduledAt.difference(now);

      final maxParticipants =
          _safeInt(widget.liveClass!['max_participants']) ?? 100;
      final currentParticipants =
          _safeInt(widget.liveClass!['current_participants']) ?? 0;
      _isNearCapacity = (currentParticipants / maxParticipants) >= 0.8;

      setState(() {
        if (rawStatus == 'live') {
          _currentStatus = LiveClassStatus.live;
          _timeUntilStart = null;
        } else if (rawStatus == 'ended' || rawStatus == 'completed') {
          _currentStatus = LiveClassStatus.ended;
          _timeUntilStart = null;
        } else if (rawStatus == 'cancelled') {
          _currentStatus = LiveClassStatus.cancelled;
          _timeUntilStart = null;
        } else if (difference.inMinutes <= 15 && difference.inMinutes > -30) {
          _currentStatus = LiveClassStatus.starting_soon;
          _timeUntilStart = difference.isNegative ? null : difference;
        } else if (scheduledAt.isAfter(now)) {
          _currentStatus = LiveClassStatus.scheduled;
          _timeUntilStart = difference;
        } else {
          _currentStatus = LiveClassStatus.ended;
          _timeUntilStart = null;
        }
      });
    } catch (e) {
      debugPrint('Error parsing scheduled_at: $e');
      setState(() => _currentStatus = LiveClassStatus.scheduled);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = widget.width ?? 300.0;
    final cardHeight = widget.height ?? 380.0;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: widget.isLoading || widget.liveClass == null
          ? _buildSkeletonCard(cardWidth, cardHeight)
          : _buildLiveClassCard(context, cardWidth, cardHeight),
    );
  }

  // CRITICAL FIX: Completely rewritten to eliminate unbounded width errors
  Widget _buildLiveClassCard(
    BuildContext context,
    double width,
    double height,
  ) {
    final thumbnailHeight = height * 0.30;

    return Container(
      width: width, // CRITICAL: Explicit width constraint
      height: height,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 3,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _handleTap(context),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(thumbnailHeight),

              // FIXED: Use Expanded with bounded width parent
              Expanded(
                child: Container(
                  width:
                      width -
                      32, // CRITICAL: Bounded width (accounting for margins)
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTitle(),
                      const SizedBox(height: 4),
                      _buildInstructor(),
                      const SizedBox(height: 4),

                      // FIXED: Single column layout instead of problematic Row
                      _buildScheduleInfo(),
                      const SizedBox(height: 4),
                      _buildParticipantsAndPricing(),

                      // Use remaining space for button
                      const Spacer(),

                      if (widget.showEnrollButton) _buildActionButton(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(double height) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Container(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [_buildThumbnailImage(height), _buildThumbnailOverlays()],
        ),
      ),
    );
  }

  Widget _buildThumbnailImage(double height) {
    final thumbnailUrl = widget.liveClass?['thumbnail_url']?.toString();

    if (thumbnailUrl == null || thumbnailUrl.isEmpty) {
      return _buildPlaceholderThumbnail(height);
    }

    return CachedNetworkImage(
      imageUrl: thumbnailUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: height,
      placeholder: (context, url) => _buildPlaceholderThumbnail(height),
      errorWidget: (context, url, error) => _buildPlaceholderThumbnail(height),
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 200),
    );
  }

  Widget _buildPlaceholderThumbnail(double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[300]!, Colors.purple[300]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.videocam, size: 48, color: Colors.white),
    );
  }

  Widget _buildThumbnailOverlays() {
    return Stack(
      children: [
        Positioned(top: 8, left: 8, child: _buildStatusBadge()),
        if (_isNearCapacity)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange[700],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Almost Full',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (widget.liveClass?['duration_minutes'] != null)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatDuration(widget.liveClass!['duration_minutes']),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        if (_currentStatus == LiveClassStatus.live)
          Positioned(bottom: 8, left: 8, child: _buildLiveIndicator()),
      ],
    );
  }

  Widget _buildStatusBadge() {
    String text;
    Color color;

    switch (_currentStatus) {
      case LiveClassStatus.live:
        text = 'LIVE';
        color = Colors.red;
        break;
      case LiveClassStatus.starting_soon:
        text = 'STARTING SOON';
        color = Colors.orange;
        break;
      case LiveClassStatus.ended:
        text = 'ENDED';
        color = Colors.grey;
        break;
      case LiveClassStatus.cancelled:
        text = 'CANCELLED';
        color = Colors.red[300]!;
        break;
      default:
        text = 'SCHEDULED';
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return TweenAnimationBuilder(
      duration: const Duration(seconds: 1),
      tween: Tween<double>(begin: 0.5, end: 1.0),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Colors.white, size: 6),
                SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      onEnd: () {
        setState(() {}); // Restart animation
      },
    );
  }

  Widget _buildTitle() {
    final title = widget.liveClass?['title']?.toString() ?? 'Live Class';
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildInstructor() {
    final teacher = _extractTeacherData();
    final teacherName = teacher?['name'] ?? 'Unknown Instructor';

    return Text(
      teacherName,
      style: TextStyle(
        fontSize: 11,
        color: Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  // CRITICAL FIX: Removed problematic Row layout
  Widget _buildScheduleInfo() {
    final scheduledAt = _parseScheduledAt();
    if (scheduledAt == null) {
      return Text(
        'Schedule TBA',
        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatDateTime(scheduledAt),
          style: TextStyle(
            fontSize: 11,
            color: Colors.blue[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        if (_timeUntilStart != null &&
            _currentStatus == LiveClassStatus.scheduled)
          Text(
            _formatTimeUntilStart(_timeUntilStart!),
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
      ],
    );
  }

  // CRITICAL FIX: Removed problematic Row with Expanded children
  Widget _buildParticipantsAndPricing() {
    final maxParticipants =
        _safeInt(widget.liveClass?['max_participants']) ?? 0;
    final currentParticipants =
        _safeInt(widget.liveClass?['current_participants']) ?? 0;
    final price = _safeDouble(widget.liveClass?['price']) ?? 0.0;
    final isFree = widget.liveClass?['is_free'] == true || price == 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Participants info
        if (maxParticipants > 0)
          Text(
            '$currentParticipants/$maxParticipants participants',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        const SizedBox(height: 2),
        // Pricing info
        _buildPricing(isFree, price),
      ],
    );
  }

  Widget _buildPricing(bool isFree, double price) {
    if (isFree) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Text(
          'FREE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.green[700],
          ),
        ),
      );
    }

    return Text(
      '₹${_formatPrice(price)}',
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final isEnrolled = widget.liveClass?['is_enrolled'] == true;

    String buttonText;
    Color buttonColor;
    VoidCallback? onPressed;

    switch (_currentStatus) {
      case LiveClassStatus.live:
        buttonText = isEnrolled ? 'Join Now' : 'View Live';
        buttonColor = Colors.red;
        onPressed = () => _handleJoinLive(context);
        break;
      case LiveClassStatus.starting_soon:
        buttonText = isEnrolled ? 'Join Soon' : 'Enroll Now';
        buttonColor = Colors.orange;
        onPressed = isEnrolled ? null : () => _handleEnroll(context);
        break;
      case LiveClassStatus.ended:
        buttonText = _hasRecording() ? 'View Recording' : "No Recoding";
        buttonColor = Colors.blue[300]!;
        onPressed = _hasRecording()
            ? () => _handleViewRecording(context)
            : null;
        break;
      case LiveClassStatus.cancelled:
        buttonText = 'Cancelled';
        buttonColor = Colors.grey;
        onPressed = null;
        break;
      default:
        buttonText = isEnrolled ? 'Enrolled' : 'Enroll Now';
        buttonColor = isEnrolled
            ? Colors.green
            : Theme.of(context).primaryColor;
        onPressed = isEnrolled ? null : () => _handleEnroll(context);
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // Navigation and action handlers (keep existing)
  void _handleTap(BuildContext context) {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }

    if (!widget.enableNavigation) return;

    final liveClassId = _extractLiveClassId();
    if (liveClassId == null || liveClassId.isEmpty) {
      _showErrorSnackBar(context, 'Invalid live class ID');
      return;
    }

    try {
      context.go('/live-class/$liveClassId');
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to open live class');
    }
  }

  void _handleEnroll(BuildContext context) {
    final liveClassId = _extractLiveClassId();
    if (liveClassId == null) {
      _showErrorSnackBar(context, 'Cannot enroll: Invalid live class');
      return;
    }

    _showEnrollmentDialog(context, liveClassId);
  }

  void _handleJoinLive(BuildContext context) {
    final liveClassId = _extractLiveClassId();
    if (liveClassId == null) return;

    context.go('/live-class/$liveClassId/join');
  }

  void _handleViewRecording(BuildContext context) {
    final recordingUrl = widget.liveClass?['recording_url']?.toString();
    if (recordingUrl != null && recordingUrl.isNotEmpty) {
      debugPrint('Opening recording: $recordingUrl');
    }
  }

  void _showEnrollmentDialog(BuildContext context, String liveClassId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enroll in Live Class'),
        content: Text(
          'Would you like to enroll in "${widget.liveClass?['title']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performEnrollment(liveClassId);
            },
            child: const Text('Enroll'),
          ),
        ],
      ),
    );
  }

  Future<void> _performEnrollment(String liveClassId) async {
    try {
      debugPrint('Enrolling in live class: $liveClassId');
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context, 'Enrollment failed');
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Keep all your existing skeleton and helper methods
  Widget _buildSkeletonCard(double width, double height) {
    final thumbnailHeight = height * 0.30;

    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: thumbnailHeight,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 11,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 11,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 10,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 32,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods (keep all existing ones)
  String? _extractLiveClassId() {
    final possibleIdFields = ['id', 'live_class_id', 'liveClassId'];

    for (final field in possibleIdFields) {
      final value = widget.liveClass?[field];
      if (value != null) {
        final stringValue = value.toString().trim();
        if (stringValue.isNotEmpty && stringValue != 'null') {
          return stringValue;
        }
      }
    }

    return null;
  }

  Map<String, dynamic>? _extractTeacherData() {
    final teachers = widget.liveClass?['teachers'];
    if (teachers is List && teachers.isNotEmpty) {
      final teacher = teachers.first;
      final userProfile = teacher['user_profiles'];
      if (userProfile != null) {
        final firstName = userProfile['first_name']?.toString() ?? '';
        final lastName = userProfile['last_name']?.toString() ?? '';
        return {'name': '$firstName $lastName'.trim()};
      }
    }

    return null;
  }

  String _extractCenterName() {
    final coachingCenters = widget.liveClass?['coaching_centers'];
    return coachingCenters?['center_name']?.toString() ?? '';
  }

  DateTime? _parseScheduledAt() {
    final scheduledAtStr = widget.liveClass?['scheduled_at']?.toString();
    if (scheduledAtStr == null || scheduledAtStr.isEmpty) return null;

    try {
      return DateTime.parse(scheduledAtStr);
    } catch (e) {
      debugPrint('Error parsing scheduled_at: $e');
      return null;
    }
  }

  bool _hasRecording() {
    final recordingUrl = widget.liveClass?['recording_url']?.toString();
    return recordingUrl != null && recordingUrl.isNotEmpty;
  }

  double? _safeDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String _formatDuration(dynamic minutes) {
    final totalMinutes = _safeInt(minutes) ?? 0;
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final cardDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (cardDate == today) {
      dateStr = 'Today';
    } else if (cardDate == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dateStr at $timeStr';
  }

  String _formatTimeUntilStart(Duration duration) {
    if (duration.inDays > 0) {
      return 'Starts in ${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return 'Starts in ${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else if (duration.inMinutes > 0) {
      return 'Starts in ${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Starting soon';
    }
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}k';
    }
    return price.toStringAsFixed(price == price.roundToDouble() ? 0 : 2);
  }
}
