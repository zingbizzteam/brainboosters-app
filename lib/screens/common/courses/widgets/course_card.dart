// screens/common/courses/widgets/course_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CourseCard extends StatelessWidget {
  final Map course;
  final VoidCallback? onTap;
  final bool showFullDetails;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.showFullDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Enhanced responsive breakpoints
    final isSmallMobile = screenWidth < 360;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    // Dynamic card width based on screen size
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
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap:
              onTap ??
              () {
                final courseSlug = course['id']?.toString();
                if (courseSlug != null && courseSlug.isNotEmpty) {
                  context.go('/course/$courseSlug');
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
    final thumbnailUrl = course['thumbnail_url']?.toString();

    // Calculate 16:9 aspect ratio height
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
        // Level badge
        Positioned(top: 8, left: 8, child: _buildLevelBadge()),
      ],
    );
  }

  Widget _buildPriceBadge() {
    final price = _getPrice();
    final originalPrice = _getOriginalPrice();
    final hasDiscount = originalPrice > price && originalPrice > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: price == 0 ? Colors.green : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: price == 0
          ? const Text(
              'FREE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasDiscount)
                  Text(
                    '₹${originalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 9,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Text(
                  '₹${price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLevelBadge() {
    final level = _getLevel();
    Color levelColor;
    switch (level.toLowerCase()) {
      case 'beginner':
        levelColor = Colors.green;
        break;
      case 'intermediate':
        levelColor = Colors.orange;
        break;
      case 'advanced':
        levelColor = Colors.red;
        break;
      default:
        levelColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: levelColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        level.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.school, size: 48, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildContent(
    bool isSmallMobile,
    bool isMobile,
    bool isTablet,
    double cardWidth,
  ) {
    // CRITICAL FIX: Adaptive padding based on card width
    final adaptivePadding = cardWidth < 200
        ? 8.0
        : (isSmallMobile ? 10.0 : 12.0);

    return Padding(
      padding: EdgeInsets.all(adaptivePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Academy name
          Text(
            _getCoachingCenterName(),
            style: TextStyle(
              color: Colors.teal,
              fontSize: _getResponsiveFontSize(
                isSmallMobile,
                isMobile,
                isTablet,
                8, // Reduced for small cards
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

          // Course title - CRITICAL FIX: Constrained height
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: cardWidth < 200
                  ? 32
                  : (isSmallMobile ? 36 : 40), // Limit title height
            ),
            child: Text(
              _getCourseTitle(),
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  isSmallMobile,
                  isMobile,
                  isTablet,
                  13, // Reduced for small cards
                  14,
                  15,
                  16,
                ),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.1, // Tighter line height
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: cardWidth < 200 ? 3 : (isSmallMobile ? 4 : 6)),

          // Course stats row - CRITICAL FIX: Conditional display
          if (cardWidth >= 200) // Only show stats on wider cards
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: isSmallMobile ? 10 : 12,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: isSmallMobile ? 3 : 4),
                    Flexible(
                      child: Text(
                        '${_getTotalLessons()} lessons',
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
                    SizedBox(width: isSmallMobile ? 6 : 8),
                    Icon(
                      Icons.access_time,
                      size: isSmallMobile ? 10 : 12,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: isSmallMobile ? 3 : 4),
                    Text(
                      '${_getDurationHours()}h',
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
                ),
                SizedBox(height: isSmallMobile ? 4 : 6),
              ],
            ),

          // Category - CRITICAL FIX: Simplified for small cards
          if (cardWidth >= 180) // Only show category on wider cards
            Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: cardWidth < 200 ? 4 : (isSmallMobile ? 6 : 8),
                      vertical: cardWidth < 200 ? 1 : (isSmallMobile ? 2 : 3),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getCategory(),
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: _getResponsiveFontSize(
                          isSmallMobile,
                          isMobile,
                          isTablet,
                          7,
                          8,
                          9,
                          9,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: cardWidth < 200 ? 4 : (isSmallMobile ? 6 : 8)),
              ],
            ),

          // Rating and enrollment - CRITICAL FIX: Simplified layout
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
    final rating = _getRating();
    final enrollmentCount = _getEnrollmentCount();

    // For very small cards, show only rating or enrollment count
    if (cardWidth < 160) {
      if (rating > 0) {
        return _buildRating(
          isSmallMobile,
          isMobile,
          isTablet,
          true,
        ); // Compact version
      } else if (enrollmentCount > 0) {
        return _buildEnrollmentCount(isSmallMobile, isMobile, isTablet);
      } else {
        return const SizedBox.shrink();
      }
    }

    // For wider cards, show both
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: _buildRating(isSmallMobile, isMobile, isTablet, false)),
        if (enrollmentCount > 0)
          _buildEnrollmentCount(isSmallMobile, isMobile, isTablet),
      ],
    );
  }

  Widget _buildRating(
    bool isSmallMobile,
    bool isMobile,
    bool isTablet, [
    bool compact = false,
  ]) {
    final rating = _getRating();
    final totalReviews = _getTotalReviews();

    if (rating == 0.0) {
      return compact
          ? const SizedBox.shrink()
          : Text(
              'No ratings yet',
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
                color: Colors.grey,
              ),
            );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          color: Colors.amber,
          size: _getResponsiveFontSize(
            isSmallMobile,
            isMobile,
            isTablet,
            10,
            11,
            12,
            13,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
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
          ),
        ),
        if (!compact && totalReviews > 0)
          Flexible(
            child: Text(
              ' ($totalReviews)',
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
      ],
    );
  }

  Widget _buildEnrollmentCount(
    bool isSmallMobile,
    bool isMobile,
    bool isTablet,
  ) {
    final enrollmentCount = _getEnrollmentCount();
    if (enrollmentCount == 0) return const SizedBox.shrink();

    return Text(
      '${enrollmentCount}+',
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
        fontWeight: FontWeight.w500,
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

  // Safe getter methods with fallbacks (unchanged)
  String _getCourseTitle() {
    return course['title']?.toString() ?? 'Untitled Course';
  }

  String _getCoachingCenterName() {
    final centers = course['coaching_centers'];
    if (centers is Map) {
      return centers['center_name']?.toString() ?? 'Unknown Academy';
    }
    return 'Unknown Academy';
  }

  String _getCategory() {
    return course['category']?.toString() ?? 'General';
  }

  String _getLevel() {
    final level = course['level']?.toString() ?? 'beginner';
    return level[0].toUpperCase() + level.substring(1);
  }

  double _getRating() {
    final rating = course['rating'];
    if (rating is num) return rating.toDouble();
    return 0.0;
  }

  int _getTotalReviews() {
    final reviews = course['total_reviews'];
    if (reviews is num) return reviews.toInt();
    return 0;
  }

  double _getPrice() {
    final price = course['price'];
    if (price is num) return price.toDouble();
    return 0.0;
  }

  double _getOriginalPrice() {
    final originalPrice = course['original_price'];
    if (originalPrice is num) return originalPrice.toDouble();
    return _getPrice();
  }

  int _getTotalLessons() {
    final lessons = course['total_lessons'];
    if (lessons is num) return lessons.toInt();
    return 0;
  }

  double _getDurationHours() {
    final duration = course['duration_hours'];
    if (duration is num) return duration.toDouble();
    return 0.0;
  }

  int _getEnrollmentCount() {
    final count = course['enrollment_count'];
    if (count is num) return count.toInt();
    return 0;
  }
}
