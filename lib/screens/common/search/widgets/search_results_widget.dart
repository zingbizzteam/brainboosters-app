// screens/common/search/widgets/search_results_widget.dart
import 'package:brainboosters_app/screens/common/search/widgets/search_card_widgets.dart';
import 'package:flutter/material.dart';
import '../../courses/models/course_model.dart';
import '../../live_class/models/live_class_model.dart';
import '../../coaching_centers/models/coaching_center_model.dart';

class SearchResultsWidget extends StatelessWidget {
  final List<Course>? filteredCourses;
  final List<LiveClass>? filteredLiveClasses;
  final List<CoachingCenter>? filteredCoachingCenters;
  final bool isMobile;
  final bool? isTablet;
  final SearchResultsType type;

  const SearchResultsWidget._({
    this.filteredCourses,
    this.filteredLiveClasses,
    this.filteredCoachingCenters,
    required this.isMobile,
    this.isTablet,
    required this.type,
  });

  factory SearchResultsWidget.all({
    required List<Course> filteredCourses,
    required List<LiveClass> filteredLiveClasses,
    required List<CoachingCenter> filteredCoachingCenters,
    required bool isMobile,
  }) {
    return SearchResultsWidget._(
      filteredCourses: filteredCourses,
      filteredLiveClasses: filteredLiveClasses,
      filteredCoachingCenters: filteredCoachingCenters,
      isMobile: isMobile,
      type: SearchResultsType.all,
    );
  }

  factory SearchResultsWidget.courses({
    required List<Course> filteredCourses,
    required bool isMobile,
    required bool isTablet,
  }) {
    return SearchResultsWidget._(
      filteredCourses: filteredCourses,
      isMobile: isMobile,
      isTablet: isTablet,
      type: SearchResultsType.courses,
    );
  }

  factory SearchResultsWidget.liveClasses({
    required List<LiveClass> filteredLiveClasses,
    required bool isMobile,
    required bool isTablet,
  }) {
    return SearchResultsWidget._(
      filteredLiveClasses: filteredLiveClasses,
      isMobile: isMobile,
      isTablet: isTablet,
      type: SearchResultsType.liveClasses,
    );
  }

  factory SearchResultsWidget.coachingCenters({
    required List<CoachingCenter> filteredCoachingCenters,
    required bool isMobile,
    required bool isTablet,
  }) {
    return SearchResultsWidget._(
      filteredCoachingCenters: filteredCoachingCenters,
      isMobile: isMobile,
      isTablet: isTablet,
      type: SearchResultsType.coachingCenters,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case SearchResultsType.all:
        return _buildAllResults();
      case SearchResultsType.courses:
        return _buildCoursesGrid();
      case SearchResultsType.liveClasses:
        return _buildLiveClassesGrid();
      case SearchResultsType.coachingCenters:
        return _buildCoachingCentersGrid();
    }
  }

  Widget _buildAllResults() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (filteredCourses?.isNotEmpty == true) ...[
            const Text(
              'Courses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filteredCourses!.take(5).length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 250,
                    margin: const EdgeInsets.only(right: 16),
                    child: CourseCard(
                      course: filteredCourses![index],
                      isMobile: isMobile,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
          
          if (filteredLiveClasses?.isNotEmpty == true) ...[
            const Text(
              'Live Classes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filteredLiveClasses!.take(5).length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 250,
                    margin: const EdgeInsets.only(right: 16),
                    child: LiveClassCard(
                      liveClass: filteredLiveClasses![index],
                      isMobile: isMobile,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
          
          if (filteredCoachingCenters?.isNotEmpty == true) ...[
            const Text(
              'Coaching Centers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filteredCoachingCenters!.take(5).length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 250,
                    margin: const EdgeInsets.only(right: 16),
                    child: CoachingCenterCard(
                      center: filteredCoachingCenters![index],
                      isMobile: isMobile,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCoursesGrid() {
    if (filteredCourses?.isEmpty == true) {
      return const EmptyStateWidget(message: 'No courses found');
    }
    
    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet! ? 40 : 80),
        vertical: 24,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : (isTablet! ? 2 : 3),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 1.2 : 0.75,
      ),
      itemCount: filteredCourses!.length,
      itemBuilder: (context, index) {
        return CourseCard(
          course: filteredCourses![index],
          isMobile: isMobile,
        );
      },
    );
  }

  Widget _buildLiveClassesGrid() {
    if (filteredLiveClasses?.isEmpty == true) {
      return const EmptyStateWidget(message: 'No live classes found');
    }
    
    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet! ? 40 : 80),
        vertical: 24,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : (isTablet! ? 2 : 3),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 1.2 : 0.75,
      ),
      itemCount: filteredLiveClasses!.length,
      itemBuilder: (context, index) {
        return LiveClassCard(
          liveClass: filteredLiveClasses![index],
          isMobile: isMobile,
        );
      },
    );
  }

  Widget _buildCoachingCentersGrid() {
    if (filteredCoachingCenters?.isEmpty == true) {
      return const EmptyStateWidget(message: 'No coaching centers found');
    }
    
    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet! ? 40 : 80),
        vertical: 24,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : (isTablet! ? 2 : 3),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 1.2 : 0.75,
      ),
      itemCount: filteredCoachingCenters!.length,
      itemBuilder: (context, index) {
        return CoachingCenterCard(
          center: filteredCoachingCenters![index],
          isMobile: isMobile,
        );
      },
    );
  }
}

enum SearchResultsType { all, courses, liveClasses, coachingCenters }
