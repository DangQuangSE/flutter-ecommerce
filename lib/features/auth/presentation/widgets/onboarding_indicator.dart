import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';

class OnboardingIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const OnboardingIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isSelected = index == currentIndex;

        return Transform(
          transform: Matrix4.skewX(-0.15), // Premium slanted capsule shape
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: const Cubic(0.32, 0.72, 0, 1.0), // High-end spring physics curve
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            width: isSelected ? 28.0 : 8.0, // Stretches/morphs dynamically
            height: 6.0,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3.0),
            ),
          ),
        );
      }),
    );
  }
}
