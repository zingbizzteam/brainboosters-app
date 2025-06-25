// screens/coaching_center/courses/widgets/course_filter.dart
import 'package:flutter/material.dart';

class CourseFilter extends StatelessWidget {
  final String selectedCategory;
  final String selectedLevel;
  final String selectedSort;
  final Function(String) onCategoryChanged;
  final Function(String) onLevelChanged;
  final Function(String) onSortChanged;
  final VoidCallback onClearFilters;

  const CourseFilter({
    super.key,
    required this.selectedCategory,
    required this.selectedLevel,
    required this.selectedSort,
    required this.onCategoryChanged,
    required this.onLevelChanged,
    required this.onSortChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: constraints.maxWidth > 600 ? 16 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onClearFilters,
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: constraints.maxWidth > 600 ? 14 : 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Filter Controls
                if (constraints.maxWidth > 800)
                  _buildWideFilters()
                else if (constraints.maxWidth > 600)
                  _buildMediumFilters()
                else
                  _buildNarrowFilters(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWideFilters() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildCategoryDropdown()),
          const SizedBox(width: 12),
          Expanded(child: _buildLevelDropdown()),
          const SizedBox(width: 12),
          Expanded(child: _buildSortDropdown()),
        ],
      ),
    );
  }

  Widget _buildMediumFilters() {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildCategoryDropdown()),
              const SizedBox(width: 12),
              Expanded(child: _buildLevelDropdown()),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildSortDropdown(),
      ],
    );
  }

  Widget _buildNarrowFilters() {
    return Column(
      children: [
        _buildCategoryDropdown(),
        const SizedBox(height: 12),
        _buildLevelDropdown(),
        const SizedBox(height: 12),
        _buildSortDropdown(),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth,
            minWidth: 0,
          ),
          child: DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 200 ? 12 : 8,
                vertical: 8,
              ),
            ),
            onChanged: (value) => onCategoryChanged(value!),
            isExpanded: true, // Critical: Prevents overflow
            menuMaxHeight: 300, // Limits dropdown height
            items: const [
              DropdownMenuItem(
                value: 'all',
                child: Text(
                  'All Categories',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              DropdownMenuItem(
                value: 'programming',
                child: Text(
                  'Programming',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              DropdownMenuItem(
                value: 'mathematics',
                child: Text(
                  'Mathematics',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              DropdownMenuItem(
                value: 'science',
                child: Text(
                  'Science',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              DropdownMenuItem(
                value: 'language',
                child: Text(
                  'Language',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              DropdownMenuItem(
                value: 'business',
                child: Text(
                  'Business',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              DropdownMenuItem(
                value: 'design',
                child: Text(
                  'Design',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              DropdownMenuItem(
                value: 'marketing',
                child: Text(
                  'Marketing',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLevelDropdown() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth,
            minWidth: 0,
          ),
          child: DropdownButtonFormField<String>(
            value: selectedLevel,
            decoration: InputDecoration(
              labelText: 'Level',
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 200 ? 12 : 8,
                vertical: 8,
              ),
            ),
            onChanged: (value) => onLevelChanged(value!),
            isExpanded: true, // Critical: Prevents overflow
            menuMaxHeight: 300, // Limits dropdown height
            items: const [
              DropdownMenuItem(
                value: 'all',
                child: Text(
                  'All Levels',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              DropdownMenuItem(
                value: 'beginner',
                child: Text(
                  'Beginner',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              DropdownMenuItem(
                value: 'intermediate',
                child: Text(
                  'Intermediate',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              DropdownMenuItem(
                value: 'advanced',
                child: Text(
                  'Advanced',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortDropdown() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth,
            minWidth: 0,
          ),
          child: DropdownButtonFormField<String>(
            value: selectedSort,
            decoration: InputDecoration(
              labelText: 'Sort By',
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 200 ? 12 : 8,
                vertical: 8,
              ),
            ),
            onChanged: (value) => onSortChanged(value!),
            isExpanded: true, // Critical: Prevents overflow
            menuMaxHeight: 300, // Limits dropdown height
            items: const [
              DropdownMenuItem(
                value: 'newest',
                child: Text(
                  'Newest First',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              DropdownMenuItem(
                value: 'oldest',
                child: Text(
                  'Oldest First',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              DropdownMenuItem(
                value: 'popular',
                child: Text(
                  'Most Popular',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              DropdownMenuItem(
                value: 'rating',
                child: Text(
                  'Highest Rated',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              DropdownMenuItem(
                value: 'price_low',
                child: Text(
                  'Price: Low to High',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              DropdownMenuItem(
                value: 'price_high',
                child: Text(
                  'Price: High to Low',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
