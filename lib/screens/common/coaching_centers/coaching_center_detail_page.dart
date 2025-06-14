// screens/common/coaching_centers/coaching_center_detail_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CoachingCenterDetailPage extends StatelessWidget {
  final String centerId;
  
  const CoachingCenterDetailPage({super.key, required this.centerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coaching Center Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Coaching Center ID: $centerId'),
            const SizedBox(height: 20),
            const Text('Coaching center details will be implemented here'),
          ],
        ),
      ),
    );
  }
}
