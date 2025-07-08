// screens/common/courses/widgets/course_categories_section.dart

import 'package:brainboosters_app/screens/common/courses/course_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../ui/navigation/common_routes/common_routes.dart';

class CourseCategoriesSection extends StatefulWidget {
  // NEW: Add refresh callback to coordinate with parent
  final VoidCallback? onRefreshComplete;
  final bool forceRefresh; // NEW: External refresh trigger

  const CourseCategoriesSection({
    super.key,
    this.onRefreshComplete,
    this.forceRefresh = false,
  });

  @override
  State<CourseCategoriesSection> createState() =>
      _CourseCategoriesSectionState();
}

class _CourseCategoriesSectionState extends State<CourseCategoriesSection> {
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  String? error;
  bool _lastForceRefreshState = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadCategoriesWithCounts();
    });
  }

  @override
  void didUpdateWidget(CourseCategoriesSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    // NEW: Detect when parent triggers refresh
    if (widget.forceRefresh != _lastForceRefreshState && widget.forceRefresh) {
      print('DEBUG: Categories section received refresh trigger');
      _lastForceRefreshState = widget.forceRefresh;
      _handleRefresh();
    } else if (!widget.forceRefresh) {
      _lastForceRefreshState = false;
    }
  }

  // NEW: Handle external refresh trigger
  Future<void> _handleRefresh() async {
    print('DEBUG: Categories section starting refresh...');

    // Clear cache to ensure fresh data
    CourseRepository.clearCache();

    // Reset state and show skeleton
    setState(() {
      isLoading = true;
      error = null;
    });

    await _loadCategoriesWithCounts(isRefresh: true);

    // Notify parent that refresh is complete
    if (widget.onRefreshComplete != null) {
      widget.onRefreshComplete!();
    }
  }

  Future<void> _loadCategoriesWithCounts({bool isRefresh = false}) async {
    try {
      if (!isRefresh) {
        setState(() {
          isLoading = true;
          error = null;
        });
      }

      print(
        'DEBUG: ${isRefresh ? "Refreshing" : "Loading"} categories with counts...',
      );

      // Fetch categories from app_config
      final configResponse = await Supabase.instance.client
          .from('app_config')
          .select('config_value')
          .eq('config_key', 'course_categories')
          .eq('is_active', true)
          .maybeSingle();

      if (configResponse == null) {
        throw Exception('Course categories configuration not found');
      }

      final configData = configResponse['config_value'] as Map<String, dynamic>;
      final categoriesConfig = configData['categories'] as List<dynamic>;

      print('DEBUG: Found ${categoriesConfig.length} categories in config');

      // OPTIMIZED: Get all counts in a single batch operation
      final countMap = await CourseRepository.getAllCategoryCounts();

      print(
        'DEBUG: Retrieved counts for ${countMap.length} categories: $countMap',
      );

      // Build categories with real counts
      final categoriesWithCounts = <Map<String, dynamic>>[];

      for (final categoryConfig in categoriesConfig) {
        final categoryName = categoryConfig['name'] as String;
        final count = countMap[categoryName] ?? 0;

        final iconMap = {
          '💻': Icons.computer,
          '📊': Icons.business,
          '🎨': Icons.design_services,
          '🔬': Icons.science,
        };

        final colorMap = {
          '#3B82F6': Colors.blue,
          '#10B981': Colors.green,
          '#F59E0B': Colors.orange,
          '#8B5CF6': Colors.purple,
        };

        categoriesWithCounts.add({
          'id': categoryConfig['id'],
          'title': categoryName,
          'subtitle': categoryConfig['description'],
          'icon': iconMap[categoryConfig['icon']] ?? Icons.category,
          'color': colorMap[categoryConfig['color']] ?? Colors.blue,
          'count': count,
          'displayCount': count > 0 ? '$count+ Courses' : 'No Courses',
        });
      }

      print(
        'DEBUG: Built ${categoriesWithCounts.length} categories with counts',
      );

      if (mounted) {
        setState(() {
          categories = categoriesWithCounts;
          isLoading = false;
        });

        print('DEBUG: Categories state updated successfully');
      }
    } catch (e) {
      print('ERROR: Failed to load categories: $e');

      if (mounted) {
        setState(() {
          error = 'Failed to load categories: $e';
          isLoading = false;
          categories = _getFallbackCategories();
        });
      }
    }
  }

  List<Map<String, dynamic>> _getFallbackCategories() {
    return [
      {
        'id': 'technology',
        'title': 'Technology',
        'subtitle': 'Programming, web development, and emerging technologies',
        'icon': Icons.computer,
        'color': Colors.blue,
        'count': 0,
        'displayCount': 'Loading...',
      },
      {
        'id': 'business',
        'title': 'Business',
        'subtitle': 'Business skills, management, and entrepreneurship',
        'icon': Icons.business,
        'color': Colors.green,
        'count': 0,
        'displayCount': 'Loading...',
      },
      {
        'id': 'design',
        'title': 'Design',
        'subtitle': 'UI/UX design, graphic design, and creative skills',
        'icon': Icons.design_services,
        'color': Colors.purple,
        'count': 0,
        'displayCount': 'Loading...',
      },
      {
        'id': 'science',
        'title': 'Science',
        'subtitle': 'Data science, research, and scientific methods',
        'icon': Icons.science,
        'color': Colors.orange,
        'count': 0,
        'displayCount': 'Loading...',
      },
    ];
  }

  void _onCategoryTap(Map<String, dynamic> category) {
    final categoryName = category['title'] as String;
    context.push(CommonRoutes.getCoursesByCategoryRoute(categoryName));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    final isSmallMobile = screenWidth < 360;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
        vertical: 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course Categories',
                      style: TextStyle(
                        fontSize: isSmallMobile ? 18 : (isMobile ? 20 : 24),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explore courses across different learning domains',
                      style: TextStyle(
                        fontSize: isSmallMobile ? 13 : (isMobile ? 14 : 16),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // NEW: Always show skeleton when loading (including refresh)
          if (isLoading)
            _buildSkeletonLoader(isMobile, isTablet, isSmallMobile)
          else if (error != null)
            _buildErrorState()
          else
            _buildCategoriesLayout(isMobile, isTablet, isSmallMobile),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader(
    bool isMobile,
    bool isTablet,
    bool isSmallMobile,
  ) {
    print('DEBUG: Rendering skeleton loader');

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: isMobile
          ? Column(
              children: List.generate(
                4,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildSkeletonCard(true, isSmallMobile),
                ),
              ),
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 2 : 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: 4,
              itemBuilder: (context, index) =>
                  _buildSkeletonCard(false, isSmallMobile),
            ),
    );
  }

  Widget _buildSkeletonCard(bool isMobile, bool isSmallMobile) {
    return Container(
      padding: EdgeInsets.all(isSmallMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isSmallMobile ? 40 : 48,
                height: isSmallMobile ? 40 : 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              if (!isMobile) const Spacer(),
              if (!isMobile)
                Container(
                  width: 80,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
            ],
          ),
          SizedBox(height: isSmallMobile ? 12 : 16),
          Container(
            height: isSmallMobile ? 16 : 18,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: isSmallMobile ? 12 : 14,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          if (isMobile) ...[
            SizedBox(height: isSmallMobile ? 8 : 12),
            Container(
              height: 12,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error ?? 'Something went wrong',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _loadCategoriesWithCounts(),
                child: const Text('Retry'),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    error = null;
                    categories = _getFallbackCategories();
                  });
                },
                child: const Text('Use Offline Mode'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesLayout(
    bool isMobile,
    bool isTablet,
    bool isSmallMobile,
  ) {
    return isMobile
        ? Column(
            children: categories
                .map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildCategoryCard(category, true, isSmallMobile),
                  ),
                )
                .toList(),
          )
        : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 2 : 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) =>
                _buildCategoryCard(categories[index], false, isSmallMobile),
          );
  }

  Widget _buildCategoryCard(
    Map<String, dynamic> category,
    bool isMobile,
    bool isSmallMobile,
  ) {
    final isOfflineMode = category['displayCount'] == 'Loading...';

    return GestureDetector(
      onTap: isOfflineMode ? null : () => _onCategoryTap(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isSmallMobile ? 16 : 24),
        decoration: BoxDecoration(
          color: isOfflineMode ? Colors.grey[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: isSmallMobile ? 40 : 48,
                  height: isSmallMobile ? 40 : 48,
                  decoration: BoxDecoration(
                    color: category['color'].withOpacity(
                      isOfflineMode ? 0.3 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    category['icon'],
                    color: category['color'].withOpacity(
                      isOfflineMode ? 0.6 : 1.0,
                    ),
                    size: isSmallMobile ? 20 : 24,
                  ),
                ),
                if (!isMobile) const Spacer(),
                if (!isMobile)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: category['color'].withOpacity(
                        isOfflineMode ? 0.3 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category['displayCount'],
                      style: TextStyle(
                        fontSize: 12,
                        color: category['color'].withOpacity(
                          isOfflineMode ? 0.6 : 1.0,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: isSmallMobile ? 12 : 16),
            Text(
              category['title'],
              style: TextStyle(
                fontSize: isSmallMobile ? 14 : (isMobile ? 16 : 18),
                fontWeight: FontWeight.bold,
                color: isOfflineMode ? Colors.grey[600] : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              category['subtitle'],
              style: TextStyle(
                fontSize: isSmallMobile ? 11 : (isMobile ? 12 : 14),
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isMobile) ...[
              SizedBox(height: isSmallMobile ? 8 : 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category['displayCount'],
                    style: TextStyle(
                      fontSize: 12,
                      color: category['color'].withOpacity(
                        isOfflineMode ? 0.6 : 1.0,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!isOfflineMode)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.grey[400],
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
