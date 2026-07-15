import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/order_status_label.dart';
import 'package:flutter_ecommerce/features/admin/domain/entities/admin_order_entity.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_order_cubit.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_order_state.dart';
import 'package:flutter_ecommerce/features/admin/presentation/widgets/admin_order_item_card.dart';

class AdminOrderDetailPage extends StatelessWidget {
  final String orderId;

  const AdminOrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppStrings.adminOrderDetailTitle,
          style: GoogleFonts.lexend(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: AppSizes.fontXxl,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocConsumer<AdminOrderCubit, AdminOrderState>(
        listener: (context, state) {
          if (state is AdminOrderDetailLoaded && state.message != null) {
            final isSuccess =
                state.message == AppStrings.adminOrderStatusUpdated;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor:
                    isSuccess ? AppColors.success : AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminOrderDetailLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is AdminOrderDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, textAlign: TextAlign.center),
                  SizedBox(height: AppSizes.spacing12),
                  FilledButton(
                    onPressed: () => context
                        .read<AdminOrderCubit>()
                        .refreshDetail(int.parse(orderId)),
                    child: Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }

          if (state is AdminOrderDetailLoaded) {
            return _OrderDetailBody(
              order: state.order,
              isUpdating: state.isUpdatingStatus,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OrderDetailBody extends StatelessWidget {
  final AdminOrderEntity order;
  final bool isUpdating;

  const _OrderDetailBody({
    required this.order,
    required this.isUpdating,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final (badgeBg, badgeText) = OrderStatusLabel.badgeColors(order.status);

    return RefreshIndicator(
      onRefresh: () =>
          context.read<AdminOrderCubit>().refreshDetail(order.id),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _OrderHeaderCard(
              order: order,
              dateFormat: dateFormat,
              badgeBg: badgeBg,
              badgeText: badgeText,
            ),
            const SizedBox(height: 16),
            _Section(
              title: AppStrings.adminOrderInfoSection,
              icon: Icons.receipt_long_outlined,
              children: [
                _DetailRow(
                    label: AppStrings.adminOrderCodeLabel,
                    value: order.displayCode),
                _DetailRow(
                    label: AppStrings.adminOrderCustomerNameLabel,
                    value: order.displayCustomerName),
                _DetailRow(
                    label: AppStrings.adminOrderPhoneLabel,
                    value: order.phoneNumber),
                _DetailRow(
                  label: AppStrings.adminOrderPaymentLabel,
                  value: OrderStatusLabel.paymentMethodVi(order.paymentMethod),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: AppStrings.adminOrderAddressSection,
              icon: Icons.location_on_outlined,
              children: [
                _DetailRow(
                    label: AppStrings.adminOrderAddressLabel,
                    value: order.shippingAddress),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: AppStrings.adminOrderItemsSection(order.items.length),
              icon: Icons.shopping_bag_outlined,
              children: order.items
                  .map((item) => AdminOrderItemCard(
                        orderId: order.id,
                        item: item,
                        currencyFormat: currencyFormat,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            _OrderTotalCard(
                totalAmount: order.totalAmount, currencyFormat: currencyFormat),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: isUpdating
                  ? null
                  : () => showAdminOrderStatusSheet(context, order),
              icon: isUpdating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.edit_rounded),
              label: Text(
                isUpdating
                    ? AppStrings.adminOrderUpdating
                    : AppStrings.adminOrderUpdateStatus,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OrderHeaderCard extends StatelessWidget {
  final AdminOrderEntity order;
  final DateFormat dateFormat;
  final Color badgeBg;
  final Color badgeText;

  const _OrderHeaderCard({
    required this.order,
    required this.dateFormat,
    required this.badgeBg,
    required this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.displayCode,
                  style: GoogleFonts.lexend(
                    fontSize: AppSizes.fontXxl,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(order.createdAt),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing10,
                vertical: AppSizes.paddingXs),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(AppSizes.radius8),
            ),
            child: Text(
              OrderStatusLabel.vi(order.status),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: badgeText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTotalCard extends StatelessWidget {
  final num totalAmount;
  final NumberFormat currencyFormat;

  const _OrderTotalCard({
    required this.totalAmount,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.adminOrderTotalLabel,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            currencyFormat.format(totalAmount),
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
