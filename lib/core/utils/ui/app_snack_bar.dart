import 'package:flutter/material.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';

enum AppSnackBarType { success, error, warning, info }

abstract final class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
    Duration duration = const Duration(seconds: 2),
    Widget? icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: icon == null
              ? Text(message)
              : Row(
                  children: [
                    icon,
                    const SizedBox(width: 10),
                    Expanded(child: Text(message)),
                  ],
                ),
          backgroundColor: _backgroundColor(type),
          behavior: SnackBarBehavior.floating,
          duration: duration,
          action: actionLabel != null && onAction != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: Colors.white,
                  onPressed: onAction,
                )
              : null,
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
