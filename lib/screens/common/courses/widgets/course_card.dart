// course_card.dart - ENHANCED WITH GO_ROUTER NAVIGATION
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';

class CourseCard extends StatelessWidget {
  final Map<String, dynamic>? course;
  final bool isLoading;
  final VoidCallback? onTap; // Keep for custom overrides
  final double? width;
  final double? height;
  final bool enableNavigation; // ADDED: Control navigation behavior

  const CourseCard({
    super.key,
    this.course,
    this.isLoading = false,
    this.onTap,
    this.width,
    this.height,
    this.enableNavigation = true, // ADDED: Default to true
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = width ?? 280.0;
    final cardHeight = height ?? 320.0;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: isLoading || course == null 
        ? _buildSkeletonCard(cardWidth, cardHeight)
        : _buildCourseCard(context, cardWidth, cardHeight), // ADDED: context parameter
    );
  }

  Widget _buildCourseCard(BuildContext context, double width, double height) {
    final thumbnailHeight = height * 0.5;
    
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _handleTap(context), // ENHANCED: Smart tap handling
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(thumbnailHeight),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // CRITICAL: Smart tap handling with validation and error handling
  void _handleTap(BuildContext context) {
    // PRIORITY 1: Custom onTap override (for special cases)
    if (onTap != null) {
      onTap!();
      return;
    }

    // PRIORITY 2: Navigation disabled
    if (!enableNavigation) {
      debugPrint('CourseCard: Navigation disabled');
      return;
    }

    // PRIORITY 3: No course data
    if (course == null) {
      _showErrorSnackBar(context, 'Course data not available');
      return;
    }

    // PRIORITY 4: Extract and validate course ID
    final courseId = _extractCourseId();
    if (courseId == null || courseId.isEmpty) {
      _showErrorSnackBar(context, 'Invalid course ID');
      return;
    }

    // PRIORITY 5: Perform navigation with error handling
    _navigateToCourseDetail(context, courseId);
  }

  // ENHANCED: Robust course ID extraction with multiple fallbacks
  String? _extractCourseId() {
    // Try multiple possible ID fields (common in different API structures)
    final possibleIdFields = ['id', 'course_id', 'courseId', 'slug', 'uuid'];
    
    for (final field in possibleIdFields) {
      final value = course?[field];
      if (value != null) {
        final stringValue = value.toString().trim();
        if (stringValue.isNotEmpty && stringValue != 'null') {
          return stringValue;
        }
      }
    }
    
    return null;
  }

  // CRITICAL: Safe navigation with error handling
  void _navigateToCourseDetail(BuildContext context, String courseId) {
    try {
      // OPTION 1: Using your CommonRoutes helper (recommended)
      final route = '/course/$courseId';
      context.go(route);
      
      debugPrint('CourseCard: Navigating to course $courseId');
    } catch (e, stackTrace) {
      debugPrint('CourseCard: Navigation error: $e');
      debugPrint('StackTrace: $stackTrace');
      _showErrorSnackBar(context, 'Failed to open course');
    }
  }

  // ENHANCED: User-friendly error feedback
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
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // ... [Keep all your existing helper methods unchanged] ...
  
  Widget _buildThumbnail(double height) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Container(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            _buildThumbnailImage(height),
            _buildThumbnailOverlays(),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailImage(double height) {
    final thumbnailUrl = course?['thumbnail_url']?.toString();
    
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
      color: Colors.grey[200],
      child: const Icon(
        Icons.play_circle_outline,
        size: 48,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildThumbnailOverlays() {
    return Stack(
      children: [
        if (course?['duration_hours'] != null)
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
                _formatDuration(course!['duration_hours']),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        if (course?['level'] != null)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getLevelColor(course!['level']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formatLevel(course!['level']),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(),
        const SizedBox(height: 6),
        _buildInstructor(),
        const SizedBox(height: 8),
        _buildRating(),
        const Spacer(),
        _buildPricing(),
      ],
    );
  }

  Widget _buildTitle() {
    final title = course?['title']?.toString() ?? 'Course Title';
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildInstructor() {
    final centerName = course?['coaching_centers']?['center_name']?.toString() ?? 
                     course?['coaching_center']?['center_name']?.toString() ?? 
                     'Unknown Center';
    
    return Row(
      children: [
        Icon(
          Icons.school_outlined,
          size: 12,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            centerName,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRating() {
    final rating = _safeDouble(course?['rating']) ?? 0.0;
    final totalReviews = _safeInt(course?['total_reviews']) ?? 0;
    final totalLessons = _safeInt(course?['total_lessons']) ?? 0;

    return Row(
      children: [
        if (rating > 0) ...[
          Icon(
            Icons.star,
            size: 12,
            color: Colors.amber[600],
          ),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            '($totalReviews)',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (totalLessons > 0) ...[
          Icon(
            Icons.play_lesson_outlined,
            size: 12,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 2),
          Text(
            '$totalLessons lessons',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPricing() {
    final price = _safeDouble(course?['price']) ?? 0.0;
    final originalPrice = _safeDouble(course?['original_price']);
    final isFree = price == 0.0;

    if (isFree) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Text(
          'FREE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.green[700],
          ),
        ),
      );
    }

    return Row(
      children: [
        Text(
          '₹${_formatPrice(price)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        if (originalPrice != null && originalPrice > price) ...[
          const SizedBox(width: 6),
          Text(
            '₹${_formatPrice(originalPrice)}',
            style: TextStyle(
              fontSize: 11,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey[500],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSkeletonCard(double width, double height) {
    final thumbnailHeight = height * 0.5;
    
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
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
                        height: 14,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 11,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 11,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 14,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
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

  // Safe type conversion helpers
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

  String _formatDuration(dynamic hours) {
    final h = _safeDouble(hours) ?? 0.0;
    final totalMinutes = (h * 60).round();
    final hoursPart = totalMinutes ~/ 60;
    final minutesPart = totalMinutes % 60;
    
    if (hoursPart > 0) {
      return '${hoursPart}h ${minutesPart}m';
    }
    return '${minutesPart}m';
  }

  String _formatLevel(String? level) {
    if (level == null || level.isEmpty) return 'All Levels';
    return level.split('_').map((word) => 
      word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
    ).join(' ');
  }

  Color _getLevelColor(String? level) {
    switch (level?.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      case 'expert':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}k';
    }
    return price.toStringAsFixed(price == price.roundToDouble() ? 0 : 2);
  }
}
