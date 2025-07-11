// notification_filters_bottom_sheet.dart
import 'package:brainboosters_app/screens/student/notifications/notification_model.dart';
import 'package:flutter/material.dart';

class NotificationFiltersBottomSheet extends StatefulWidget {
  final NotificationFilters filters;
  final Function(NotificationFilters) onFiltersChanged;

  const NotificationFiltersBottomSheet({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
  });

  @override
  State<NotificationFiltersBottomSheet> createState() => _NotificationFiltersBottomSheetState();
}

class _NotificationFiltersBottomSheetState extends State<NotificationFiltersBottomSheet> {
  late NotificationFilters _filters;

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
                  _buildReadStatusFilter(),
                  const SizedBox(height: 24),
                  _buildTypeFilter(),
                  const SizedBox(height: 24),
                  _buildPriorityFilter(),
                  const SizedBox(height: 24),
                  _buildDateRangeFilter(),
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
            'Filter Notifications',
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

  Widget _buildReadStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Read Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilterChip(
                label: const Text('All'),
                selected: _filters.isRead == null,
                onSelected: (selected) {
                  setState(() {
                    _filters = _filters.copyWith(isRead: null);
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterChip(
                label: const Text('Unread'),
                selected: _filters.isRead == false,
                onSelected: (selected) {
                  setState(() {
                    _filters = _filters.copyWith(isRead: false);
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterChip(
                label: const Text('Read'),
                selected: _filters.isRead == true,
                onSelected: (selected) {
                  setState(() {
                    _filters = _filters.copyWith(isRead: true);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notification Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: NotificationType.values.map((type) {
            final isSelected = _filters.types.contains(type);
            return FilterChip(
              label: Text(type.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _filters = _filters.copyWith(
                      types: [..._filters.types, type],
                    );
                  } else {
                    _filters = _filters.copyWith(
                      types: _filters.types.where((t) => t != type).toList(),
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

  Widget _buildPriorityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: NotificationPriority.values.map((priority) {
            final isSelected = _filters.priorities.contains(priority);
            return FilterChip(
              label: Text(priority.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _filters = _filters.copyWith(
                      priorities: [..._filters.priorities, priority],
                    );
                  } else {
                    _filters = _filters.copyWith(
                      priorities: _filters.priorities.where((p) => p != priority).toList(),
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
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                    initialDateRange: _filters.fromDate != null && _filters.toDate != null
                        ? DateTimeRange(
                            start: _filters.fromDate!,
                            end: _filters.toDate!,
                          )
                        : null,
                  );
                  if (picked != null) {
                    setState(() {
                      _filters = _filters.copyWith(
                        fromDate: picked.start,
                        toDate: picked.end,
                      );
                    });
                  }
                },
                child: Text(
                  _filters.fromDate != null && _filters.toDate != null
                      ? '${_filters.fromDate!.day}/${_filters.fromDate!.month} - ${_filters.toDate!.day}/${_filters.toDate!.month}'
                      : 'Select Date Range',
                ),
              ),
            ),
            if (_filters.fromDate != null)
              IconButton(
                onPressed: () {
                  setState(() {
                    _filters = _filters.copyWith(fromDate: null, toDate: null);
                  });
                },
                icon: const Icon(Icons.clear),
              ),
          ],
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
      _filters = NotificationFilters();
    });
  }
}
