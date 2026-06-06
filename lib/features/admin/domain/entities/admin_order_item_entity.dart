import 'package:equatable/equatable.dart';

class AdminOrderItemEntity extends Equatable {
  final int id;
  final int productVariantId;
  final String productName;
  final String sku;
  final String size;
  final String color;
  final int quantity;
  final double price;
  final int? customDesignId;
  final String? designImageUrl;
  final double? printingPrice;

  const AdminOrderItemEntity({
    required this.id,
    required this.productVariantId,
    required this.productName,
    required this.sku,
    required this.size,
    required this.color,
    required this.quantity,
    required this.price,
    this.customDesignId,
    this.designImageUrl,
    this.printingPrice,
  });

  @override
  List<Object?> get props => [
        id,
        productVariantId,
        productName,
        sku,
        size,
        color,
        quantity,
        price,
        customDesignId,
        designImageUrl,
        printingPrice,
      ];
}
