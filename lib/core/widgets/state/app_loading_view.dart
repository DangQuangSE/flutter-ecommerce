import 'package:flutter/material.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';

class AppLoadingView extends StatelessWidget {
  final double? size;

  const AppLoadingView({
    super.key,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final progress = CircularProgressIndicator(
      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
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
