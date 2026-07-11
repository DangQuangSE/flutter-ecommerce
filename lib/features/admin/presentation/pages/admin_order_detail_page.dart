import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/order_status_label.dart';
import 'package:flutter_ecommerce/features/admin/domain/entities/admin_order_entity.dart';
import 'package:flutter_ecommerce/features/admin/domain/entities/admin_order_item_entity.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_order_cubit.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_order_state.dart';

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
      onRefresh: () => context.read<AdminOrderCubit>().refreshDetail(order.id),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
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
                        SizedBox(height: 4),
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
            ),
            SizedBox(height: 16),
            _Section(
              title: AppStrings.adminOrderInfoSection,
              icon: Icons.receipt_long_outlined,
              children: [
                _DetailRow(
                  label: AppStrings.adminOrderCodeLabel,
                  value: order.displayCode,
                ),
                _DetailRow(
                  label: AppStrings.adminOrderCustomerNameLabel,
                  value: order.displayCustomerName,
                ),
                _DetailRow(
                  label: AppStrings.adminOrderPhoneLabel,
                  value: order.phoneNumber,
                ),
                _DetailRow(
                  label: AppStrings.adminOrderPaymentLabel,
                  value: OrderStatusLabel.paymentMethodVi(order.paymentMethod),
                ),
              ],
            ),
            SizedBox(height: 16),
            _Section(
              title: AppStrings.adminOrderAddressSection,
              icon: Icons.location_on_outlined,
              children: [
                _DetailRow(label: AppStrings.adminOrderAddressLabel, value: order.shippingAddress),
              ],
            ),
            SizedBox(height: 16),
            _Section(
              title: AppStrings.adminOrderItemsSection(order.items.length),
              icon: Icons.shopping_bag_outlined,
              children: order.items
                  .map((item) => _ItemCard(
                        item: item,
                        currencyFormat: currencyFormat,
                      ))
                  .toList(),
            ),
            SizedBox(height: 16),
            Container(
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
                    currencyFormat.format(order.totalAmount),
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            FilledButton.icon(
              onPressed:
                  isUpdating ? null : () => _showStatusSheet(context, order),
              icon: isUpdating
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.edit_rounded),
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
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _showStatusSheet(
    BuildContext context,
    AdminOrderEntity order,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (context) {
        final maxHeight = MediaQuery.sizeOf(context).height *
            AppSizes.bottomSheetMaxHeightRatio;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMd),
                  child: Text(
                    AppStrings.adminOrderSelectStatus,
                    style: GoogleFonts.lexend(
                      fontSize: AppSizes.fontXl,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: OrderStatusLabel.allStatuses.length,
                    itemBuilder: (context, index) {
                      final status = OrderStatusLabel.allStatuses[index];
                      return ListTile(
                        title: Text(OrderStatusLabel.vi(status)),
                        trailing: order.status == status
                            ? Icon(
                                Icons.check_rounded,
                                color: AppColors.primary,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, status),
                      );
                    },
                  ),
                ),
                SizedBox(height: AppSizes.paddingSm),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || selected == order.status || !context.mounted) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.confirm),
        content: Text(
          AppStrings.adminOrderStatusChangeConfirm(
            OrderStatusLabel.vi(selected),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AdminOrderCubit>().updateStatus(order.id, selected);
    }
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
              SizedBox(width: 8),
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
          SizedBox(height: 12),
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

class _ItemCard extends StatelessWidget {
  final AdminOrderItemEntity item;
  final NumberFormat currencyFormat;

  const _ItemCard({
    required this.item,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.designImageUrl != null
                ? Image.network(
                    item.designImageUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(context),
                  )
                : _placeholder(context),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '${item.size} · ${item.color} · x${item.quantity}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (item.hasCustomPrinting) ...[
                  SizedBox(height: 4),
                  Text(
                    AppStrings.orderCustomPrinting(
                      item.customDesignId!,
                      currencyFormat.format(item.printingLineTotal),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            currencyFormat.format(item.productLineTotal),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      color: Theme.of(context).colorScheme.surface,
      child: Icon(Icons.image_outlined, color: AppColors.textSecondary),
    );
  }
}
