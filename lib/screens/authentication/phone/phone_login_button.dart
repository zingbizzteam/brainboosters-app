import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhoneLoginButton extends StatelessWidget {
  final void Function(AuthResponse?)? onOtpSent;
  final void Function(Object error)? onError;
  final double? width;
  final double? height;

  const PhoneLoginButton({
    Key? key,
    this.onOtpSent,
    this.onError,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.phone),
        label: const Text('Sign in with Phone'),
        onPressed: () async {
          final phoneController = TextEditingController();
          final result = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Phone Login'),
              content: TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: '+1234567890'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, phoneController.text),
                  child: const Text('Send OTP'),
                ),
              ],
            ),
          );
          if (result != null && result.isNotEmpty) {
            try {
              final res = await Supabase.instance.client.auth.signInWithOtp(
                phone: result,
              );
              // onOtpSent?.call(res);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('OTP sent. Please check your phone.'),
                ),
              );
            } catch (e) {
              onError?.call(e);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Phone login failed: $e')));
            }
          }
        },
      ),
    );
  }
}
