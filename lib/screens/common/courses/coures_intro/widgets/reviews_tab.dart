// screens/common/courses/widgets/reviews_tab.dart

import 'package:flutter/material.dart';

class ReviewsTab extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;

  const ReviewsTab({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;

    if (reviews.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No reviews yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Be the first to review this course!',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewsHeader(isMobile),
          const SizedBox(height: 20),
          ...reviews.map((review) => _buildReviewCard(review, isMobile)),
        ],
      ),
    );
  }

  Widget _buildReviewsHeader(bool isMobile) {
    final averageRating = reviews.isNotEmpty
        ? reviews.fold(0.0, (sum, review) => sum + _getReviewRating(review)) /
              reviews.length
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Student Reviews',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        size: 16,
                        color: index < averageRating.floor()
                            ? Colors.amber
                            : Colors.grey[300],
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${averageRating.toStringAsFixed(1)} (${reviews.length} reviews)',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review, bool isMobile) {
    final rating = _getReviewRating(review);
    final userName = _getReviewUserName(review);
    final userAvatarUrl = _getReviewUserAvatar(review);
    final comment = review['review_text']?.toString() ?? '';
    final pros = review['pros']?.toString();
    final cons = review['cons']?.toString();
    final isVerifiedPurchase = review['is_verified_purchase'] == true;
    final createdAt = _parseDate(review['created_at']);
    final helpfulCount = (review['helpful_votes_count'] as num?)?.toInt() ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      userAvatarUrl != null && userAvatarUrl.isNotEmpty
                      ? NetworkImage(userAvatarUrl)
                      : null,
                  child: userAvatarUrl == null || userAvatarUrl.isEmpty
                      ? Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName.isNotEmpty ? userName : 'Anonymous',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                Icons.star,
                                size: 14,
                                color: index < rating
                                    ? Colors.amber
                                    : Colors.grey[300],
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(createdAt),
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (isVerifiedPurchase) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'VERIFIED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isMobile ? 8 : 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                comment,
                style: TextStyle(fontSize: isMobile ? 14 : 16, height: 1.5),
              ),
            ],
            if (pros != null || cons != null) ...[
              const SizedBox(height: 12),
              if (pros != null && pros.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.thumb_up, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pros,
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (cons != null && cons.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.thumb_down, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cons,
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Implement helpful functionality
                  },
                  icon: const Icon(Icons.thumb_up_outlined, size: 16),
                  label: Text('Helpful ($helpfulCount)'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    textStyle: TextStyle(fontSize: isMobile ? 12 : 14),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Implement report functionality
                  },
                  icon: const Icon(Icons.flag_outlined, size: 16),
                  label: const Text('Report'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    textStyle: TextStyle(fontSize: isMobile ? 12 : 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods to safely extract data from raw review data
  int _getReviewRating(Map<String, dynamic> review) {
    final rating = review['rating'];
    if (rating is num) return rating.toInt();
    return 0;
  }

  String _getReviewUserName(Map<String, dynamic> review) {
    final students = review['students'];
    if (students is Map) {
      final userProfiles = students['user_profiles'];
      if (userProfiles is Map) {
        final firstName = userProfiles['first_name']?.toString() ?? '';
        final lastName = userProfiles['last_name']?.toString() ?? '';
        return '$firstName $lastName'.trim();
      }
    }
    return '';
  }

  String? _getReviewUserAvatar(Map<String, dynamic> review) {
    final students = review['students'];
    if (students is Map) {
      final userProfiles = students['user_profiles'];
      if (userProfiles is Map) {
        return userProfiles['avatar_url']?.toString();
      }
    }
    return null;
  }

  DateTime _parseDate(dynamic dateString) {
    if (dateString == null) return DateTime.now();

    try {
      return DateTime.parse(dateString.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Recently';
    }
  }
}
