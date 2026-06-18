import 'package:flutter_ecommerce/features/order/domain/entities/order_item_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.productName,
    required super.size,
    required super.color,
    required super.quantity,
    required super.price,
    super.imageUrl,
    super.isReviewed,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int,
      productName: json['productName'] as String? ?? '',
      size: json['size'] as String? ?? '',
      color: json['color'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['designImageUrl'] as String?,
      isReviewed: json['isReviewed'] as bool? ?? false,
    );
  }
}
