// screens/common/coaching_centers/widgets/coaching_center_filter_bar.dart
import 'package:flutter/material.dart';

class CoachingCenterFilterBar extends StatelessWidget {
  final String sortBy;
  final String filterLocation;
  final bool showOnlyVerified;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<bool> onVerifiedToggled;

  const CoachingCenterFilterBar({
    super.key,
    required this.sortBy,
    required this.filterLocation,
    required this.showOnlyVerified,
    required this.onSortChanged,
    required this.onLocationChanged,
    required this.onVerifiedToggled,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 80,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: isMobile ? _buildMobileFilters() : _buildDesktopFilters(),
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sort dropdown
        Row(
          children: [
            Text(
              'Sort:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButton<String>(
                  value: sortBy,
                  underline: Container(),
                  isExpanded: true,
                  items: [
                    'Rating',
                    'Students',
                    'Experience',
                    'Fees: Low to High',
                    'Fees: High to Low',
                  ].map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 13),
                    ),
                  )).toList(),
                  onChanged: (value) => onSortChanged(value!),
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Location and Verified filters
        Row(
          children: [
            // Location filter
            Expanded(
              child: Row(
                children: [
                  Text(
                    'Location:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButton<String>(
                        value: filterLocation,
                        underline: Container(),
                        isExpanded: true,
                        items: [
                          'All',
                          'Chennai',
                          'Trichy',
                          'Bangalore',
                        ].map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 13),
                          ),
                        )).toList(),
                        onChanged: (value) => onLocationChanged(value!),
                        style: const TextStyle(fontSize: 13, color: Colors.black),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Verified filter
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: showOnlyVerified,
                    onChanged: onVerifiedToggled,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        if (!states.contains(WidgetState.selected)) {
                          return Colors.grey[400];
                        }
                        return null;
                      },
                    ),
                    trackOutlineWidth: WidgetStateProperty.resolveWith<double?>(
                      (Set<WidgetState> states) {
                        if (!states.contains(WidgetState.selected)) {
                          return 1.5;
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Text(
                  'Verified',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopFilters() {
    return Row(
      children: [
        // Sort by dropdown
        Text(
          'Sort by',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButton<String>(
            value: sortBy,
            underline: Container(),
            items: [
              'Rating',
              'Students',
              'Experience',
              'Fees: Low to High',
              'Fees: High to Low',
            ].map((item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            )).toList(),
            onChanged: (value) => onSortChanged(value!),
            style: const TextStyle(fontSize: 14, color: Colors.black),
            isDense: true,
          ),
        ),

        const SizedBox(width: 24),

        // Location filter
        Text(
          'Location:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButton<String>(
            value: filterLocation,
            underline: Container(),
            items: [
              'All',
              'Chennai',
              'Trichy',
              'Bangalore',
            ].map((item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            )).toList(),
            onChanged: (value) => onLocationChanged(value!),
            style: const TextStyle(fontSize: 14, color: Colors.black),
            isDense: true,
          ),
        ),

        const SizedBox(width: 24),

        // Verified filter
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: showOnlyVerified,
              onChanged: onVerifiedToggled,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (!states.contains(WidgetState.selected)) {
                    return Colors.grey[400];
                  }
                  return null;
                },
              ),
              trackOutlineWidth: WidgetStateProperty.resolveWith<double?>(
                (Set<WidgetState> states) {
                  if (!states.contains(WidgetState.selected)) {
                    return 1.5;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Verified only',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
