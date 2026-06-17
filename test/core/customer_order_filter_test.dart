import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/core/utils/customer_order_filter.dart';
import 'package:flutter_ecommerce/features/order/domain/entities/order_entity.dart';

OrderEntity _order(String status) => OrderEntity(
      id: 1,
      status: status,
      totalAmount: 100,
      createdAt: DateTime(2026, 6, 1),
      shippingAddress: '',
      phoneNumber: '',
      paymentMethod: 'COD',
      paymentCompleted: false,
      items: const [],
    );

void main() {
  group('CustomerOrderFilter', () {
    test('matches CONFIRMED for Xác nhận pill', () {
      expect(CustomerOrderFilter.matches('Xác nhận', 'CONFIRMED'), isTrue);
      expect(CustomerOrderFilter.matches('Xác nhận', 'SHIPPED'), isFalse);
    });

    test('matches PROCESSING for Đang xử lý pill', () {
      expect(CustomerOrderFilter.matches('Đang xử lý', 'PROCESSING'), isTrue);
      expect(CustomerOrderFilter.matches('Đang xử lý', 'CONFIRMED'), isFalse);
    });

    test('apply filters orders by pill', () {
      final orders = [
        _order('CONFIRMED'),
        _order('SHIPPED'),
        _order('DELIVERED'),
      ];

      final confirmed = CustomerOrderFilter.apply('Xác nhận', orders);
      expect(confirmed, hasLength(1));
      expect(confirmed.first.status, 'CONFIRMED');

      final shipping = CustomerOrderFilter.apply('Đang giao', orders);
      expect(shipping, hasLength(1));
      expect(shipping.first.status, 'SHIPPED');
    });

    test('Tất cả returns all orders', () {
      final orders = [_order('PENDING'), _order('CANCELLED')];
      expect(CustomerOrderFilter.apply('Tất cả', orders), orders);
    });
  });
}
