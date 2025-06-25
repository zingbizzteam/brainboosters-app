// screens/common/search/search_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../courses/data/course_dummy_data.dart';
import '../courses/models/course_model.dart';
import '../live_class/data/live_class_dummy_data.dart';
import '../live_class/models/live_class_model.dart';
import '../view_coaching_centers/data/coaching_center_dummy_data.dart';
import '../view_coaching_centers/models/coaching_center_model.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/search_filters_widget.dart';
import 'widgets/search_results_widget.dart';
import 'widgets/search_tab_bar_widget.dart';

enum SearchContentType { all, courses, liveClasses, coachingCenters }

class SearchPage extends StatefulWidget {
  final String query;
  const SearchPage({super.key, required this.query});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  SearchContentType selectedType = SearchContentType.all;
  String sortBy = 'Relevance';
  String filterDifficulty = 'All';
  String filterPrice = 'All';
  String filterCategory = 'All';
  bool showFilters = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Get filtered courses
  List<Course> get _filteredCourses {
    List<Course> results = CourseDummyData.courses;
    
    if (widget.query.isNotEmpty) {
      results = results.where((c) =>
          c.title.toLowerCase().contains(widget.query.toLowerCase()) ||
          c.subject.toLowerCase().contains(widget.query.toLowerCase()) ||
          c.academy.toLowerCase().contains(widget.query.toLowerCase()) ||
          c.description.toLowerCase().contains(widget.query.toLowerCase())).toList();
    }

    // Apply filters
    if (filterDifficulty != 'All') {
      results = results.where((c) => c.difficulty == filterDifficulty).toList();
    }
    
    if (filterPrice == 'Free') {
      results = results.where((c) => c.isFree).toList();
    } else if (filterPrice == 'Paid') {
      results = results.where((c) => !c.isFree).toList();
    }
    
    if (filterCategory != 'All') {
      results = results.where((c) => c.category == filterCategory).toList();
    }

    // Apply sorting
    _applySorting(results);
    return results;
  }

  // Get filtered live classes
  List<LiveClass> get _filteredLiveClasses {
    List<LiveClass> results = LiveClassDummyData.liveClasses;
    
    if (widget.query.isNotEmpty) {
      results = results.where((lc) =>
          lc.title.toLowerCase().contains(widget.query.toLowerCase()) ||
          lc.subject.toLowerCase().contains(widget.query.toLowerCase()) ||
          lc.instructor.toLowerCase().contains(widget.query.toLowerCase()) ||
          lc.description.toLowerCase().contains(widget.query.toLowerCase())).toList();
    }

    return results;
  }

  // Get filtered coaching centers
  List<CoachingCenter> get _filteredCoachingCenters {
    List<CoachingCenter> results = CoachingCenterDummyData.coachingCenters;
    
    if (widget.query.isNotEmpty) {
      results = results.where((cc) =>
          cc.name.toLowerCase().contains(widget.query.toLowerCase()) ||
          cc.location.toLowerCase().contains(widget.query.toLowerCase()) ||
          cc.description.toLowerCase().contains(widget.query.toLowerCase()) ||
          cc.specializations.any((s) => s.toLowerCase().contains(widget.query.toLowerCase()))).toList();
    }

    return results;
  }

  void _applySorting<T>(List<T> results) {
    switch (sortBy) {
      case 'Newest':
        if (T == Course) {
          (results as List<Course>).sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }
        break;
      case 'Price: Low to High':
        if (T == Course) {
          (results as List<Course>).sort((a, b) => a.price.compareTo(b.price));
        }
        break;
      case 'Price: High to Low':
        if (T == Course) {
          (results as List<Course>).sort((a, b) => b.price.compareTo(a.price));
        }
        break;
      case 'Rating':
        if (T == Course) {
          (results as List<Course>).sort((a, b) => b.rating.compareTo(a.rating));
        } else if (T == CoachingCenter) {
          (results as List<CoachingCenter>).sort((a, b) => b.rating.compareTo(a.rating));
        }
        break;
      case 'Popularity':
        if (T == Course) {
          (results as List<Course>).sort((a, b) => b.totalRatings.compareTo(a.totalRatings));
        }
        break;
    }
  }

  int get _totalResults {
    switch (selectedType) {
      case SearchContentType.courses:
        return _filteredCourses.length;
      case SearchContentType.liveClasses:
        return _filteredLiveClasses.length;
      case SearchContentType.coachingCenters:
        return _filteredCoachingCenters.length;
      case SearchContentType.all:
        return _filteredCourses.length + _filteredLiveClasses.length + _filteredCoachingCenters.length;
    }
  }

  void _onFilterChanged({
    String? sortBy,
    String? filterDifficulty,
    String? filterPrice,
    String? filterCategory,
    bool? showFilters,
  }) {
    setState(() {
      if (sortBy != null) this.sortBy = sortBy;
      if (filterDifficulty != null) this.filterDifficulty = filterDifficulty;
      if (filterPrice != null) this.filterPrice = filterPrice;
      if (filterCategory != null) this.filterCategory = filterCategory;
      if (showFilters != null) this.showFilters = showFilters;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: widget.query.isNotEmpty 
          ? Text('Search Results for "${widget.query}"')
          : const Text('Search Everything'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        bottom: SearchTabBarWidget(
          tabController: _tabController,
          filteredCourses: _filteredCourses,
          filteredLiveClasses: _filteredLiveClasses,
          filteredCoachingCenters: _filteredCoachingCenters,
          onTabChanged: (index) {
            setState(() {
              selectedType = SearchContentType.values[index];
            });
          },
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          SearchBarWidget(
            initialQuery: widget.query,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
              vertical: 16,
            ),
          ),
          
          // Filters and Sort
          SearchFiltersWidget(
            totalResults: _totalResults,
            selectedType: selectedType,
            sortBy: sortBy,
            filterDifficulty: filterDifficulty,
            filterPrice: filterPrice,
            filterCategory: filterCategory,
            showFilters: showFilters,
            isMobile: isMobile,
            isTablet: isTablet,
            onFilterChanged: _onFilterChanged,
          ),
          
          // Results
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SearchResultsWidget.all(
                  filteredCourses: _filteredCourses,
                  filteredLiveClasses: _filteredLiveClasses,
                  filteredCoachingCenters: _filteredCoachingCenters,
                  isMobile: isMobile,
                ),
                SearchResultsWidget.courses(
                  filteredCourses: _filteredCourses,
                  isMobile: isMobile,
                  isTablet: isTablet,
                ),
                SearchResultsWidget.liveClasses(
                  filteredLiveClasses: _filteredLiveClasses,
                  isMobile: isMobile,
                  isTablet: isTablet,
                ),
                SearchResultsWidget.coachingCenters(
                  filteredCoachingCenters: _filteredCoachingCenters,
                  isMobile: isMobile,
                  isTablet: isTablet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
