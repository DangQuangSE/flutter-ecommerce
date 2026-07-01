import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/app_state_view.dart';

class CartEmptyState extends StatelessWidget {
  const CartEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateView(
      icon: Icons.shopping_bag_outlined,
      title: AppStrings.cartEmptyTitle,
      message: AppStrings.cartEmptyMessage,
      actionLabel: AppStrings.continueShopping,
      actionColor: AppColors.accent,
      onAction: () => context.goNamed(AppRoutes.productList),
    );
  }
}
