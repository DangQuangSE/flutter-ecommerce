import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_variant_entity.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryId;
  final int stockQuantity;
  final List<ProductVariantEntity>? variants;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    required this.stockQuantity,
    this.variants,
  });

  bool get isInStock => stockQuantity > 0;

  @override
  List<Object?> get props =>
      [id, name, description, price, imageUrl, categoryId, stockQuantity, variants];
}
