// search_result_card.dart
import 'package:brainboosters_app/screens/common/search/search_models.dart';
import 'package:flutter/material.dart';

class SearchResultCard extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onTap;

  const SearchResultCard({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    if (result.subtitle != null) ...[
                      const SizedBox(height: 4),
                      _buildSubtitle(),
                    ],
                    if (result.description != null) ...[
                      const SizedBox(height: 8),
                      _buildDescription(),
                    ],
                    const SizedBox(height: 12),
                    _buildMetadata(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
      ),
      child: result.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                result.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(),
              ),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    IconData icon;
    switch (result.entityType) {
      case SearchEntityType.courses:
        icon = Icons.play_circle_outline;
        break;
      case SearchEntityType.coachingCenters:
        icon = Icons.school;
        break;
      case SearchEntityType.liveClasses:
        icon = Icons.live_tv;
        break;
      case SearchEntityType.teachers:
        icon = Icons.person;
        break;
    }

    return Icon(icon, size: 40, color: Colors.grey.shade400);
  }

  Widget _buildTitle() {
    return Text(
      result.title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      result.subtitle!,
      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription() {
    return Text(
      result.description!,
      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetadata() {
    final widgets = <Widget>[];

    // Rating
    if (result.rating != null) {
      widgets.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              result.rating!.toStringAsFixed(1),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            if (result.reviewCount != null) ...[
              const SizedBox(width: 4),
              Text(
                '(${result.reviewCount})',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      );
    }

    // Price
    if (result.price != null) {
      widgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: result.price == 0 ? Colors.green : const Color(0xFF4AA0E6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            result.price == 0
                ? 'Free'
                : '${result.currency ?? '₹'}${result.price!.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // Entity type badge
    widgets.add(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getEntityTypeColor().withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _getEntityTypeLabel(),
          style: TextStyle(
            color: _getEntityTypeColor(),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );

    return Wrap(spacing: 8, runSpacing: 4, children: widgets);
  }

  Color _getEntityTypeColor() {
    switch (result.entityType) {
      case SearchEntityType.courses:
        return Colors.blue;
      case SearchEntityType.coachingCenters:
        return Colors.purple;
      case SearchEntityType.liveClasses:
        return Colors.red;
      case SearchEntityType.teachers:
        return Colors.green;
    }
  }

  String _getEntityTypeLabel() {
    switch (result.entityType) {
      case SearchEntityType.courses:
        return 'Course';
      case SearchEntityType.coachingCenters:
        return 'Center';
      case SearchEntityType.liveClasses:
        return 'Live Class';
      case SearchEntityType.teachers:
        return 'Teacher';
    }
  }
}
