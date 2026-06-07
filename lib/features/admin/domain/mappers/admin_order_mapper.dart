import 'package:flutter_ecommerce/core/utils/order_status_label.dart';
import 'package:flutter_ecommerce/features/admin/domain/entities/admin_order_entity.dart';
import 'package:flutter_ecommerce/features/admin/domain/entities/recent_order_entity.dart';

RecentOrderEntity adminOrderToRecentOrder(AdminOrderEntity order) {
  return RecentOrderEntity(
    id: order.id.toString(),
    orderCode: order.displayCode,
    productName: order.primaryProductName,
    rawStatus: order.status,
    status: OrderStatusLabel.vi(order.status),
    price: order.totalAmount,
    date: order.createdAt,
  );
}
