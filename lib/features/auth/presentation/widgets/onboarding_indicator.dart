import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';

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
    // Dynamic active colors matching the current background/slide stage
    final List<Color> activeColors = [
      const Color(0xFF1A73E8), // Electric Blue
      const Color(0xFF6D28D9), // Purple/Violet
      const Color(0xFFEA580C), // Orange/Sunset
    ];

    final int index1 = scrollOffset.floor().clamp(0, count - 1);
    final int index2 = scrollOffset.ceil().clamp(0, count - 1);
    final double t = (scrollOffset - index1).clamp(0.0, 1.0);
    final Color activeColor = Color.lerp(activeColors[index1], activeColors[index2], t) ?? activeColors[0];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        // Calculate dynamic proximity factor to current scroll position
        final double distance = (scrollOffset - index).abs();
        final double factor = (1.0 - distance).clamp(0.0, 1.0);

        // Interpolate width and color continuously
        final double width = 8.0 + (factor * 22.0); // Stretches from 8.0 to 30.0
        final Color color = Color.lerp(
          AppColors.textSecondary.withValues(alpha: 0.15),
          activeColor,
          factor,
        ) ?? AppColors.textSecondary.withValues(alpha: 0.15);

        return Transform(
          transform: Matrix4.skewX(-0.15), // Slanted premium pill look
          alignment: Alignment.center,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            width: width,
            height: 6.0,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3.0),
            ),
          ),
        );
      }),
    );
  }
}
