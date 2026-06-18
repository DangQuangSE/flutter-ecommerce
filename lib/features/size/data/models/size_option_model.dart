import 'package:flutter_ecommerce/features/size/domain/entities/size_option_entity.dart';

class SizeOptionModel extends SizeOptionEntity {
  const SizeOptionModel({
    super.id,
    required super.name,
    required super.displayOrder,
  });

  factory SizeOptionModel.fromJson(Map<String, dynamic> json) {
    return SizeOptionModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      displayOrder: json['displayOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'displayOrder': displayOrder,
      };

  factory SizeOptionModel.fromEntity(SizeOptionEntity entity) {
    return SizeOptionModel(
      id: entity.id,
      name: entity.name,
      displayOrder: entity.displayOrder,
    );
  }
}
