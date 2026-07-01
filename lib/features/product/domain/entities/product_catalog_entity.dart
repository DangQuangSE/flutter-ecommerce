import 'package:equatable/equatable.dart';

class ProductCatalogEntity extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? sku;
  final double basePrice;
  final double originalPrice;
  final double? salePrice;
  final String? imageUrl;
  final String categoryName;
  final String brandName;
  final int totalStock;
  final double averageRating;
  final int? reviewCount;
  final String status;
  final String? gender;
  final List<String> availableSizes;
  final List<String> availableColors;

  const ProductCatalogEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.sku,
    required this.basePrice,
    required this.originalPrice,
    required this.salePrice,
    this.imageUrl,
    required this.categoryName,
    required this.brandName,
    required this.totalStock,
    required this.averageRating,
    this.reviewCount,
    required this.status,
    this.gender,
    required this.availableSizes,
    required this.availableColors,
  });

  bool get hasDiscount => salePrice != null && salePrice! < originalPrice;

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        sku,
        basePrice,
        originalPrice,
        salePrice,
        imageUrl,
        categoryName,
        brandName,
        totalStock,
        averageRating,
        reviewCount,
        status,
        gender,
        availableSizes,
        availableColors,
      ];
}
