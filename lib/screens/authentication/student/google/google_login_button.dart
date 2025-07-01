// widgets/google_login_button.dart
import 'package:brainboosters_app/ui/navigation/auth_routes.dart';
import 'package:brainboosters_app/ui/navigation/student_routes/student_routes.dart';
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
      const webClientId =
          '46751973266-6kpsbkqs8ua6r80jb4dveh36vq6ofq0a.apps.googleusercontent.com';
      const iosClientId =
          '46751973266-husicesg2ic79fp7sth8phha2bgvf1e8.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
        scopes: ['email', 'profile'],
      );

      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
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
      // Check if user profile exists (should be auto-created by trigger)
      final userProfile = await _getUserProfile(user.id);
      
      if (userProfile == null) {
        // This shouldn't happen if trigger is working, but handle it
        debugPrint('User profile not found, trigger might have failed');
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile setup required. Please complete registration.'),
            backgroundColor: Colors.orange,
          ),
        );
        context.go(AuthRoutes.userSetup);
        return;
      }

      // Check if user is a student (only students allowed)
      if (userProfile['user_type'] != 'student') {
        await _supabase.auth.signOut();
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Access denied. Only students can access this app. '
              'Your account type: ${userProfile['user_type']}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      // Check if student profile exists
      final studentProfile = await _getStudentProfile(user.id);
      
      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            studentProfile == null 
              ? 'Welcome! Please complete your profile setup.'
              : 'Welcome back, ${userProfile['first_name']}!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate based on profile completion
      if (studentProfile == null || !userProfile['onboarding_completed']) {
        context.go(AuthRoutes.userSetup);
      } else {
        context.go(StudentRoutes.home);
      }

    } catch (e) {
      debugPrint('Navigation error: $e');
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred during sign in. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Get user profile from user_profiles table
  Future<Map<String, dynamic>?> _getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select('user_type, first_name, last_name, onboarding_completed, is_active')
          .eq('id', userId)
          .single();
      
      return response;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  // Get student profile from students table
  Future<Map<String, dynamic>?> _getStudentProfile(String userId) async {
    try {
      final response = await _supabase
          .from('students')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      debugPrint('Error fetching student profile: $e');
      return null;
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
      } else if (error.toString().contains('already_in_use')) {
        errorMessage = 'This Google account is already linked to another user.';
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
    return Container(
      decoration: BoxDecoration(
        border: const Border(
          bottom: BorderSide(color: Color(0xFFCCCCCC), width: 2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                )
              : Image.asset(
                  'assets/icons/google_icon.png',
                  width: 20,
                  height: 20,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.g_mobiledata,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
          label: Text(
            _isLoading ? 'Signing in...' : 'Continue with Google',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: _isLoading ? null : _signInWithGoogle,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}
