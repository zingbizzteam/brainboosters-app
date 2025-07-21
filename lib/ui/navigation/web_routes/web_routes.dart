// ui/navigation/web_routes.dart - ENHANCED FOR ALL PAGES
import 'package:brainboosters_app/screens/common/coaching_centers/coaching_centers_page.dart';
import 'package:brainboosters_app/screens/common/coaching_centers/coaching_center_details/coaching_center_details_page.dart';
import 'package:brainboosters_app/screens/common/coaching_centers/teachers/coaching_center_teachers_page.dart';
import 'package:brainboosters_app/screens/common/coaching_centers/teachers/teacher_details/teacher_details_page.dart';
import 'package:brainboosters_app/screens/common/courses/courses_page.dart';
import 'package:brainboosters_app/screens/common/courses/coures_intro/course_intro_page.dart';
import 'package:brainboosters_app/screens/common/courses/course_player/course_player_page.dart';
import 'package:brainboosters_app/screens/common/courses/category_courses/category_courses_page.dart';
import 'package:brainboosters_app/screens/common/live_class/live_classes_page.dart';
import 'package:brainboosters_app/screens/common/live_class/live_class_intro/live_class_intro_page.dart';
import 'package:brainboosters_app/screens/common/live_class/room/live_class_join_page.dart';
import 'package:brainboosters_app/screens/common/search/search_page.dart';
import 'package:brainboosters_app/screens/student/dashboard/dashboard_page.dart';
import 'package:brainboosters_app/screens/student/notifications/notifications_page.dart';
import 'package:brainboosters_app/screens/student/profile/profile_page.dart';
import 'package:brainboosters_app/screens/student/profile/edit_profile_page.dart';
import 'package:brainboosters_app/screens/student/settings/settings_page.dart';
import 'package:brainboosters_app/screens/student/settings/privacy_settings_page.dart';
import 'package:brainboosters_app/screens/student/settings/notification_settings_page.dart';
import 'package:brainboosters_app/screens/student/settings/account_settings_page.dart';
import 'package:brainboosters_app/screens/student/settings/learning_preferences_page.dart';
import 'package:brainboosters_app/screens/web/web_main_screen.dart';
import 'package:go_router/go_router.dart';

class WebRoutes {
  static final routes = [
    ShellRoute(
      builder: (context, state, child) => WebMainScreen(child: child),
      routes: [
        // Dashboard/Home routes
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const DashboardPage(),
        ),
        
        // Courses routes (with all nested routes)
        GoRoute(
          path: '/courses',
          builder: (context, state) => const CoursesPage(),
          routes: [
            GoRoute(
              path: 'category/:categoryName',
              builder: (context, state) {
                final categoryName = state.pathParameters['categoryName']!;
                return CategoryCoursesPage(
                  categoryName: Uri.decodeComponent(categoryName),
                );
              },
            ),
          ],
        ),
        
        // Course detail and player routes
        GoRoute(
          path: '/course/:courseId',
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
        
        // Live Classes routes (with all nested routes)
        GoRoute(
          path: '/live-classes',
          builder: (context, state) => const LiveClassesPage(),
        ),
        GoRoute(
          path: '/live-class/:liveClassId',
          builder: (context, state) {
            final liveClassId = state.pathParameters['liveClassId']!;
            return LiveClassIntroPage(liveClassId: liveClassId);
          },
          routes: [
            GoRoute(
              path: 'join',
              builder: (context, state) {
                final liveClassId = state.pathParameters['liveClassId']!;
                return LiveClassJoinPage(liveClassId: liveClassId);
              },
            ),
          ],
        ),
        
        // Coaching Centers routes (with all nested routes)
        GoRoute(
          path: '/coaching-centers',
          builder: (context, state) => const CoachingCentersPage(),
        ),
        GoRoute(
          path: '/coaching-center/:centerId',
          builder: (context, state) {
            final centerId = state.pathParameters['centerId']!;
            return CoachingCenterDetailPage(centerId: centerId);
          },
          routes: [
            GoRoute(
              path: 'teachers',
              builder: (context, state) {
                final centerId = state.pathParameters['centerId']!;
                return CoachingCenterTeachersPage(centerId: centerId);
              },
            ),
            GoRoute(
              path: 'teacher/:teacherId',
              builder: (context, state) {
                final centerId = state.pathParameters['centerId']!;
                final teacherId = state.pathParameters['teacherId']!;
                return TeacherDetailPage(
                  teacherId: teacherId,
                  centerId: centerId,
                );
              },
            ),
          ],
        ),
        
        // Profile routes (with nested edit route)
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) => const EditProfilePage(),
            ),
          ],
        ),
        
        // Notifications route
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsPage(),
        ),
        
        // Settings routes (with all sub-routes)
        GoRoute(
          path: '/settings',
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
        
        // Search route
        GoRoute(
          path: '/search',
          builder: (context, state) {
            final query = state.uri.queryParameters['q'];
            return SearchPage(initialQuery: query);
          },
        ),
      ],
    ),
  ];
}
