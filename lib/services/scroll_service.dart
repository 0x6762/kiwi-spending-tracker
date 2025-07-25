import 'package:flutter/material.dart';

class ScrollService extends ChangeNotifier {
  double _scrollOffset = 0;
  double _lastScrollOffset = 0;
  static const double _maxScrollDistance = 100.0; // Distance to fully hide nav

  double get scrollOffset => _scrollOffset;
  double get navigationOpacity => (1.0 - (_scrollOffset / _maxScrollDistance)).clamp(0.0, 1.0);
  bool get isNavigationVisible => navigationOpacity > 0.0;

  void handleScroll(ScrollNotification scrollInfo) {
    final currentOffset = scrollInfo.metrics.pixels;
    final scrollDelta = currentOffset - _lastScrollOffset;

    // Update scroll offset proportionally
    if (scrollDelta > 0) {
      // Scrolling down - increase offset (hide nav)
      _scrollOffset = (_scrollOffset + scrollDelta).clamp(0.0, _maxScrollDistance);
    } else if (scrollDelta < 0) {
      // Scrolling up - decrease offset (show nav)
      _scrollOffset = (_scrollOffset + scrollDelta).clamp(0.0, _maxScrollDistance);
    }

    _lastScrollOffset = currentOffset;
    notifyListeners();
  }

  void showNavigation() {
    _scrollOffset = 0.0;
    notifyListeners();
  }

  void hideNavigation() {
    _scrollOffset = _maxScrollDistance;
    notifyListeners();
  }
} 