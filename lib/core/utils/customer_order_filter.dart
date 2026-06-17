import 'package:flutter_ecommerce/features/order/domain/entities/order_entity.dart';

abstract final class CustomerOrderFilter {
  static const pills = [
    'Tất cả',
    'Xác nhận',
    'Đang xử lý',
    'Đang giao',
    'Đã giao',
    'Đã hủy',
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
      _ => true,
    };
  }

  static List<OrderEntity> apply(String pill, List<OrderEntity> orders) {
    if (pill == 'Tất cả') return orders;
    return orders.where((order) => matches(pill, order.status)).toList();
  }
}
