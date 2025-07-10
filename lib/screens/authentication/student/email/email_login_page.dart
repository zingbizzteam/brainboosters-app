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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberPassword = false;
  bool _isResendingEmail = false;

  // Email verification resend tracking
  int _resendCount = 0;
  DateTime? _lastResendTime;
  static const int maxResendPerDay = 3;
  static const int resendCooldownMinutes = 2;

  @override
  void initState() {
    super.initState();
    _loadResendData();
  }

  Future<void> _loadResendData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final savedDate = prefs.getString('resend_date') ?? '';

    if (savedDate == today) {
      _resendCount = prefs.getInt('resend_count') ?? 0;
      final lastResendString = prefs.getString('last_resend_time');
      if (lastResendString != null) {
        _lastResendTime = DateTime.parse(lastResendString);
      }
    } else {
      // Reset for new day
      _resendCount = 0;
      _lastResendTime = null;
      await prefs.setString('resend_date', today);
      await prefs.setInt('resend_count', 0);
      await prefs.remove('last_resend_time');
    }
  }

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

  bool get _canResendEmail {
    if (_resendCount >= maxResendPerDay) return false;
    if (_lastResendTime == null) return true;

    final timeDiff = DateTime.now().difference(_lastResendTime!);
    return timeDiff.inMinutes >= resendCooldownMinutes;
  }

  String get _resendButtonText {
    if (_resendCount >= maxResendPerDay) {
      return 'Daily limit reached';
    }
    if (_lastResendTime != null && !_canResendEmail) {
      final remaining =
          resendCooldownMinutes -
          DateTime.now().difference(_lastResendTime!).inMinutes;
      return 'Resend in ${remaining}m';
    }
    return 'Resend verification email';
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        if (!mounted) return;

        // Check if email is verified
        if (response.user!.emailConfirmedAt == null) {
          await Supabase.instance.client.auth.signOut();

          if (!mounted) return;

          _showEmailVerificationDialog(email);
          return;
        }

        // Get user profile to check user type
        final userProfile = await _getUserProfile(response.user!.id);
        if (!mounted) return;
        if (userProfile == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please complete your profile setup')),
          );
          context.go(AuthRoutes.userSetup);
          return;
        }

        // Check if user is a student
        if (userProfile['user_type'] != 'student') {
          await Supabase.instance.client.auth.signOut();

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

        // Check if student profile is complete
        final studentProfile = await _getStudentProfile(response.user!.id);

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful!')));

        // Navigate based on profile completion
        if (studentProfile == null || !userProfile['onboarding_completed']) {
          context.go(AuthRoutes.userSetup);
        } else {
          context.go(StudentRoutes.home);
        }
      }
    } on AuthException catch (e) {
      if (!mounted) return;

      String errorMessage = 'Login failed';

      switch (e.message.toLowerCase()) {
        case 'invalid login credentials':
          errorMessage = 'Invalid email or password';
          break;
        case 'email not confirmed':
          errorMessage = 'Please verify your email before logging in';
          _showEmailVerificationDialog(_emailController.text.trim());
          return;
        case 'too many requests':
          errorMessage = 'Too many login attempts. Please try again later';
          break;
        default:
          errorMessage = e.message;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showEmailVerificationDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.email, color: Color(0xFF5DADE2)),
              SizedBox(width: 8),
              Text('Email Verification Required'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please verify your email address to continue. We sent a verification link to:',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  email,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Didn\'t receive the email? Check your spam folder or request a new one.',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              if (_resendCount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Verification emails sent today: $_resendCount/$maxResendPerDay',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
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

  Future<void> _resendVerificationEmail(String email) async {
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );

      _resendCount++;
      _lastResendTime = DateTime.now();
      await _saveResendData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent! Please check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send verification email: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> _getUserProfile(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('user_profiles')
          .select(
            'user_type, first_name, last_name, onboarding_completed, is_active',
          )
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getStudentProfile(String userId) async {
    try {
      final response = await Supabase.instance.client
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

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String? _validateInputs() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      return 'Please enter your email';
    }

    if (!_isValidEmail(email)) {
      return 'Please enter a valid email address';
    }

    if (password.isEmpty) {
      return 'Please enter your password';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  Future<void> _handleLogin() async {
    final validationError = _validateInputs();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await _login();
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
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/Brain_Boosters_Logo.png',
                                height: 60,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 60,
                                  width: 60,
                                  color: Colors.blue,
                                  child: const Icon(
                                    Icons.school,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
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
                                  color: Colors.blue.withValues(alpha: 0.3),
                                  child: const Icon(Icons.computer, size: 100),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
                ),
                label: const Text('Go Back', style: TextStyle(fontSize: 16)),
                onPressed: () => context.go(AuthRoutes.authSelection),
                icon: const Icon(Icons.arrow_back_ios),
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

              // Subtitle
              Row(
                children: [
                  const Text(
                    'Don\'t have an account? ',
                    style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  ),
                  IgnorePointer(
                    child: GestureDetector(
                      onTap: () => context.go(AuthRoutes.emailRegister),
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 14,
                          // color: Color(0xFF5DADE2),
                          color: Colors.grey[400], // Changed to grey

                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Email Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Color(0xFF999999)),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF5DADE2)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Color(0xFF999999)),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF5DADE2)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
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
                onSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: 32),

              // Sign In Button
              Container(
                decoration: BoxDecoration(
                  border: const Border(
                    bottom: BorderSide(color: Color(0xFF9d5f0e), width: 3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4845C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
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

              const SizedBox(height: 20),

              // Remember Password Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _rememberPassword,
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _rememberPassword = value ?? false;
                            });
                          },
                    activeColor: const Color(0xFF5DADE2),
                  ),
                  const Text(
                    'Remember Password',
                    style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Forgot Password Link
              GestureDetector(
                onTap: _isLoading
                    ? null
                    : () => context.go(AuthRoutes.emailResetPassword),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 14,
                    color: _isLoading ? Colors.grey : const Color(0xFF999999),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
