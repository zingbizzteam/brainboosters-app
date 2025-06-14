// app_router.dart
import 'package:brainboosters_app/ui/navigation/student_routes/student_routes.dart';
import 'package:brainboosters_app/ui/navigation/auth_routes.dart';
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
    ],
  );

  // app_router.dart - Fixed redirect logic
static Future<String?> _redirectLogic(
  BuildContext context,
  GoRouterState state,
) async {
  final session = Supabase.instance.client.auth.currentSession;
  final isLoggedIn = session != null;
  final currentPath = state.uri.path;

  print('Redirect check - Path: $currentPath, LoggedIn: $isLoggedIn');

  // If not logged in and trying to access protected routes
  if (!isLoggedIn) {
    // Allow access to onboarding and auth routes
    if (currentPath == onboarding || 
        currentPath.startsWith('/auth') || 
        AuthRoutes.routes.any((route) => route.path == currentPath)) {
      return null; // Allow navigation
    }
    return onboarding; // Redirect to onboarding
  }

  // If logged in and on onboarding page, redirect based on user status
  if (isLoggedIn && currentPath == onboarding) {
    bool isNew = await isNewUser(session!.user.id);
    if (isNew) {
      return AuthRoutes.userSetup;
    } else {
      return StudentRoutes.home;
    }
  }

  // For all other cases when logged in, allow navigation to proceed
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

// Move this to your authentication service or provider
Future<bool> isNewUser(String userId) async {
  try {
    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response == null;
  } on PostgrestException catch (e) {
    debugPrint('Profile check error: $e');
    return true;
  } catch (e) {
    debugPrint('Unexpected error: $e');
    return true;
  }
}
