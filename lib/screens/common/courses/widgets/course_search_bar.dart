// screens/common/courses/widgets/course_search_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../ui/navigation/common_routes/common_routes.dart';

class CourseSearchBar extends StatefulWidget {
  const CourseSearchBar({super.key});

  @override
  State<CourseSearchBar> createState() => _CourseSearchBarState();
}

class _CourseSearchBarState extends State<CourseSearchBar> {
  final TextEditingController _controller = TextEditingController();

  void _onSearch() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      context.push(CommonRoutes.getSearchCoursesRoute(query));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
        vertical: 24,
      ),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _onSearch(),
                decoration: InputDecoration(
                  hintText: 'Search for courses, topics, instructors...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: isMobile ? 14 : 16,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[500],
                    size: isMobile ? 20 : 24,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isMobile ? 12 : 16,
                    horizontal: 16,
                  ),
                ),
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _onSearch,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 14 : 18,
                horizontal: isMobile ? 20 : 32,
              ),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search,
                  size: isMobile ? 18 : 20,
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 8),
                  const Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
