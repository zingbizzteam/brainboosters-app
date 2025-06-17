// screens/common/courses/search_courses_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../courses/data/course_dummy_data.dart';
import '../courses/models/course_model.dart';
import '../../../ui/navigation/common_routes/common_routes.dart';

class SearchPage extends StatefulWidget {
  final String query;
  const SearchPage({super.key, required this.query});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String sortBy = 'Relevance';
  String filterDifficulty = 'All';
  String filterPrice = 'All';
  String filterCategory = 'All';
  bool showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.query;
  }

  List<Course> get _filteredCourses {
    List<Course> results = CourseDummyData.courses;
    
    // Search filter
    if (widget.query.isNotEmpty) {
      results = results.where((c) =>
          c.title.toLowerCase().contains(widget.query.toLowerCase()) ||
          c.subject.toLowerCase().contains(widget.query.toLowerCase()) ||
          c.academy.toLowerCase().contains(widget.query.toLowerCase()) ||
          c.description.toLowerCase().contains(widget.query.toLowerCase())).toList();
    }

    // Difficulty filter
    if (filterDifficulty != 'All') {
      results = results.where((c) => c.difficulty == filterDifficulty).toList();
    }
    
    // Price filter
    if (filterPrice == 'Free') {
      results = results.where((c) => c.isFree).toList();
    } else if (filterPrice == 'Paid') {
      results = results.where((c) => !c.isFree).toList();
    }
    
    // Category filter
    if (filterCategory != 'All') {
      results = results.where((c) => c.category == filterCategory).toList();
    }

    // Sort
    switch (sortBy) {
      case 'Newest':
        results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Price: Low to High':
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Rating':
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Popularity':
        results.sort((a, b) => b.totalRatings.compareTo(a.totalRatings));
        break;
    }

    return results;
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    context.pushReplacement(CommonRoutes.getSearchCoursesRoute(query));
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
          : const Text('All Courses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
              vertical: 16,
            ),
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
                      hintText: 'Search for courses...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _onSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 14 : 16,
                      horizontal: isMobile ? 16 : 24,
                    ),
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          
          // Filters and Sort
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_filteredCourses.length} courses found',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isMobile)
                      IconButton(
                        onPressed: () => setState(() => showFilters = !showFilters),
                        icon: Icon(showFilters ? Icons.close : Icons.filter_list),
                      ),
                  ],
                ),
                
                if (!isMobile || showFilters) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      _buildDropdown(
                        'Sort by',
                        sortBy,
                        ['Relevance', 'Newest', 'Price: Low to High', 'Price: High to Low', 'Rating', 'Popularity'],
                        (value) => setState(() => sortBy = value!),
                      ),
                      _buildDropdown(
                        'Difficulty',
                        filterDifficulty,
                        ['All', 'Beginner', 'Intermediate', 'Advanced'],
                        (value) => setState(() => filterDifficulty = value!),
                      ),
                      _buildDropdown(
                        'Price',
                        filterPrice,
                        ['All', 'Free', 'Paid'],
                        (value) => setState(() => filterPrice = value!),
                      ),
                      _buildDropdown(
                        'Category',
                        filterCategory,
                        ['All', 'Programming', 'Data Science', 'Technology', 'Mobile Development'],
                        (value) => setState(() => filterCategory = value!),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Results
          Expanded(
            child: _filteredCourses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No courses found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
                      vertical: 24,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isMobile ? 1.2 : 0.75,
                    ),
                    itemCount: _filteredCourses.length,
                    itemBuilder: (context, index) {
                      return _buildCourseCard(_filteredCourses[index], isMobile);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButton<String>(
        value: value,
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text('$label: $item'),
        )).toList(),
        onChanged: onChanged,
        underline: Container(),
        style: const TextStyle(fontSize: 14, color: Colors.black),
        isDense: true,
      ),
    );
  }

  Widget _buildCourseCard(Course course, bool isMobile) {
    return GestureDetector(
      onTap: () {
        context.push(CommonRoutes.getCourseDetailRoute(course.id));
      },
      child: Container(
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
            // Course Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  course.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.book, size: 40, color: Colors.grey),
                  ),
                ),
              ),
            ),
            
            // Course Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.academy,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: isMobile ? 14 : 16),
                        const SizedBox(width: 4),
                        Text(
                          course.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          course.isFree ? 'Free' : '₹${course.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: course.isFree ? Colors.green : Colors.black,
                          ),
                        ),
                      ],
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
}
