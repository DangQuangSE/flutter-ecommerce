import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final int itemId; // cart_item.id on backend (used for DELETE /items/{itemId})
  final int variantId; // product_variant.id (used for POST /items)
  final String productName;
  final String productSlug;
  final String? size;
  final String? color;
  final double originalPrice;
  final double salePrice;
  final int quantity;
  final double itemTotal;
  final String? imageUrl;
  final int? customDesignId;
  final String? designImageUrl;
  final double printingPrice;
  final bool isCustomizable;

  const CartItemEntity({
    required this.itemId,
    required this.variantId,
    required this.productName,
    required this.productSlug,
    this.size,
    this.color,
    required this.originalPrice,
    required this.salePrice,
    required this.quantity,
    required this.itemTotal,
    this.imageUrl,
    this.customDesignId,
    this.designImageUrl,
    this.printingPrice = 0,
    this.isCustomizable = false,
  });

  double get subtotal => itemTotal;
  double get price => salePrice > 0 ? salePrice : originalPrice;

  CartItemEntity copyWith({int? quantity}) => CartItemEntity(
        itemId: itemId,
        variantId: variantId,
        productName: productName,
        productSlug: productSlug,
        size: size,
        color: color,
        originalPrice: originalPrice,
        salePrice: salePrice,
        quantity: quantity ?? this.quantity,
        itemTotal: (salePrice > 0 ? salePrice : originalPrice) *
                (quantity ?? this.quantity) +
            printingPrice,
        imageUrl: imageUrl,
        customDesignId: customDesignId,
        designImageUrl: designImageUrl,
        printingPrice: printingPrice,
        isCustomizable: isCustomizable,
      );

  @override
  List<Object?> get props => [
        itemId,
        variantId,
        productName,
        quantity,
      ];
}
