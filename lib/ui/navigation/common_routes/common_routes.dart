// common_routes/common_routes.dart
import 'package:brainboosters_app/screens/common/settings/profile_page.dart';
import 'package:brainboosters_app/screens/common/settings/settings_page.dart';
import 'package:brainboosters_app/screens/common/coaching_centers/coaching_centers_page.dart';
import 'package:brainboosters_app/screens/common/courses/courses_page.dart';
import 'package:brainboosters_app/screens/common/live_class/live_classes_page.dart';
import 'package:brainboosters_app/screens/common/notifications/notifications_page.dart';
import 'package:go_router/go_router.dart';

class CommonRoutes {
  // Route paths with leading slash for proper routing
  static const String courses = '/courses';
  static const String notifications = '/notifications';
  static const String liveClasses = '/live-classes';
  static const String coachingCenters = '/coaching-centers';
  static const String settings = '/settings';

  // Create StatefulShellBranch routes for shared navigation (only the ones used in navigation)
  static List<StatefulShellBranch> createNavigationBranches() {
    return [
      // Branch for Courses
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: courses,
            builder: (context, state) => const CoursesPage(),
          ),
        ],
      ),
      // Branch for Live Classes
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: liveClasses,
            builder: (context, state) => const LiveClassesPage(),
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
          ),
        ],
      ),
    ];
  }

  // Keep the original routes for non-shell navigation if needed
  static final List<RouteBase> routes = [
    GoRoute(path: courses, builder: (context, state) => const CoursesPage()),
    GoRoute(path: liveClasses, builder: (context, state) => const LiveClassesPage()),
    GoRoute(path: notifications, builder: (context, state) => const NotificationsPage()),
    GoRoute(path: coachingCenters, builder: (context, state) => const CoachingCentersPage()),
    GoRoute(path: settings, builder: (context, state) => const SettingsPage()),
  ];
}
