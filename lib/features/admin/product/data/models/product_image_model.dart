import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_image_entity.dart';

class ProductImageModel {
  final int id;
  final String imageUrl;
  final bool isThumbnail;
  final int sortOrder;

  const ProductImageModel({
    required this.id,
    required this.imageUrl,
    required this.isThumbnail,
    required this.sortOrder,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: (json['id'] as num).toInt(),
      imageUrl: json['imageUrl'] as String,
      isThumbnail: json['isThumbnail'] as bool? ?? false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  ProductImageEntity toEntity() => ProductImageEntity(
        id: id,
        imageUrl: imageUrl,
        isThumbnail: isThumbnail,
        sortOrder: sortOrder,
      );
}
