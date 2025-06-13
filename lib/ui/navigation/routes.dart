// routes.dart

import 'package:brainboosters_app/ui/navigation/dashboard_routes.dart';
import 'package:brainboosters_app/ui/navigation/auth_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../screens/onboarding/onboarding_screen.dart';

class Routes {
  static const String onboarding = '/';

  static final _authStateListener = SupabaseAuthStateListener();

  static final router = GoRouter(
    initialLocation: onboarding,
    refreshListenable: _authStateListener,
    redirect: _redirectLogic,
    routes: [
      GoRoute(path: onboarding, builder: (_, __) => const OnboardingScreen()),
      ...AuthRoutes.routes,
      ...DashboardRoutes.routes,
    ],
  );

  static Future<String?> _redirectLogic(
    BuildContext context,
    GoRouterState state,
  ) async {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    final isOnAuthPage = state.uri.toString().startsWith(
      AuthRoutes.authSelection,
    );

    // If not logged in  → redirect to onboarding
    if (!isLoggedIn && !isOnAuthPage) return onboarding;

    if (isLoggedIn && isOnAuthPage) {
      bool isNew = await isNewUser(session.user.id);
      print(isNew);
      if (isNew) {
        return AuthRoutes.userSetup;
      } else {
        return DashboardRoutes.home;
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
