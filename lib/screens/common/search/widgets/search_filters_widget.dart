// screens/common/search/widgets/search_filters_widget.dart
import 'package:flutter/material.dart';
import '../search_page.dart';

class SearchFiltersWidget extends StatelessWidget {
  final int totalResults;
  final SearchContentType selectedType;
  final String sortBy;
  final String filterDifficulty;
  final String filterPrice;
  final String filterCategory;
  final bool showFilters;
  final bool isMobile;
  final bool isTablet;
  final Function({
    String? sortBy,
    String? filterDifficulty,
    String? filterPrice,
    String? filterCategory,
    bool? showFilters,
  }) onFilterChanged;

  const SearchFiltersWidget({
    super.key,
    required this.totalResults,
    required this.selectedType,
    required this.sortBy,
    required this.filterDifficulty,
    required this.filterPrice,
    required this.filterCategory,
    required this.showFilters,
    required this.isMobile,
    required this.isTablet,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$totalResults results found',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isMobile)
                IconButton(
                  onPressed: () => onFilterChanged(showFilters: !showFilters),
                  icon: Icon(showFilters ? Icons.close : Icons.filter_list),
                ),
            ],
          ),
          
          if (!isMobile || showFilters) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _buildDropdown(
                  'Sort by',
                  sortBy,
                  ['Relevance', 'Newest', 'Price: Low to High', 'Price: High to Low', 'Rating', 'Popularity'],
                  (value) => onFilterChanged(sortBy: value),
                ),
                if (selectedType == SearchContentType.all || selectedType == SearchContentType.courses) ...[
                  _buildDropdown(
                    'Difficulty',
                    filterDifficulty,
                    ['All', 'Beginner', 'Intermediate', 'Advanced'],
                    (value) => onFilterChanged(filterDifficulty: value),
                  ),
                  _buildDropdown(
                    'Price',
                    filterPrice,
                    ['All', 'Free', 'Paid'],
                    (value) => onFilterChanged(filterPrice: value),
                  ),
                ],
                _buildDropdown(
                  'Category',
                  filterCategory,
                  ['All', 'Programming', 'Data Science', 'Technology', 'Mobile Development'],
                  (value) => onFilterChanged(filterCategory: value),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButton<String>(
        value: value,
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text('$label: $item'),
        )).toList(),
        onChanged: onChanged,
        underline: Container(),
        style: const TextStyle(fontSize: 14, color: Colors.black),
        isDense: true,
      ),
    );
  }
}
