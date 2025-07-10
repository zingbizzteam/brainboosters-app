import 'package:flutter/material.dart';

class TeacherReviewsTab extends StatelessWidget {
  final Map<String, dynamic> teacher;
  final List<Map<String, dynamic>> reviews;
  final bool isMobile;

  const TeacherReviewsTab({
    super.key,
    required this.teacher,
    required this.reviews,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 20),

          if (reviews.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No reviews yet.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...reviews.map((review) => _buildReviewCard(review)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with student info and rating
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: _getStudentAvatarUrl(review) != null
                    ? NetworkImage(_getStudentAvatarUrl(review)!)
                    : null,
                child: _getStudentAvatarUrl(review) == null
                    ? const Icon(Icons.person, size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStudentName(review),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _getFormattedDate(review['created_at']),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Rating stars
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < _getRating(review) ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Course name
          if (review['courses'] != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                review['courses']['title'] ?? 'Unknown Course',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Review text
          if (_getReviewText(review).isNotEmpty) ...[
            Text(
              _getReviewText(review),
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
          ],

          // Pros and Cons
          if (_getPros(review).isNotEmpty || _getCons(review).isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_getPros(review).isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.thumb_up,
                              size: 14,
                              color: Colors.green[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Pros',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getPros(review),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                if (_getPros(review).isNotEmpty && _getCons(review).isNotEmpty)
                  const SizedBox(width: 16),
                if (_getCons(review).isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.thumb_down,
                              size: 14,
                              color: Colors.red[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Cons',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getCons(review),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Helper methods
  String _getStudentName(Map<String, dynamic> review) {
    final student = review['students'];
    final userProfile = student?['user_profiles'];
    if (userProfile == null) return 'Anonymous';

    final firstName = userProfile['first_name']?.toString() ?? '';
    final lastName = userProfile['last_name']?.toString() ?? '';
    return '$firstName $lastName'.trim();
  }

  String? _getStudentAvatarUrl(Map<String, dynamic> review) {
    final student = review['students'];
    final userProfile = student?['user_profiles'];
    return userProfile?['avatar_url']?.toString();
  }

  int _getRating(Map<String, dynamic> review) {
    return review['rating'] ?? 0;
  }

  String _getReviewText(Map<String, dynamic> review) {
    return review['review_text']?.toString() ?? '';
  }

  String _getPros(Map<String, dynamic> review) {
    return review['pros']?.toString() ?? '';
  }

  String _getCons(Map<String, dynamic> review) {
    return review['cons']?.toString() ?? '';
  }

  String _getFormattedDate(dynamic date) {
    if (date == null) return '';

    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return '';
    }
  }
}
