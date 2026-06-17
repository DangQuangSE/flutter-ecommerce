import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/data/models/product_variant_model.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    super.imageUrls = const [],
    required super.categoryId,
    required super.stockQuantity,
    super.variants,
    super.numericId,
    super.averageRating = 0.0,
    super.reviewCount = 0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawVariants = json['variants'] as List<dynamic>? ?? [];
    return ProductModel(
      id: json['slug'] as String? ?? (json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: ((json['salePrice'] ??
              json['price'] ??
              json['basePrice'] ??
              json['minPrice'] ??
              0.0) as num)
          .toDouble(),
      imageUrl: json['imageUrl'] as String? ??
          json['thumbnailUrl'] as String? ??
          json['image_url'] as String? ??
          _extractThumbnail(json['images'] as List<dynamic>?),
      imageUrls: _extractAllImageUrls(json['images'] as List<dynamic>?),
      categoryId: (json['categoryId'] ?? json['category_id'] ?? '').toString(),
      stockQuantity: (json['totalStock'] ??
          json['stockQuantity'] ??
          json['stock_quantity'] ??
          0) as int,
      variants: rawVariants
          .map((e) => ProductVariantModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList(),
      numericId: int.tryParse((json['id'] ?? '').toString()),
      averageRating: ((json['averageRating'] ?? 0.0) as num).toDouble(),
      reviewCount: (json['reviewCount'] ?? 0) as int,
    );
  }

  static List<Map<String, dynamic>> _sortedImages(List<dynamic>? images) {
    if (images == null || images.isEmpty) return [];
    return (List<Map<String, dynamic>>.from(
      images.map((e) => e as Map<String, dynamic>),
    )..sort((a, b) => ((a['sortOrder'] as int?) ?? 0).compareTo((b['sortOrder'] as int?) ?? 0)));
  }

  static String _extractThumbnail(List<dynamic>? images) {
    final sorted = _sortedImages(images);
    if (sorted.isEmpty) return '';
    final thumb = sorted.firstWhere(
      (img) => img['isThumbnail'] == true,
      orElse: () => sorted.first,
    );
    return thumb['imageUrl'] as String? ?? '';
  }

  static List<String> _extractAllImageUrls(List<dynamic>? images) {
    return _sortedImages(images)
        .map((img) => img['imageUrl'] as String? ?? '')
        .where((url) => url.isNotEmpty)
        .toList();
  }
}
