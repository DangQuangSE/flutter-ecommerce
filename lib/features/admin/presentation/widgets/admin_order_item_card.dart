import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/features/admin/domain/entities/admin_order_item_entity.dart';
import 'package:flutter_ecommerce/core/utils/order_status_label.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_order_cubit.dart';

/// Card displaying a single product item within an admin order.
class AdminOrderItemCard extends StatelessWidget {
  final int orderId;
  final AdminOrderItemEntity item;
  final NumberFormat currencyFormat;

  const AdminOrderItemCard({
    super.key,
    required this.orderId,
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
          const SizedBox(width: 12),
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
                const SizedBox(height: 4),
                Text(
                  '${item.size} · ${item.color} · x${item.quantity}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (item.hasCustomPrinting) ...[
                  const SizedBox(height: 4),
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
                  TextButton(
                    onPressed: () => context.pushNamed(
                      AppRoutes.adminOrderDesignViewer,
                      pathParameters: {
                        'orderId': orderId.toString(),
                        'designId': item.customDesignId.toString(),
                      },
                    ),
                    child: const Text(AppStrings.designViewerViewAction),
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

/// Shows the order status selection bottom sheet + confirmation dialog.
///
/// Returns after the user selects and confirms a new status, dispatching the
/// cubit update automatically. Call with a [context] that has [AdminOrderCubit].
Future<void> showAdminOrderStatusSheet(
  BuildContext context,
  dynamic order,
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
      final maxHeight =
          MediaQuery.sizeOf(context).height * AppSizes.bottomSheetMaxHeightRatio;
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
                          ? Icon(Icons.check_rounded, color: AppColors.primary)
                          : null,
                      onTap: () => Navigator.pop(context, status),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSizes.paddingSm),
            ],
          ),
        ),
      );
    },
  );

  if (selected == null || selected == order.status || !context.mounted) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(AppStrings.confirm),
      content: Text(AppStrings.adminOrderStatusChangeConfirm(OrderStatusLabel.vi(selected))),
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
