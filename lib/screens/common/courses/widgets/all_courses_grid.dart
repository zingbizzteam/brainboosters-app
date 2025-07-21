// screens/common/courses/widgets/all_courses_grid.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'course_card.dart';

class AllCoursesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const AllCoursesGrid({
    super.key,
    required this.courses,
    this.loading = false,
    this.loadingMore = false,
    this.hasMore = true,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
        vertical: 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Courses',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore our complete course catalog',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          _buildContent(isMobile, isTablet),
        ],
      ),
    );
  }

  Widget _buildContent(bool isMobile, bool isTablet) {
    // Show error state
    if (errorMessage != null && courses.isEmpty) {
      return _buildErrorState(isMobile);
    }

    // Show loading state for initial load
    if (loading && courses.isEmpty) {
      return _buildLoadingState(isMobile, isTablet);
    }

    // Show empty state
    if (!loading && courses.isEmpty && errorMessage == null) {
      return _buildEmptyState(isMobile);
    }

    // Show courses grid
    return _buildCoursesGrid(isMobile, isTablet);
  }

  Widget _buildErrorState(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: isMobile ? 48 : 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Courses',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Something went wrong',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (onRetry != null)
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try Again'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isMobile, bool isTablet) {
    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isMobile ? 1.2 : 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 14,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.school_outlined,
              size: isMobile ? 48 : 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Courses Available',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new courses',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

 // Update your all_courses_grid.dart to pass loading state

Widget _buildCoursesGrid(bool isMobile, bool isTablet) {
  final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);

  return Column(
    children: [
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: isMobile ? 1.2 : 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: loading ? 6 : courses.length, // Show 6 shimmer cards when loading
        itemBuilder: (context, index) {
          return CourseCard(
            course: loading ? null : courses[index],
            isLoading: loading,
          );
        },
      ),

      // Loading indicator for pagination
      if (loadingMore)
        const Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),

      // Load more button (fallback)
      if (!loadingMore && hasMore)
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: OutlinedButton(
            onPressed: () {
              // Trigger load more
            },
            child: const Text('Load More'),
          ),
        ),
    ],
  );
}

}
