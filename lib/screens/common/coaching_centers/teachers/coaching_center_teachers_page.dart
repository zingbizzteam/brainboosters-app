import 'package:brainboosters_app/screens/common/coaching_centers/coaching_center_details/widgets/coaching_center_header_widget.dart';
import 'package:brainboosters_app/screens/common/coaching_centers/coaching_center_repository.dart';
import 'package:brainboosters_app/screens/common/coaching_centers/teachers/teacher_details/widgets/teacher_card.dart';
import 'package:brainboosters_app/screens/common/coaching_centers/teachers/teacher_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // ADD THIS IMPORT
import 'package:go_router/go_router.dart';
import '../../../../ui/navigation/common_routes/common_routes.dart';

class CoachingCenterTeachersPage extends StatefulWidget {
  final String centerId;

  const CoachingCenterTeachersPage({super.key, required this.centerId});

  @override
  State<CoachingCenterTeachersPage> createState() => _CoachingCenterTeachersPageState();
}

class _CoachingCenterTeachersPageState extends State<CoachingCenterTeachersPage> {
  List<Map<String, dynamic>> teachers = [];
  Map<String, dynamic>? coachingCenter;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    // FIXED: Schedule data loading after the first frame is built
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      // Only set loading state if we're not already loading
      if (!isLoading) {
        setState(() {
          isLoading = true;
          error = null;
        });
      }

      final results = await Future.wait([
        CoachingCenterRepository.getCoachingCenterById(widget.centerId),
        TeacherRepository.getTeachersByCoachingCenter(widget.centerId),
      ]);

      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          coachingCenter = results[0] as Map<String, dynamic>?;
          teachers = results[1] as List<Map<String, dynamic>>;
          isLoading = false;
        });
      }
    } catch (e) {
      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          error = 'Failed to load teachers: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Teachers',
          style: TextStyle(
            color: Colors.black,
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildContent(isMobile),
    );
  }

  Widget _buildContent(bool isMobile) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(error!, style: TextStyle(color: Colors.red[600])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coaching center header
          if (coachingCenter != null) ...[
            CoachingCenterHeaderWidget(
              coachingCenter: coachingCenter!,
              isMobile: isMobile,
              showTeachersCount: true,
            ),
            const SizedBox(height: 32),
          ],

          // Teachers section
          Text(
            'Our Faculty (${teachers.length})',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          if (teachers.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No teachers found for this coaching center.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 1 : 2,
                childAspectRatio: isMobile ? 1.2 : 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: teachers.length,
              itemBuilder: (context, index) {
                return TeacherCard(
                  teacher: teachers[index],
                  onTap: () {
                    context.push(
                      CommonRoutes.getCoachingCenterTeacherDetailRoute(
                        widget.centerId,
                        teachers[index]['id'],
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
