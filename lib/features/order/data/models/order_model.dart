import 'package:flutter_ecommerce/features/order/data/models/order_item_model.dart';
import 'package:flutter_ecommerce/features/order/domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.status,
    required super.totalAmount,
    required super.createdAt,
    required super.shippingAddress,
    required super.phoneNumber,
    required super.paymentMethod,
    required super.paymentCompleted,
    required super.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List? ?? [];
    return OrderModel(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'PENDING',
      totalAmount: (json['totalAmount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      shippingAddress: json['shippingAddress'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      paymentCompleted: json['paymentCompleted'] as bool? ?? false,
      items: itemsJson
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
