import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/widgets/app_state_view.dart';

class CheckoutEmptyState extends StatelessWidget {
  const CheckoutEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateView(
      icon: Icons.shopping_bag_outlined,
      title: 'ÄÆ N HÃ€NG Rá»–NG',
      message:
          'KhÃ´ng tÃ¬m tháº¥y sáº£n pháº©m nÃ o Ä‘á»ƒ thanh toÃ¡n. HÃ£y quay vá» giá» hÃ ng hoáº·c tiáº¿p tá»¥c mua sáº¯m nhÃ©!',
      actionLabel: 'QUAY Láº I MUA Sáº®M',
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
      title: 'KhÃ´ng thá»ƒ táº£i thÃ´ng tin thanh toÃ¡n.',
      message: message,
      actionLabel: 'Thá»­ láº¡i',
      iconColor: AppColors.error,
      onAction: onRetry,
    );
  }
}
