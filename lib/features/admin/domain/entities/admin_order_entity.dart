import 'package:equatable/equatable.dart';

import 'admin_order_item_entity.dart';

class AdminOrderEntity extends Equatable {
  final int id;
  final String shippingAddress;
  final String phoneNumber;
  final String? customerName;
  final double totalAmount;
  final String status;
  final String paymentMethod;
  final DateTime createdAt;
  final List<AdminOrderItemEntity> items;

  const AdminOrderEntity({
    required this.id,
    required this.shippingAddress,
    required this.phoneNumber,
    this.customerName,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    required this.items,
  });

  String get displayCode => '#${id.toString().padLeft(4, '0')}';

  String get displayCustomerName {
    final name = customerName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return '—';
  }

  String get primaryProductName =>
      items.isNotEmpty ? items.first.productName : 'Không có sản phẩm';

  @override
  List<Object?> get props => [
        id,
        shippingAddress,
        phoneNumber,
        customerName,
        totalAmount,
        status,
        paymentMethod,
        createdAt,
        items,
      ];
}
