import 'package:brainboosters_app/screens/common/coaching_centers/teachers/teacher_repository.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

class CoachingCenterFacultyTab extends StatefulWidget {
  final Map<String, dynamic> center;
  final bool isMobile;

  const CoachingCenterFacultyTab({
    super.key,
    required this.center,
    required this.isMobile,
  });

  @override
  State<CoachingCenterFacultyTab> createState() =>
      _CoachingCenterFacultyTabState();
}

class _CoachingCenterFacultyTabState extends State<CoachingCenterFacultyTab> {
  List<Map<String, dynamic>> faculty = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadFaculty();
    });
  }

  Future<void> _loadFaculty() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // ✅ FIXED: Use user_id instead of id
      final coachingCenterId = widget.center['user_id'] ?? widget.center['id'];
      
      if (coachingCenterId == null) {
        throw Exception('Coaching center ID not found');
      }

      final result = await TeacherRepository.getTeachersByCoachingCenter(
        coachingCenterId,
      );

      if (mounted) {
        setState(() {
          faculty = result;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Failed to load faculty: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Faculty',
            style: TextStyle(
              fontSize: widget.isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      error!,
                      style: TextStyle(color: Colors.red[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadFaculty,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (faculty.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'Faculty information will be updated soon.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...faculty.map((teacher) => _buildFacultyCard(teacher)),
        ],
      ),
    );
  }

  Widget _buildFacultyCard(Map<String, dynamic> teacher) {
    final userProfile = teacher['user_profiles'];

    return InkWell(
      onTap: () {
        context.go(
          CommonRoutes.getCoachingCenterTeacherDetailRoute(
            widget.center['id'],
            teacher['id'],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: _getAvatarUrl(userProfile) != null
                  ? NetworkImage(_getAvatarUrl(userProfile)!)
                  : null,
              onBackgroundImageError: (exception, stackTrace) {},
              child: _getAvatarUrl(userProfile) == null
                  ? const Icon(Icons.person, size: 30)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTeacherName(userProfile),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_getExperienceYears(teacher)} years experience',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  if (_getSpecializations(teacher).isNotEmpty) ...[
                    Text(
                      'Specializations: ${_getSpecializations(teacher).take(3).join(', ')}',
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (_getRating(teacher) > 0) ...[
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _getRating(teacher).toStringAsFixed(1),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${_getTotalReviews(teacher)} reviews)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (_isVerified(teacher))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }

  // Helper methods
  String _getTeacherName(Map<String, dynamic>? userProfile) {
    if (userProfile == null) return 'Unknown Teacher';
    final firstName = userProfile['first_name']?.toString() ?? '';
    final lastName = userProfile['last_name']?.toString() ?? '';
    return '$firstName $lastName'.trim();
  }

  String? _getAvatarUrl(Map<String, dynamic>? userProfile) {
    return userProfile?['avatar_url']?.toString();
  }

  int _getExperienceYears(Map<String, dynamic> teacher) {
    return teacher['experience_years'] ?? 0;
  }

  List<String> _getSpecializations(Map<String, dynamic> teacher) {
    final specializations = teacher['specializations'];
    if (specializations is List) {
      return specializations.map((e) => e.toString()).toList();
    }
    return [];
  }

  double _getRating(Map<String, dynamic> teacher) {
    final rating = teacher['rating'];
    if (rating is num) return rating.toDouble();
    return 0.0;
  }

  int _getTotalReviews(Map<String, dynamic> teacher) {
    return teacher['total_reviews'] ?? 0;
  }

  bool _isVerified(Map<String, dynamic> teacher) {
    return teacher['is_verified'] == true;
  }
}

