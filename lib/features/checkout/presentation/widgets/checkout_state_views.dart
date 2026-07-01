import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/app_state_view.dart';

class CheckoutEmptyState extends StatelessWidget {
  const CheckoutEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateView(
      icon: Icons.shopping_bag_outlined,
      title: AppStrings.checkoutEmptyTitle,
      message: AppStrings.checkoutEmptyMessage,
      actionLabel: AppStrings.checkoutBackToShopping,
      actionColor: AppColors.accent,
      onAction: () => context.goNamed(AppRoutes.productList),
    );
  }
}

class CheckoutErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const CheckoutErrorStateView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppStateView(
      icon: Icons.error_outline_rounded,
      title: AppStrings.checkoutLoadErrorTitle,
      message: message,
      actionLabel: AppStrings.checkoutRetry,
      iconColor: AppColors.error,
      onAction: onRetry,
    );
  }
}
