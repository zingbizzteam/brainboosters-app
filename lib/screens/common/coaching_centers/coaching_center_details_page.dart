// screens/common/coaching_centers/coaching_center_detail_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'data/coaching_center_dummy_data.dart';
import 'models/coaching_center_model.dart';

class CoachingCenterDetailPage extends StatefulWidget {
  final String centerId;

  const CoachingCenterDetailPage({super.key, required this.centerId});

  @override
  State<CoachingCenterDetailPage> createState() => _CoachingCenterDetailPageState();
}

class _CoachingCenterDetailPageState extends State<CoachingCenterDetailPage> {
  CoachingCenter? coachingCenter;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoachingCenter();
  }

  void _loadCoachingCenter() {
    try {
      final center = CoachingCenterDummyData.coachingCenters
          .firstWhere((center) => center.id == widget.centerId);
      setState(() {
        coachingCenter = center;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (coachingCenter == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text(
            'Coaching Center not found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Breadcrumb Navigation
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
                vertical: 16,
              ),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Home / Python Coaching Centers / ${coachingCenter!.name}',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image
                      Container(
                        width: isMobile ? 80 : 120,
                        height: isMobile ? 80 : 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.network(
                            coachingCenter!.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.school,
                              size: isMobile ? 40 : 60,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: isMobile ? 16 : 24),

                      // Title and Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    coachingCenter!.name,
                                    style: TextStyle(
                                      fontSize: isMobile ? 24 : 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                if (coachingCenter!.isVerified)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Verified',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              coachingCenter!.description,
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  coachingCenter!.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${coachingCenter!.studentsEnrolled.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} students',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Tab Navigation
                  Row(
                    children: [
                      _buildTab('Batches', false),
                      const SizedBox(width: 32),
                      _buildTab('Courses', false),
                      const SizedBox(width: 32),
                      _buildTab('About', true),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Bio Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${coachingCenter!.name} is a dynamic coaching center focused on empowering students and professionals with cutting-edge programming skills. With ${coachingCenter!.experienceYears} years of experience, we have trained over ${coachingCenter!.studentsEnrolled} students.',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Specializations
                      const Text(
                        'Specializations:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: coachingCenter!.specializations.map((specialization) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Text(
                              specialization,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // Facilities
                      const Text(
                        'Facilities:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ...coachingCenter!.facilities.map((facility) => 
                        _buildBulletPoint(facility)),

                      const SizedBox(height: 32),

                      // Additional Info Grid
                      if (isMobile)
                        Column(
                          children: [
                            _buildInfoCard('Established Year', coachingCenter!.establishedDate.year.toString()),
                            const SizedBox(height: 16),
                            _buildInfoCard('Location', coachingCenter!.location),
                            const SizedBox(height: 16),
                            _buildInfoCard('Experience', '${coachingCenter!.experienceYears} years'),
                            const SizedBox(height: 16),
                            _buildInfoCard('Courses Offered', coachingCenter!.coursesOffered.toString()),
                            const SizedBox(height: 16),
                            _buildInfoCard('Starting Fees', '₹${coachingCenter!.fees.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'),
                            const SizedBox(height: 16),
                            _buildInfoCard('Contact', coachingCenter!.contactPhone),
                          ],
                        )
                      else
                        Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      _buildInfoCard('Established Year', coachingCenter!.establishedDate.year.toString()),
                                      const SizedBox(height: 16),
                                      _buildInfoCard('Experience', '${coachingCenter!.experienceYears} years'),
                                      const SizedBox(height: 16),
                                      _buildInfoCard('Starting Fees', '₹${coachingCenter!.fees.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 32),
                                Expanded(
                                  child: Column(
                                    children: [
                                      _buildInfoCard('Location', coachingCenter!.location),
                                      const SizedBox(height: 16),
                                      _buildInfoCard('Courses Offered', coachingCenter!.coursesOffered.toString()),
                                      const SizedBox(height: 16),
                                      _buildInfoCard('Contact', coachingCenter!.contactPhone),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                      const SizedBox(height: 32),

                      // Contact Information
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Contact Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.blue, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    coachingCenter!.address,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.phone, color: Colors.blue, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  coachingCenter!.contactPhone,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.email, color: Colors.blue, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  coachingCenter!.contactEmail,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool isActive) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Colors.black87 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        if (isActive) Container(height: 2, width: 40, color: Colors.black87),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
