// common_routes/common_routes.dart
import 'package:brainboosters_app/screens/common/settings/profile_page.dart';
import 'package:brainboosters_app/screens/common/settings/settings_page.dart';
import 'package:brainboosters_app/screens/common/coaching_centers/coaching_centers_page.dart';
import 'package:brainboosters_app/screens/common/coaching_centers/coaching_center_detail_page.dart';
import 'package:brainboosters_app/screens/common/courses/courses_page.dart';
import 'package:brainboosters_app/screens/common/courses/course_intro_page.dart';
import 'package:brainboosters_app/screens/common/live_class/live_classes_page.dart';
import 'package:brainboosters_app/screens/common/live_class/live_class_intro_page.dart';
import 'package:brainboosters_app/screens/common/notifications/notifications_page.dart';
import 'package:go_router/go_router.dart';

class CommonRoutes {
  // Route paths with leading slash for proper routing
  static const String courses = '/courses';
  static const String courseDetail = '/courses/:courseId';
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

  // Create StatefulShellBranch routes for shared navigation (only the ones used in navigation)
  static List<StatefulShellBranch> createNavigationBranches() {
    return [
      // Branch for Courses
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: courses,
            builder: (context, state) => const CoursesPage(),
            routes: [
              // Nested route for course details
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
              // Nested route for live class details
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
      // Branch for Notifications
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: notifications,
            builder: (context, state) => const NotificationsPage(),
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

  // Create all shell branches including coaching centers (for other uses)
  static List<StatefulShellBranch> createAllShellBranches() {
    return [
      ...createNavigationBranches(),
      // Branch for Coaching Centers (not in main navigation)
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: coachingCenters,
            builder: (context, state) => const CoachingCentersPage(),
            routes: [
              // Nested route for coaching center details
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
    ];
  }

  // Keep the original routes for non-shell navigation if needed
  static final List<RouteBase> routes = [
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
    GoRoute(path: notifications, builder: (context, state) => const NotificationsPage()),
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
    GoRoute(path: settings, builder: (context, state) => const SettingsPage()),
  ];
}
