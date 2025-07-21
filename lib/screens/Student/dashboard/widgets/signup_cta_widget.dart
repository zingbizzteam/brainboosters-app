// screens/student/dashboard/widgets/signup_cta_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboosters_app/ui/navigation/auth_routes.dart';

class SignUpCtaWidget extends StatelessWidget {
  const SignUpCtaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Ready to Start Your Learning Journey?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Sign up today to access personalized learning paths, track your progress, and earn certificates.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => context.go(AuthRoutes.emailRegister),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4AA0E6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Sign Up Free'),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => context.go(AuthRoutes.prefix),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF4AA0E6)),
                  foregroundColor: const Color(0xFF4AA0E6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
