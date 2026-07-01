import 'package:flutter/material.dart';

class LoginAnimatedEntrance extends StatelessWidget {
  final Widget child;
  final int delay;
  final AnimationController controller;

  const LoginAnimatedEntrance({
    super.key,
    required this.child,
    required this.delay,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final start = delay / 1000.0;
    final end = (delay + 450) / 1000.0;

    final curvedAnimation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        start.clamp(0.0, 1.0),
        end.clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: curvedAnimation.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 24 * (1.0 - curvedAnimation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
