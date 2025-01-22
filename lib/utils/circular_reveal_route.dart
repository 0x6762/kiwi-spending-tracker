import 'package:flutter/material.dart';

class CircularRevealRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Offset center;

  CircularRevealRoute({
    required this.child,
    required this.center,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          opaque: false,
          barrierDismissible: false,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideAnimation = Tween(
              begin: center,
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ));

            final fadeAnimation = Tween(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ));

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return ClipPath(
                  clipper: CircularRevealClipper(
                    fraction: animation.value,
                    center: center,
                  ),
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: Transform.translate(
                      offset: Offset(
                        slideAnimation.value.dx * (1 - animation.value),
                        slideAnimation.value.dy * (1 - animation.value),
                      ),
                      child: child,
                    ),
                  ),
                );
              },
              child: child,
            );
          },
        );
}

class CircularRevealClipper extends CustomClipper<Path> {
  final double fraction;
  final Offset center;

  CircularRevealClipper({
    required this.fraction,
    required this.center,
  });

  @override
  Path getClip(Size size) {
    final maxRadius = _calcMaxRadius(size, center);
    final radius = fraction * maxRadius;
    final path = Path();

    if (radius == 0) {
      path.addRect(Rect.fromLTWH(0, 0, 0, 0));
    } else {
      path.addOval(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
      );
    }

    return path;
  }

  double _calcMaxRadius(Size size, Offset center) {
    final points = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];

    double maxDistance = 0;
    for (final point in points) {
      final distance = (point - center).distance;
      if (distance > maxDistance) {
        maxDistance = distance;
      }
    }
    return maxDistance;
  }

  @override
  bool shouldReclip(CircularRevealClipper oldClipper) {
    return oldClipper.fraction != fraction || oldClipper.center != center;
  }
}
