import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/widgets/loaders/truck_loader.dart';

/// Full-page loading indicator using the animated truck loader.
/// For inline/small loading sprites, use [AppLoadingSpinner] instead.
class AppLoadingView extends StatelessWidget {
  final double? size;
  final Color color;

  const AppLoadingView({
    super.key,
    this.size,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    // Small inline spinners (< 40) keep a simple CircularProgressIndicator
    if (size != null && size! < 40) {
      return Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
        ),
      );
    }

    // Full-page loading shows the truck animation
    return const TruckLoadingOverlay();
  }
}
