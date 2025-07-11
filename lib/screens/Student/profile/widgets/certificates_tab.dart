// lib/screens/student/profile/widgets/certificates_tab.dart
import 'package:brainboosters_app/screens/student/profile/widgets/certificates_widget.dart';
import 'package:flutter/material.dart';
import 'profile_model.dart';

class CertificatesTab extends StatelessWidget {
  final ProfileData profileData;
  final VoidCallback onRefresh;

  const CertificatesTab({
    super.key,
    required this.profileData,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Certificates Header
        Row(
          children: [
            const Text(
              'Your Certificates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Certificates Widget
        Expanded(child: CertificatesWidget(onRefresh: onRefresh)),
      ],
    );
  }
}
