// screens/authentication/coaching_center/coaching_center_login_page.dart
import 'package:brainboosters_app/ui/navigation/auth_routes.dart';
import 'package:brainboosters_app/ui/navigation/coaching_center_routes/coaching_center_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CoachingCenterLoginPage extends StatefulWidget {
  const CoachingCenterLoginPage({super.key});

  @override
  State<CoachingCenterLoginPage> createState() => _CoachingCenterLoginPageState();
}

class _CoachingCenterLoginPageState extends State<CoachingCenterLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Check if email is confirmed
        if (response.user!.emailConfirmedAt == null) {
          // Email not confirmed, sign out and show message
          await Supabase.instance.client.auth.signOut();
          
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: const Text(
                'Please verify your email before logging in. Check your inbox for the verification link.',
              ),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'Resend',
                textColor: Colors.white,
                onPressed: () => _resendConfirmationEmail(email),
              ),
            ),
          );
          return;
        }

        // Check if user is a coaching center
        final centerData = await Supabase.instance.client
            .from('coaching_centers')
            .select('id, center_name, verification_status')
            .eq('id', response.user!.id)
            .maybeSingle();

        if (centerData != null) {
          // Check verification status
          if (centerData['verification_status'] == 'email_pending') {
            // Update status to pending admin approval since email is now verified
            await Supabase.instance.client
                .from('coaching_centers')
                .update({
                  'verification_status': 'pending',
                  'updated_at': DateTime.now().toIso8601String(),
                })
                .eq('id', response.user!.id);

            await Supabase.instance.client.auth.signOut();
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text(
                  'Email verified! Your registration is now pending admin approval. You will be notified once approved.',
                ),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 5),
              ),
            );
            return;
          }

          if (centerData['verification_status'] == 'pending') {
            await Supabase.instance.client.auth.signOut();
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text(
                  'Your registration is pending admin approval. Please wait for approval notification.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          if (centerData['verification_status'] == 'rejected') {
            await Supabase.instance.client.auth.signOut();
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text(
                  'Your registration has been rejected. Please contact support for more information.',
                ),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          if (centerData['verification_status'] == 'suspended') {
            await Supabase.instance.client.auth.signOut();
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text(
                  'Your account has been suspended. Please contact support.',
                ),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // If approved, allow login
          if (centerData['verification_status'] == 'approved') {
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Login successful!')),
            );

            if (!mounted) return;
            context.go(CoachingCenterRoutes.dashboard);
          }
        } else {
          // Sign out if not a coaching center
          await Supabase.instance.client.auth.signOut();
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('You are not registered as a coaching center.'),
            ),
          );
        }
      }
    } on AuthException catch (e) {
      String errorMessage = e.message;
      
      // Handle specific auth errors
      if (e.message.contains('Email not confirmed')) {
        errorMessage = 'Please verify your email before logging in.';
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Resend',
              textColor: Colors.white,
              onPressed: () => _resendConfirmationEmail(email),
            ),
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Unexpected error occurred')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendConfirmationEmail(String email) async {
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Please check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending email: $e')),
        );
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
                    color: const Color(0xFF00B894),
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
                                  color: Colors.white,
                                  child: const Icon(
                                    Icons.school,
                                    color: Color(0xFF00B894),
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
                              Icon(
                                Icons.business,
                                size: 200,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Coaching Center Portal',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
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
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                ),
                label: const Text('Go Back', style: TextStyle(fontSize: 16)),
                onPressed: () => context.go(AuthRoutes.authSelection),
                icon: const Icon(Icons.arrow_back_ios),
              ),
              const SizedBox(height: 20),

              const Text(
                'Coaching Center',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00B894),
                ),
              ),
              const SizedBox(height: 40),

              // Email Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Center Email',
                  labelStyle: const TextStyle(color: Color(0xFF999999)),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00B894)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF999999)),
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
                    borderSide: BorderSide(color: Color(0xFF00B894)),
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
              ),
              const SizedBox(height: 32),

              // Login Button
              Container(
                decoration: BoxDecoration(
                  border: const Border(
                    bottom: BorderSide(color: Color(0xFF00A085), width: 3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B894),
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
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Resend verification email link
              Center(
                child: GestureDetector(
                  onTap: () => _resendConfirmationEmail(_emailController.text.trim()),
                  child: const Text(
                    'Didn\'t receive verification email? Resend',
                    style: TextStyle(
                      color: Color(0xFF00B894),
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
