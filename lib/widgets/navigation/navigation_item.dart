import 'package:flutter/material.dart';

enum NavigationAction {
  navigate,
  showDialog,
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final NavigationAction action;
  final bool isSpecial; // For special styling like the add button

  const NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.action,
    this.isSpecial = false,
  });
} 