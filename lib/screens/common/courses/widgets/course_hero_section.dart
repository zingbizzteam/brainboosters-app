import 'package:brainboosters_app/screens/common/courses/course_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../ui/navigation/common_routes/common_routes.dart';

class CourseHeroSection extends StatefulWidget {
  final String courseId;
  final bool forceRefresh; // NEW: Add refresh trigger
  final VoidCallback? onRefreshComplete; // NEW: Add completion callback

  const CourseHeroSection({
    super.key,
    required this.courseId,
    this.forceRefresh = false, // NEW
    this.onRefreshComplete, // NEW
  });

  @override
  State<CourseHeroSection> createState() => _CourseHeroSectionState();
}

class _CourseHeroSectionState extends State<CourseHeroSection> {
  Map<String, dynamic>? course;
  bool isLoading = true;
  String? error;
  bool isEnrolled = false;
  bool isWishlisted = false;
  bool isEnrolling = false;
  bool isAuthenticated = false;
  bool _previousRefreshState = false; // NEW: Track refresh state

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fetchCourse();
      _checkUserStatus();
    });
  }

  @override
  void didUpdateWidget(CourseHeroSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    // NEW: Handle refresh trigger
    if (widget.forceRefresh && !_previousRefreshState) {
      debugPrint('DEBUG: Hero section refresh triggered');
      _handleRefresh();
    }
    _previousRefreshState = widget.forceRefresh;
  }

  // NEW: Handle refresh with skeleton loader
  Future<void> _handleRefresh() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    await _fetchCourse(isRefresh: true);

    // Notify parent that refresh is complete
    if (widget.onRefreshComplete != null) {
      widget.onRefreshComplete!();
    }
  }

  Future<void> _fetchCourse({bool isRefresh = false}) async {
    if (!isRefresh) {
      setState(() {
        isLoading = true;
        error = null;
      });
    }

    try {
      debugPrint(
        'DEBUG: ${isRefresh ? "Refreshing" : "Loading"} hero course...',
      );
      final data = await CourseRepository.getCourseById(widget.courseId);
      if (data == null) throw Exception('Course not found');

      setState(() {
        course = data;
        isLoading = false;
      });

      await _checkEnrollmentStatus();
      debugPrint(
        'DEBUG: Hero course ${isRefresh ? "refreshed" : "loaded"} successfully',
      );
    } catch (e) {
      debugPrint(
        'ERROR: Failed to ${isRefresh ? "refresh" : "load"} hero course: $e',
      );
      setState(() {
        error = 'Failed to load course: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _checkUserStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    setState(() {
      isAuthenticated = user != null;
    });
  }

  Future<void> _checkEnrollmentStatus() async {
    if (!isAuthenticated || course == null) return;
    try {
      final user = Supabase.instance.client.auth.currentUser!;
      final enrollment = await Supabase.instance.client
          .from('course_enrollments')
          .select('id')
          .eq('course_id', course!['id'])
          .eq('student_id', user.id)
          .eq('is_active', true)
          .maybeSingle();
      final wishlist = await Supabase.instance.client
          .from('course_wishlists')
          .select('id')
          .eq('course_id', course!['id'])
          .eq('user_id', user.id)
          .maybeSingle();
      setState(() {
        isEnrolled = enrollment != null;
        isWishlisted = wishlist != null;
      });
    } catch (_) {}
  }

  Future<void> _handleEnrollment() async {
    if (!isAuthenticated) {
      _showAuthDialog();
      return;
    }
    if (isEnrolled) {
      _navigateToCourse();
      return;
    }
    setState(() => isEnrolling = true);
    try {
      final user = Supabase.instance.client.auth.currentUser!;
      final studentData = await Supabase.instance.client
          .from('students')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();
      if (studentData == null) throw Exception('Student profile not found');
      await Supabase.instance.client.from('course_enrollments').insert({
        'student_id': studentData['id'],
        'course_id': course!['id'],
        'enrolled_at': DateTime.now().toIso8601String(),
        'is_active': true,
      });
      setState(() {
        isEnrolled = true;
        isEnrolling = false;
      });
       if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully enrolled in ${course!['title']}!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Start Learning',
            textColor: Colors.white,
            onPressed: _navigateToCourse,
          ),
        ),
      );
    } catch (e) {
      setState(() => isEnrolling = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to enroll: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleWishlist() async {
    if (!isAuthenticated) {
      _showAuthDialog();
      return;
    }
    try {
      final user = Supabase.instance.client.auth.currentUser!;
      if (isWishlisted) {
        await Supabase.instance.client
            .from('course_wishlists')
            .delete()
            .eq('course_id', course!['id'])
            .eq('user_id', user.id);
        setState(() => isWishlisted = false);
         if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from wishlist'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        await Supabase.instance.client.from('course_wishlists').insert({
          'course_id': course!['id'],
          'user_id': user.id,
          'added_at': DateTime.now().toIso8601String(),
        });
        setState(() => isWishlisted = true);
         if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to wishlist'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update wishlist: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToCourse() {
    if (course != null) {
      context.push(CommonRoutes.getCourseDetailRoute(course!['id']));
    }
  }

  void _showAuthDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In Required'),
        content: const Text('Please sign in to enroll or add to wishlist.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/auth/login');
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
          vertical: isMobile ? 40 : 60,
        ),
        child: isLoading
            ? _buildShimmer(isMobile)
            : error != null
            ? _buildError(isMobile)
            : _buildHeroContent(isMobile, isTablet),
      ),
    );
  }

  Widget _buildShimmer(bool isMobile) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.3),
      highlightColor: Colors.white.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 32, width: 220, color: Colors.white),
          const SizedBox(height: 16),
          Container(height: 20, width: 150, color: Colors.white),
          const SizedBox(height: 24),
          Container(height: 16, width: 280, color: Colors.white),
          const SizedBox(height: 32),
          Row(
            children: List.generate(
              3,
              (i) => Container(
                margin: EdgeInsets.only(right: i < 2 ? 24 : 0),
                height: 16,
                width: 90,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Container(height: 48, width: 140, color: Colors.white),
              const SizedBox(width: 16),
              Container(height: 48, width: 180, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError(bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: isMobile ? 48 : 64,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Course',
            style: TextStyle(
              fontSize: isMobile ? 18 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error ?? 'Something went wrong',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchCourse,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue[900],
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroContent(bool isMobile, bool isTablet) {
    if (course == null) return const SizedBox.shrink();

    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCourseImage(180),
              const SizedBox(height: 24),
              _buildCourseInfo(isMobile),
              const SizedBox(height: 32),
              _buildActionButtons(isMobile),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: _buildCourseInfo(false)),
              const SizedBox(width: 60),
              Expanded(flex: 4, child: _buildCourseImage(260)),
            ],
          );
  }

  Widget _buildCourseImage(double height) {
    final url = course!['thumbnail_url']?.toString();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildImagePlaceholder(height),
              )
            : _buildImagePlaceholder(height),
      ),
    );
  }

  Widget _buildImagePlaceholder(double height) {
    return Container(
      height: height,
      color: Colors.white.withValues(alpha: 0.2),
      child: Center(
        child: Icon(
          Icons.school,
          size: height * 0.3,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildCourseInfo(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          course!['title'] ?? 'Untitled Course',
          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          course!['description'] ?? 'No description available',
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.5,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildFeature(
              Icons.play_circle_outline,
              '${course!['total_lessons'] ?? 0} Lessons',
              isMobile,
            ),
            const SizedBox(width: 24),
            _buildFeature(
              Icons.access_time,
              '${course!['duration_hours'] ?? 0}h',
              isMobile,
            ),
            const SizedBox(width: 24),
            _buildFeature(
              Icons.star,
              (course!['rating'] ?? 0.0).toStringAsFixed(1),
              isMobile,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildFeature(
              Icons.people,
              '${course!['enrollment_count'] ?? 0} Students',
              isMobile,
            ),
            const SizedBox(width: 24),
            _buildFeature(
              Icons.category,
              course!['category']?.toString() ?? 'General',
              isMobile,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeature(IconData icon, String text, bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: isMobile ? 16 : 20),
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
    );
  }

  Widget _buildActionButtons(bool isMobile) {
    final price = course!['price'] ?? 0.0;
    final originalPrice = course!['original_price'] ?? price;
    final hasDiscount = originalPrice > price && originalPrice > 0;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        ElevatedButton.icon(
          onPressed: isEnrolling ? null : _handleEnrollment,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 32,
              vertical: isMobile ? 12 : 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: isEnrolling
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue,
                  ),
                )
              : Icon(isEnrolled ? Icons.play_arrow : Icons.school),
          label: Text(
            isEnrolled
                ? 'Go to Course'
                : 'Enroll Now${price == 0 ? " (Free)" : ""}',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _handleWishlist,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 32,
              vertical: isMobile ? 12 : 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Icon(
            isWishlisted ? Icons.favorite : Icons.favorite_border,
            color: Colors.pinkAccent,
          ),
          label: Text(
            isWishlisted ? 'Wishlisted' : 'Add to Wishlist',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (hasDiscount)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '₹${originalPrice.toStringAsFixed(0)} → ₹${price.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else if (price > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '₹${price.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
