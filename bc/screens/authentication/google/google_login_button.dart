import 'package:brainboosters_app/screens/authentication/email/email_login_page.dart';
import 'package:brainboosters_app/ui/navigation/auth_routes.dart';
import 'package:brainboosters_app/ui/navigation/student_routes/student_routes.dart';
import 'package:brainboosters_app/ui/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class GoogleAuthButton extends StatefulWidget {
  const GoogleAuthButton({super.key});

  @override
  State<GoogleAuthButton> createState() => _GoogleAuthButtonState();
}

class _GoogleAuthButtonState extends State<GoogleAuthButton> {
  bool _isLoading = false;
  final _supabase = Supabase.instance.client;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        await _webSignIn();
      } else {
        await _nativeSignIn();
      }
    } catch (e) {
      _handleError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _webSignIn() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb
          ? null
          : 'https://ipnhjkbgxlhjptviiqcq.supabase.co/auth/v1/callback',
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
    );
  }

  Future<void> _nativeSignIn() async {
    try {
      // Client IDs from your configuration
      const webClientId =
          '46751973266-6kpsbkqs8ua6r80jb4dveh36vq6ofq0a.apps.googleusercontent.com';
      const iosClientId =
          '46751973266-husicesg2ic79fp7sth8phha2bgvf1e8.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId, // For iOS
        serverClientId: webClientId, // For Android
        scopes: ['email', 'profile'],
      );

      // Sign out first to ensure clean state
      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        debugPrint('User cancelled Google sign-in');
        return;
      }

      final googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Google authentication failed: Missing tokens');
      }

      debugPrint('Google sign-in successful, authenticating with Supabase...');

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );

      if (response.user != null) {
        debugPrint('Supabase authentication successful');
        await _handlePostLoginNavigation(response.user!);
      } else {
        throw Exception('Supabase authentication failed: No user returned');
      }
    } catch (e) {
      debugPrint('Native sign-in error: $e');
      rethrow;
    }
  }

  Future<void> _handlePostLoginNavigation(User user) async {
    try {
      final isNew = await isNewUser(user.id);

      if (mounted) {
        isNew
            ? context.go(AuthRoutes.userSetup)
            : context.go(StudentRoutes.home);
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
      // Handle navigation error
    }
  }

  void _handleError(dynamic error) {
    debugPrint('Google sign in error: $error');
    if (mounted) {
      String errorMessage = 'Sign in failed';

      if (error.toString().contains('ApiException: 10')) {
        errorMessage = 'Configuration error. Please check your setup.';
      } else if (error.toString().contains('network_error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (error.toString().contains('sign_in_canceled')) {
        errorMessage = 'Sign in was cancelled';
      } else if (error.toString().contains('sign_in_failed')) {
        errorMessage = 'Google sign in failed. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Image.asset(
        'assets/icons/google_icon.png',
        width: 20,
        height: 20,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.error, color: Colors.red),
      ),
      label: Text(_isLoading ? 'Signing in...' : 'Sign in with Google'),
      onPressed: _isLoading ? null : _signInWithGoogle,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
