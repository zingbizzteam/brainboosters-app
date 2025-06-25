// ui/navigation/faculty_routes/faculty_routes.dart
import 'package:brainboosters_app/screens/faculty/dashboard/faculty_dashboard_page.dart';
import 'package:brainboosters_app/screens/faculty/students/faculty_students_page.dart';
import 'package:brainboosters_app/screens/faculty/classes/faculty_classes_page.dart';
import 'package:brainboosters_app/screens/faculty/profile/faculty_profile_page.dart';
import 'package:brainboosters_app/screens/faculty/faculty_main_screen.dart';
import 'package:go_router/go_router.dart';

class FacultyRoutes {
  static const String dashboard = '/faculty/dashboard';
  static const String students = '/faculty/students';
  static const String classes = '/faculty/classes';
  static const String profile = '/faculty/profile';

  static final StatefulShellRoute statefulRoute = StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) => FacultyMainScreen(shell: navigationShell),
    branches: [
      // Branch 0: Dashboard
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: dashboard,
            builder: (context, state) => const FacultyDashboardPage(),
          ),
        ],
      ),
      
      // Branch 1: Students
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: students,
            builder: (context, state) => const FacultyStudentsPage(),
          ),
        ],
      ),
      
      // Branch 2: Classes
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: classes,
            builder: (context, state) => const FacultyClassesPage(),
          ),
        ],
      ),
      
      // Branch 3: Profile
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: profile,
            builder: (context, state) => const FacultyProfilePage(),
          ),
        ],
      ),
    ],
  );
}
