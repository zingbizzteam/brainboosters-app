import 'package:brainboosters_app/ui/navigation/auth_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailResetPasswordPage extends StatefulWidget {
  const EmailResetPasswordPage({super.key});
  
  @override
  State<EmailResetPasswordPage> createState() => _EmailResetPasswordPageState();
}

class _EmailResetPasswordPageState extends State<EmailResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    
    // Validate email first
    final validationError = _validateEmail(email);
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
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'https://yourapp.com/auth/reset-password', // Configure this URL
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Password reset link sent!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('Please check your email ($email) and follow the instructions to reset your password.'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      context.go(AuthRoutes.emailLogin);
      
    } on AuthException catch (e) {
      if (!mounted) return;
      
      String errorMessage = 'Failed to send reset link';
      
      switch (e.message.toLowerCase()) {
        case 'user not found':
          errorMessage = 'No account found with this email address';
          break;
        case 'email rate limit exceeded':
          errorMessage = 'Too many reset attempts. Please try again later';
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

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Please enter your email address';
    }
    
    if (!_isValidEmail(email)) {
      return 'Please enter a valid email address';
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
                              const Icon(
                                Icons.lock_reset,
                                size: 120,
                                color: Color(0xFF5DADE2),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Reset Your Password',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
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
                    child: _buildResetForm(),
                  ),
                ),
              ],
            );
          } else {
            return Container(
              color: Colors.white,
              child: SafeArea(child: _buildResetForm()),
            );
          }
        },
      ),
    );
  }

  Widget _buildResetForm() {
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
                onPressed: () => context.go(AuthRoutes.emailLogin),
                icon: const Icon(Icons.arrow_back_ios),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5DADE2),
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              const Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),

              // Email Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
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
                onSubmitted: (_) => _resetPassword(),
              ),
              const SizedBox(height: 40),

              // Send Reset Link Button
              Container(
                decoration: BoxDecoration(
                  border: const Border(
                    bottom: BorderSide(
                      color: Color(0xFF9d5f0e),
                      width: 3,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
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
                            'Send Reset Link',
                            style: TextStyle(
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
                  onTap: () => context.go(AuthRoutes.emailLogin),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5DADE2),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Help Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF5DADE2),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Make sure to check your spam folder if you don\'t receive the email within a few minutes.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
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
    super.dispose();
  }
}
