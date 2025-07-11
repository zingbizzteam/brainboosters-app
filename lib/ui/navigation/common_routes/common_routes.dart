// common_routes/common_routes.dart - COMPLETE FIXED VERSION
import 'package:brainboosters_app/screens/common/coaching_centers/teachers/teacher_details/teacher_details_page.dart';
import 'package:brainboosters_app/screens/common/courses/assesment/assesment_page.dart';
import 'package:brainboosters_app/screens/common/courses/assesment/quiz_attempt_page.dart';
import 'package:brainboosters_app/screens/common/courses/assesment/quiz_results_page.dart';
import 'package:brainboosters_app/screens/common/courses/category_courses/category_courses_page.dart';
import 'package:brainboosters_app/screens/common/courses/course_player/course_player_page.dart';
import 'package:brainboosters_app/screens/common/courses/exercises/exercise_attempt_page.dart';
import 'package:brainboosters_app/screens/common/courses/exercises/exercise_results_page.dart';
import 'package:brainboosters_app/screens/common/courses/exercises/practice_exercise_page.dart';
import 'package:brainboosters_app/screens/common/live_class/room/live_class_join_page.dart';
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
  // FIXED: Proper route constants with clear naming
  static const String _courses = '/courses';
  static const String _courseDetail = '/course';
  static const String _coursesByCategory = '/courses/category';
  static const String _searchCourses = '/search-courses';
  static const String _liveClasses = '/live-classes';
  static const String _liveClassDetail = '/live-class';
  static const String _liveClassJoin = '/live-class';
  static const String _coachingCenters = '/coaching-centers';
  static const String _coachingCenterDetail = '/coaching-center';
  static const String _coursePlayer = '/course';
  static const String _assignment = '/assignment';
  static const String _assessment = '/assessment';
  static const String _exercise = '/exercise';
  static const String _quiz = '/quiz';
  static const String _search = '/search';

  // FIXED: Route template constants (these are the actual route patterns)
  static const String coursesRoute = '/courses';
  static const String courseDetailRoute = '/course/:courseId';
  static const String coursePlayerRoute = '/course/:courseId/lesson/:lessonId';
  static const String coursePlayerSimpleRoute = '/course/:courseId/player';
  static const String coursesByCategoryRoute = '/courses/category/:categoryName';
  static const String liveClassesRoute = '/live-classes';
  static const String liveClassDetailRoute = '/live-class/:liveClassId';
  static const String liveClassJoinRoute = '/live-class/:liveClassId/join';
  static const String coachingCentersRoute = '/coaching-centers';
  static const String coachingCenterDetailRoute = '/coaching-center/:centerId';
  static const String coachingCenterTeachersRoute = '/coaching-center/:centerId/teachers';
  static const String coachingCenterTeacherDetailRoute = '/coaching-center/:centerId/teacher/:teacherId';
  static const String assignmentRoute = '/assignment/:assignmentId';
  static const String assessmentRoute = '/assessment/:assessmentId/:type';
  static const String exerciseRoute = '/exercise/:exerciseId';
  static const String exerciseAttemptRoute = '/exercise/:exerciseId/attempt';
  static const String exerciseResultsRoute = '/exercise/:exerciseId/results';
  static const String quizAttemptRoute = '/quiz/:testId/attempt';
  static const String quizResultsRoute = '/quiz/:testId/results';
  static const String searchRoute = '/search';

  // FIXED: Helper methods for generating dynamic routes using constants
  static String getCourseDetailRoute(String courseId) => '$_courseDetail/$courseId';
  
  static String getLiveClassDetailRoute(String liveClassId) => '$_liveClassDetail/$liveClassId';
  
  static String getLiveClassJoinRoute(String liveClassId) => '$_liveClassDetail/$liveClassId/join';
  
  static String getCoachingCenterDetailRoute(String centerId) => '$_coachingCenterDetail/$centerId';
  
  static String getSearchCoursesRoute(String query) => '$_searchCourses?q=${Uri.encodeComponent(query)}';
  
  static String getCoursesByCategoryRoute(String categoryName) => '$_coursesByCategory/${Uri.encodeComponent(categoryName)}';
  
  static String getCoachingCenterTeachersRoute(String centerId) => '$_coachingCenterDetail/$centerId/teachers';
  
  static String getCoachingCenterTeacherDetailRoute(String centerId, String teacherId) => '$_coachingCenterDetail/$centerId/teacher/$teacherId';

  // FIXED: Assessment route helpers using constants
  static String getAssignmentRoute(String assignmentId, {String? courseId, String? lessonId}) {
    var route = '$_assignment/$assignmentId';
    final params = <String>[];
    if (courseId != null) params.add('courseId=$courseId');
    if (lessonId != null) params.add('lessonId=$lessonId');
    if (params.isNotEmpty) route += '?${params.join('&')}';
    return route;
  }

  static String getAssessmentRoute(String assessmentId, String type, {String? courseId, String? lessonId}) {
    var route = '/$type/$assessmentId';
    final params = <String>[];
    if (courseId != null) params.add('courseId=$courseId');
    if (lessonId != null) params.add('lessonId=$lessonId');
    if (params.isNotEmpty) route += '?${params.join('&')}';
    return route;
  }

  static String getQuizAttemptRoute(String testId, {String? courseId, String? lessonId}) {
    var route = '$_quiz/$testId/attempt';
    final params = <String>[];
    if (courseId != null) params.add('courseId=$courseId');
    if (lessonId != null) params.add('lessonId=$lessonId');
    if (params.isNotEmpty) route += '?${params.join('&')}';
    return route;
  }

  static String getQuizResultsRoute(String testId) => '$_quiz/$testId/results';

  /// FIXED: Complete GoRouter routes with all live class functionality
  static List<RouteBase> getAllRoutes() {
    return [
      // Quiz routes (moved to top for priority)
      GoRoute(
        path: quizAttemptRoute,
        builder: (context, state) {
          final testId = state.pathParameters['testId']!;
          final courseId = state.uri.queryParameters['courseId'];
          final lessonId = state.uri.queryParameters['lessonId'];
          return QuizAttemptPage(
            testId: testId,
            courseId: courseId,
            lessonId: lessonId,
          );
        },
      ),

      GoRoute(
        path: quizResultsRoute,
        builder: (context, state) {
          final testId = state.pathParameters['testId']!;
          final courseId = state.uri.queryParameters['courseId'];
          final lessonId = state.uri.queryParameters['lessonId'];
          return QuizResultsPage(
            testId: testId,
            courseId: courseId,
            lessonId: lessonId,
          );
        },
      ),

      // Courses routes
      GoRoute(
        path: coursesRoute,
        builder: (context, state) => const CoursesPage(),
      ),

      GoRoute(
        path: courseDetailRoute,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return CourseIntroPage(courseId: courseId);
        },
      ),

      GoRoute(
        path: coursePlayerRoute,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          final lessonId = state.pathParameters['lessonId']!;
          return CoursePlayerPage(courseId: courseId, lessonId: lessonId);
        },
      ),

      GoRoute(
        path: coursePlayerSimpleRoute,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return CoursePlayerPage(courseId: courseId);
        },
      ),

      GoRoute(
        path: coursesByCategoryRoute,
        builder: (context, state) {
          final categoryName = state.pathParameters['categoryName']!;
          return CategoryCoursesPage(
            categoryName: Uri.decodeComponent(categoryName),
          );
        },
      ),

      // FIXED: Complete live class routes
      GoRoute(
        path: liveClassesRoute,
        builder: (context, state) => const LiveClassesPage(),
      ),

      GoRoute(
        path: liveClassDetailRoute,
        builder: (context, state) {
          final liveClassId = state.pathParameters['liveClassId']!;
          return LiveClassIntroPage(liveClassId: liveClassId);
        },
        routes: [
          // CRITICAL: Missing live class join route - this was causing your error
          GoRoute(
            path: 'join',
            builder: (context, state) {
              final liveClassId = state.pathParameters['liveClassId']!;
              return LiveClassJoinPage(
                liveClassId: liveClassId,
              );
            },
          ),
        ],
      ),

      // Assignment routes
      GoRoute(
        path: assignmentRoute,
        builder: (context, state) {
          final assignmentId = state.pathParameters['assignmentId']!;
          final courseId = state.uri.queryParameters['courseId'];
          final lessonId = state.uri.queryParameters['lessonId'];
          return AssignmentPage(
            assignmentId: assignmentId,
            courseId: courseId,
            lessonId: lessonId,
          );
        },
      ),

      // Generic assessment route
      GoRoute(
        path: assessmentRoute,
        builder: (context, state) {
          final assessmentId = state.pathParameters['assessmentId']!;
          final type = state.pathParameters['type']!;
          final courseId = state.uri.queryParameters['courseId'];
          final lessonId = state.uri.queryParameters['lessonId'];
          
          switch (type) {
            case 'assignment':
              return AssignmentPage(
                assignmentId: assessmentId,
                courseId: courseId,
                lessonId: lessonId,
              );
            case 'quiz':
            case 'exam':
              return PracticeExercisePage(
                exerciseId: assessmentId,
                courseId: courseId,
                lessonId: lessonId,
              );
            default:
              throw Exception('Unknown assessment type: $type');
          }
        },
      ),

      // Exercise routes
      GoRoute(
        path: exerciseRoute,
        builder: (context, state) {
          final exerciseId = state.pathParameters['exerciseId']!;
          final courseId = state.uri.queryParameters['courseId'];
          final lessonId = state.uri.queryParameters['lessonId'];
          return PracticeExercisePage(
            exerciseId: exerciseId,
            courseId: courseId,
            lessonId: lessonId,
          );
        },
        routes: [
          GoRoute(
            path: 'attempt',
            builder: (context, state) {
              final exerciseId = state.pathParameters['exerciseId']!;
              return ExerciseAttemptPage(exerciseId: exerciseId);
            },
          ),
          GoRoute(
            path: 'results',
            builder: (context, state) {
              final exerciseId = state.pathParameters['exerciseId']!;
              return ExerciseResultsPage(exerciseId: exerciseId);
            },
          ),
        ],
      ),

      // Search route
      GoRoute(
        path: searchRoute,
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

      // Coaching center routes
      GoRoute(
        path: coachingCentersRoute,
        builder: (context, state) => const CoachingCentersPage(),
      ),

      GoRoute(
        path: coachingCenterDetailRoute,
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
    ];
  }

  // FIXED: Route validation helper
  static bool isValidRoute(String route) {
    final allRoutes = getAllRoutes();
    // This is a simplified check - in production you'd want more sophisticated validation
    return route.startsWith('/');
  }

  // FIXED: Debug helper to list all routes
  static List<String> getAllRoutePaths() {
    return [
      coursesRoute,
      courseDetailRoute,
      coursePlayerRoute,
      coursePlayerSimpleRoute,
      coursesByCategoryRoute,
      liveClassesRoute,
      liveClassDetailRoute,
      liveClassJoinRoute,
      coachingCentersRoute,
      coachingCenterDetailRoute,
      coachingCenterTeachersRoute,
      coachingCenterTeacherDetailRoute,
      assignmentRoute,
      assessmentRoute,
      exerciseRoute,
      exerciseAttemptRoute,
      exerciseResultsRoute,
      quizAttemptRoute,
      quizResultsRoute,
      searchRoute,
    ];
  }
}
