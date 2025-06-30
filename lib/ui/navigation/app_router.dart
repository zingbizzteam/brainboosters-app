// app_router.dart
import 'package:brainboosters_app/ui/navigation/student_routes/student_routes.dart';
import 'package:brainboosters_app/ui/navigation/auth_routes.dart';
import 'package:brainboosters_app/ui/navigation/admin_routes/admin_routes.dart';
import 'package:brainboosters_app/ui/navigation/coaching_center_routes/coaching_center_routes.dart';
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
    debugLogDiagnostics: true,
    redirect: _redirectLogic,
    routes: [
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      ...AuthRoutes.routes,
      StudentRoutes.statefulRoute,
      AdminRoutes.statefulRoute,
      CoachingCenterRoutes.statefulRoute,
      // Add standalone coaching center routes (without bottom nav)
      ...CoachingCenterRoutes.standaloneRoutes,
      // Add additional routes from CommonRoutes
      ...CommonRoutes.getAdditionalRoutes(),
    ],
  );

  static Future<String?> _redirectLogic(
    BuildContext context,
    GoRouterState state,
  ) async {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    final currentPath = state.uri.path;

    debugPrint('Redirect check - Path: $currentPath, LoggedIn: $isLoggedIn');

    // If not logged in and trying to access protected routes
    if (!isLoggedIn) {
      // Allow access to onboarding and auth routes
      if (currentPath == onboarding ||
          currentPath.startsWith('/auth') ||
          AuthRoutes.routes.any((route) => route.path == currentPath)) {
        return null;
      }
      return onboarding;
    }

    // If logged in and on onboarding page, redirect based on user status
    if (isLoggedIn && currentPath == onboarding) {
      // Check user type for proper redirection
      final userProfile = await getUserProfile(session.user.id);

      if (userProfile == null) {
        return AuthRoutes.userSetup;
      }

      // Redirect based on user type
      switch (userProfile['user_type']) {
        case 'admin':
          return AdminRoutes.dashboard;
        case 'coaching_center':
          return CoachingCenterRoutes.dashboard;
        case 'faculty':
          // Add faculty routes when ready
          return StudentRoutes.home; // Temporary
        default:
          return StudentRoutes.home;
      }
    }

    return null;
  }
}

class SupabaseAuthStateListener extends ChangeNotifier {
  SupabaseAuthStateListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      notifyListeners();
    });
  }
}

// Updated helper function to get user profile
Future<Map<String, dynamic>?> getUserProfile(String userId) async {
  try {
    final response = await Supabase.instance.client
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response;
  } on PostgrestException catch (e) {
    debugPrint('Profile check error: $e');
    return null;
  } catch (e) {
    debugPrint('Unexpected error: $e');
    return null;
  }
}

// Keep the old function for backward compatibility
Future<bool> isNewUser(String userId) async {
  final profile = await getUserProfile(userId);
  return profile == null;
}
