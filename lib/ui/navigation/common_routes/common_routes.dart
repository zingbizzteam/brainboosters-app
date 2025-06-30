// common_routes/common_routes.dart
import 'package:brainboosters_app/screens/common/settings/profile_page.dart';
import 'package:brainboosters_app/screens/common/settings/settings_page.dart';
import 'package:brainboosters_app/screens/common/view_coaching_centers/coaching_centers_page.dart';
import 'package:brainboosters_app/screens/common/view_coaching_centers/coaching_center_details_page.dart';
import 'package:brainboosters_app/screens/common/courses/courses_page.dart';
import 'package:brainboosters_app/screens/common/courses/course_intro_page.dart';
import 'package:brainboosters_app/screens/common/search/search_page.dart';
import 'package:brainboosters_app/screens/common/live_class/live_classes_page.dart';
import 'package:brainboosters_app/screens/common/live_class/live_class_intro_page.dart';
import 'package:brainboosters_app/screens/common/notifications/notifications_page.dart';
import 'package:go_router/go_router.dart';

class CommonRoutes {
  // Route paths
  static const String courses = '/courses';
  static const String courseDetail = '/courses/:courseId';
  static const String searchCourses = '/search-courses';
  static const String notifications = '/notifications';
  static const String liveClasses = '/live-classes';
  static const String liveClassDetail = '/live-classes/:liveClassId';
  static const String coachingCenters = '/coaching-centers';
  static const String coachingCenterDetail = '/coaching-centers/:centerId';
  static const String settings = '/settings';

  // Helper methods to generate dynamic routes
  static String getCourseDetailRoute(String courseId) => '/courses/$courseId';
  static String getLiveClassDetailRoute(String liveClassId) => '/live-classes/$liveClassId';
  static String getCoachingCenterDetailRoute(String centerId) => '/coaching-centers/$centerId';
  static String getSearchCoursesRoute(String query) => '/search-courses?q=${Uri.encodeComponent(query)}';

  // Create StatefulShellBranch routes for navigation
  static List<StatefulShellBranch> createNavigationBranches() {
    return [
      // Branch for Courses
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: courses,
            builder: (context, state) => const CoursesPage(),
            routes: [
              GoRoute(
                path: ':courseId',
                builder: (context, state) {
                  final courseId = state.pathParameters['courseId']!;
                  return CourseIntroPage(courseId: courseId);
                },
              ),
            ],
          ),
        ],
      ),
      // Branch for Live Classes
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: liveClasses,
            builder: (context, state) => const LiveClassesPage(),
            routes: [
              GoRoute(
                path: ':liveClassId',
                builder: (context, state) {
                  final liveClassId = state.pathParameters['liveClassId']!;
                  return LiveClassIntroPage(liveClassId: liveClassId);
                },
              ),
            ],
          ),
        ],
      ),
      // Branch for Coaching Centers
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: coachingCenters,
            builder: (context, state) => const CoachingCentersPage(),
            routes: [
              GoRoute(
                path: ':centerId',
                builder: (context, state) {
                  final centerId = state.pathParameters['centerId']!;
                  return CoachingCenterDetailPage(centerId: centerId);
                },
              ),
            ],
          ),
        ],
      ),
      // Branch for Settings
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: settings,
            builder: (context, state) => const SettingsPage(),
            routes: [
              GoRoute(
                path: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ];
  }

  // Additional routes that are not part of main navigation but accessible
  static List<RouteBase> getAdditionalRoutes() {
    return [
      // Notifications route
      GoRoute(
        path: notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      // Search route
      GoRoute(
        path: searchCourses,
        builder: (context, state) {
          final query = state.uri.queryParameters['q'] ?? '';
          return SearchPage(query: query);
        },
      ),
    ];
  }
}
