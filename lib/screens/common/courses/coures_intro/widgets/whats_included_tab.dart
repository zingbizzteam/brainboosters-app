// screens/common/courses/widgets/whats_included_tab.dart
import 'package:flutter/material.dart';

class WhatsIncludedTab extends StatelessWidget {
  final List<String> whatsIncluded;

  const WhatsIncludedTab({super.key, required this.whatsIncluded});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;

    if (whatsIncluded.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'No information available.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This course includes:',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...whatsIncluded.map((item) => _buildIncludedItem(item, isMobile)),
        ],
      ),
    );
  }

  Widget _buildIncludedItem(String item, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              item,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
