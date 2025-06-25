import 'package:brainboosters_app/ui/navigation/auth_routes.dart';
import 'package:brainboosters_app/ui/navigation/student_routes/student_routes.dart';
import 'package:brainboosters_app/ui/navigation/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> _login() async {
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Check for admin backdoor credentials
      if (email.toLowerCase() == 'bb_admin' && password == 'BB_ADMIN') {
        // Redirect to admin login page
        if (!mounted) return;
        context.go(AuthRoutes.adminLogin);
        return;
      }
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Check mounted before using context
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful!')));

        final userId = response.user!.id;
        final isNew = await isNewUser(userId);

        // Check mounted again after another async operation
        if (!mounted) return;

        if (isNew) {
          context.go(AuthRoutes.userSetup);
        } else {
          context.go(StudentRoutes.home);
        }
      }
    } on AuthException catch (e) {
      // Check mounted before using context
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      // Check mounted before using context
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error occurred')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                        // Brain Boosters Logo
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
                        // Illustration
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
            // Mobile layout
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
                  padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                ),
                label: Text('Go Back', style: TextStyle(fontSize: 16)),
                onPressed: () => context.go(AuthRoutes.authSelection),
                icon: Icon(Icons.arrow_back_ios),
              ),

              // Title
              const Text(
                'Log In',
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
                  GestureDetector(
                    onTap: () => context.go(AuthRoutes.emailRegister),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5DADE2),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              const Text(
                'It will take less than a minute',
                style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
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
              ),
              const SizedBox(height: 32),

              // Sign In Button
              Container(
                decoration: BoxDecoration(
                  border: const Border(
                    bottom: BorderSide(
                      color: Color(0xFF9d5f0e), // #9d5f0e
                      width: 3,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(
                    8,
                  ), // Match button's radius
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4845C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // Match here too
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
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
                    onChanged: (value) {
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
                onTap: () => context.go(AuthRoutes.emailResetPassword),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
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
