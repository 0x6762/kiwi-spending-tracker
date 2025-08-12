import 'package:flutter/material.dart';

// Simple scroll direction detector that can be used with any scrollable widget
class ScrollDirectionDetector extends StatefulWidget {
  final Widget child;
  final Function(bool isScrollingUp) onScrollDirectionChanged;

  const ScrollDirectionDetector({
    super.key,
    required this.child,
    required this.onScrollDirectionChanged,
  });

  @override
  State<ScrollDirectionDetector> createState() =>
      _ScrollDirectionDetectorState();
}

class _ScrollDirectionDetectorState extends State<ScrollDirectionDetector> {
  double _lastScrollOffset = 0;
  DateTime? _lastUpdateTime;
  static const Duration _debounceTime = Duration(milliseconds: 150);

  bool _handleScroll(ScrollNotification scrollInfo) {
    final now = DateTime.now();

    // Debounce rapid scroll events
    if (_lastUpdateTime != null &&
        now.difference(_lastUpdateTime!) < _debounceTime) {
      return false;
    }

    final currentOffset = scrollInfo.metrics.pixels;
    final isScrollingUp = currentOffset < _lastScrollOffset;

    // Only update if we have a significant scroll and direction changed
    if ((currentOffset - _lastScrollOffset).abs() > 10) {
      _lastScrollOffset = currentOffset;
      _lastUpdateTime = now;
      widget.onScrollDirectionChanged(isScrollingUp);
    }

    return false; // Don't consume the notification
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScroll,
      child: widget.child,
    );
  }
}
