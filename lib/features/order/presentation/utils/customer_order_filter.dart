import 'package:flutter_ecommerce/features/order/domain/entities/order_entity.dart';

abstract final class CustomerOrderFilter {
  static const pills = [
    'Tất cả',
    'Xác nhận',
    'Đang xử lý',
    'Đang giao',
    'Đã giao',
    'Đã hủy',
    'Yêu cầu trả hàng',
    'Đã trả hàng',
    'Đã hoàn tiền',
  ];

  static const defaultPill = 'Tất cả';

  static bool matches(String pill, String rawStatus) {
    final status = rawStatus.toUpperCase();
    return switch (pill) {
      'Tất cả' => true,
      'Xác nhận' => status == 'CONFIRMED',
      'Đang xử lý' => status == 'PROCESSING',
      'Đang giao' => status == 'SHIPPED',
      'Đã giao' => status == 'DELIVERED',
      'Đã hủy' => status == 'CANCELLED',
      'Yêu cầu trả hàng' => status == 'RETURN_REQUESTED',
      'Đã trả hàng' => status == 'RETURNED',
      'Đã hoàn tiền' => status == 'REFUNDED',
      _ => true,
    };
  }

  static List<OrderEntity> apply(String pill, List<OrderEntity> orders) {
    if (pill == defaultPill) return orders;
    return orders.where((order) => matches(pill, order.status)).toList();
  }
}
