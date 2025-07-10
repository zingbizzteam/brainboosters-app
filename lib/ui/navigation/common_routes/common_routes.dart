// common_routes/common_routes.dart - FIXED VERSION
import 'package:brainboosters_app/screens/common/coaching_centers/teachers/teacher_details/teacher_details_page.dart';
import 'package:brainboosters_app/screens/common/courses/assesment/assesment_page.dart';
import 'package:brainboosters_app/screens/common/courses/assesment/quiz_attempt_page.dart';
import 'package:brainboosters_app/screens/common/courses/assesment/quiz_results_page.dart';
import 'package:brainboosters_app/screens/common/courses/category_courses/category_courses_page.dart';
import 'package:brainboosters_app/screens/common/courses/course_player/course_player_page.dart';
import 'package:brainboosters_app/screens/common/courses/exercises/exercise_attempt_page.dart';
import 'package:brainboosters_app/screens/common/courses/exercises/exercise_results_page.dart';
import 'package:brainboosters_app/screens/common/courses/exercises/practice_exercise_page.dart';
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
  // Main navigation route constants
  static const String courses = '/courses';
  static const String courseDetail = '/course/:courseId';
  static const String coursesByCategory = '/courses/category/:categoryName';
  static const String searchCourses = '/search-courses';
  static const String liveClasses = '/live-classes';
  static const String liveClassDetail = '/live-class/:liveClassId';
  static const String coachingCenters = '/coaching-centers';
  static const String coachingCenterDetail = '/coaching-center/:centerId';
  static const String coursePlayer = '/course/:courseId/lesson/:lessonId';

  // FIXED: Top-level assessment routes (not nested)
  static const String assignmentDetail = '/assignment/:assignmentId';
  static const String assessmentDetail = '/assessment/:assessmentId';
  static const String exerciseDetail = '/exercise/:exerciseId';
  static const String exerciseAttempt = '/exercise/:exerciseId/attempt';
  static const String exerciseResults = '/exercise/:exerciseId/results';
  static const String quizDetail = '/quiz/:quizId';
  static const String quizAttempt = '/quiz/:quizId/attempt';
  static const String quizResults = '/quiz/:quizId/results';

  // Teacher routes nested under coaching centers
  static const String coachingCenterTeachers =
      '/coaching-center/:centerId/teachers';
  static const String coachingCenterTeacherDetail =
      '/coaching-center/:centerId/teacher/:teacherId';
  static const String searchRoute = '/search';

  // Helper methods for generating dynamic routes
  static String getCourseDetailRoute(String courseId) => '/course/$courseId';
  static String getLiveClassDetailRoute(String liveClassId) =>
      '/live-class/$liveClassId';
  static String getCoachingCenterDetailRoute(String centerId) =>
      '/coaching-center/$centerId';
  static String getSearchCoursesRoute(String query) =>
      '/search-courses?q=${Uri.encodeComponent(query)}';
  static String getCoursesByCategoryRoute(String categoryName) =>
      '/courses/category/${Uri.encodeComponent(categoryName)}';
  static String getCoachingCenterTeachersRoute(String centerId) =>
      '/coaching-center/$centerId/teachers';
  static String getCoachingCenterTeacherDetailRoute(
    String centerId,
    String teacherId,
  ) => '/coaching-center/$centerId/teacher/$teacherId';

  // FIXED: Assessment route helpers
  static String getAssignmentRoute(
    String assignmentId, {
    String? courseId,
    String? lessonId,
  }) {
    var route = '/assignment/$assignmentId';
    final params = <String>[];
    if (courseId != null) params.add('courseId=$courseId');
    if (lessonId != null) params.add('lessonId=$lessonId');
    if (params.isNotEmpty) route += '?${params.join('&')}';
    return route;
  }

  static String getAssessmentRoute(
    String assessmentId,
    String type, {
    String? courseId,
    String? lessonId,
  }) {
    var route = '/$type/$assessmentId';
    final params = <String>[];
    if (courseId != null) params.add('courseId=$courseId');
    if (lessonId != null) params.add('lessonId=$lessonId');
    if (params.isNotEmpty) route += '?${params.join('&')}';
    return route;
  }

  /// FIXED: All GoRouter routes for common navigation
  static List<RouteBase> getAllRoutes() {
    return [

      GoRoute(
      path: '/quiz/:testId/attempt',
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
    
    // Quiz results route
    GoRoute(
      path: '/quiz/:testId/results',
      builder: (context, state) {
        final testId = state.pathParameters['testId']!;
        return QuizResultsPage(testId: testId);
      },
    ),
      // Courses main page
      GoRoute(path: courses, builder: (context, state) => const CoursesPage()),

      // Course details
      GoRoute(
        path: '/course/:courseId',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return CourseIntroPage(courseId: courseId);
        },
      ),

      // Course player
      GoRoute(
        path: '/course/:courseId/lesson/:lessonId',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          final lessonId = state.pathParameters['lessonId']!;
          return CoursePlayerPage(courseId: courseId, lessonId: lessonId);
        },
      ),

      GoRoute(
        path: '/course/:courseId/player',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return CoursePlayerPage(courseId: courseId);
        },
      ),

      // FIXED: Top-level assignment routes
      GoRoute(
        path: '/assignment/:assignmentId',
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

      // FIXED: Generic assessment route
      GoRoute(
        path: '/assessment/:assessmentId/:type',
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
        path: '/exercise/:exerciseId',
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

      // Search page
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

      // Courses by category
      GoRoute(
        path: '/courses/category/:categoryName',
        builder: (context, state) {
          final categoryName = state.pathParameters['categoryName']!;
          return CategoryCoursesPage(
            categoryName: Uri.decodeComponent(categoryName),
          );
        },
      ),

      // Live Classes main page
      GoRoute(
        path: liveClasses,
        builder: (context, state) => const LiveClassesPage(),
      ),

      // Live Class details
      GoRoute(
        path: '/live-class/:liveClassId',
        builder: (context, state) {
          final liveClassId = state.pathParameters['liveClassId']!;
          return LiveClassIntroPage(liveClassId: liveClassId);
        },
      ),

      // Coaching Centers main page
      GoRoute(
        path: coachingCenters,
        builder: (context, state) => const CoachingCentersPage(),
      ),

      // Coaching Center details and nested teacher routes
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
}
