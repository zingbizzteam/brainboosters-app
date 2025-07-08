// search_filters_bottom_sheet.dart
import 'package:brainboosters_app/screens/common/search/search_models.dart';
import 'package:flutter/material.dart';

class SearchFiltersBottomSheet extends StatefulWidget {
  final SearchFilters filters;
  final SearchEntityType entityType;
  final Function(SearchFilters) onFiltersChanged;

  const SearchFiltersBottomSheet({
    super.key,
    required this.filters,
    required this.entityType,
    required this.onFiltersChanged,
  });

  @override
  State<SearchFiltersBottomSheet> createState() => _SearchFiltersBottomSheetState();
}

class _SearchFiltersBottomSheetState extends State<SearchFiltersBottomSheet> {
  late SearchFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.filters;
  }

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
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.entityType == SearchEntityType.courses) ...[
                    _buildCategoryFilter(),
                    const SizedBox(height: 24),
                    _buildLevelFilter(),
                    const SizedBox(height: 24),
                    _buildPriceFilter(),
                    const SizedBox(height: 24),
                    _buildRatingFilter(),
                    const SizedBox(height: 24),
                    _buildFreeFilter(),
                  ],
                  if (widget.entityType == SearchEntityType.teachers) ...[
                    _buildExperienceFilter(),
                    const SizedBox(height: 24),
                    _buildRatingFilter(),
                    const SizedBox(height: 24),
                    _buildSpecializationFilter(),
                  ],
                  if (widget.entityType == SearchEntityType.liveClasses) ...[
                    _buildFreeFilter(),
                    const SizedBox(height: 24),
                    _buildDateRangeFilter(),
                  ],
                  if (widget.entityType == SearchEntityType.coachingCenters) ...[
                    _buildLocationFilter(),
                  ],
                ],
              ),
            ),
          ),
          _buildActions(),
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
      child: Row(
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    const categories = [
      'Programming',
      'Design',
      'Business',
      'Marketing',
      'Photography',
      'Music',
      'Health & Fitness',
      'Language',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected = _filters.categories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _filters = _filters.copyWith(
                      categories: [..._filters.categories, category],
                    );
                  } else {
                    _filters = _filters.copyWith(
                      categories: _filters.categories.where((c) => c != category).toList(),
                    );
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLevelFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Level',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CourseLevel.values.map((level) {
            final isSelected = _filters.levels.contains(level);
            return FilterChip(
              label: Text(level.name.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _filters = _filters.copyWith(
                      levels: [..._filters.levels, level],
                    );
                  } else {
                    _filters = _filters.copyWith(
                      levels: _filters.levels.where((l) => l != level).toList(),
                    );
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Range',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        RangeSlider(
          values: RangeValues(
            _filters.priceRange?.min ?? 0,
            _filters.priceRange?.max ?? 10000,
          ),
          min: 0,
          max: 10000,
          divisions: 100,
          labels: RangeLabels(
            '₹${(_filters.priceRange?.min ?? 0).toInt()}',
            '₹${(_filters.priceRange?.max ?? 10000).toInt()}',
          ),
          onChanged: (values) {
            setState(() {
              _filters = _filters.copyWith(
                priceRange: PriceRange(min: values.start, max: values.end),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Minimum Rating',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [1, 2, 3, 4, 5].map((rating) {
            final isSelected = (_filters.minRating ?? 0) >= rating;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _filters = _filters.copyWith(
                    minRating: rating.toDouble(),
                  );
                });
              },
              child: Icon(
                Icons.star,
                color: isSelected ? Colors.amber : Colors.grey.shade300,
                size: 32,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFreeFilter() {
    return Row(
      children: [
        const Text(
          'Free Only',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Switch(
          value: _filters.isFree ?? false,
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(isFree: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildExperienceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Minimum Experience (Years)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Slider(
          value: (_filters.minExperience ?? 0).toDouble(),
          min: 0,
          max: 20,
          divisions: 20,
          label: '${_filters.minExperience ?? 0} years',
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(minExperience: value.toInt());
            });
          },
        ),
      ],
    );
  }

  Widget _buildSpecializationFilter() {
    const specializations = [
      'Mathematics',
      'Physics',
      'Chemistry',
      'Biology',
      'English',
      'History',
      'Geography',
      'Computer Science',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Specializations',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: specializations.map((specialization) {
            final isSelected = _filters.specializations.contains(specialization);
            return FilterChip(
              label: Text(specialization),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _filters = _filters.copyWith(
                      specializations: [..._filters.specializations, specialization],
                    );
                  } else {
                    _filters = _filters.copyWith(
                      specializations: _filters.specializations.where((s) => s != specialization).toList(),
                    );
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date Range',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              initialDateRange: _filters.dateRange != null
                  ? DateTimeRange(
                      start: _filters.dateRange!.start,
                      end: _filters.dateRange!.end,
                    )
                  : null,
            );
            if (picked != null) {
              setState(() {
                _filters = _filters.copyWith(
                  dateRange: DateRange(
                    start: picked.start,
                    end: picked.end,
                  ),
                );
              });
            }
          },
          child: Text(
            _filters.dateRange != null
                ? '${_filters.dateRange!.start.day}/${_filters.dateRange!.start.month} - ${_filters.dateRange!.end.day}/${_filters.dateRange!.end.month}'
                : 'Select Date Range',
          ),
        ),
      ],
    );
  }

  Widget _buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            hintText: 'Enter city or area',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.location_on),
          ),
          onChanged: (value) {
            // Handle location filter
          },
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Color(0xFF4AA0E6)),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF4AA0E6)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                widget.onFiltersChanged(_filters);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4AA0E6),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _filters = SearchFilters();
    });
  }
}
