import 'package:flutter/material.dart';

class BreadcrumbItem {
  final String text;
  final bool isLast;
  final VoidCallback? onTap; // <-- Add this

  BreadcrumbItem(this.text, this.isLast, {this.onTap});
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
      widgets.add(_buildBreadcrumbItem(items[i]));
      if (i < items.length - 1) {
        widgets.add(_buildBreadcrumbSeparator());
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  Widget _buildBreadcrumbItem(BreadcrumbItem item) {
    if (item.isLast || item.onTap == null) {
      return Text(
        item.text,
        style: TextStyle(
          fontSize: 12,
          color: item.isLast ? Colors.black : Colors.grey[600],
          fontWeight: item.isLast ? FontWeight.w500 : FontWeight.normal,
        ),
      );
    } else {
      return InkWell(
        onTap: item.onTap,
        child: Text(
          item.text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.blue,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.normal,
          ),
        ),
      );
    }
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
