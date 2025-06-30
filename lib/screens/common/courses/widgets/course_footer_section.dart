// screens/common/courses/widgets/course_footer_section.dart
import 'package:flutter/material.dart';

class CourseFooterSection extends StatelessWidget {
  const CourseFooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Container(
      width: double.infinity,
      color: const Color(0xFF1E3A8A), // Dark blue background
      child: Column(
        children: [
          // Main Footer Content
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
              vertical: 60,
            ),
            child: isMobile ? _buildMobileFooter() : _buildDesktopFooter(),
          ),

          // Bottom Bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
              vertical: 20,
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '© 2025 Brain Boosters. All rights reserved.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
                if (!isMobile)
                  Row(
                    children: [
                      _buildFooterLink('Privacy Policy'),
                      const SizedBox(width: 24),
                      _buildFooterLink('Terms of Service'),
                      const SizedBox(width: 24),
                      _buildFooterLink('Cookie Policy'),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo and Description
        _buildBrandSection(),
        const SizedBox(height: 40),

        // Company Links
        _buildFooterColumn('Company', [
          'About Us',
          'Careers',
          'Contact Us',
          'Blog',
        ]),
        const SizedBox(height: 32),

        // Essentials Links
        _buildFooterColumn('Essentials', [
          'Courses',
          'Live Classes',
          'Coaching Centers',
          'Certifications',
        ]),
        const SizedBox(height: 32),

        // Follow Us
        _buildSocialSection(),
      ],
    );
  }

  Widget _buildDesktopFooter() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo and Description (40% width)
        Expanded(flex: 4, child: _buildBrandSection()),

        const SizedBox(width: 60),

        // Company Links
        Expanded(
          flex: 2,
          child: _buildFooterColumn('Company', [
            'About Us',
            'Careers',
            'Contact Us',
            'Blog',
          ]),
        ),

        // Essentials Links
        Expanded(
          flex: 2,
          child: _buildFooterColumn('Essentials', [
            'Courses',
            'Live Classes',
            'Coaching Centers',
            'Certifications',
          ]),
        ),

        // Follow Us
        Expanded(flex: 2, child: _buildSocialSection()),
      ],
    );
  }

  Widget _buildBrandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.school,
                color: Color(0xFF1E3A8A),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'BRAIN BOOSTERS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Description
        Text(
          'Empowering learners worldwide with quality education and professional development opportunities.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterColumn(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildFooterLink(link),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Follow Us',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildSocialIcon(Icons.facebook),
            const SizedBox(width: 16),
            _buildSocialIcon(Icons.alternate_email), // Twitter/X
            const SizedBox(width: 16),
            _buildSocialIcon(Icons.camera_alt), // Instagram
            const SizedBox(width: 16),
            _buildSocialIcon(Icons.play_arrow), // YouTube
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Running a coaching center? Reach more learners on Brain Boosters.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1E3A8A),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Teach on Brain Boosters',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLink(String text) {
    return GestureDetector(
      onTap: () {
        // Handle link navigation
      },
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return GestureDetector(
      onTap: () {
        // Handle social media navigation
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
