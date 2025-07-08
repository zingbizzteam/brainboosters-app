// app_router.dart

import 'package:brainboosters_app/ui/navigation/student_routes/student_routes.dart';
import 'package:brainboosters_app/ui/navigation/auth_routes.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../screens/onboarding/onboarding_screen.dart';

class AppRouter {
  static const String onboarding = '/';
  static final _authStateListener = SupabaseAuthStateListener();

  static final router = GoRouter(
    refreshListenable: _authStateListener,
    // debugLogDiagnostics: true, // Enable for debugging
    redirect: _redirectLogic,
    routes: [
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      ...AuthRoutes.routes,
      StudentRoutes.statefulRoute,
      // Include additional student routes
      ...StudentRoutes.getAdditionalRoutes(),
      ...CommonRoutes.getAllRoutes(),
    ],
  );

  // ... rest of your redirect logic remains the same
  static Future<String?> _redirectLogic(
    BuildContext context,
    GoRouterState state,
  ) async {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    final currentPath = state.uri.path;

    debugPrint('Redirect check - Path: $currentPath, LoggedIn: $isLoggedIn');

    // If not logged in, allow only onboarding and auth routes
    if (!isLoggedIn) {
      if (currentPath == onboarding || currentPath.startsWith('/auth')) {
        return null; // Allow access
      }
      return onboarding; // Redirect to onboarding
    }

    // If logged in and on onboarding, check user setup status
    if (currentPath == onboarding) {
      return await _getRedirectForLoggedInUser(session!.user.id);
    }

    return null; // No redirect needed
  }

  static Future<String?> _getRedirectForLoggedInUser(String userId) async {
    try {
      // Fetch user_profile and student in a single go
      final userProfile = await Supabase.instance.client
          .from('user_profiles')
          .select(
            'user_type, onboarding_completed, first_name, last_name, phone, gender, date_of_birth',
          )
          .eq('id', userId)
          .maybeSingle();

      final studentProfile = await Supabase.instance.client
          .from('students')
          .select('id, grade_level, learning_goals, preferred_learning_style')
          .eq('user_id', userId)
          .maybeSingle();

      // If missing profile, must setup
      if (userProfile == null) return AuthRoutes.userSetup;

      // Only allow students
      if (userProfile['user_type'] != 'student') {
        await Supabase.instance.client.auth.signOut();
        return onboarding;
      }

      // If missing student record, must setup
      if (studentProfile == null) return AuthRoutes.userSetup;

      // Check for required fields in user_profiles
      final requiredUserFields = [
        userProfile['first_name'],
        userProfile['last_name'],
        userProfile['phone'],
        userProfile['gender'],
        userProfile['date_of_birth'],
      ];
      if (requiredUserFields.any(
        (f) => f == null || (f is String && f.trim().isEmpty),
      )) {
        return AuthRoutes.userSetup;
      }

      // Check for required fields in students
      final requiredStudentFields = [
        studentProfile['grade_level'],
        studentProfile['learning_goals'],
        studentProfile['preferred_learning_style'],
      ];
      if (requiredStudentFields.any(
        (f) =>
            f == null ||
            (f is String && f.trim().isEmpty) ||
            (f is List && f.isEmpty),
      )) {
        return AuthRoutes.userSetup;
      }

      // Finally, check onboarding_completed
      if (!userProfile['onboarding_completed']) return AuthRoutes.userSetup;

      return StudentRoutes.home;
    } catch (e) {
      debugPrint('Redirect error: $e');
      return AuthRoutes.userSetup;
    }
  }
}

class SupabaseAuthStateListener extends ChangeNotifier {
  SupabaseAuthStateListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      notifyListeners();
    });
  }
}
