import 'package:flutter/material.dart';
import '../models/review_model.dart';

class ReviewsTab extends StatelessWidget {
  final List<Review> reviews;
  const ReviewsTab({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Center(child: Text("No reviews yet."));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, i) {
        final review = reviews[i];
        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(review.userAvatarUrl)),
          title: Row(
            children: [
              Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Icon(Icons.star, color: Colors.amber, size: 16),
              Text(review.rating.toString()),
            ],
          ),
          subtitle: Text(review.comment),
          trailing: Text("${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}"),
        );
      },
    );
  }
}
