import 'package:flutter/material.dart';
import 'bottom_navigation_bar.dart';
import 'navigation_item.dart';

class AnimatedBottomNavigationBar extends StatelessWidget {
  final List<NavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final double opacity;

  const AnimatedBottomNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, (1.0 - opacity) * 100), // Slide down as opacity decreases
      child: AppBottomNavigationBar(
        items: items,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
      ),
    );
  }
} 