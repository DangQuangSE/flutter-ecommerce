import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/order_status_label.dart';
import 'package:flutter_ecommerce/features/order/domain/entities/order_entity.dart';
import 'package:flutter_ecommerce/features/order/domain/entities/order_item_entity.dart';
import 'package:flutter_ecommerce/features/order/presentation/widgets/detail/order_detail_bottom_bar.dart';
import 'package:flutter_ecommerce/features/order/presentation/widgets/detail/order_detail_item_card.dart';
import 'package:flutter_ecommerce/features/order/presentation/widgets/detail/order_detail_section.dart';
import 'package:flutter_ecommerce/features/order/presentation/widgets/detail/order_detail_summary.dart';
import 'package:flutter_ecommerce/features/order/presentation/widgets/detail/order_status_card.dart';

class OrderDetailBody extends StatelessWidget {
  final OrderEntity order;
  final void Function(BuildContext context, OrderItemEntity item)
      onReviewRequested;
  final VoidCallback? onCancelRequested;

  const OrderDetailBody({
    super.key,
    required this.order,
    required this.onReviewRequested,
    this.onCancelRequested,
  });

  @override
  Widget build(BuildContext context) {
    final (_, statusColor) = OrderStatusLabel.badgeColors(order.status);
    final statusLabel = OrderStatusLabel.vi(order.status);
    final dateStr = DateFormat('dd/MM/yyyy').format(order.createdAt);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                OrderStatusCard(
                  statusLabel: statusLabel,
                  statusColor: statusColor,
                ),
                const SizedBox(height: 16),
                OrderDetailSection(
                  title: AppStrings.orderInfoSectionTitle,
                  icon: Icons.receipt_long_outlined,
                  children: [
                    OrderDetailRow(
                      label: AppStrings.orderCodeLabel,
                      value: order.displayCode,
                    ),
                    OrderDetailRow(
                      label: AppStrings.orderDateLabel,
                      value: dateStr,
                    ),
                    OrderDetailRow(
                      label: AppStrings.orderPaymentMethodLabel,
                      value: OrderStatusLabel.paymentMethodVi(
                        order.paymentMethod,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OrderDetailSection(
                  title: AppStrings.orderShippingAddressSectionTitle,
                  icon: Icons.location_on_outlined,
                  children: [
                    OrderDetailRow(
                      label: AppStrings.orderShippingAddressLabel,
                      value: order.shippingAddress,
                    ),
                    if (order.phoneNumber.isNotEmpty)
                      OrderDetailRow(
                        label: 'S\u1ed1 \u0111i\u1ec7n tho\u1ea1i',
                        value: order.phoneNumber,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                OrderDetailSection(
                  title: AppStrings.orderProductsSectionTitle(
                    order.items.length,
                  ),
                  icon: Icons.shopping_bag_outlined,
                  children: order.items
                      .map(
                        (item) => OrderDetailItemCard(
                          order: order,
                          item: item,
                          onReviewRequested: () =>
                              onReviewRequested(context, item),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                OrderDetailSummary(order: order),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        OrderDetailBottomBar(
          order: order,
          onCancelRequested: onCancelRequested,
        ),
      ],
    );
  }
}
