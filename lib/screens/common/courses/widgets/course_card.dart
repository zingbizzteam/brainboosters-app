// screens/common/courses/widgets/course_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class CourseCard extends StatelessWidget {
  final Map? course;
  final VoidCallback? onTap;
  final bool showFullDetails;
  final bool isLoading; // NEW: Loading state support
  final double? fixedWidth; // NEW: Fixed width for grid layouts

  const CourseCard({
    super.key,
    this.course,
    this.onTap,
    this.showFullDetails = true,
    this.isLoading = false,
    this.fixedWidth,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Enhanced responsive breakpoints
    final isSmallMobile = screenWidth < 360;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    // Dynamic card width based on screen size or fixed width
    double cardWidth;
    if (fixedWidth != null) {
      cardWidth = fixedWidth!;
    } else if (isSmallMobile) {
      cardWidth = screenWidth * 0.75;
    } else if (isMobile) {
      cardWidth = screenWidth * 0.60;
    } else if (isTablet) {
      cardWidth = 300;
    } else {
      cardWidth = 320;
    }

    // NEW: Show shimmer when loading or course is null
    if (isLoading || course == null) {
      return _buildShimmerCard(cardWidth, isSmallMobile, isMobile, isTablet);
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
                final courseSlug = course!['id']?.toString();
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

  // NEW: Shimmer card for loading states
  Widget _buildShimmerCard(
    double cardWidth,
    bool isSmallMobile,
    bool isMobile,
    bool isTablet,
  ) {
    final thumbnailHeight = cardWidth * (9 / 16);
    final adaptivePadding = cardWidth < 200
        ? 8.0
        : (isSmallMobile ? 10.0 : 12.0);

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

              // Content shimmer
              Padding(
                padding: EdgeInsets.all(adaptivePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Academy name shimmer
                    Container(
                      height: 12,
                      width: cardWidth * 0.6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: isSmallMobile ? 3 : 4),

                    // Title shimmer
                    Container(
                      height: isSmallMobile ? 14 : 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: isSmallMobile ? 14 : 16,
                      width: cardWidth * 0.7,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: isSmallMobile ? 4 : 6),

                    // Stats shimmer (only for wider cards)
                    if (cardWidth >= 200) ...[
                      Row(
                        children: [
                          Container(
                            height: 10,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            height: 10,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallMobile ? 4 : 6),
                    ],

                    // Category shimmer (only for wider cards)
                    if (cardWidth >= 180) ...[
                      Container(
                        height: 20,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(height: isSmallMobile ? 6 : 8),
                    ],

                    // Bottom row shimmer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 12,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          height: 12,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(double cardWidth) {
    final thumbnailUrl = course!['thumbnail_url']?.toString();
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

          // Course title
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: cardWidth < 200 ? 32 : (isSmallMobile ? 36 : 40),
            ),
            child: Text(
              _getCourseTitle(),
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

          // Course stats row
          if (cardWidth >= 200)
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

          // Category
          if (cardWidth >= 180)
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

          // Rating and enrollment
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

    if (cardWidth < 160) {
      if (rating > 0) {
        return _buildRating(isSmallMobile, isMobile, isTablet, true);
      } else if (enrollmentCount > 0) {
        return _buildEnrollmentCount(isSmallMobile, isMobile, isTablet);
      } else {
        return const SizedBox.shrink();
      }
    }

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
      '${enrollmentCount}+ Enrolled',
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

  // Safe getter methods with fallbacks
  String _getCourseTitle() {
    return course!['title']?.toString() ?? 'Untitled Course';
  }

  String _getCoachingCenterName() {
    final centers = course!['coaching_centers'];
    if (centers is Map) {
      return centers['center_name']?.toString() ?? 'Unknown Academy';
    }
    return 'Unknown Academy';
  }

  String _getCategory() {
    return course!['category']?.toString() ?? 'General';
  }

  String _getLevel() {
    final level = course!['level']?.toString() ?? 'beginner';
    return level[0].toUpperCase() + level.substring(1);
  }

  double _getRating() {
    final rating = course!['rating'];
    if (rating is num) return rating.toDouble();
    return 0.0;
  }

  int _getTotalReviews() {
    final reviews = course!['total_reviews'];
    if (reviews is num) return reviews.toInt();
    return 0;
  }

  double _getPrice() {
    final price = course!['price'];
    if (price is num) return price.toDouble();
    return 0.0;
  }

  double _getOriginalPrice() {
    final originalPrice = course!['original_price'];
    if (originalPrice is num) return originalPrice.toDouble();
    return _getPrice();
  }

  int _getTotalLessons() {
    final lessons = course!['total_lessons'];
    if (lessons is num) return lessons.toInt();
    return 0;
  }

  double _getDurationHours() {
    final duration = course!['duration_hours'];
    if (duration is num) return duration.toDouble();
    return 0.0;
  }

  int _getEnrollmentCount() {
    final count = course!['enrollment_count'];
    if (count is num) return count.toInt();
    return 0;
  }
}
