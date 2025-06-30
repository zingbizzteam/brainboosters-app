// ui/navigation/admin_routes/admin_routes.dart
import 'package:go_router/go_router.dart';
import '../../../screens/admin/dashboard/admin_dashboard_page.dart';
import '../../../screens/admin/coaching_centers/admin_coaching_centers_page.dart';
import '../../../screens/admin/users/admin_users_page.dart';
import '../../../screens/admin/settings/admin_settings_page.dart';
import '../../../screens/admin/admin_mainscreen.dart';

class AdminRoutes {
  static const String dashboard = '/admin/dashboard';
  static const String coachingCenters = '/admin/coaching-centers';
  static const String users = '/admin/users';
  static const String settings = '/admin/settings';

  static final StatefulShellRoute statefulRoute = StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) => AdminMainScreen(shell: navigationShell),
    branches: [
      // Branch 0: Dashboard
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: dashboard,
            builder: (context, state) => const AdminDashboardPage(),
          ),
        ],
      ),
      
      // Branch 1: Coaching Centers
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: coachingCenters,
            builder: (context, state) => const AdminCoachingCentersPage(),
          ),
        ],
      ),
      
      // Branch 2: Users
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: users,
            builder: (context, state) => const AdminUsersPage(),
          ),
        ],
      ),
      
      // Branch 3: Settings
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: settings,
            builder: (context, state) => const AdminSettingsPage(),
          ),
        ],
      ),
    ],
  );
}
