// lib/models/navigation_item.dart
import 'package:flutter/material.dart';

class NavigationItem {
  final String route;
  final String label;
  final IconData icon;
  final Color color;

  const NavigationItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationItem &&
        other.route == route &&
        other.label == label &&
        other.icon == icon &&
        other.color == color;
  }

  @override
  int get hashCode {
    return route.hashCode ^
        label.hashCode ^
        icon.hashCode ^
        color.hashCode;
  }

  @override
  String toString() {
    return 'NavigationItem(route: $route, label: $label, icon: $icon, color: $color)';
  }
}
