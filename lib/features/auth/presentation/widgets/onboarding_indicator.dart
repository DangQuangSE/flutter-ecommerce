import 'package:flutter/material.dart';

class OnboardingIndicator extends StatelessWidget {
  final int count;
  final double scrollOffset;

  const OnboardingIndicator({
    super.key,
    required this.count,
    required this.scrollOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        // Calculate dynamic proximity factor to current scroll position
        final double distance = (scrollOffset - index).abs();
        final double factor = (1.0 - distance).clamp(0.0, 1.0);

        // Interpolate width and opacity continuously
        final double width = 6.0 + (factor * 16.0); // Stretches from 6.0 (circle) to 22.0 (capsule pill)
        final Color color = Colors.white.withValues(
          alpha: 0.2 + (factor * 0.8), // Blends from 0.2 opacity (inactive) to 1.0 (active)
        );

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: width,
          height: 6.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10.0), // Rounded pill/circle
          ),
        );
      }),
    );
  }
}
