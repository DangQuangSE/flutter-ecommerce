import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.itemId,
    required super.variantId,
    required super.productName,
    required super.productSlug,
    super.size,
    super.color,
    required super.originalPrice,
    required super.salePrice,
    required super.quantity,
    required super.itemTotal,
    super.imageUrl,
    super.customDesignId,
    super.designImageUrl,
    super.printingPrice,
    super.isCustomizable,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      itemId: (json['id'] as num).toInt(),
      variantId: (json['variantId'] as num).toInt(),
      productName: json['productName'] as String? ?? '',
      productSlug: json['productSlug'] as String? ?? '',
      size: json['size'] as String?,
      color: json['color'] as String?,
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0,
      salePrice: (json['salePrice'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num).toInt(),
      itemTotal: (json['itemTotal'] as num?)?.toDouble() ?? 0,
      imageUrl: json['productImageUrl'] as String?,
      customDesignId: (json['customDesignId'] as num?)?.toInt(),
      designImageUrl: json['designImageUrl'] as String?,
      printingPrice: (json['printingPrice'] as num?)?.toDouble() ?? 0,
      isCustomizable: json['isCustomizable'] as bool? ?? false,
    );
  }
}
