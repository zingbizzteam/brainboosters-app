// screens/common/coaching_centers/coaching_centers_page.dart
import 'package:brainboosters_app/screens/common/coaching_centers/data/coaching_center_dummy_data.dart';
import 'package:brainboosters_app/screens/common/coaching_centers/models/coaching_center_model.dart';
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
      case 'Fees: Low to High':
        filtered.sort((a, b) => a.fees.compareTo(b.fees));
        break;
      case 'Fees: High to Low':
        filtered.sort((a, b) => b.fees.compareTo(a.fees));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // Header and Description
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mobile breadcrumb
                  if (isMobile) ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildBreadcrumbItem('Home', false),
                          _buildBreadcrumbSeparator(),
                          _buildBreadcrumbItem('Python Coaching Centers', true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    // Desktop breadcrumb
                    Row(
                      children: [
                        _buildBreadcrumbItem('Home', false),
                        _buildBreadcrumbSeparator(),
                        _buildBreadcrumbItem('Python Coaching Centers', true),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  Text(
                    isMobile
                        ? 'Coaching Centers for Python'
                        : 'Coaching Centers for Python',
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

            // Filter Bar
            CoachingCenterFilterBar(
              sortBy: _sortBy,
              filterLocation: _filterLocation,
              showOnlyVerified: _showOnlyVerified,
              onSortChanged: (value) => setState(() => _sortBy = value),
              onLocationChanged: (value) =>
                  setState(() => _filterLocation = value),
              onVerifiedToggled: (value) =>
                  setState(() => _showOnlyVerified = value),
            ),

            // Coaching Centers List
            Expanded(
              child: _filteredAndSortedCenters.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(
                        isMobile ? 12 : (isTablet ? 40 : 80),
                      ),
                      itemCount: _filteredAndSortedCenters.length,
                      itemBuilder: (context, index) {
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
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbItem(String text, bool isLast) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: isLast ? Colors.black : Colors.grey[600],
        fontWeight: isLast ? FontWeight.w500 : FontWeight.normal,
      ),
    );
  }

  Widget _buildBreadcrumbSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text('/', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
