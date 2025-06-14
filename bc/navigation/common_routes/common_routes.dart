// common_routes/common_routes.dart
import 'package:brainboosters_app/screens/common/coaching_centers/coaching_centers_page.dart';
import 'package:brainboosters_app/screens/common/courses/courses_page.dart';
import 'package:brainboosters_app/screens/common/live_class/live_classes_page.dart';
import 'package:brainboosters_app/screens/common/notifications/notifications_page.dart';
import 'package:go_router/go_router.dart';

class CommonRoutes {
  static const String courses = 'courses';
  static const String notifications = 'notifications';
  
  static const String liveClasses = 'live-classes';
  static const String coachingCenters = 'coaching-centers';

  static final List<RouteBase> routes = [
    GoRoute(path: courses, builder: (context, state) => const CoursesPage()),
    GoRoute(
      path: liveClasses,

      builder: (context, state) => const LiveClassesPage(),
    ),
    GoRoute(
      path: notifications,

      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: coachingCenters,

      builder: (context, state) => const CoachingCentersPage(),
    ),
  ];
}
