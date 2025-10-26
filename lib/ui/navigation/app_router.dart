// app_router.dart

import 'package:brainboosters_app/ui/navigation/student_routes/student_routes.dart';
import 'package:brainboosters_app/ui/navigation/auth_routes.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import 'package:brainboosters_app/ui/navigation/web_routes/web_routes.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AppRouter {
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static final _authStateListener = SupabaseAuthStateListener();

  static final router = GoRouter(
    refreshListenable: _authStateListener,
    redirect: _redirectLogic,
    routes: [
      // Platform-specific routes
      if (kIsWeb)
        ...WebRoutes.routes, // This will wrap ALL web routes with sidebar

      if (!kIsWeb) ...[
        GoRoute(
          path: '/',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        // Mobile student routes (existing StatefulNavigationShell)
        StudentRoutes.statefulRoute,
      ],

      ...AuthRoutes.routes,

      // Conditional student routes based on platform
      if (!kIsWeb) StudentRoutes.statefulRoute,
      if (kIsWeb) ...StudentRoutes.getWebRoutes(),

      ...StudentRoutes.getAdditionalRoutes(),
      ...CommonRoutes.getAllRoutes(),
    ],
  );

  static Future<String?> _redirectLogic(
    BuildContext context,
    GoRouterState state,
  ) async {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    final currentPath = state.uri.path;
    final queryParams = state.uri.queryParameters; // ADD THIS LINE

    // ADD THIS: Check for OAuth callback
    final isOAuthCallback =
        queryParams.containsKey('code') ||
        queryParams.containsKey('access_token');

    if (kIsWeb) {
      return _handleWebRedirection(
        currentPath,
        isLoggedIn,
        session?.user.id,
        isOAuthCallback, // ADD THIS PARAMETER
      );
    }

    return _handleMobileRedirection(currentPath, isLoggedIn, session?.user.id);
  }

  static Future<String?> _handleWebRedirection(
    String currentPath,
    bool isLoggedIn,
    String? userId,
    bool isOAuthCallback,
  ) async {
    // CRITICAL FIX: Handle OAuth callback when logged in
    if (isOAuthCallback && isLoggedIn && currentPath.startsWith('/auth')) {
      debugPrint('🔄 OAuth callback detected - redirecting logged-in user');
      if (userId != null) {
        final redirectPath = await _getRedirectForLoggedInUser(userId);
        return redirectPath ?? StudentRoutes.home;
      }
      return StudentRoutes.home;
    }

    final publicWebRoutes = [
      '/',
      '/courses',
      '/live-classes',
      '/coaching-centers',
      '/search',
    ];

    if (publicWebRoutes.any((route) => currentPath.startsWith(route))) {
      return null;
    }

   if (currentPath.startsWith('/auth')) {
  // If logged in and NOT an OAuth callback, redirect away
  if (isLoggedIn && userId != null && !isOAuthCallback) {
    debugPrint('🔄 Logged in user trying to access /auth - redirecting');
    final redirectPath = await _getRedirectForLoggedInUser(userId);
    return redirectPath ?? StudentRoutes.home;
  }
  // Not logged in or OAuth callback - allow access
  return null;
}

    final protectedRoutes = [
      '/home',
      '/profile',
      '/settings',
      '/notifications',
    ];

    if (protectedRoutes.any((route) => currentPath.startsWith(route))) {
      if (!isLoggedIn) {
        return '/auth';
      }

      if (userId != null) {
        final redirectPath = await _getRedirectForLoggedInUser(userId);
        if (redirectPath != null && redirectPath != StudentRoutes.home) {
          return redirectPath;
        }
      }
      return null;
    }

    return null;
  }

  static Future<String?> _handleMobileRedirection(
    String currentPath,
    bool isLoggedIn,
    String? userId,
  ) async {
    // Existing mobile logic
    if (!isLoggedIn) {
      if (currentPath == onboarding || currentPath.startsWith('/auth')) {
        return null;
      }
      return onboarding;
    }

    if (currentPath == onboarding || currentPath == '/') {
      return await _getRedirectForLoggedInUser(userId!);
    }

    return null;
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
