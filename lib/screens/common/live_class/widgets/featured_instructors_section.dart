// screens/common/live_class/widgets/featured_instructors_section.dart
import 'package:flutter/material.dart';

class FeaturedInstructorsSection extends StatelessWidget {
  const FeaturedInstructorsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    
    final instructors = [
      {
        'name': 'Dr. Sarah Johnson',
        'expertise': 'AI & Machine Learning',
        'experience': '10+ years',
        'rating': 4.9,
        'students': '50K+',
        'image': 'https://picsum.photos/200/200?random=101',
      },
      {
        'name': 'Prof. Mike Chen',
        'expertise': 'Full Stack Development',
        'experience': '8+ years',
        'rating': 4.8,
        'students': '35K+',
        'image': 'https://picsum.photos/200/200?random=102',
      },
      {
        'name': 'Dr. Emily Watson',
        'expertise': 'Data Science',
        'experience': '12+ years',
        'rating': 4.9,
        'students': '45K+',
        'image': 'https://picsum.photos/200/200?random=103',
      },
      {
        'name': 'Mr. David Kim',
        'expertise': 'UI/UX Design',
        'experience': '6+ years',
        'rating': 4.7,
        'students': '28K+',
        'image': 'https://picsum.photos/200/200?random=104',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
        vertical: 40,
      ),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Featured Instructors',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Learn from industry experts and experienced professionals',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 4),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 3 : 0.8,
            ),
            itemCount: instructors.length,
            itemBuilder: (context, index) {
              return _buildInstructorCard(instructors[index], isMobile);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorCard(Map<String, dynamic> instructor, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isMobile ? _buildMobileInstructorLayout(instructor) : _buildDesktopInstructorLayout(instructor),
    );
  }

  Widget _buildMobileInstructorLayout(Map<String, dynamic> instructor) {
    return Row(
      children: [
        // Instructor Image
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image.network(
            instructor['image'],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: const Icon(Icons.person, size: 30, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // Instructor Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                instructor['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                instructor['expertise'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${instructor['rating']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${instructor['students']} students',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopInstructorLayout(Map<String, dynamic> instructor) {
    return Column(
      children: [
        // Instructor Image
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Image.network(
            instructor['image'],
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 80,
              height: 80,
              color: Colors.grey[300],
              child: const Icon(Icons.person, size: 40, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Instructor Info
        Text(
          instructor['name'],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          instructor['expertise'],
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          instructor['experience'],
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              '${instructor['rating']}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${instructor['students']} students',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}
