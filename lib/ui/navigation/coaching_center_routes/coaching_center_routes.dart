// ui/navigation/coaching_center_routes/coaching_center_routes.dart
import 'package:brainboosters_app/screens/coaching_center/courses/widgets/assign_faculty_page.dart';
import 'package:brainboosters_app/screens/coaching_center/dashboard/coaching_center_dashboard_page.dart';
import 'package:brainboosters_app/screens/coaching_center/faculty/coaching_center_faculty_page.dart';
import 'package:brainboosters_app/screens/coaching_center/students/coaching_center_students_page.dart';
import 'package:brainboosters_app/screens/coaching_center/courses/coaching_center_courses_page.dart';
import 'package:brainboosters_app/screens/coaching_center/courses/create_course_page.dart';
import 'package:brainboosters_app/screens/coaching_center/courses/edit_course_page.dart';
import 'package:brainboosters_app/screens/coaching_center/courses/course_details_page.dart';
import 'package:brainboosters_app/screens/coaching_center/courses/course_content_page.dart';
import 'package:brainboosters_app/screens/coaching_center/analytics/coaching_center_analytics_page.dart';
import 'package:brainboosters_app/screens/coaching_center/settings/coaching_center_settings_page.dart';
import 'package:brainboosters_app/screens/coaching_center/coaching_center_mainscreen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class CoachingCenterRoutes {
  // Main navigation routes
  static const String dashboard = '/coaching-center/dashboard';
  static const String faculty = '/coaching-center/faculty';
  static const String students = '/coaching-center/students';
  static const String courses = '/coaching-center/courses';
  static const String analytics = '/coaching-center/analytics';
  static const String settings = '/coaching-center/settings';

  // Course management routes
  static const String createCourse = '/coaching-center/courses/create';
  static const String editCourse = '/coaching-center/courses/edit';
  static const String courseDetails = '/coaching-center/courses/details';
  static const String courseContent = '/coaching-center/courses/content';
  static const String assignFaculty = '/coaching-center/courses/assign-faculty';

  static final StatefulShellRoute statefulRoute = StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) => CoachingCenterMainScreen(shell: navigationShell),
    branches: [
      // Branch 0: Dashboard
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: dashboard,
            builder: (context, state) => const CoachingCenterDashboardPage(),
          ),
        ],
      ),
      
      // Branch 1: Faculty Management
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: faculty,
            builder: (context, state) => const CoachingCenterFacultyPage(),
          ),
        ],
      ),
      
      // Branch 2: Students
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: students,
            builder: (context, state) => const CoachingCenterStudentsPage(),
          ),
        ],
      ),
      
      // Branch 3: Courses with nested routes
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: courses,
            builder: (context, state) => const CoachingCenterCoursesPage(),
            routes: [
              // Create Course
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateCoursePage(),
              ),
              
              // Edit Course
              GoRoute(
                path: 'edit/:courseId',
                builder: (context, state) {
                  final courseId = state.pathParameters['courseId']!;
                  final course = state.extra as Map<String, dynamic>?;
                  return EditCoursePage(
                    course: course ?? {'id': courseId},
                  );
                },
              ),
              
              // Course Details
              GoRoute(
                path: 'details/:courseId',
                builder: (context, state) {
                  final courseId = state.pathParameters['courseId']!;
                  return CourseDetailsPage(courseId: courseId);
                },
                routes: [
                  // Course Content Management
                  GoRoute(
                    path: 'content',
                    builder: (context, state) {
                      final courseId = state.pathParameters['courseId']!;
                      final courseTitle = state.uri.queryParameters['title'] ?? 'Course';
                      return CourseContentPage(
                        courseId: courseId,
                        courseTitle: courseTitle,
                      );
                    },
                  ),
                  
                  // Assign Faculty
                  GoRoute(
                    path: 'assign-faculty',
                    builder: (context, state) {
                      final courseId = state.pathParameters['courseId']!;
                      final courseTitle = state.uri.queryParameters['title'] ?? 'Course';
                      return AssignFacultyPage(
                        courseId: courseId,
                        courseTitle: courseTitle,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      
      // Branch 4: Analytics
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: analytics,
            builder: (context, state) => const CoachingCenterAnalyticsPage(),
          ),
        ],
      ),
      
      // Branch 5: Settings
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: settings,
            builder: (context, state) => const CoachingCenterSettingsPage(),
          ),
        ],
      ),
    ],
  );

  // Helper methods for navigation
  static void goToDashboard(BuildContext context) {
    context.go(dashboard);
  }

  static void goToFaculty(BuildContext context) {
    context.go(faculty);
  }

  static void goToStudents(BuildContext context) {
    context.go(students);
  }

  static void goToCourses(BuildContext context) {
    context.go(courses);
  }

  static void goToAnalytics(BuildContext context) {
    context.go(analytics);
  }

  static void goToSettings(BuildContext context) {
    context.go(settings);
  }

  // Course-specific navigation helpers
  static void goToCreateCourse(BuildContext context) {
    context.go('$courses/create');
  }

  static void goToEditCourse(BuildContext context, String courseId, Map<String, dynamic> course) {
    context.go('$courses/edit/$courseId', extra: course);
  }

  static void goToCourseDetails(BuildContext context, String courseId) {
    context.go('$courses/details/$courseId');
  }

  static void goToCourseContent(BuildContext context, String courseId, String courseTitle) {
    context.go('$courses/details/$courseId/content?title=${Uri.encodeComponent(courseTitle)}');
  }

  static void goToAssignFaculty(BuildContext context, String courseId, String courseTitle) {
    context.go('$courses/details/$courseId/assign-faculty?title=${Uri.encodeComponent(courseTitle)}');
  }

  // Push navigation for modal-like behavior
  static void pushCreateCourse(BuildContext context) {
    context.push('$courses/create');
  }

  static void pushEditCourse(BuildContext context, String courseId, Map<String, dynamic> course) {
    context.push('$courses/edit/$courseId', extra: course);
  }

  static void pushCourseDetails(BuildContext context, String courseId) {
    context.push('$courses/details/$courseId');
  }

  static void pushCourseContent(BuildContext context, String courseId, String courseTitle) {
    context.push('$courses/details/$courseId/content?title=${Uri.encodeComponent(courseTitle)}');
  }

  static void pushAssignFaculty(BuildContext context, String courseId, String courseTitle) {
    context.push('$courses/details/$courseId/assign-faculty?title=${Uri.encodeComponent(courseTitle)}');
  }
}
