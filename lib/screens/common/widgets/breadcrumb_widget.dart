// screens/widgets/common/breadcrumb_widget.dart
import 'package:flutter/material.dart';

class BreadcrumbItem {
  final String text;
  final bool isLast;
  
  BreadcrumbItem(this.text, this.isLast);
}

class BreadcrumbWidget extends StatelessWidget {
  final List<BreadcrumbItem> items;
  
  const BreadcrumbWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;
    
    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _buildBreadcrumbRow(),
      );
    }
    
    return _buildBreadcrumbRow();
  }

  Widget _buildBreadcrumbRow() {
    List<Widget> widgets = [];
    
    for (int i = 0; i < items.length; i++) {
      widgets.add(_buildBreadcrumbItem(items[i].text, items[i].isLast));
      if (i < items.length - 1) {
        widgets.add(_buildBreadcrumbSeparator());
      }
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  Widget _buildBreadcrumbItem(String text, bool isLast) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: isLast ? Colors.black : Colors.grey[600],
        fontWeight: isLast ? FontWeight.w500 : FontWeight.normal,
      ),
    );
  }

  Widget _buildBreadcrumbSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '/',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
