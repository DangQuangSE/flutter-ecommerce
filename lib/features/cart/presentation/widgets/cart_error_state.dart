import 'package:flutter/material.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/app_state_view.dart';

class CartErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const CartErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppStateView(
      icon: Icons.error_outline_rounded,
      title: AppStrings.cartLoadErrorTitle,
      message: message,
      actionLabel: AppStrings.retry,
      iconColor: AppColors.error,
      onAction: onRetry,
    );
  }
}
