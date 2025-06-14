import 'package:flutter/material.dart';

class LiveClassList extends StatelessWidget {
  const LiveClassList({super.key});
  @override
  Widget build(BuildContext context) {
    final liveClasses = [
      {
        "title": "Generative AI: Prompt Engineering Basics",
        "time": "Today, 3:00 PM",
        "academy": "Leader Academy",
        "color": Colors.red,
      },
      {
        "title": "AI Security Essentials",
        "time": "Tomorrow, 6:00 PM",
        "academy": "Leader Academy",
        "color": Colors.red,
      },
      {
        "title": "Artificial Intelligence and Machine Learning",
        "time": "May 25, 6:00 PM",
        "academy": "Leader Academy",
        "color": Colors.red,
      },
    ];

    return Column(
      children: liveClasses.map((lc) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.circle, color: lc['color'] as Color, size: 10),
                        const SizedBox(width: 6),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              lc['title'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        lc['time'] as String,
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "By ${lc['academy']}",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
