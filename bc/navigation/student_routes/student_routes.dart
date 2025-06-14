// student_routes/student_routes.dart
import 'package:brainboosters_app/screens/Student/dashboard/dashboard_page.dart';
import 'package:brainboosters_app/screens/Student/leaderboard/leaderboard_page.dart';
import 'package:brainboosters_app/screens/Student/student_mainscreen.dart';
import 'package:brainboosters_app/screens/common/settings/settings_page.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:go_router/go_router.dart';

class StudentRoutes {
  static const String prefix = '/student';
  static const String home = '$prefix/home';
  static const String leaderboard = '$prefix/leaderboard';
  static const String settings = '$prefix/settings';
  
  static final List<RouteBase> routes = [
    ShellRoute(
      builder: (context, state, child) => StudentMainScreen(child: child),
      routes: [
        GoRoute(path: home, builder: (context, state) => const DashboardPage()),
        GoRoute(
          path: leaderboard,
          builder: (context, state) => const LeaderboardPage(),
        ),
        GoRoute(
          path: settings,
          builder: (context, state) => const SettingsPage(),
        ),
        // Include common routes within the shell
        ...CommonRoutes.routes,
      ],
    ),
  ];
}
