// common_routes/common_routes.dart
import 'package:brainboosters_app/screens/common/coaching_centers/teachers/teacher_details/teacher_details_page.dart';
import 'package:brainboosters_app/screens/common/courses/category_courses/category_courses_page.dart';
import 'package:brainboosters_app/screens/common/search/search_models.dart';
import 'package:brainboosters_app/screens/common/search/search_page.dart';
import 'package:brainboosters_app/screens/common/coaching_centers/coaching_centers_page.dart';
import 'package:brainboosters_app/screens/common/coaching_centers/coaching_center_details/coaching_center_details_page.dart';
import 'package:brainboosters_app/screens/common/coaching_centers/teachers/coaching_center_teachers_page.dart';
import 'package:brainboosters_app/screens/common/courses/courses_page.dart';
import 'package:brainboosters_app/screens/common/courses/coures_intro/course_intro_page.dart';
import 'package:brainboosters_app/screens/common/live_class/live_classes_page.dart';
import 'package:brainboosters_app/screens/common/live_class/live_class_intro/live_class_intro_page.dart';
import 'package:go_router/go_router.dart';

class CommonRoutes {
  // Main navigation routes
  static const String courses = '/courses';
  static const String courseDetail = '/course/:courseId';
  static const String coursesByCategory = '/courses/category/:categoryName';
  static const String searchCourses = '/search-courses';
  static const String liveClasses = '/live-classes';
  static const String liveClassDetail = '/live-class/:liveClassId';
  static const String coachingCenters = '/coaching-centers';
  static const String coachingCenterDetail = '/coaching-center/:centerId';

  // Teacher routes nested under coaching centers
  static const String coachingCenterTeachers = '/coaching-center/:centerId/teachers';
  static const String coachingCenterTeacherDetail = '/coaching-center/:centerId/teacher/:teacherId';
  static const String SearchRoute = '/search';

  // Helper methods for generating routes
  static String getCourseDetailRoute(String courseId) => '/course/$courseId';
  static String getLiveClassDetailRoute(String liveClassId) => '/live-class/$liveClassId';
  static String getCoachingCenterDetailRoute(String centerId) => '/coaching-center/$centerId';
  static String getSearchCoursesRoute(String query) => '/search-courses?q=${Uri.encodeComponent(query)}';
  static String getCoursesByCategoryRoute(String categoryName) => '/courses/category/${Uri.encodeComponent(categoryName)}';
  static String getCoachingCenterTeachersRoute(String centerId) => '/coaching-center/$centerId/teachers';
  static String getCoachingCenterTeacherDetailRoute(String centerId, String teacherId) => '/coaching-center/$centerId/teacher/$teacherId';

  // Complete routes configuration (settings removed)
  static List<GoRoute> getAllRoutes() {
    return [
      // Courses routes
      GoRoute(path: courses, builder: (context, state) => const CoursesPage()),
      GoRoute(
        path: '/course/:courseId',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return CourseIntroPage(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'];
          final entityType = state.uri.queryParameters['type'];
          
          SearchEntityType? initialEntityType;
          if (entityType != null) {
            switch (entityType) {
              case 'courses':
                initialEntityType = SearchEntityType.courses;
                break;
              case 'centers':
                initialEntityType = SearchEntityType.coachingCenters;
                break;
              case 'live-classes':
                initialEntityType = SearchEntityType.liveClasses;
                break;
              case 'teachers':
                initialEntityType = SearchEntityType.teachers;
                break;
            }
          }
          
          return SearchPage(
            initialQuery: query,
            initialEntityType: initialEntityType,
          );
        },
      ),
      GoRoute(
        path: '/courses/category/:categoryName',
        builder: (context, state) {
          final categoryName = state.pathParameters['categoryName']!;
          return CategoryCoursesPage(
            categoryName: Uri.decodeComponent(categoryName),
          );
        },
      ),
      
      // Live Classes routes
      GoRoute(
        path: liveClasses,
        builder: (context, state) => const LiveClassesPage(),
      ),
      GoRoute(
        path: '/live-class/:liveClassId',
        builder: (context, state) {
          final liveClassId = state.pathParameters['liveClassId']!;
          return LiveClassIntroPage(liveClassId: liveClassId);
        },
      ),
      
      // Coaching Centers routes with nested teacher routes
      GoRoute(
        path: coachingCenters,
        builder: (context, state) => const CoachingCentersPage(),
      ),
      GoRoute(
        path: '/coaching-center/:centerId',
        builder: (context, state) {
          final centerId = state.pathParameters['centerId']!;
          return CoachingCenterDetailPage(centerId: centerId);
        },
        routes: [
          // Teachers list for this coaching center
          GoRoute(
            path: 'teachers',
            builder: (context, state) {
              final centerId = state.pathParameters['centerId']!;
              return CoachingCenterTeachersPage(centerId: centerId);
            },
          ),
          // Individual teacher detail within this coaching center
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
    ];
  }

  // Navigation branches for StatefulShellRoute (settings removed)
  static List<StatefulShellBranch> createNavigationBranches() {
    return [
      // Branch for Courses
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: courses,
            builder: (context, state) => const CoursesPage(),
            routes: [
              GoRoute(
                path: ':courseId',
                builder: (context, state) {
                  final courseId = state.pathParameters['courseId']!;
                  return CourseIntroPage(courseId: courseId);
                },
              ),
            ],
          ),
        ],
      ),
      
      // Branch for Live Classes
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: liveClasses,
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
      
      // Branch for Coaching Centers (with nested teacher routes)
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: coachingCenters,
            builder: (context, state) => const CoachingCentersPage(),
            routes: [
              GoRoute(
                path: ':centerId',
                builder: (context, state) {
                  final centerId = state.pathParameters['centerId']!;
                  return CoachingCenterDetailPage(centerId: centerId);
                },
                routes: [
                  // Teachers list route
                  GoRoute(
                    path: 'teachers',
                    builder: (context, state) {
                      final centerId = state.pathParameters['centerId']!;
                      return CoachingCenterTeachersPage(centerId: centerId);
                    },
                  ),
                  // Individual teacher route
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
            ],
          ),
        ],
      ),
    ];
  }
}
