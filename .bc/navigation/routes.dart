// routes.dart

import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:brainboosters_app/ui/navigation/student_routes/student_routes.dart';
import 'package:brainboosters_app/ui/navigation/auth_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../screens/onboarding/onboarding_screen.dart';

class Routes {
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
    ...StudentRoutes.routes, // CommonRoutes are now included here
  ],
);

  static Future<String?> _redirectLogic(
    BuildContext context,
    GoRouterState state,
  ) async {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
  
    // If not logged in   → redirect to onboarding
    if (!isLoggedIn) return onboarding;
    // If  logged in  → redirect to dashboard or user setup
    bool isNew = await isNewUser(session.user.id);
    if (isLoggedIn && isNew) {
      return AuthRoutes.userSetup;
    } else {
      return StudentRoutes.home;
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
