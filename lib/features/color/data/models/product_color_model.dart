import 'package:flutter_ecommerce/features/color/domain/entities/product_color_entity.dart';

class ProductColorModel extends ProductColorEntity {
  const ProductColorModel({
    super.id,
    required super.name,
    required super.hexCode,
  });

  factory ProductColorModel.fromJson(Map<String, dynamic> json) {
    return ProductColorModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      hexCode: json['hexCode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hexCode': hexCode,
    };
  }

  factory ProductColorModel.fromEntity(ProductColorEntity entity) {
    return ProductColorModel(
      id: entity.id,
      name: entity.name,
      hexCode: entity.hexCode,
    );
  }
}
