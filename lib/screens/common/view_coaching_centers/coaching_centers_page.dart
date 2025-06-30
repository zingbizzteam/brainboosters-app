// screens/common/coaching_centers/coaching_centers_page.dart
import 'package:brainboosters_app/screens/common/view_coaching_centers/data/coaching_center_dummy_data.dart';
import 'package:brainboosters_app/screens/common/view_coaching_centers/models/coaching_center_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../ui/navigation/common_routes/common_routes.dart';
import 'widgets/coaching_center_card.dart';
import 'widgets/coaching_center_filter_bar.dart';

class CoachingCentersPage extends StatefulWidget {
  const CoachingCentersPage({super.key});

  @override
  State<CoachingCentersPage> createState() => _CoachingCentersPageState();
}

class _CoachingCentersPageState extends State<CoachingCentersPage> {
  List<CoachingCenter> _coachingCenters = [];
  String _sortBy = 'Rating';
  String _filterLocation = 'All';
  bool _showOnlyVerified = false;
  bool _isFilterExpanded = false; // Added for filter toggle

  @override
  void initState() {
    super.initState();
    _loadCoachingCenters();
  }

  void _loadCoachingCenters() {
    setState(() {
      _coachingCenters = CoachingCenterDummyData.getCoachingCenters();
    });
  }

  List<CoachingCenter> get _filteredAndSortedCenters {
    var filtered = _coachingCenters;

    // Apply location filter
    if (_filterLocation != 'All') {
      filtered = filtered
          .where((center) => center.location.contains(_filterLocation))
          .toList();
    }

    // Apply verified filter
    if (_showOnlyVerified) {
      filtered = filtered.where((center) => center.isVerified).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'Rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Students':
        filtered.sort(
          (a, b) => b.studentsEnrolled.compareTo(a.studentsEnrolled),
        );
        break;
      case 'Experience':
        filtered.sort((a, b) => b.experienceYears.compareTo(a.experienceYears));
        break;
      case 'Success Rate':
        filtered.sort((a, b) => b.successRate.compareTo(a.successRate));
        break;
      case 'Fees: Low to High':
        filtered.sort((a, b) => a.fees.compareTo(b.fees));
        break;
      case 'Fees: High to Low':
        filtered.sort((a, b) => b.fees.compareTo(a.fees));
        break;
    }

    return filtered;
  }

  void _toggleFilter() {
    setState(() {
      _isFilterExpanded = !_isFilterExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Section (Scrollable)
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coaching Centers',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isMobile
                          ? 'Top coaching centers partner with us. Select one to view their courses.'
                          : 'Some of the top coaching centers in the country partner with us.\nSelect a coaching center to view the courses offered by them.',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 16,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filter Toggle Button
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_filteredAndSortedCenters.length} coaching centers found',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _toggleFilter,
                      icon: Icon(
                        _isFilterExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: const Color(0xFF4AA0E6),
                      ),
                      label: Text(
                        _isFilterExpanded ? 'Hide Filters' : 'Show Filters',
                        style: const TextStyle(
                          color: Color(0xFF4AA0E6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Collapsible Filter Bar
            SliverToBoxAdapter(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: _isFilterExpanded ? null : 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isFilterExpanded ? 1.0 : 0.0,
                  child: _isFilterExpanded
                      ? CoachingCenterFilterBar(
                          sortBy: _sortBy,
                          filterLocation: _filterLocation,
                          showOnlyVerified: _showOnlyVerified,
                          onSortChanged: (value) =>
                              setState(() => _sortBy = value),
                          onLocationChanged: (value) =>
                              setState(() => _filterLocation = value),
                          onVerifiedToggled: (value) =>
                              setState(() => _showOnlyVerified = value),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),

            // Coaching Centers List
            _filteredAndSortedCenters.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState())
                : SliverPadding(
                    padding: EdgeInsets.all(
                      isMobile ? 12 : (isTablet ? 40 : 80),
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return CoachingCenterCard(
                          coachingCenter: _filteredAndSortedCenters[index],
                          onTap: () {
                            context.push(
                              CommonRoutes.getCoachingCenterDetailRoute(
                                _filteredAndSortedCenters[index].id,
                              ),
                            );
                          },
                        );
                      }, childCount: _filteredAndSortedCenters.length),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No coaching centers found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
