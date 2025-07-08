// search_sort_bottom_sheet.dart
import 'package:brainboosters_app/screens/common/search/search_models.dart';
import 'package:flutter/material.dart';

class SearchSortBottomSheet extends StatelessWidget {
  final SearchSortBy currentSort;
  final SearchEntityType entityType;
  final Function(SearchSortBy) onSortChanged;

  const SearchSortBottomSheet({
    super.key,
    required this.currentSort,
    required this.entityType,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildSortOptions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: const Row(
        children: [
          Text(
            'Sort By',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions() {
    final sortOptions = _getSortOptionsForEntityType();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: sortOptions.length,
      itemBuilder: (context, index) {
        final option = sortOptions[index];
        final isSelected = currentSort == option.sortBy;

        return ListTile(
          title: Text(
            option.title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? const Color(0xFF4AA0E6) : Colors.black,
            ),
          ),
          subtitle: option.subtitle != null
              ? Text(
                  option.subtitle!,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                )
              : null,
          trailing: isSelected
              ? const Icon(
                  Icons.check,
                  color: Color(0xFF4AA0E6),
                )
              : null,
          onTap: () {
            onSortChanged(option.sortBy);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  List<SortOption> _getSortOptionsForEntityType() {
    switch (entityType) {
      case SearchEntityType.courses:
        return [
          SortOption(SearchSortBy.relevance, 'Relevance', 'Best match for your search'),
          SortOption(SearchSortBy.rating, 'Highest Rated', 'Top rated courses first'),
          SortOption(SearchSortBy.popularity, 'Most Popular', 'Most enrolled courses'),
          SortOption(SearchSortBy.newest, 'Newest', 'Recently published courses'),
          SortOption(SearchSortBy.oldest, 'Oldest', 'Oldest courses first'),
          SortOption(SearchSortBy.priceLowToHigh, 'Price: Low to High', 'Cheapest first'),
          SortOption(SearchSortBy.priceHighToLow, 'Price: High to Low', 'Most expensive first'),
        ];

      case SearchEntityType.coachingCenters:
        return [
          SortOption(SearchSortBy.relevance, 'Relevance', 'Best match for your search'),
          SortOption(SearchSortBy.popularity, 'Most Popular', 'Most students enrolled'),
          SortOption(SearchSortBy.newest, 'Newest', 'Recently joined centers'),
          SortOption(SearchSortBy.oldest, 'Oldest', 'Established centers first'),
        ];

      case SearchEntityType.liveClasses:
        return [
          SortOption(SearchSortBy.relevance, 'Relevance', 'Best match for your search'),
          SortOption(SearchSortBy.newest, 'Upcoming Soon', 'Classes starting soon'),
          SortOption(SearchSortBy.popularity, 'Most Popular', 'Most participants'),
          SortOption(SearchSortBy.priceLowToHigh, 'Price: Low to High', 'Cheapest first'),
          SortOption(SearchSortBy.priceHighToLow, 'Price: High to Low', 'Most expensive first'),
        ];

      case SearchEntityType.teachers:
        return [
          SortOption(SearchSortBy.relevance, 'Relevance', 'Best match for your search'),
          SortOption(SearchSortBy.rating, 'Highest Rated', 'Top rated teachers'),
          SortOption(SearchSortBy.popularity, 'Most Popular', 'Most reviewed teachers'),
        ];
    }
  }
}

class SortOption {
  final SearchSortBy sortBy;
  final String title;
  final String? subtitle;

  SortOption(this.sortBy, this.title, [this.subtitle]);
}
