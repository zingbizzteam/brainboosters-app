import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class LiveClassCard extends StatelessWidget {
  final Map<String, dynamic> liveClass;
  final VoidCallback? onTap;
 final bool isLoading; // NEW: Loading state support

  const LiveClassCard({
    super.key,
    required this.liveClass,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 360;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    double cardWidth;
    if (isSmallMobile) {
      cardWidth = screenWidth * 0.75;
    } else if (isMobile) {
      cardWidth = screenWidth * 0.60;
    } else if (isTablet) {
      cardWidth = 300;
    } else {
      cardWidth = 320;
    }
    if (isLoading || liveClass == null) {
      return _buildShimmerCard(context);
    }

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap:
              onTap ??
              () {
                final liveClassId = liveClass['id']?.toString();
                if (liveClassId != null && liveClassId.isNotEmpty) {
                  context.go('/live-class/$liveClassId');
                }
              },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThumbnail(cardWidth),
              _buildContent(isSmallMobile, isMobile, isTablet, cardWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(double cardWidth) {
    final thumbnailUrl = liveClass['thumbnail_url']?.toString();
    final thumbnailHeight = cardWidth * (9 / 16);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          child: Container(
            height: thumbnailHeight,
            width: double.infinity,
            child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                ? Image.network(
                    thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholder(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildPlaceholder();
                    },
                  )
                : _buildPlaceholder(),
          ),
        ),
        // Price badge
        Positioned(top: 8, right: 8, child: _buildPriceBadge()),
        // Status badge
        Positioned(top: 8, left: 8, child: _buildStatusBadge()),
        // Live indicator for live classes
        if (_getStatus().toLowerCase() == 'live')
          Positioned(top: 8, left: 50, child: _buildLiveIndicator()),
      ],
    );
  }

  Widget _buildPriceBadge() {
    final price = _getPrice();
    final isFree = _isFree();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFree ? Colors.green : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        isFree ? 'FREE' : '₹${price.toStringAsFixed(0)}',
        style: TextStyle(
          color: isFree ? Colors.white : Colors.green,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final status = _getStatus();
    final statusColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 3),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.live_tv, size: 48, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildContent(
    bool isSmallMobile,
    bool isMobile,
    bool isTablet,
    double cardWidth,
  ) {
    final adaptivePadding = cardWidth < 200
        ? 8.0
        : (isSmallMobile ? 10.0 : 12.0);

    return Padding(
      padding: EdgeInsets.all(adaptivePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Instructor/Academy name
          Text(
            _getInstructorName(),
            style: TextStyle(
              color: Colors.purple,
              fontSize: _getResponsiveFontSize(
                isSmallMobile,
                isMobile,
                isTablet,
                8,
                9,
                10,
                11,
              ),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: cardWidth < 200 ? 2 : (isSmallMobile ? 3 : 4)),

          // Live class title
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: cardWidth < 200 ? 32 : (isSmallMobile ? 36 : 40),
            ),
            child: Text(
              _getLiveClassTitle(),
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  isSmallMobile,
                  isMobile,
                  isTablet,
                  13,
                  14,
                  15,
                  16,
                ),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: cardWidth < 200 ? 3 : (isSmallMobile ? 4 : 6)),

          // Description (only for wider cards)
          if (cardWidth >= 200 && _getDescription().isNotEmpty) ...[
            Text(
              _getDescription(),
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  isSmallMobile,
                  isMobile,
                  isTablet,
                  7,
                  8,
                  9,
                  9,
                ),
                color: Colors.grey[600],
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isSmallMobile ? 4 : 6),
          ],

          // Time and duration row
          if (cardWidth >= 180)
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: isSmallMobile ? 10 : 12,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: isSmallMobile ? 3 : 4),
                    Flexible(
                      child: Text(
                        _getFormattedTime(),
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(
                            isSmallMobile,
                            isMobile,
                            isTablet,
                            7,
                            8,
                            9,
                            9,
                          ),
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_getDuration().isNotEmpty) ...[
                      SizedBox(width: isSmallMobile ? 6 : 8),
                      Icon(
                        Icons.access_time,
                        size: isSmallMobile ? 10 : 12,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: isSmallMobile ? 3 : 4),
                      Text(
                        _getDuration(),
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(
                            isSmallMobile,
                            isMobile,
                            isTablet,
                            7,
                            8,
                            9,
                            9,
                          ),
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: cardWidth < 200 ? 4 : (isSmallMobile ? 6 : 8)),
              ],
            ),

          // Bottom row with participants and join button
          _buildBottomRow(isSmallMobile, isMobile, isTablet, cardWidth),
        ],
      ),
    );
  }

  Widget _buildBottomRow(
    bool isSmallMobile,
    bool isMobile,
    bool isTablet,
    double cardWidth,
  ) {
    final participantCount = _getParticipantCount();
    final status = _getStatus().toLowerCase();

    // For very small cards, show only essential info
    if (cardWidth < 160) {
      if (status == 'live') {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'JOIN NOW',
            style: TextStyle(
              color: Colors.red,
              fontSize: _getResponsiveFontSize(
                isSmallMobile,
                isMobile,
                isTablet,
                7,
                8,
                9,
                9,
              ),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else {
        return Text(
          _getFormattedTime(),
          style: TextStyle(
            fontSize: _getResponsiveFontSize(
              isSmallMobile,
              isMobile,
              isTablet,
              7,
              8,
              8,
              9,
            ),
            color: Colors.grey[600],
          ),
        );
      }
    }

    // For wider cards, show full bottom row
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (participantCount > 0)
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people,
                  size: _getResponsiveFontSize(
                    isSmallMobile,
                    isMobile,
                    isTablet,
                    10,
                    11,
                    12,
                    13,
                  ),
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 2),
                Text(
                  '$participantCount',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(
                      isSmallMobile,
                      isMobile,
                      isTablet,
                      8,
                      9,
                      10,
                      10,
                    ),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        _buildActionButton(isSmallMobile, isMobile, isTablet, status),
      ],
    );
  }

  Widget _buildActionButton(
    bool isSmallMobile,
    bool isMobile,
    bool isTablet,
    String status,
  ) {
    String buttonText;
    Color buttonColor;

    switch (status) {
      case 'live':
        buttonText = 'JOIN';
        buttonColor = Colors.red;
        break;
      case 'scheduled':
        buttonText = 'ENROLL';
        buttonColor = Colors.orange;
        break;
      case 'completed':
        buttonText = 'REPLAY';
        buttonColor = Colors.green;
        break;
      default:
        buttonText = 'VIEW';
        buttonColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallMobile ? 6 : 8,
        vertical: isSmallMobile ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: buttonColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: buttonColor.withOpacity(0.3)),
      ),
      child: Text(
        buttonText,
        style: TextStyle(
          color: buttonColor,
          fontSize: _getResponsiveFontSize(
            isSmallMobile,
            isMobile,
            isTablet,
            7,
            8,
            9,
            9,
          ),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper method for responsive font sizes
  double _getResponsiveFontSize(
    bool isSmallMobile,
    bool isMobile,
    bool isTablet,
    double smallMobileSize,
    double mobileSize,
    double tabletSize,
    double desktopSize,
  ) {
    if (isSmallMobile) return smallMobileSize;
    if (isMobile) return mobileSize;
    if (isTablet) return tabletSize;
    return desktopSize;
  }

  // Status color mapping
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
        return Colors.blue;
    }
  }

  // Safe getter methods with fallbacks
  String _getLiveClassTitle() {
    return liveClass['title']?.toString() ?? 'Untitled Live Class';
  }

  String _getInstructorName() {
    // Handle instructor data from live class
    final teachers = liveClass['teachers'];
    final coachingCenters = liveClass['coaching_centers'];

    String instructorName = 'Unknown Instructor';
    String centerName = '';

    // Get instructor name
    if (teachers is Map) {
      final userProfiles = teachers['user_profiles'];
      if (userProfiles is Map) {
        final firstName = userProfiles['first_name']?.toString() ?? '';
        final lastName = userProfiles['last_name']?.toString() ?? '';
        if (firstName.isNotEmpty || lastName.isNotEmpty) {
          instructorName = '$firstName $lastName'.trim();
        }
      }
    }

    // Get coaching center name
    if (coachingCenters is Map) {
      centerName = coachingCenters['center_name']?.toString() ?? '';
    }

    // Return formatted string
    if (centerName.isNotEmpty) {
      return '$instructorName - $centerName';
    }

    return instructorName;
  }

  String _getDescription() {
    return liveClass['description']?.toString() ?? '';
  }

  String _getStatus() {
    return liveClass['status']?.toString() ?? 'scheduled';
  }

  String _getFormattedTime() {
    final scheduledAt = liveClass['scheduled_at'];
    if (scheduledAt == null) return '';

    final dt = DateTime.tryParse(scheduledAt.toString());
    if (dt == null) return '';

    return DateFormat('MMM d, h:mm a').format(dt.toLocal());
  }

  String _getDuration() {
    final durationMinutes = liveClass['duration_minutes'];
    if (durationMinutes == null) return '';

    if (durationMinutes is num) {
      return '${durationMinutes.toInt()} min';
    }

    return '';
  }

  double _getPrice() {
    final price = liveClass['price'];
    if (price is num) return price.toDouble();
    return 0.0;
  }

  bool _isFree() {
    final isFree = liveClass['is_free'];
    if (isFree is bool) return isFree;
    return _getPrice() == 0.0;
  }

  int _getParticipantCount() {
    final count = liveClass['current_participants'];
    if (count is num) return count.toInt();
    return 0;
  }
}
 Widget _buildShimmerCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 360;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    double cardWidth;
    if (isSmallMobile) {
      cardWidth = screenWidth * 0.75;
    } else if (isMobile) {
      cardWidth = screenWidth * 0.60;
    } else if (isTablet) {
      cardWidth = 300;
    } else {
      cardWidth = 320;
    }

    final thumbnailHeight = cardWidth * (9 / 16);
    final adaptivePadding = cardWidth < 200 ? 8.0 : (isSmallMobile ? 10.0 : 12.0);

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thumbnail shimmer
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                child: Container(
                  height: thumbnailHeight,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
              
              // Content shimmer - same structure as your original card
              Padding(
                padding: EdgeInsets.all(adaptivePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // All your shimmer elements here...
                    // (Use the shimmer structure from above)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }