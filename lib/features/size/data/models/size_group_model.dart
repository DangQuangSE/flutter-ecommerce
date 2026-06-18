import 'package:flutter_ecommerce/features/size/data/models/size_option_model.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_group_entity.dart';

class SizeGroupModel extends SizeGroupEntity {
  const SizeGroupModel({
    super.id,
    required super.name,
    super.description,
    super.sizes = const [],
  });

  factory SizeGroupModel.fromJson(Map<String, dynamic> json) {
    final rawSizes = json['sizes'] as List<dynamic>? ?? [];
    return SizeGroupModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      sizes: rawSizes
          .map((s) => SizeOptionModel.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'sizes':
            sizes.map((s) => SizeOptionModel.fromEntity(s).toJson()).toList(),
      };

  factory SizeGroupModel.fromEntity(SizeGroupEntity entity) {
    return SizeGroupModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      sizes: entity.sizes.map(SizeOptionModel.fromEntity).toList(),
    );
  }
}
