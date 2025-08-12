import 'package:flutter/material.dart';

// Simple scroll direction detector that can be used with any scrollable widget
class ScrollDirectionDetector extends StatefulWidget {
  final Widget child;
  final Function(bool isScrollingUp) onScrollDirectionChanged;
  final ScrollController? scrollController; // Add optional scroll controller

  const ScrollDirectionDetector({
    super.key,
    required this.child,
    required this.onScrollDirectionChanged,
    this.scrollController, // Make it optional
  });

  @override
  State<ScrollDirectionDetector> createState() =>
      _ScrollDirectionDetectorState();
}

class _ScrollDirectionDetectorState extends State<ScrollDirectionDetector> {
  double _lastScrollOffset = 0;
  DateTime? _lastUpdateTime;
  static const Duration _debounceTime = Duration(milliseconds: 150);

  @override
  void initState() {
    super.initState();
    // If a scroll controller is provided, listen to it directly
    if (widget.scrollController != null) {
      widget.scrollController!.addListener(_onScrollChanged);
    }
  }

  @override
  void dispose() {
    if (widget.scrollController != null) {
      widget.scrollController!.removeListener(_onScrollChanged);
    }
    super.dispose();
  }

  void _onScrollChanged() {
    if (widget.scrollController == null) return;
    
    final now = DateTime.now();
    if (_lastUpdateTime != null &&
        now.difference(_lastUpdateTime!) < _debounceTime) {
      return;
    }

    final currentOffset = widget.scrollController!.offset;
    final isScrollingUp = currentOffset < _lastScrollOffset;

    if ((currentOffset - _lastScrollOffset).abs() > 10) {
      _lastScrollOffset = currentOffset;
      _lastUpdateTime = now;
      widget.onScrollDirectionChanged(isScrollingUp);
    }
  }

  bool _handleScroll(ScrollNotification scrollInfo) {
    // If we have a scroll controller, ignore scroll notifications
    // as we're listening to the controller directly
    if (widget.scrollController != null) {
      return false;
    }

    final now = DateTime.now();
    if (_lastUpdateTime != null &&
        now.difference(_lastUpdateTime!) < _debounceTime) {
      return false;
    }

    final currentOffset = scrollInfo.metrics.pixels;
    final isScrollingUp = currentOffset < _lastScrollOffset;

    if ((currentOffset - _lastScrollOffset).abs() > 10) {
      _lastScrollOffset = currentOffset;
      _lastUpdateTime = now;
      widget.onScrollDirectionChanged(isScrollingUp);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScroll,
      child: widget.child,
    );
  }
}
