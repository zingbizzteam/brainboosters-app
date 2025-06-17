// screens/common/courses/widgets/app_promotion_section.dart
import 'package:flutter/material.dart';

class AppPromotionSection extends StatelessWidget {
  const AppPromotionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
        vertical: 40,
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4F46E5),
              Color(0xFF7C3AED),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextContent(true),
        const SizedBox(height: 24),
        _buildPhoneImage(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: _buildTextContent(false),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 4,
          child: _buildPhoneImage(),
        ),
      ],
    );
  }

  Widget _buildTextContent(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Get our learning app',
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Our progress, your courses — now in your pocket.\nDownload the Brain Boosters app for:\n• Offline access to your lessons\n• Push notifications for your sessions\n• Seamless learning on the go',
          style: TextStyle(
            color: Colors.white70,
            fontSize: isMobile ? 14 : 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        
        // Download buttons
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildDownloadButton(
              'assets/images/google_play.png',
              'Get it on Google Play',
              isMobile,
            ),
            _buildDownloadButton(
              'assets/images/app_store.png',
              'Download on the App Store',
              isMobile,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDownloadButton(String imagePath, String text, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: isMobile ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            text.contains('Google') ? Icons.android : Icons.apple,
            color: Colors.white,
            size: isMobile ? 20 : 24,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneImage() {
    return Center(
      child: Container(
        width: 200,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.phone_android,
          color: Colors.white,
          size: 80,
        ),
      ),
    );
  }
}
