import 'package:flutter/material.dart';
import 'bottom_navigation_bar.dart';
import 'navigation_item.dart';

class BottomNavigation extends StatefulWidget {
  final List<NavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback? onShow;
  final VoidCallback? onHide;

  const BottomNavigation({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.onShow,
    this.onHide,
  });

  @override
  State<BottomNavigation> createState() => BottomNavigationState();
}

class BottomNavigationState extends State<BottomNavigation> {
  bool _isVisible = true;
  static const Duration _animationDuration = Duration(milliseconds: 200);

  // Expose methods for external control
  void showNavigation() {
    if (!_isVisible) {
      setState(() {
        _isVisible = true;
      });
      widget.onShow?.call();
    }
  }

  void hideNavigation() {
    if (_isVisible) {
      setState(() {
        _isVisible = false;
      });
      widget.onHide?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _animationDuration,
      curve: Curves.easeInOut,
      child: Transform.translate(
        offset: Offset(0, _isVisible ? 0 : 200), // Move 200px down when hidden
        child: AppBottomNavigationBar(
          items: widget.items,
          selectedIndex: widget.selectedIndex,
          onDestinationSelected: widget.onDestinationSelected,
        ),
      ),
    );
  }
}
