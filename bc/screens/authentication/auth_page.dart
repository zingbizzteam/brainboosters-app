import 'package:brainboosters_app/ui/navigation/auth_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import './google/google_login_button.dart';

class AuthSelectionPage extends StatelessWidget {
  const AuthSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isWide ? 24 : 0),
            boxShadow: isWide
                ? [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App logo or illustration
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

              const SizedBox(height: 24),
              Text(
                "Welcome to Brain Boosters",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Sign in to continue your learning journey",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Email sign-in button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.email_outlined, color: Colors.white),
                  label: const Text("Sign in with Email"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => context.go(AuthRoutes.emailLogin),
                ),
              ),
              const SizedBox(height: 16),

              //TODO: Phone sign-in button
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton.icon(
              //     icon: Icon(Icons.phone_android, color: Colors.white),
              //     label: const Text("Sign in with Phone"),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.green[600],
              //       foregroundColor: Colors.white,
              //       padding: const EdgeInsets.symmetric(vertical: 14),
              //       textStyle: const TextStyle(
              //         fontSize: 16,
              //         fontWeight: FontWeight.w600,
              //       ),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(8),
              //       ),
              //     ),

              //
              //     onPressed: () => context.go(AuthRoutes.emailLogin),
              //   ),
              // ),
              // const SizedBox(height: 16),

              // Google sign-in button
              SizedBox(width: double.infinity, child: GoogleAuthButton()),

              const SizedBox(height: 32),
              Divider(),
              const SizedBox(height: 12),
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
