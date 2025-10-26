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

  /// Main Google sign-in entry point
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

  /// Web-specific Google sign-in
  Future<void> _webSignIn() async {
    try {
      debugPrint('🌐 Starting web Google sign-in');

      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb
            ? Uri.base.toString()
            : 'brainboosters://auth/callback',
        authScreenLaunchMode: LaunchMode.platformDefault,
      );

      // Web redirects automatically, so we don't handle post-login here
    } catch (e) {
      debugPrint('❌ Web sign-in error: $e');
      throw Exception('Web Google sign-in failed: $e');
    }
  }

  /// Native (iOS/Android) Google sign-in
  Future<void> _nativeSignIn() async {
    try {
      debugPrint('📱 Starting native Google sign-in');

      // Initialize Google Sign-In
      const webClientId =
          'YOUR_WEB_CLIENT_ID'; // TODO: Replace with actual client ID
      const iosClientId =
          'YOUR_IOS_CLIENT_ID'; // TODO: Replace with actual iOS client ID

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
      );

      // Trigger Google Sign-In flow
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('⚠️ Google sign-in cancelled by user');
        return;
      }

      debugPrint('✅ Google user obtained: ${googleUser.email}');

      // Get authentication tokens
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw Exception('No Access Token found');
      }
      if (idToken == null) {
        throw Exception('No ID Token found');
      }

      // Sign in to Supabase with Google tokens
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw Exception('Google sign-in failed: No user returned');
      }

      debugPrint('✅ Supabase authentication successful');

      // Handle post-login navigation
      if (!mounted) return;
      await _handlePostLoginNavigation(response.user!);
    } catch (e) {
      debugPrint('❌ Native sign-in error: $e');
      throw Exception('Native Google sign-in failed: $e');
    }
  }

  /// Handle post-login navigation with comprehensive checks
  Future<void> _handlePostLoginNavigation(User user) async {
    try {
      debugPrint('🔍 Checking user profile for: ${user.email}');

      // Get or wait for profile creation (trigger might have slight delay)
      final userProfile = await _getUserProfileWithRetry(user.id);

      if (!mounted) return;

      if (userProfile == null) {
        debugPrint(
          '⚠️ User profile not found after retries - redirecting to setup',
        );
        _showSuccess('Welcome! Let\'s set up your profile.');
        context.go(AuthRoutes.userSetup);
        return;
      }

      // CRITICAL: Check if user is a student (ONLY students allowed)
      if (userProfile['user_type'] != 'student') {
        debugPrint(
          '❌ Access denied: Not a student (user_type: ${userProfile['user_type']})',
        );
        await _supabase.auth.signOut();

        if (!mounted) return;

        // Show specific error based on user type
        String errorMsg = 'Access denied. This app is for students only.';
        if (userProfile['user_type'] == 'teacher') {
          errorMsg =
              'Teachers should use the Teacher Portal. This app is for students only.';
        } else if (userProfile['user_type'] == 'coaching_center') {
          errorMsg =
              'Coaching centers should use the Admin Portal. This app is for students only.';
        }

        _showError(errorMsg);
        return;
      }

      // Check if account is active
      if (userProfile['is_active'] == false) {
        await _supabase.auth.signOut();
        if (!mounted) return;
        _showError(
          'Your account has been deactivated. Please contact support.',
        );
        return;
      }

      // Check if student profile exists
      final studentProfile = await _getStudentProfileWithRetry(user.id);

      if (!mounted) return;

      debugPrint('✅ Google login successful - Student verified');

      _showSuccess('Welcome, ${userProfile['first_name'] ?? 'Student'}!');

      // Navigate based on profile completion
      if (studentProfile == null ||
          userProfile['onboarding_completed'] != true) {
        debugPrint('➡️ Redirecting to user setup (onboarding incomplete)');
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) context.go(AuthRoutes.userSetup);
      } else {
        debugPrint('➡️ Redirecting to home');
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) context.go(StudentRoutes.home);
      }
    } catch (e) {
      debugPrint('❌ Post-login navigation error: $e');
      if (mounted) {
        _showError('Failed to load profile. Please try again.');
      }
    }
  }

  /// Get user profile with retry logic (database trigger might have delay)
  Future<Map<String, dynamic>?> _getUserProfileWithRetry(String userId) async {
    int attempts = 0;
    const maxAttempts = 5;
    const delay = Duration(milliseconds: 500);

    while (attempts < maxAttempts) {
      try {
        final response = await _supabase
            .from('user_profiles')
            .select(
              'user_type, first_name, last_name, onboarding_completed, is_active, email_verified',
            )
            .eq('id', userId)
            .maybeSingle();

        if (response != null) {
          debugPrint('✅ User profile found (attempt ${attempts + 1})');
          return response;
        }

        attempts++;
        if (attempts < maxAttempts) {
          debugPrint(
            '⏳ Profile not found, retrying... (attempt $attempts/$maxAttempts)',
          );
          await Future.delayed(delay);
        }
      } catch (e) {
        debugPrint('⚠️ Error fetching profile (attempt ${attempts + 1}): $e');
        attempts++;
        if (attempts < maxAttempts) {
          await Future.delayed(delay);
        }
      }
    }

    debugPrint('❌ Failed to fetch user profile after $maxAttempts attempts');
    return null;
  }

  /// Get student profile with retry logic
  Future<Map<String, dynamic>?> _getStudentProfileWithRetry(
    String userId,
  ) async {
    int attempts = 0;
    const maxAttempts = 5;
    const delay = Duration(milliseconds: 500);

    while (attempts < maxAttempts) {
      try {
        final response = await _supabase
            .from('students')
            .select('*')
            .eq('user_id', userId)
            .maybeSingle();

        if (response != null) {
          debugPrint('✅ Student profile found (attempt ${attempts + 1})');
          return response;
        }

        attempts++;
        if (attempts < maxAttempts) {
          debugPrint(
            '⏳ Student profile not found, retrying... (attempt $attempts/$maxAttempts)',
          );
          await Future.delayed(delay);
        }
      } catch (e) {
        debugPrint(
          '⚠️ Error fetching student profile (attempt ${attempts + 1}): $e',
        );
        attempts++;
        if (attempts < maxAttempts) {
          await Future.delayed(delay);
        }
      }
    }

    debugPrint('⚠️ Student profile not found after $maxAttempts attempts');
    return null;
  }

  /// Handle generic errors
  void _handleError(Object error) {
    if (!mounted) return;

    debugPrint('❌ Google sign-in error: $error');

    String errorMessage = 'Google sign-in failed';

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('cancelled') || errorString.contains('canceled')) {
      // User cancelled - don't show error
      return;
    } else if (errorString.contains('network')) {
      errorMessage = 'Network error. Please check your internet connection.';
    } else if (errorString.contains('popup')) {
      errorMessage =
          'Sign-in popup was blocked. Please allow popups and try again.';
    } else if (errorString.contains('access_denied')) {
      errorMessage = 'Access denied. Please try again.';
    } else {
      errorMessage = 'Google sign-in failed. Please try again.';
    }

    _showError(errorMessage);
  }

  /// Show success message
  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show error message
  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _signInWithGoogle,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            disabledBackgroundColor: Colors.grey.shade100,
          ),
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                )
              : Image.asset(
                  'assets/icons/google_icon.png', // ✅ CORRECT
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
