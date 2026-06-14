import 'package:flutter_ecommerce/features/product/domain/entities/product_catalog_entity.dart';

class ProductCatalogModel {
  final int id;
  final String name;
  final String slug;
  final String? sku;
  final double basePrice;
  final double originalPrice;
  final double salePrice;
  final String? imageUrl;
  final String categoryName;
  final String brandName;
  final int totalStock;
  final double averageRating;
  final String status;
  final String? gender;
  final List<String> availableSizes;
  final List<String> availableColors;

  const ProductCatalogModel({
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
    required this.status,
    this.gender,
    required this.availableSizes,
    required this.availableColors,
  });

  factory ProductCatalogModel.fromJson(Map<String, dynamic> json) {
    return ProductCatalogModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      sku: json['sku'] as String?,
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0.0,
      salePrice: (json['salePrice'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String?,
      categoryName: json['categoryName'] as String? ?? '',
      brandName: json['brandName'] as String? ?? '',
      totalStock: (json['totalStock'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'ACTIVE',
      gender: json['gender'] as String?,
      availableSizes: (json['availableSizes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      availableColors: (json['availableColors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  ProductCatalogEntity toEntity() => ProductCatalogEntity(
        id: id,
        name: name,
        slug: slug,
        sku: sku,
        basePrice: basePrice,
        originalPrice: originalPrice,
        salePrice: salePrice,
        imageUrl: imageUrl,
        categoryName: categoryName,
        brandName: brandName,
        totalStock: totalStock,
        averageRating: averageRating,
        status: status,
        gender: gender,
        availableSizes: availableSizes,
        availableColors: availableColors,
      );
}
