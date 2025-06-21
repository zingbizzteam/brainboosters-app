// screens/common/search/widgets/search_bar_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../ui/navigation/common_routes/common_routes.dart';

class SearchBarWidget extends StatefulWidget {
  final String? initialQuery;
  final String? hintText;
  final VoidCallback? onSearchToggle;
  final bool isExpanded;
  final bool autoFocus;
  final EdgeInsetsGeometry? padding;

  const SearchBarWidget({
    super.key,
    this.initialQuery,
    this.hintText,
    this.onSearchToggle,
    this.isExpanded = false,
    this.autoFocus = false,
    this.padding,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.push(CommonRoutes.getSearchCoursesRoute(query));
      widget.onSearchToggle?.call(); // Close search after navigation
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isExpanded) {
      return Container(
        height: 40,
        margin: widget.padding ?? EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: TextField(
          controller: _searchController,
          autofocus: widget.autoFocus,
          onSubmitted: (_) => _onSearch(),
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText:
                widget.hintText ??
                'Search courses, live classes, coaching centers...',
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8, 
            ),
            hintStyle: const TextStyle(fontSize: 14),
            isDense: true, 
          ),
          style: const TextStyle(fontSize: 14),
        ),
      );
    }

    // Full search bar for search page
    return Container(
      padding:
          widget.padding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _onSearch(),
              decoration: InputDecoration(
                hintText:
                    widget.hintText ??
                    'Search for courses, live classes, coaching centers...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search),
                // Removed textAlignVertical from here since it was causing issues
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16, // Added explicit vertical padding
                ),
                isDense: false, // Keep this false for the full search bar
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _onSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4AA0E6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}
