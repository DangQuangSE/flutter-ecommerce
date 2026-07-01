import 'package:flutter/material.dart';

import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_empty_view.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_error_view.dart';

class CouponEmptyView extends StatelessWidget {
  final VoidCallback onCreate;

  const CouponEmptyView({
    super.key,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) => AppEmptyView(
        icon: Icons.local_offer_outlined,
        title: AppStrings.adminCouponEmptyTitle,
        message: AppStrings.adminCouponEmptyMessage,
        actionLabel: AppStrings.adminCouponAdd,
        onAction: onCreate,
      );
}

class CouponErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const CouponErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => AppErrorView(
        title: AppStrings.adminCouponLoadErrorTitle,
        message: message,
        onRetry: onRetry,
      );
}
