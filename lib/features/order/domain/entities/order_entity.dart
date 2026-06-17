import 'package:equatable/equatable.dart';

import 'order_item_entity.dart';

class OrderEntity extends Equatable {
  final int id;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final String shippingAddress;
  final String phoneNumber;
  final String paymentMethod;
  final bool paymentCompleted;
  final List<OrderItemEntity> items;

  const OrderEntity({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.shippingAddress,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.paymentCompleted,
    required this.items,
  });

  String get displayCode => '#${id.toString().padLeft(4, '0')}';

  OrderItemEntity? get primaryItem => items.isNotEmpty ? items.first : null;

  double get subtotal =>
      items.fold<double>(0, (sum, item) => sum + item.lineTotal);

  @override
  List<Object?> get props => [
        id,
        status,
        totalAmount,
        createdAt,
        shippingAddress,
        phoneNumber,
        paymentMethod,
        paymentCompleted,
        items,
      ];
}
