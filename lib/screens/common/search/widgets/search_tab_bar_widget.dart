// screens/common/search/widgets/search_tab_bar_widget.dart
import 'package:flutter/material.dart';
import '../../courses/models/course_model.dart';
import '../../live_class/models/live_class_model.dart';
import '../../view_coaching_centers/models/coaching_center_model.dart';

class SearchTabBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final List<Course> filteredCourses;
  final List<LiveClass> filteredLiveClasses;
  final List<CoachingCenter> filteredCoachingCenters;
  final ValueChanged<int> onTabChanged;

  const SearchTabBarWidget({
    super.key,
    required this.tabController,
    required this.filteredCourses,
    required this.filteredLiveClasses,
    required this.filteredCoachingCenters,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      onTap: onTabChanged,
      tabs: [
        Tab(text: 'All (${filteredCourses.length + filteredLiveClasses.length + filteredCoachingCenters.length})'),
        Tab(text: 'Courses (${filteredCourses.length})'),
        Tab(text: 'Live Classes (${filteredLiveClasses.length})'),
        Tab(text: 'Coaching Centers (${filteredCoachingCenters.length})'),
      ],
      labelColor: const Color(0xFF4AA0E6),
      unselectedLabelColor: Colors.grey,
      indicatorColor: const Color(0xFF4AA0E6),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
