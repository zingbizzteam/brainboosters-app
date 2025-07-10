import 'package:brainboosters_app/screens/Student/notifications/notifications_page.dart';
import 'package:brainboosters_app/screens/common/coaching_centers/coaching_centers_page.dart';
import 'package:brainboosters_app/screens/common/courses/courses_page.dart';
import 'package:brainboosters_app/screens/common/courses/coures_intro/course_intro_page.dart';
import 'package:brainboosters_app/screens/common/courses/course_player/course_player_page.dart';
import 'package:brainboosters_app/screens/common/live_class/live_classes_page.dart';
import 'package:brainboosters_app/screens/common/live_class/live_class_intro/live_class_intro_page.dart';
import 'package:brainboosters_app/screens/student/dashboard/dashboard_page.dart';
import 'package:brainboosters_app/screens/student/student_mainscreen.dart';
import 'package:brainboosters_app/screens/student/settings/settings_page.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboosters_app/screens/student/profile/profile_page.dart';

class StudentRoutes {
  static const String home = '/home';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String profile = '/profile';

  static final StatefulShellRoute statefulRoute =
      StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        StudentMainScreen(shell: navigationShell),
    branches: [
      // Home
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: home,
            builder: (context, state) => const DashboardPage(),
          ),
        ],
      ),

      // Courses with nested routes
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: CommonRoutes.courses,
            builder: (context, state) => const CoursesPage(),
            routes: [
              // Course intro page
              GoRoute(
                path: ':courseId',
                builder: (context, state) {
                  final courseId = state.pathParameters['courseId']!;
                  return CourseIntroPage(courseId: courseId);
                },
                routes: [
                  // Course player routes
                  GoRoute(
                    path: 'player',
                    builder: (context, state) {
                      final courseId = state.pathParameters['courseId']!;
                      return CoursePlayerPage(courseId: courseId);
                    },
                  ),
                  GoRoute(
                    path: 'lesson/:lessonId',
                    builder: (context, state) {
                      final courseId = state.pathParameters['courseId']!;
                      final lessonId = state.pathParameters['lessonId']!;
                      return CoursePlayerPage(
                        courseId: courseId,
                        lessonId: lessonId,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
// Live Classes
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: CommonRoutes.liveClasses,
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
     

      // Coaching Centers
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: CommonRoutes.coachingCenters,
            builder: (context, state) => const CoachingCentersPage(),
          ),
        ],
      ),

      // Profile
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: profile,
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),

      
    ],
  );

  // Standalone routes (not in bottom nav)
  static List<RouteBase> getAdditionalRoutes() {
    return [
      GoRoute(
        path: notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsPage(),
      ),
    ];
  }
}
