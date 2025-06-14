// screens/widgets/common/stats_widget.dart
import 'package:flutter/material.dart';

class StatItem {
  final IconData icon;
  final String text;
  
  StatItem({required this.icon, required this.text});
}

class StatsWidget extends StatelessWidget {
  final List<StatItem> items;
  final Widget? trailingWidget;
  
  const StatsWidget({
    super.key,
    required this.items,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;
    
    if (isMobile) {
      return _buildMobileStats();
    } else if (isTablet) {
      return _buildTabletStats();
    } else {
      return _buildDesktopStats();
    }
  }

  Widget _buildMobileStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildStatItem(item.icon, item.text, 12),
        )),
        if (trailingWidget != null) ...[
          const SizedBox(height: 8),
          trailingWidget!,
        ],
      ],
    );
  }

  Widget _buildTabletStats() {
    return Column(
      children: [
        Wrap(
          spacing: 24,
          runSpacing: 12,
          children: items.map((item) => _buildStatItem(item.icon, item.text, 13)).toList(),
        ),
        if (trailingWidget != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              trailingWidget!,
              const Spacer(),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopStats() {
    return Row(
      children: [
        ...items.map((item) => [
          _buildStatItem(item.icon, item.text, 14),
          const SizedBox(width: 32),
        ]).expand((x) => x),
        const Spacer(),
        if (trailingWidget != null) trailingWidget!,
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text, double fontSize) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: fontSize + 4,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
