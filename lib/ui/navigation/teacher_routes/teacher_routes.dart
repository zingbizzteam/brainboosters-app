import 'package:brainboosters_app/screens/Teacher/teacher_home_page/teacher_home_page.dart';
import 'package:brainboosters_app/screens/Teacher/teacher_mainscreen.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:go_router/go_router.dart';

class TeacherRoutes {
  static const String teacherhome = '/teacher-home';
  static const String courses = '/courses';
  static const String liveClasses = '/live-classes';

  static final StatefulShellRoute statefulRoute = StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) => TeacherMainScreen(shell: navigationShell),
    branches: [
      // Branch 0: Home (Teacher-specific)
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: teacherhome,
            builder: (context, state) => const TeacherHomePage(),
          ),
        ],
      ),
      // Branches 1-4: Common navigation routes (courses, live-classes, notifications, settings)
      ...CommonRoutes.createNavigationBranches(),
    ],
  );  
}
  