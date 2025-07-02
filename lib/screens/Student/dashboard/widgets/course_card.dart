import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final Map course;
  final VoidCallback onTap;

  const CourseCard({super.key, required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double rating = (course['rating'] ?? 0.0).toDouble();
    final int totalReviews = course['total_reviews'] ?? 0;

    return SizedBox(
      width: 220,
      height: 230, // Fixed height for all cards
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              child: Image.network(
                course['thumbnail_url'] ?? '',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: const Icon(Icons.book, size: 48, color: Colors.white),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 2,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Actual title text
                    Text(
                      course['title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),
                    Text(
                      "${course['category'] ?? ''} • ${course['level'] ?? ''}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Rating row
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 15),
                        const SizedBox(width: 2),
                        Text(
                          rating > 0 ? rating.toStringAsFixed(1) : "N/A",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        if (totalReviews > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            "($totalReviews)",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
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
  }
}
