import 'package:brainboosters_app/ui/navigation/auth_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailResetPasswordPage extends StatefulWidget {
  const EmailResetPasswordPage({super.key});

  @override
  State<EmailResetPasswordPage> createState() => _EmailResetPasswordPageState();
}

class _EmailResetPasswordPageState extends State<EmailResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  
  bool _isLoading = false;
  bool _emailSent = false;

  // Rate limiting tracking
  int _resetCount = 0;
  DateTime? _lastResetTime;
  static const int maxResetPerDay = 3;
  static const int resetCooldownMinutes = 5;

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadResetData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Load rate limiting data
  Future<void> _loadResetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T');
      final savedDate = prefs.getString('reset_date') ?? '';

      if (savedDate == today) {
        setState(() {
          _resetCount = prefs.getInt('reset_count') ?? 0;
          final lastResetString = prefs.getString('last_reset_time');
          if (lastResetString != null) {
            _lastResetTime = DateTime.parse(lastResetString);
          }
        });
      } else {
        // Reset for new day
        setState(() {
          _resetCount = 0;
          _lastResetTime = null;
        });
        await prefs.setString('reset_date', today as String);
        await prefs.setInt('reset_count', 0);
        await prefs.remove('last_reset_time');
      }
    } catch (e) {
      debugPrint('Error loading reset data: $e');
    }
  }

  /// Save rate limiting data
  Future<void> _saveResetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T');
      await prefs.setString('reset_date', today as String);
      await prefs.setInt('reset_count', _resetCount);
      if (_lastResetTime != null) {
        await prefs.setString(
          'last_reset_time',
          _lastResetTime!.toIso8601String(),
        );
      }
    } catch (e) {
      debugPrint('Error saving reset data: $e');
    }
  }

  /// Check if user can send reset email
  bool get _canSendReset {
    if (_resetCount >= maxResetPerDay) return false;
    if (_lastResetTime == null) return true;
    final timeDiff = DateTime.now().difference(_lastResetTime!);
    return timeDiff.inMinutes >= resetCooldownMinutes;
  }

  /// Get remaining cooldown time
  String get _cooldownMessage {
    if (_resetCount >= maxResetPerDay) {
      return 'Daily limit reached (3 resets/day)';
    }
    if (_lastResetTime != null && !_canSendReset) {
      final remaining = resetCooldownMinutes -
          DateTime.now().difference(_lastResetTime!).inMinutes;
      return 'Please wait $remaining minute${remaining > 1 ? 's' : ''} before trying again';
    }
    return '';
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    // Stricter email validation
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  /// Check if email exists and belongs to a student
  Future<bool> _validateStudentEmail(String email) async {
    try {
      debugPrint('🔍 Checking if email belongs to student: $email');

      final response = await _supabase
          .from('user_profiles')
          .select('id, user_type, is_active')
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        debugPrint('❌ No account found with this email');
        return false;
      }

      // CRITICAL: Check if user is a student
      if (response['user_type'] != 'student') {
        debugPrint('❌ Account exists but not a student (${response['user_type']})');
        throw Exception(
          'This app is for students only. '
          '${response['user_type'] == 'teacher' ? 'Teachers should use the Teacher Portal.' : ''}'
          '${response['user_type'] == 'coaching_center' ? 'Coaching centers should use the Admin Portal.' : ''}'
        );
      }

      // Check if account is active
      if (response['is_active'] == false) {
        debugPrint('❌ Account is deactivated');
        throw Exception('This account has been deactivated. Please contact support.');
      }

      debugPrint('✅ Valid student account found');
      return true;
    } catch (e) {
      if (e is Exception) rethrow;
      debugPrint('⚠️ Error validating email: $e');
      return false;
    }
  }

  /// Main password reset function
  Future<void> _resetPassword() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Check rate limiting
    if (!_canSendReset) {
      _showError(_cooldownMessage);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();

      debugPrint('🔐 Starting password reset for: $email');

      // Step 1: Validate email format
      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }

      // Step 2: Check if email belongs to a student account
      final isValidStudent = await _validateStudentEmail(email);
      
      if (!isValidStudent) {
        // For privacy, don't reveal that account doesn't exist
        // Just show success message anyway
        debugPrint('⚠️ Email not found, but showing success for privacy');
        _showSuccessAndNavigate(email);
        return;
      }

      // Step 3: Send password reset email using correct API
      debugPrint('📧 Sending password reset email');
      
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: _getRedirectUrl(),
      );

      debugPrint('✅ Password reset email sent successfully');

      // Update rate limiting
      _resetCount++;
      _lastResetTime = DateTime.now();
      await _saveResetData();

      if (!mounted) return;
      
      _showSuccessAndNavigate(email);

    } catch (e) {
      debugPrint('❌ Password reset error: $e');
      
      if (!mounted) return;

      String errorMessage = 'Failed to send reset link';

      if (e is AuthException) {
        final message = e.message.toLowerCase();
        if (message.contains('rate limit')) {
          errorMessage = 'Too many reset attempts. Please try again in 5 minutes.';
        } else if (message.contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        } else {
          errorMessage = e.message;
        }
      } else if (e is Exception) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      _showError(errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Get appropriate redirect URL based on platform
  String _getRedirectUrl() {
    // TODO: Update these URLs with your actual deployment URLs
    // For now, using deep link for mobile
    return 'brainboosters://auth/reset-password';
  }

  /// Show success message and navigate
  void _showSuccessAndNavigate(String email) {
    setState(() => _emailSent = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Password Reset Email Sent!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a password reset link to:\n$email',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              'Please check your email and click the link to reset your password.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );

    // Navigate back to login after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go(AuthRoutes.emailLogin);
      }
    });
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
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
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
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth >= 768;
          bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 768;

          if (isDesktop) {
            return Row(
              children: [
                // Left side - Illustration
                Expanded(
                  flex: 1,
                  child: Container(
                    color: const Color(0xFFB8E6F5),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 40,
                          left: 40,
                          child: Image.asset(
                            'assets/images/Brain_Boosters_Logo.png',
                            height: 60,
                            errorBuilder: (_, __, ___) => Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.school,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.lock_reset,
                                size: 150,
                                color: Color(0xFF5DADE2),
                              ),
                              const SizedBox(height: 32),
                              const Text(
                                'Forgot Your Password?',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5DADE2),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 60),
                                child: Text(
                                  'No worries! We\'ll help you reset it.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Right side - Reset Form
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.white,
                    child: _buildResetForm(isDesktop, isTablet),
                  ),
                ),
              ],
            );
          } else {
            return Container(
              color: Colors.white,
              child: SafeArea(
                child: _buildResetForm(isDesktop, isTablet),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildResetForm(bool isDesktop, bool isTablet) {
    // Responsive sizing
    final double horizontalPadding = isDesktop ? 40 : (isTablet ? 32 : 24);
    final double iconSize = isDesktop ? 120 : (isTablet ? 100 : 80);
    final double titleSize = isDesktop ? 36 : (isTablet ? 32 : 28);
    final double subtitleSize = isDesktop ? 14 : 13;
    final double buttonHeight = isDesktop ? 56 : (isTablet ? 52 : 48);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(horizontalPadding),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  label: const Text(
                    'Go Back',
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () => context.go(AuthRoutes.emailLogin),
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                ),
                const SizedBox(height: 32),

                // Mobile illustration (only on mobile)
                if (!isDesktop) ...[
                  Center(
                    child: Icon(
                      Icons.lock_reset,
                      size: iconSize,
                      color: const Color(0xFF5DADE2),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Title
                Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5DADE2),
                  ),
                ),
                const SizedBox(height: 16),

                // Subtitle
                Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: const Color(0xFF999999),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: const TextStyle(color: Color(0xFF999999)),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF5DADE2),
                        width: 2,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Color(0xFF999999),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading && !_emailSent,
                  onFieldSubmitted: (_) => _resetPassword(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!_isValidEmail(value.trim())) {
                      return 'Invalid email address';
                    }
                    return null;
                  },
                ),
                
                // Rate limiting info
                if (_resetCount > 0) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Reset attempts today: $_resetCount/$maxResetPerDay',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                
                const SizedBox(height: 40),

                // Send Reset Link Button
                Container(
                  decoration: BoxDecoration(
                    border: const Border(
                      bottom: BorderSide(
                        color: Color(0xFF9D5F0E),
                        width: 3,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: (_isLoading || _emailSent || !_canSendReset)
                          ? null
                          : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4845C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              _emailSent ? 'Email Sent ✓' : 'Send Reset Link',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Back to Login Link
                Center(
                  child: GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () => context.go(AuthRoutes.emailLogin),
                    child: Text(
                      'Back to Login',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isLoading
                            ? Colors.grey
                            : const Color(0xFF5DADE2),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Help Text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF5DADE2),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Important:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• Check your spam/junk folder\n'
                              '• Reset link expires in 1 hour\n'
                              '• Maximum 3 resets per day\n'
                              '• 5 minute cooldown between requests',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
