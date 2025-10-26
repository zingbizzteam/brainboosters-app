import 'package:brainboosters_app/ui/navigation/auth_routes.dart';
import 'package:brainboosters_app/ui/navigation/student_routes/student_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailLoginPage extends StatefulWidget {
  const EmailLoginPage({super.key});

  @override
  State<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isResendingEmail = false;

  // Email verification resend tracking
  int _resendCount = 0;
  DateTime? _lastResendTime;
  static const int maxResendPerDay = 3;
  static const int resendCooldownMinutes = 2;

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadResendData();
    _loadRememberedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Load remembered email if exists
  Future<void> _loadRememberedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberedEmail = prefs.getString('remembered_email');
      if (rememberedEmail != null && rememberedEmail.isNotEmpty) {
        setState(() {
          _emailController.text = rememberedEmail;
          _rememberMe = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading remembered email: $e');
    }
  }

  /// Load resend tracking data
  Future<void> _loadResendData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final savedDate = prefs.getString('resend_date') ?? '';

    if (savedDate == today) {
      setState(() {
        _resendCount = prefs.getInt('resend_count') ?? 0;
        final lastResendString = prefs.getString('last_resend_time');
        if (lastResendString != null) {
          _lastResendTime = DateTime.parse(lastResendString);
        }
      });
    } else {
      // Reset for new day
      setState(() {
        _resendCount = 0;
        _lastResendTime = null;
      });
      await prefs.setString('resend_date', today);
      await prefs.setInt('resend_count', 0);
      await prefs.remove('last_resend_time');
    }
  }

  /// Save resend tracking data
  Future<void> _saveResendData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('resend_date', today);
    await prefs.setInt('resend_count', _resendCount);
    if (_lastResendTime != null) {
      await prefs.setString(
        'last_resend_time',
        _lastResendTime!.toIso8601String(),
      );
    }
  }

  /// Check if user can resend email
  bool get _canResendEmail {
    if (_resendCount >= maxResendPerDay) return false;
    if (_lastResendTime == null) return true;
    final timeDiff = DateTime.now().difference(_lastResendTime!);
    return timeDiff.inMinutes >= resendCooldownMinutes;
  }

  /// Get resend button text
  String get _resendButtonText {
    if (_resendCount >= maxResendPerDay) {
      return 'Daily limit reached';
    }
    if (_lastResendTime != null && !_canResendEmail) {
      final remaining = resendCooldownMinutes -
          DateTime.now().difference(_lastResendTime!).inMinutes;
      return 'Resend in ${remaining}m';
    }
    return 'Resend verification email';
  }

  /// Validate inputs
  String? _validateInputs() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) return 'Please enter your email';
    if (!_isValidEmail(email)) return 'Please enter a valid email address';
    if (password.isEmpty) return 'Please enter your password';
    if (password.length < 6) return 'Password must be at least 6 characters';

    return null;
  }

  /// Email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  /// Main login function with comprehensive checks
  Future<void> _login() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    final validationError = _validateInputs();
    if (validationError != null) {
      _showError(validationError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      debugPrint('🔐 Starting login for: $email');

      // Attempt login
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed: No user returned');
      }

      debugPrint('✅ Authentication successful');

      // Check if email is verified
      if (response.user!.emailConfirmedAt == null) {
        debugPrint('⚠️ Email not verified');
        await _supabase.auth.signOut();
        if (!mounted) return;
        _showEmailVerificationDialog(email);
        return;
      }

      // Save email if remember me is checked
      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('remembered_email', email);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('remembered_email');
      }

      // Get and validate user profile with retry logic
      final userProfile = await _getUserProfileWithRetry(response.user!.id);
      
      if (!mounted) return;

      if (userProfile == null) {
        debugPrint('⚠️ User profile not found after retries');
        _showError('Profile setup incomplete. Please complete your profile.');
        context.go(AuthRoutes.userSetup);
        return;
      }

      // CRITICAL: Check if user is a student (ONLY students allowed in this app)
      if (userProfile['user_type'] != 'student') {
        debugPrint('❌ Access denied: Not a student (user_type: ${userProfile['user_type']})');
        await _supabase.auth.signOut();
        if (!mounted) return;
        
        // Show specific error based on user type
        String errorMsg = 'Access denied. This app is for students only.';
        if (userProfile['user_type'] == 'teacher') {
          errorMsg = 'Teachers should use the Teacher Portal. This app is for students only.';
        } else if (userProfile['user_type'] == 'coaching_center') {
          errorMsg = 'Coaching centers should use the Admin Portal. This app is for students only.';
        }
        
        _showError(errorMsg);
        return;
      }

      // Check if user account is active
      if (userProfile['is_active'] == false) {
        await _supabase.auth.signOut();
        if (!mounted) return;
        _showError('Your account has been deactivated. Please contact support.');
        return;
      }

      // Check if student profile exists (with retry)
      final studentProfile = await _getStudentProfileWithRetry(response.user!.id);
      
      if (!mounted) return;

      debugPrint('✅ Login successful - Student verified');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome back, ${userProfile['first_name'] ?? 'Student'}!',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate based on profile completion
      if (studentProfile == null || userProfile['onboarding_completed'] != true) {
        debugPrint('➡️ Redirecting to user setup (onboarding incomplete)');
        context.go(AuthRoutes.userSetup);
      } else {
        debugPrint('➡️ Redirecting to home');
        context.go(StudentRoutes.home);
      }

    } on AuthException catch (e) {
      debugPrint('❌ Auth error: ${e.message}');
      _handleAuthError(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      if (mounted) {
        _showError('Login failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            .select('user_type, first_name, last_name, onboarding_completed, is_active, email_verified')
            .eq('id', userId)
            .maybeSingle();

        if (response != null) {
          debugPrint('✅ User profile found (attempt ${attempts + 1})');
          return response;
        }

        attempts++;
        if (attempts < maxAttempts) {
          debugPrint('⏳ Profile not found, retrying... (attempt $attempts/$maxAttempts)');
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
  Future<Map<String, dynamic>?> _getStudentProfileWithRetry(String userId) async {
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
          debugPrint('⏳ Student profile not found, retrying... (attempt $attempts/$maxAttempts)');
          await Future.delayed(delay);
        }
      } catch (e) {
        debugPrint('⚠️ Error fetching student profile (attempt ${attempts + 1}): $e');
        attempts++;
        if (attempts < maxAttempts) {
          await Future.delayed(delay);
        }
      }
    }

    debugPrint('⚠️ Student profile not found after $maxAttempts attempts');
    return null;
  }

  /// Handle authentication-specific errors
  void _handleAuthError(AuthException e) {
    if (!mounted) return;

    String errorMessage = 'Login failed';
    final message = e.message.toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid email or password')) {
      errorMessage = 'Invalid email or password. Please try again.';
    } else if (message.contains('email not confirmed')) {
      errorMessage = 'Please verify your email before logging in';
      _showEmailVerificationDialog(_emailController.text.trim());
      return;
    } else if (message.contains('too many requests')) {
      errorMessage =
          'Too many login attempts. Please wait a few minutes and try again.';
    } else if (message.contains('network')) {
      errorMessage = 'Network error. Please check your internet connection.';
    } else if (message.contains('user not found')) {
      errorMessage = 'No account found with this email.';
    } else {
      errorMessage = e.message;
    }

    _showError(errorMessage);
  }

  /// Resend verification email
  Future<void> _resendVerificationEmail(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );

      _resendCount++;
      _lastResendTime = DateTime.now();
      await _saveResendData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✉️ Verification email sent! Please check your inbox.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to send verification email. Please try again.');
    }
  }

  /// Show email verification dialog
  void _showEmailVerificationDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.email, color: Color(0xFF5DADE2)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Email Verification Required',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please verify your email address to continue.',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Verification link sent to:',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mail_outline, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        email,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Didn\'t receive it? Check your spam folder or request a new one.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              if (_resendCount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Emails sent today: $_resendCount/$maxResendPerDay',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: _canResendEmail && !_isResendingEmail
                  ? () async {
                      setDialogState(() => _isResendingEmail = true);
                      await _resendVerificationEmail(email);
                      setDialogState(() => _isResendingEmail = false);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5DADE2),
                foregroundColor: Colors.white,
              ),
              child: _isResendingEmail
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(_resendButtonText),
            ),
          ],
        ),
      ),
    );
  }

  /// Show error snackbar
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
                              Image.asset(
                                'assets/images/learning_illustration.png',
                                height: 300,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 300,
                                  width: 300,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.computer,
                                    size: 100,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              const Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5DADE2),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Continue your learning journey',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Right side - Login Form
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.white,
                    child: _buildLoginForm(),
                  ),
                ),
              ],
            );
          } else {
            return Container(
              color: Colors.white,
              child: SafeArea(child: _buildLoginForm()),
            );
          }
        },
      ),
    );
  }

  Widget _buildLoginForm() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
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
                      : () => context.go(AuthRoutes.authSelection),
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5DADE2),
                  ),
                ),
                const SizedBox(height: 16),

                // Subtitle with registration link
                Row(
                  children: [
                    const Text(
                      'Don\'t have an account? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () => context.go(AuthRoutes.emailRegister),
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 14,
                          color: _isLoading
                              ? Colors.grey
                              : const Color(0xFF5DADE2),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
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
                  enabled: !_isLoading,
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
                const SizedBox(height: 24),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                      Icons.lock,
                      color: Color(0xFF999999),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFF999999),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  enabled: !_isLoading,
                  onFieldSubmitted: (_) => _login(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Remember Me Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                      activeColor: const Color(0xFF5DADE2),
                    ),
                    const Text(
                      'Remember Me',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () => context.go(AuthRoutes.emailResetPassword),
                    child: Text(
                      'Forgot Password?',
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
                const SizedBox(height: 32),

                // Sign In Button
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
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
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
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
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