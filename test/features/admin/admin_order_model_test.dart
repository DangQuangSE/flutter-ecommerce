import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/features/admin/data/models/admin_order_model.dart';
import 'package:flutter_ecommerce/features/checkout/data/models/order_request_model.dart';

void main() {
  group('OrderRequestModel', () {
    test('toJson includes customerName when provided', () {
      const model = OrderRequestModel(
        shippingAddress: '123 St',
        phoneNumber: '0987654321',
        customerName: 'Alex Mercer',
        paymentMethod: 'COD',
        cartItemIds: [1],
      );

      expect(model.toJson()['customerName'], 'Alex Mercer');
    });

    test('toJson omits customerName when empty', () {
      const model = OrderRequestModel(
        shippingAddress: '123 St',
        phoneNumber: '0987654321',
        customerName: '   ',
        paymentMethod: 'COD',
        cartItemIds: [1],
      );

      expect(model.toJson().containsKey('customerName'), isFalse);
    });
  });

  group('AdminOrderModel', () {
    test('fromJson parses customerName', () {
      final model = AdminOrderModel.fromJson({
        'id': 1,
        'shippingAddress': '123 St',
        'phoneNumber': '0987654321',
        'customerName': 'Alex Mercer',
        'totalAmount': 129000,
        'status': 'PENDING',
        'paymentMethod': 'BANK_TRANSFER',
        'createdAt': '2026-06-16T16:39:00',
        'items': [],
      });

      expect(model.customerName, 'Alex Mercer');
      expect(model.displayCustomerName, 'Alex Mercer');
    });

    test('displayCustomerName falls back to em dash when missing', () {
      final model = AdminOrderModel.fromJson({
        'id': 2,
        'shippingAddress': '123 St',
        'phoneNumber': '0987654321',
        'totalAmount': 129000,
        'status': 'PENDING',
        'paymentMethod': 'COD',
        'createdAt': '2026-06-16T16:39:00',
        'items': [],
      });

      expect(model.customerName, isNull);
      expect(model.displayCustomerName, '—');
    });
  });
}
