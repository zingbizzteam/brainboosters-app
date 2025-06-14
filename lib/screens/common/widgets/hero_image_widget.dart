// screens/widgets/common/hero_image_widget.dart
import 'package:flutter/material.dart';

class HeroImageWidget extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final Widget? overlayContent;
  
  const HeroImageWidget({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    this.overlayContent,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;
    
    return Container(
      width: double.infinity,
      height: isMobile ? 250 : 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.3),
            ],
          ),
        ),
        child: Stack(
          children: [
            if (overlayContent != null) overlayContent!,
          ],
        ),
      ),
    );
  }
}
