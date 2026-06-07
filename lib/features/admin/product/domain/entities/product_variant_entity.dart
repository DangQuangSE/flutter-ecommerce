import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';

class ProductVariantEntity extends Equatable {
  final int id;
  final String sku;
  final String size;
  final int colorId;
  final String colorName;
  final String colorHex;
  final double originalPrice;
  final double? salePrice;
  final int stockQuantity;
  final ProductStatus status;

  const ProductVariantEntity({
    required this.id,
    required this.sku,
    required this.size,
    required this.colorId,
    required this.colorName,
    required this.colorHex,
    required this.originalPrice,
    this.salePrice,
    required this.stockQuantity,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        sku,
        size,
        colorId,
        colorName,
        colorHex,
        originalPrice,
        salePrice,
        stockQuantity,
        status,
      ];
}
