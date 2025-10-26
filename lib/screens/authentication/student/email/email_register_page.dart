import 'package:brainboosters_app/ui/navigation/auth_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailRegisterPage extends StatefulWidget {
  const EmailRegisterPage({super.key});

  @override
  State<EmailRegisterPage> createState() => _EmailRegisterPageState();
}

class _EmailRegisterPageState extends State<EmailRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Validate all inputs before submission
  String? _validateInputs() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (firstName.isEmpty) return 'Please enter your first name';
    if (firstName.length < 2) return 'First name must be at least 2 characters';
    
    if (lastName.isEmpty) return 'Please enter your last name';
    if (lastName.length < 2) return 'Last name must be at least 2 characters';
    
    if (email.isEmpty) return 'Please enter your email';
    if (!_isValidEmail(email)) return 'Please enter a valid email address';
    
    if (password.isEmpty) return 'Please enter your password';
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!_isStrongPassword(password)) {
      return 'Password must contain uppercase, lowercase, and number';
    }

    return null;
  }

  /// Email validation regex
  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  /// Strong password validation
  bool _isStrongPassword(String password) {
    return password.contains(RegExp(r'[A-Z]')) &&
           password.contains(RegExp(r'[a-z]')) &&
           password.contains(RegExp(r'[0-9]'));
  }

  /// Main registration function with proper error handling
  Future<void> _register() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    final validationError = _validateInputs();
    if (validationError != null) {
      _showError(validationError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Check if email already exists (prevents duplicate registration attempts)
      final existingUser = await _checkEmailExists(email);
      if (existingUser) {
        throw AuthException(
          'An account with this email already exists. Please login instead.',
        );
      }

      debugPrint('📝 Starting registration for: $email');

      // Sign up with email verification
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'user_type': 'student',
          'first_name': firstName,
          'last_name': lastName,
          'full_name': '$firstName $lastName',
        },
        emailRedirectTo: 'brainboosters://auth/callback',
      );

      debugPrint('✅ Registration response received');

      if (response.user == null) {
        throw Exception('Registration failed: No user returned');
      }

      // Verify profile was created by trigger
      await _verifyProfileCreation(response.user!.id);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '✅ Registration Successful!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a verification email to:\n$email',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                'Please check your inbox and click the verification link.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 8),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );

      // Navigate to login page
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        context.go(AuthRoutes.emailLogin);
      }

    } on AuthException catch (e) {
      debugPrint('❌ Auth error: ${e.message}');
      _handleAuthError(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      if (mounted) {
        _showError('Registration failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Check if email already exists in database
  Future<bool> _checkEmailExists(String email) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      debugPrint('Error checking email existence: $e');
      return false;
    }
  }

  /// Verify that the trigger created the profile
  Future<void> _verifyProfileCreation(String userId) async {
    debugPrint('🔍 Verifying profile creation for user: $userId');
    
    int attempts = 0;
    const maxAttempts = 5;
    const delay = Duration(milliseconds: 500);

    while (attempts < maxAttempts) {
      try {
        final profile = await _supabase
            .from('user_profiles')
            .select('id, user_type')
            .eq('id', userId)
            .maybeSingle();

        if (profile != null) {
          debugPrint('✅ Profile verified: ${profile['user_type']}');
          return;
        }

        attempts++;
        if (attempts < maxAttempts) {
          await Future.delayed(delay);
        }
      } catch (e) {
        debugPrint('⚠️ Profile verification attempt $attempts failed: $e');
        attempts++;
        if (attempts < maxAttempts) {
          await Future.delayed(delay);
        }
      }
    }

    // Profile creation failed - this is critical
    throw Exception(
      'Profile creation failed. Please contact support with error code: PROFILE_CREATE_FAIL',
    );
  }

  /// Handle authentication-specific errors
  void _handleAuthError(AuthException e) {
    if (!mounted) return;

    String errorMessage = 'Registration failed';
    
    final message = e.message.toLowerCase();
    
    if (message.contains('already registered') || 
        message.contains('already exists')) {
      errorMessage = 'An account with this email already exists. Please login instead.';
    } else if (message.contains('password')) {
      errorMessage = 'Password must be at least 8 characters with uppercase, lowercase, and number';
    } else if (message.contains('email')) {
      errorMessage = 'Invalid email address';
    } else if (message.contains('rate limit')) {
      errorMessage = 'Too many registration attempts. Please wait a few minutes.';
    } else if (message.contains('network')) {
      errorMessage = 'Network error. Please check your connection.';
    } else {
      errorMessage = e.message;
    }

    _showError(errorMessage);
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
                                'Join Brain Boosters',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5DADE2),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Start your learning journey today',
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
                // Right side - Registration Form
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.white,
                    child: _buildRegisterForm(),
                  ),
                ),
              ],
            );
          } else {
            return Container(
              color: Colors.white,
              child: SafeArea(child: _buildRegisterForm()),
            );
          }
        },
      ),
    );
  }

  Widget _buildRegisterForm() {
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
                  'Create Account',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5DADE2),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join thousands of students learning with Brain Boosters',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                ),
                const SizedBox(height: 40),

                // First Name Field
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name *',
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
                      Icons.person,
                      color: Color(0xFF999999),
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    if (value.trim().length < 2) {
                      return 'Too short';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Last Name Field
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name *',
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
                      Icons.person_outline,
                      color: Color(0xFF999999),
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    if (value.trim().length < 2) {
                      return 'Too short';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email *',
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
                      return 'Required';
                    }
                    if (!_isValidEmail(value.trim())) {
                      return 'Invalid email';
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
                    labelText: 'Password *',
                    labelStyle: const TextStyle(color: Color(0xFF999999)),
                    helperText: 'Min 8 chars, uppercase, lowercase, number',
                    helperStyle: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (value.length < 8) {
                      return 'Min 8 characters';
                    }
                    if (!_isStrongPassword(value)) {
                      return 'Must have uppercase, lowercase & number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Terms & Conditions
                Text(
                  'By creating an account, you agree to our Terms of Service and Privacy Policy',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Sign Up Button
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
                      onPressed: _isLoading ? null : _register,
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
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Link
                Center(
                  child: GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () => context.go(AuthRoutes.emailLogin),
                    child: Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: const TextStyle(color: Color(0xFF999999)),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color: _isLoading
                                  ? Colors.grey
                                  : const Color(0xFF5DADE2),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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