import 'package:flutter/material.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';

enum AppSnackBarType { success, error, warning, info }

abstract final class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: _backgroundColor(type),
          behavior: SnackBarBehavior.floating,
          duration: duration,
        ),
      );
  }

  static Color _backgroundColor(AppSnackBarType type) => switch (type) {
        AppSnackBarType.success => AppColors.success,
        AppSnackBarType.error => AppColors.error,
        AppSnackBarType.warning => AppColors.warning,
        AppSnackBarType.info => AppColors.textSecondary,
      };
}
