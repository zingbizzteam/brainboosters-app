// screens/coaching_center/courses/widgets/course_card.dart
import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.onEdit,
    this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isPublished = course['is_published'] ?? false;
    final enrollmentCount = course['current_enrollments'] ?? 0;
    final rating = (course['rating'] ?? 0.0).toDouble();
    final price = course['price'] ?? 0.0;
    final createdAt = DateTime.parse(course['created_at']);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallCard = constraints.maxWidth < 200;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Image/Thumbnail - UPDATED
                Flexible(
                  flex: isSmallCard ? 2 : 3,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Course Image - FIXED to use course_image_url
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: _buildCourseImage(),
                        ),

                        // Status Badge
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallCard ? 6 : 8,
                              vertical: isSmallCard ? 2 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: isPublished ? Colors.green : Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isPublished ? 'PUBLISHED' : 'DRAFT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallCard ? 8 : 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Menu Button
                        Positioned(
                          top: 8,
                          left: 8,
                          child: PopupMenuButton(
                            icon: Container(
                              padding: EdgeInsets.all(isSmallCard ? 2 : 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.more_vert,
                                color: Colors.white,
                                size: isSmallCard ? 14 : 16,
                              ),
                            ),
                            onSelected: (value) =>
                                _handleMenuAction(context, value),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Color(0xFF00B894)),
                                    SizedBox(width: 8),
                                    Text('Edit Course'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'toggle',
                                child: Row(
                                  children: [
                                    Icon(
                                      isPublished
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: isPublished
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(isPublished ? 'Unpublish' : 'Publish'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Course Details
                Flexible(
                  flex: isSmallCard ? 3 : 2,
                  child: Padding(
                    padding: EdgeInsets.all(isSmallCard ? 8 : 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Flexible(
                          child: Text(
                            course['title'] ?? 'Untitled Course',
                            style: TextStyle(
                              fontSize: isSmallCard ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: isSmallCard ? 2 : 4),

                        // Category
                        Text(
                          course['category']
                                  ?.replaceAll('_', ' ')
                                  ?.toUpperCase() ??
                              'GENERAL',
                          style: TextStyle(
                            fontSize: isSmallCard ? 10 : 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: isSmallCard ? 4 : 8),

                        // Rating and Enrollments
                        if (!isSmallCard)
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.people,
                                color: Colors.grey[600],
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '$enrollmentCount',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                        const Spacer(),

                        // Price and Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                course['is_free'] == true
                                    ? 'Free'
                                    : '₹${price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: isSmallCard ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF00B894),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                              style: TextStyle(
                                fontSize: isSmallCard ? 9 : 11,
                                color: Colors.grey[500],
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
      },
    );
  }

  // UPDATED: New method to build course image with proper fallback
  Widget _buildCourseImage() {
    // Check for course_image_url (correct field name)
    if (course['course_image_url'] != null &&
        course['course_image_url'].toString().isNotEmpty) {
      return Image.network(
        course['course_image_url'],
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) => _buildDefaultThumbnail(),
      );
    }

    // Fallback to default thumbnail
    return _buildDefaultThumbnail();
  }

  // Loading placeholder while image loads
  Widget _buildLoadingPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00B894).withOpacity(0.3),
            const Color(0xFF00B894).withOpacity(0.1),
          ],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B894)),
        ),
      ),
    );
  }

  // Default thumbnail when no image is available
  Widget _buildDefaultThumbnail() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00B894).withOpacity(0.8),
            const Color(0xFF00B894),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, color: Colors.white, size: 32),
            SizedBox(height: 8),
            Text(
              'Course',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        if (onEdit != null) onEdit!();
        break;
      case 'toggle':
        if (onToggleStatus != null) onToggleStatus!();
        break;
    }
  }
}
