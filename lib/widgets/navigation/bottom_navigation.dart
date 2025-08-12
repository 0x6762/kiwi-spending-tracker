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

class BottomNavigationState extends State<BottomNavigation>
    with SingleTickerProviderStateMixin {
  bool _isVisible = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  static const Duration _animationDuration = Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Expose methods for external control
  void showNavigation() {
    if (!_isVisible) {
      setState(() {
        _isVisible = true;
      });
      _animationController.reverse();
      widget.onShow?.call();
    }
  }

  void hideNavigation() {
    if (_isVisible) {
      setState(() {
        _isVisible = false;
      });
      _animationController.forward();
      widget.onHide?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: AppBottomNavigationBar(
                items: widget.items,
                selectedIndex: widget.selectedIndex,
                onDestinationSelected: widget.onDestinationSelected,
              ),
            ),
          ),
        );
      },
    );
  }
}
