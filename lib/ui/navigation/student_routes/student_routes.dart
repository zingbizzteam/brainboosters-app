// student_routes/student_routes.dart
import 'package:brainboosters_app/screens/Student/notifications/notifications_page.dart';
import 'package:brainboosters_app/screens/student/dashboard/dashboard_page.dart';
import 'package:brainboosters_app/screens/student/student_mainscreen.dart';
import 'package:brainboosters_app/screens/student/settings/settings_page.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:go_router/go_router.dart';

class StudentRoutes {
  static const String home = '/home';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  static final StatefulShellRoute statefulRoute =
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            StudentMainScreen(shell: navigationShell),
        branches: [
          // Branch 0: Home (Student-specific)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: home,
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),

          // Branches 1-3: Common navigation routes (excluding settings)
          ...CommonRoutes.createNavigationBranches(),

          // Branch 4: Settings ONLY (notifications removed from here)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      );

  // Standalone routes that exist outside the bottom navigation
  static List<GoRoute> getAdditionalRoutes() {
    return [
      // Notifications as a standalone page (no app bar, no bottom nav)
      GoRoute(
        path: notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
    ];
  }
}
