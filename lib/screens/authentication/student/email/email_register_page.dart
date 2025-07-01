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
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _register() async {
    setState(() => _isLoading = true);
    
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    // final phone = _phoneController.text.trim();

    // Validate inputs
    final validationError = _validateInputs();
    if (validationError != null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Sign up with email verification required
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'user_type': 'student',
          'first_name': firstName,
          'last_name': lastName,
        },
        emailRedirectTo: 'https://yourapp.com/auth/callback', // Configure this URL
      );

      if (response.user != null) {
        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registration successful!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Please check your email ($email) and click the verification link to activate your account.'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 6),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate to login page
        context.go(AuthRoutes.emailLogin);
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      
      String errorMessage = 'Registration failed';
      
      switch (e.message.toLowerCase()) {
        case 'user already registered':
          errorMessage = 'An account with this email already exists';
          break;
        case 'password should be at least 6 characters':
          errorMessage = 'Password must be at least 6 characters long';
          break;
        case 'signup is disabled':
          errorMessage = 'New registrations are currently disabled';
          break;
        default:
          errorMessage = e.message;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
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

  String? _validateInputs() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (firstName.isEmpty) {
      return 'Please enter your first name';
    }

    if (lastName.isEmpty) {
      return 'Please enter your last name';
    }

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

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
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
                                  child: const Icon(Icons.school, color: Colors.white),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                ),
                label: const Text('Go Back', style: TextStyle(fontSize: 16)),
                onPressed: () => context.go(AuthRoutes.authSelection),
                icon: const Icon(Icons.arrow_back_ios, size: 16),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5DADE2),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Join Brain Boosters and start your learning journey',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                ),
              ),
              const SizedBox(height: 40),

              // First Name Field
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
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
                  prefixIcon: const Icon(Icons.person, color: Color(0xFF999999)),
                ),
                textCapitalization: TextCapitalization.words,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),

              // Last Name Field
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
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
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF999999)),
                ),
                textCapitalization: TextCapitalization.words,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),

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
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF999999)),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),

              // Phone Field (Optional)
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number (Optional)',
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
                  prefixIcon: const Icon(Icons.phone, color: Color(0xFF999999)),
                ),
                keyboardType: TextInputType.phone,
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
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF999999)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
              ),
              const SizedBox(height: 32),

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
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
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
                  onTap: () => context.go(AuthRoutes.emailLogin),
                  child: const Text.rich(
                    TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(color: Color(0xFF999999)),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: TextStyle(
                            color: Color(0xFF5DADE2),
                            fontWeight: FontWeight.w500,
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
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
