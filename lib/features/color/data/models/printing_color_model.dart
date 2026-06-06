import 'package:flutter_ecommerce/features/color/domain/entities/printing_color_entity.dart';

class PrintingColorModel extends PrintingColorEntity {
  const PrintingColorModel({
    super.id,
    required super.name,
    required super.hexCode,
    required super.isActive,
  });

  factory PrintingColorModel.fromJson(Map<String, dynamic> json) {
    return PrintingColorModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      hexCode: json['hexCode'] as String? ?? json['hex_code'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hexCode': hexCode,
      'isActive': isActive,
    };
  }

  factory PrintingColorModel.fromEntity(PrintingColorEntity entity) {
    return PrintingColorModel(
      id: entity.id,
      name: entity.name,
      hexCode: entity.hexCode,
      isActive: entity.isActive,
    );
  }
}
