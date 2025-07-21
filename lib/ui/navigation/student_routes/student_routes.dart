import 'package:brainboosters_app/screens/common/courses/enrolled_courses_page.dart';
import 'package:brainboosters_app/screens/common/live_class/enrolled_live_classes_page.dart';
import 'package:brainboosters_app/screens/common/live_class/live_class_intro/live_class_intro_page.dart';
import 'package:brainboosters_app/screens/common/live_class/live_classes_page.dart';
import 'package:brainboosters_app/screens/student/notifications/notifications_page.dart';
import 'package:brainboosters_app/screens/common/coaching_centers/coaching_centers_page.dart';
import 'package:brainboosters_app/screens/common/courses/courses_page.dart';
import 'package:brainboosters_app/screens/common/courses/coures_intro/course_intro_page.dart';
import 'package:brainboosters_app/screens/common/courses/course_player/course_player_page.dart';
import 'package:brainboosters_app/screens/student/dashboard/dashboard_page.dart';
import 'package:brainboosters_app/screens/student/student_mainscreen.dart';
import 'package:brainboosters_app/screens/student/profile/profile_page.dart';
import 'package:brainboosters_app/screens/student/profile/edit_profile_page.dart';
import 'package:brainboosters_app/screens/student/settings/settings_page.dart';
import 'package:brainboosters_app/screens/student/settings/privacy_settings_page.dart';
import 'package:brainboosters_app/screens/student/settings/notification_settings_page.dart';
import 'package:brainboosters_app/screens/student/settings/account_settings_page.dart';
import 'package:brainboosters_app/screens/student/settings/learning_preferences_page.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:go_router/go_router.dart';

class StudentRoutes {
  static const String home = '/home';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';

  // Enrolled content routes
  static const String enrolledCourses = '/enrolled-courses';
  static const String enrolledLiveClasses = '/enrolled-live-classes';

  // Settings sub-routes
  static const String privacySettings = '/settings/privacy';
  static const String notificationSettings = '/settings/notifications';
  static const String accountSettings = '/settings/account';
  static const String learningPreferences = '/settings/learning';

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
                path: CommonRoutes.coursesRoute,
                builder: (context, state) => const CoursesPage(),
                routes: [
                  GoRoute(
                    path: ':courseId',
                    builder: (context, state) {
                      final courseId = state.pathParameters['courseId']!;
                      return CourseIntroPage(courseId: courseId);
                    },
                    routes: [
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

          // Coaching Centers
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: CommonRoutes.coachingCentersRoute,
                builder: (context, state) => const CoachingCentersPage(),
              ),
            ],
          ),

          // Profile with nested edit route
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: profile,
                builder: (context, state) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => const EditProfilePage(),
                  ),
                ],
              ),
            ],
          ),

          // Live Classes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: CommonRoutes.liveClassesRoute,
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
        ],
      );

  static List<GoRoute> getWebRoutes() {
    return [
      GoRoute(
        path: '/home',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfilePage(),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => const EditProfilePage(),
          ),
        ],
      ),
      // Enrolled content routes for web
      GoRoute(
        path: enrolledCourses,
        builder: (context, state) => const EnrolledCoursesPage(),
      ),
      GoRoute(
        path: enrolledLiveClasses,
        builder: (context, state) => const EnrolledLiveClassesPage(),
      ),
    ];
  }

  // Standalone routes (not in bottom nav)
  static List<RouteBase> getAdditionalRoutes() {
    return [
      GoRoute(
        path: notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      // Enrolled content routes
      GoRoute(
        path: enrolledCourses,
        builder: (context, state) => const EnrolledCoursesPage(),
      ),
      GoRoute(
        path: enrolledLiveClasses,
        builder: (context, state) => const EnrolledLiveClassesPage(),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'privacy',
            builder: (context, state) => const PrivacySettingsPage(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationSettingsPage(),
          ),
          GoRoute(
            path: 'account',
            builder: (context, state) => const AccountSettingsPage(),
          ),
          GoRoute(
            path: 'learning',
            builder: (context, state) => const LearningPreferencesPage(),
          ),
        ],
      ),
    ];
  }
}
