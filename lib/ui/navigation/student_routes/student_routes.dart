// student_routes/student_routes.dart
import 'package:brainboosters_app/screens/Student/dashboard/dashboard_page.dart';
import 'package:brainboosters_app/screens/Student/student_mainscreen.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:go_router/go_router.dart';

class StudentRoutes {
  static const String home = '/home';

  static final StatefulShellRoute statefulRoute = StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) => StudentMainScreen(shell: navigationShell),
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
      // Branches 1-4: Common navigation routes
      ...CommonRoutes.createNavigationBranches(),
    ],
  );
}
