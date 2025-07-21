// search_page.dart
import 'package:brainboosters_app/screens/common/search/search_models.dart';
import 'package:brainboosters_app/screens/common/search/search_repository.dart';
import 'package:brainboosters_app/screens/common/search/widgets/search_result_card.dart';
import 'package:brainboosters_app/screens/common/search/widgets/search_filters_bottom_sheet.dart';
import 'package:brainboosters_app/screens/common/search/widgets/search_sort_bottom_sheet.dart';
import 'package:brainboosters_app/ui/navigation/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class SearchPage extends StatefulWidget {
  final String? initialQuery;
  final SearchEntityType? initialEntityType;

  const SearchPage({super.key, this.initialQuery, this.initialEntityType});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  late TabController _tabController;

  List<SearchResult> _searchResults = [];
  List<String> _searchSuggestions = [];
  SearchFilters _filters = SearchFilters();
  SearchSortBy _sortBy = SearchSortBy.relevance;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _showSuggestions = false;
  String _currentQuery = '';
  int _currentPage = 0;

  static const int _pageSize = 20;

  final List<SearchEntityType> _entityTypes = [
    SearchEntityType.courses,
    SearchEntityType.coachingCenters,
    SearchEntityType.liveClasses,
    SearchEntityType.teachers,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _entityTypes.length, vsync: this);
    _searchController.text = widget.initialQuery ?? '';
    _currentQuery = widget.initialQuery ?? '';

    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);

    if (widget.initialQuery?.isNotEmpty == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query != _currentQuery) {
      _currentQuery = query;
      if (query.length >= 2) {
        _getSuggestions(query);
      } else {
        setState(() {
          _showSuggestions = false;
          _searchSuggestions.clear();
        });
      }
    }
  }

  void _onFocusChanged() {
    if (_searchFocusNode.hasFocus && _searchSuggestions.isNotEmpty) {
      setState(() {
        _showSuggestions = true;
      });
    } else {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  Future<void> _getSuggestions(String query) async {
    try {
      final suggestions = await SearchRepository.getSearchSuggestions(query);
      setState(() {
        _searchSuggestions = suggestions;
        _showSuggestions = _searchFocusNode.hasFocus && suggestions.isNotEmpty;
      });
    } catch (e) {
      // Handle error silently for suggestions
    }
  }

  Future<void> _performSearch({bool isLoadMore = false}) async {
    if (_currentQuery.trim().isEmpty) return;

    setState(() {
      if (isLoadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
        _currentPage = 0;
        _searchResults.clear();
        _hasMore = true;
      }
      _showSuggestions = false;
    });

    try {
      final results = await SearchRepository.searchAll(
        query: _currentQuery,
        limit: _pageSize,
        offset: _currentPage * _pageSize,
        entityTypes: [_entityTypes[_tabController.index]],
        filters: _filters,
        sortBy: _sortBy,
      );

      setState(() {
        if (isLoadMore) {
          _searchResults.addAll(results.results);
        } else {
          _searchResults = results.results;
        }
        _hasMore = results.hasMore;
        _currentPage++;
      });
    } catch (e) {
      _showErrorSnackBar('Search failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoadingMore || _isLoading) return;
    await _performSearch(isLoadMore: true);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchFiltersBottomSheet(
        filters: _filters,
        entityType: _entityTypes[_tabController.index],
        onFiltersChanged: (newFilters) {
          setState(() {
            _filters = newFilters;
          });
          _performSearch();
        },
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SearchSortBottomSheet(
        currentSort: _sortBy,
        entityType: _entityTypes[_tabController.index],
        onSortChanged: (newSort) {
          setState(() {
            _sortBy = newSort;
          });
          _performSearch();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_showSuggestions) _buildSuggestions(),
          _buildTabBar(),
          _buildFilterSortBar(),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          // Check if we can pop, otherwise go to home
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRouter.home);
          }
        },
      ),
      title: const Text(
        'Search',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search courses, teachers, centers...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF4AA0E6)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _currentQuery = '';
                      _searchResults.clear();
                      _showSuggestions = false;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4AA0E6)),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        onSubmitted: (query) {
          _currentQuery = query;
          _performSearch();
        },
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _searchSuggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _searchSuggestions[index];
          return ListTile(
            leading: const Icon(Icons.search, color: Colors.grey),
            title: Text(suggestion),
            onTap: () {
              _searchController.text = suggestion;
              _currentQuery = suggestion;
              _performSearch();
            },
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF4AA0E6),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF4AA0E6),
        onTap: (index) {
          if (_currentQuery.isNotEmpty) {
            _performSearch();
          }
        },
        tabs: const [
          Tab(text: 'Courses'),
          Tab(text: 'Centers'),
          Tab(text: 'Live Classes'),
          Tab(text: 'Teachers'),
        ],
      ),
    );
  }

  Widget _buildFilterSortBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _searchResults.isEmpty && !_isLoading
                  ? 'Enter search query'
                  : '${_searchResults.length} results',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          TextButton.icon(
            onPressed: _showFiltersBottomSheet,
            icon: const Icon(Icons.filter_list, size: 18),
            label: const Text('Filter'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4AA0E6),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _showSortBottomSheet,
            icon: const Icon(Icons.sort, size: 18),
            label: const Text('Sort'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4AA0E6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return _buildSkeletonLoader();
    }

    if (_searchResults.isEmpty && _currentQuery.isNotEmpty) {
      return _buildEmptyState();
    }

    if (_searchResults.isEmpty) {
      return _buildInitialState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _searchResults.length) {
          return _buildLoadingMoreIndicator();
        }

        final result = _searchResults[index];
        return SearchResultCard(
          result: result,
          onTap: () => _handleResultTap(result),
        );
      },
    );
  }

  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) => _buildSkeletonItem(),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 18,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                Container(height: 14, width: 200, color: Colors.white),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      height: 20,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 20,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Search for anything',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Courses, teachers, centers, and live classes',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4AA0E6)),
      ),
    );
  }

  void _handleResultTap(SearchResult result) {
    switch (result.entityType) {
      case SearchEntityType.courses:
        // Use GoRouter navigation
        context.go('/course/${result.id}');
        break;
      case SearchEntityType.coachingCenters:
        // Navigate to coaching center profile
        context.go('/coaching-center/${result.id}');
        break;
      case SearchEntityType.liveClasses:
        // Navigate to live class details
        context.go('/live-class/${result.id}');
        break;
      case SearchEntityType.teachers:
        // Navigate to teacher profile
        context.go('/teacher/${result.id}');
        break;
    }
  }
}
