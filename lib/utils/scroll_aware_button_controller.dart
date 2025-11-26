import 'package:flutter/material.dart';

/// Controller for managing scroll-aware button visibility with smart thresholds
class ScrollAwareButtonController {
  final AnimationController animationController;
  final double minScrollOffset;
  final double scrollThreshold;
  final VoidCallback? onShow;
  final VoidCallback? onHide;

  bool _isVisible = true;
  double _lastScrollOffset = 0;
  DateTime? _lastUpdateTime;

  static const Duration _debounceTime = Duration(milliseconds: 150);

  ScrollAwareButtonController({
    required this.animationController,
    this.minScrollOffset = 100.0, // Don't hide until scrolled 100px from top
    this.scrollThreshold = 10.0, // Minimum movement to trigger
    this.onShow,
    this.onHide,
  });

  bool get isVisible => _isVisible;

  /// Handle scroll updates - call this from scroll controller listener
  void handleScroll(ScrollMetrics metrics) {
    final now = DateTime.now();

    // Debounce rapid scroll events
    if (_lastUpdateTime != null &&
        now.difference(_lastUpdateTime!) < _debounceTime) {
      return;
    }

    final currentOffset = metrics.pixels;
    final scrollDelta = currentOffset - _lastScrollOffset;

    // Only process if movement exceeds threshold
    if (scrollDelta.abs() < scrollThreshold) {
      return;
    }

    _lastUpdateTime = now;

    // Determine scroll direction
    final isScrollingUp = scrollDelta < 0;
    final isScrollingDown = scrollDelta > 0;

    // Smart visibility logic
    if (isScrollingUp) {
      // Always show when scrolling up
      show();
    } else if (isScrollingDown) {
      // Only hide if we've scrolled past the minimum threshold from top
      if (currentOffset > minScrollOffset) {
        hide();
      }
    }

    _lastScrollOffset = currentOffset;
  }

  /// Show the button with animation
  void show() {
    if (!_isVisible) {
      _isVisible = true;
      animationController.reverse();
      onShow?.call();
    }
  }

  /// Hide the button with animation
  void hide() {
    if (_isVisible) {
      _isVisible = false;
      animationController.forward();
      onHide?.call();
    }
  }

  /// Reset controller state
  void reset() {
    _lastScrollOffset = 0;
    _lastUpdateTime = null;
    if (!_isVisible) {
      show();
    }
  }
}
