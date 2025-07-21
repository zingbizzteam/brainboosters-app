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
                "Sign in to your student account",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              Text(
                "Note: Backend under process, so we disabled new user registration",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Email sign-in button (ENABLED)
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

              // Google sign-in button (DISABLED)
              SizedBox(
                width: double.infinity,
                child: Opacity(
                  // opacity: 0.5, // Visual indication it's disabled
                  opacity: 1,
                  child:
                      // IgnorePointer(child:
                      GoogleAuthButton(),
                  // ),
                ),
              ),

              const SizedBox(height: 24),

              // Register link (DISABLED)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  // IgnorePointer(child:
                  Text(
                    "Sign up with email",
                    style: TextStyle(
                      color: Color(0xFF5DADE2),
                      // color: Colors.grey[400], // Changed to grey
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // ),
                ],
              ),

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
}
