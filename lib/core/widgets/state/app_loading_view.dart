import 'package:flutter/material.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';

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
    final progress = CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(color),
      strokeWidth: size == null ? 4 : 2.5,
    );

    return Center(
      child: size == null
          ? progress
          : SizedBox.square(
              dimension: size,
              child: progress,
            ),
    );
  }
}
