import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_variant_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';

class ProductVariantModel {
  final int id;
  final String sku;
  final String size;
  final int colorId;
  final String colorName;
  final String colorHex;
  final double originalPrice;
  final double? salePrice;
  final int stockQuantity;
  final String status;

  const ProductVariantModel({
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

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: (json['id'] as num).toInt(),
      sku: json['sku'] as String,
      size: json['size'] as String,
      colorId: (json['colorId'] as num).toInt(),
      colorName: json['colorName'] as String? ?? '',
      colorHex: json['colorHex'] as String? ?? '#000000',
      originalPrice: (json['originalPrice'] as num).toDouble(),
      salePrice: (json['salePrice'] as num?)?.toDouble(),
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }

  ProductVariantEntity toEntity() => ProductVariantEntity(
        id: id,
        sku: sku,
        size: size,
        colorId: colorId,
        colorName: colorName,
        colorHex: colorHex,
        originalPrice: originalPrice,
        salePrice: salePrice,
        stockQuantity: stockQuantity,
        status: ProductStatus.fromJson(status),
      );
}
