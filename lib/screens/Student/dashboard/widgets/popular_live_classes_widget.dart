// screens/student/dashboard/widgets/popular_live_classes_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboosters_app/screens/common/live_class/widgets/live_class_card.dart';
import 'package:brainboosters_app/ui/navigation/common_routes/common_routes.dart';

class PopularLiveClassesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> liveClasses;
  final String title;

  const PopularLiveClassesWidget({
    super.key,
    required this.liveClasses,
    this.title = "Popular Live Classes",
  });

  @override
  Widget build(BuildContext context) {
    if (liveClasses.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            TextButton(
              onPressed: () => context.go(CommonRoutes.liveClassesRoute),
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: liveClasses.length,
            itemBuilder: (context, idx) {
              final liveClass = liveClasses[idx];
              return Padding(
                padding: EdgeInsets.only(left: idx == 0 ? 0 : 8, right: 8),
                child: LiveClassCard(
                  liveClass: liveClass,
                  width: 280,
                  height: 320,
                  onTap: () => context.go(
                    CommonRoutes.getLiveClassDetailRoute(liveClass['id']),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
