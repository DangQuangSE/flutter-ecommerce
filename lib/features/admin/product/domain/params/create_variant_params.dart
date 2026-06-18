import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';

class CreateVariantParams extends Equatable {
  final String sku;
  final String size;
  final int colorId;
  final double originalPrice;
  final int stockQuantity;
  final ProductStatus status;

  const CreateVariantParams({
    required this.sku,
    required this.size,
    required this.colorId,
    required this.originalPrice,
    required this.stockQuantity,
    required this.status,
  });

  @override
  List<Object?> get props =>
      [sku, size, colorId, originalPrice, stockQuantity, status];
}
