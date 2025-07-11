// lib/screens/student/profile/widgets/analytics_filters.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'profile_model.dart';

class AnalyticsFilters extends StatefulWidget {
  final ProfileData profileData;
  final VoidCallback onFiltersChanged;

  const AnalyticsFilters({
    super.key,
    required this.profileData,
    required this.onFiltersChanged,
  });

  @override
  State<AnalyticsFilters> createState() => _AnalyticsFiltersState();
}

class _AnalyticsFiltersState extends State<AnalyticsFilters> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedType = 'all';
  String _sortBy = 'date';
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Date Range Row
          Row(
            children: [
              Icon(Icons.date_range, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Period: ${DateFormat('MMM dd').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              OutlinedButton(
                onPressed: _selectDateRange,
                child: const Text('Change'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Filters Row
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Row(
                  children: [
                    Expanded(child: _buildTypeFilter()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildSortFilter()),
                    const SizedBox(width: 16),
                    _buildSortOrderButton(),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildTypeFilter(),
                    const SizedBox(height: 8),
                    _buildSortFilter(),
                    const SizedBox(height: 8),
                    _buildSortOrderButton(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: const InputDecoration(
        labelText: 'Type',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All Types')),
        DropdownMenuItem(value: 'learning', child: Text('Learning')),
        DropdownMenuItem(value: 'test', child: Text('Tests')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedType = value!;
        });
        widget.onFiltersChanged();
      },
    );
  }

  Widget _buildSortFilter() {
    return DropdownButtonFormField<String>(
      value: _sortBy,
      decoration: const InputDecoration(
        labelText: 'Sort By',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: const [
        DropdownMenuItem(value: 'date', child: Text('Date')),
        DropdownMenuItem(value: 'score', child: Text('Score')),
        DropdownMenuItem(value: 'time', child: Text('Time')),
      ],
      onChanged: (value) {
        setState(() {
          _sortBy = value!;
        });
        widget.onFiltersChanged();
      },
    );
  }

  Widget _buildSortOrderButton() {
    return OutlinedButton.icon(
      onPressed: () {
        setState(() {
          _sortAscending = !_sortAscending;
        });
        widget.onFiltersChanged();
      },
      icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
      label: Text(_sortAscending ? 'Asc' : 'Desc'),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      widget.onFiltersChanged();
    }
  }
}
