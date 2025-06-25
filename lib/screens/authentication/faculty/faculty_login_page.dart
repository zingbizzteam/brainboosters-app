// screens/authentication/faculty/faculty_login_page.dart
import 'package:brainboosters_app/ui/navigation/auth_routes.dart';
import 'package:brainboosters_app/ui/navigation/faculty_routes/faculty_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FacultyLoginPage extends StatefulWidget {
  const FacultyLoginPage({super.key});

  @override
  State<FacultyLoginPage> createState() => _FacultyLoginPageState();
}

class _FacultyLoginPageState extends State<FacultyLoginPage> {
  final TextEditingController _coachingCenterIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    final coachingCenterId = _coachingCenterIdController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Capture ScaffoldMessenger before async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // First authenticate with Supabase
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Verify faculty belongs to the coaching center
        final facultyData = await Supabase.instance.client
            .from('faculty')
            .select('coaching_center_id, role')
            .eq('user_id', response.user!.id)
            .eq('coaching_center_id', coachingCenterId)
            .maybeSingle();

        if (facultyData != null) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Faculty login successful!'))
          );

          if (!mounted) return;
          context.go(FacultyRoutes.dashboard);
        } else {
          // Sign out if not valid faculty
          await Supabase.instance.client.auth.signOut();
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Invalid coaching center ID or you are not a faculty member'))
          );
        }
      }
    } on AuthException catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(e.message))
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Unexpected error occurred'))
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
                    color: const Color(0xFF6C5CE7),
                    child: Stack(
                      children: [
                        // Logo
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
                                    color: Color(0xFF6C5CE7),
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
                              Icon(
                                Icons.person_pin,
                                size: 200,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Faculty Portal',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                ),
                label: const Text('Go Back', style: TextStyle(fontSize: 16)),
                onPressed: () => context.go(AuthRoutes.authSelection),
                icon: const Icon(Icons.arrow_back_ios),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Faculty Login',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6C5CE7),
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              const Text(
                'Access your faculty dashboard',
                style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
              ),
              const SizedBox(height: 40),

              // Coaching Center ID Field
              TextField(
                controller: _coachingCenterIdController,
                decoration: InputDecoration(
                  labelText: 'Coaching Center ID',
                  labelStyle: const TextStyle(color: Color(0xFF999999)),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6C5CE7)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  prefixIcon: const Icon(Icons.business, color: Color(0xFF999999)),
                ),
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
                    borderSide: BorderSide(color: Color(0xFF6C5CE7)),
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
                    borderSide: BorderSide(color: Color(0xFF6C5CE7)),
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
                    bottom: BorderSide(
                      color: Color(0xFF5A4FCF),
                      width: 3,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
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
                            'Login as Faculty',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Contact Admin Link
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Show contact information or navigate to help
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Need Help?'),
                        content: const Text(
                          'Please contact your coaching center administrator for login credentials and coaching center ID.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'Need help with login?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6C5CE7),
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
    _coachingCenterIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
