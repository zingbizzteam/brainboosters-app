// screens/authentication/auth_selection_page.dart
import 'package:brainboosters_app/ui/navigation/auth_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'student/google/google_login_button.dart';

class AuthSelectionPage extends StatefulWidget {
  const AuthSelectionPage({super.key});

  @override
  State<AuthSelectionPage> createState() => _AuthSelectionPageState();
}

class _AuthSelectionPageState extends State<AuthSelectionPage> {
  String _selectedUserType = 'student';

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isWide ? 24 : 16),
            boxShadow: isWide
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App logo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4AA0E6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.asset(
                  'assets/images/Brain_Boosters_Logo.png',
                  height: 60,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.school,
                    size: 60,
                    color: Color(0xFF4AA0E6),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Welcome text
              Text(
                "Welcome to Brain Boosters",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Choose your role to get started",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // User type selection
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildUserTypeTab(
                        'Student',
                        'student',
                        Icons.school,
                        const Color(0xFF4AA0E6),
                      ),
                    ),
                    Expanded(
                      child: _buildUserTypeTab(
                        'Faculty',
                        'faculty',
                        Icons.person_pin,
                        const Color(0xFF6C5CE7),
                      ),
                    ),
                    Expanded(
                      child: _buildUserTypeTab(
                        'Center',
                        'coaching_center',
                        Icons.business,
                        const Color(0xFF00B894),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Sign-in options based on user type
              if (_selectedUserType == 'student') ...[
                // Email sign-in button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.email_outlined, color: Colors.white),
                    label: const Text("Sign in with Email"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4AA0E6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => context.go(AuthRoutes.emailLogin),
                  ),
                ),
                const SizedBox(height: 16),

                // Google sign-in button
                SizedBox(width: double.infinity, child: GoogleAuthButton()),

                const SizedBox(height: 24),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: () => context.go(AuthRoutes.emailRegister),
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          color: Color(0xFF4AA0E6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              if (_selectedUserType == 'faculty') ...[
                // Faculty login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.login, color: Colors.white),
                    label: const Text("Faculty Login"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => context.go(AuthRoutes.facultyLogin),
                  ),
                ),
                const SizedBox(height: 16),

                // Faculty info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: const Color(0xFF6C5CE7),
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Faculty Login",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6C5CE7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "You'll need your Coaching Center ID, email, and password provided by your institution.",
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],

              if (_selectedUserType == 'coaching_center') ...[
                // Coaching center login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.login, color: Colors.white),
                    label: const Text("Center Login"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B894),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => context.go(AuthRoutes.coachingCenterLogin),
                  ),
                ),
                const SizedBox(height: 24),

                // Register link (instead of button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: () =>
                          context.go(AuthRoutes.coachingCenterRegister),
                      child: const Text(
                        "Register Center",
                        style: TextStyle(
                          color: Color(0xFF00B894),
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Center info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B894).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00B894).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.business_center,
                        color: const Color(0xFF00B894),
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Join as Coaching Center",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF00B894),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Register your coaching center to manage students, faculty, and courses on our platform.",
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Divider and terms
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                "By continuing, you agree to our Terms of Service and Privacy Policy.",
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeTab(
    String title,
    String type,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedUserType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
