import 'package:flutter_ecommerce/features/cart/data/models/cart_item_model.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';

/// Represents the full cart response from `GET /api/carts/me`.
class CartResponseModel {
  final int cartId;
  final List<CartItemEntity> items;
  final double totalAmount;
  final int totalItems;

  const CartResponseModel({
    required this.cartId,
    required this.items,
    required this.totalAmount,
    required this.totalItems,
  });

  factory CartResponseModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return CartResponseModel(
      cartId: (json['cartId'] as num).toInt(),
      items: rawItems
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
    );
  }
}
