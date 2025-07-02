import 'package:flutter/material.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
