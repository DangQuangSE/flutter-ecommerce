import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/order/presentation/bloc/order_bloc.dart';
import 'package:flutter_ecommerce/features/order/presentation/bloc/order_event.dart';
import 'package:flutter_ecommerce/features/order/presentation/bloc/order_state.dart';
import 'package:flutter_ecommerce/features/order/presentation/widgets/list/order_list_item.dart';

class OrderListStateView extends StatelessWidget {
  final OrderState state;

  const OrderListStateView({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      OrderListLoading() => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.iconXxl),
          child: AppLoadingView(),
        ),
      OrderListError(:final message) => _ErrorState(message: message),
      OrderListLoaded(:final orders, :final isLoadingMore, :final message) =>
        Column(
          children: [
            if (message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  message,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (orders.isEmpty)
              const _EmptyState()
            else
              OrdersList(orders: orders),
            if (isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: AppLoadingView(size: AppSizes.paddingXl),
              ),
          ],
        ),
      _ => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.iconXxl),
          child: AppLoadingView(),
        ),
    };
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return _MessageCard(
      icon: Icons.error_outline,
      iconColor: AppColors.error,
      title: message,
      action: ElevatedButton(
        onPressed: () {
          context.read<OrderBloc>().add(const OrderListRequested());
        },
        child: Text(AppStrings.retry),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const _MessageCard(
      icon: Icons.receipt_long_outlined,
      iconColor: AppColors.textHint,
      title: AppStrings.orderEmptyTitle,
      subtitle: AppStrings.orderEmptySubtitle,
    );
  }
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? action;

  const _MessageCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.paddingXl),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppSizes.iconXxl, color: iconColor),
          SizedBox(height: AppSizes.paddingMd),
          Text(
            title,
            style: GoogleFonts.lexend(
              color: AppColors.textPrimary,
              fontSize: AppSizes.submitButtonFontSize,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            SizedBox(height: AppSizes.radiusSm),
            Text(
              subtitle!,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontMd,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            SizedBox(height: AppSizes.paddingMd),
            action!,
          ],
        ],
      ),
    );
  }
}
