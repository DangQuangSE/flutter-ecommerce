import 'package:flutter_ecommerce/features/customizer/domain/entities/printing_config_entity.dart';

class PrintingMaterialModel {
  final int id;
  final String name;
  final String description;
  final double basePrice;
  final bool isActive;

  const PrintingMaterialModel({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.isActive,
  });

  factory PrintingMaterialModel.fromJson(Map<String, dynamic> json) {
    return PrintingMaterialModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  PrintingMaterialEntity toEntity() {
    return PrintingMaterialEntity(
      id: id,
      name: name,
      description: description,
      basePrice: basePrice,
      isActive: isActive,
    );
  }
}

class PrintingPriceConfigModel {
  final int id;
  final String type;
  final double unitPrice;
  final String description;

  const PrintingPriceConfigModel({
    required this.id,
    required this.type,
    required this.unitPrice,
    required this.description,
  });

  factory PrintingPriceConfigModel.fromJson(Map<String, dynamic> json) {
    return PrintingPriceConfigModel(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
    );
  }

  PrintingPriceConfigEntity toEntity() {
    return PrintingPriceConfigEntity(
      id: id,
      type: type,
      unitPrice: unitPrice,
      description: description,
    );
  }
}

class PrintingColorModel {
  final int id;
  final String name;
  final String hexCode;
  final bool isActive;

  const PrintingColorModel({
    required this.id,
    required this.name,
    required this.hexCode,
    required this.isActive,
  });

  factory PrintingColorModel.fromJson(Map<String, dynamic> json) {
    return PrintingColorModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      hexCode: json['hexCode'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  PrintingColorEntity toEntity() {
    return PrintingColorEntity(
      id: id,
      name: name,
      hexCode: hexCode,
      isActive: isActive,
    );
  }
}

class PrintingConfigModel {
  final List<PrintingMaterialModel> materials;
  final List<PrintingPriceConfigModel> priceConfigs;
  final List<PrintingColorModel> colors;

  const PrintingConfigModel({
    required this.materials,
    required this.priceConfigs,
    required this.colors,
  });

  factory PrintingConfigModel.fromJson(Map<String, dynamic> json) {
    return PrintingConfigModel(
      materials: (json['materials'] as List? ?? [])
          .map((e) => PrintingMaterialModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      priceConfigs: (json['priceConfigs'] as List? ?? [])
          .map((e) =>
              PrintingPriceConfigModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      colors: (json['colors'] as List? ?? [])
          .map((e) => PrintingColorModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  PrintingConfigEntity toEntity() {
    return PrintingConfigEntity(
      materials: materials.map((e) => e.toEntity()).toList(),
      priceConfigs: priceConfigs.map((e) => e.toEntity()).toList(),
      colors: colors.map((e) => e.toEntity()).toList(),
    );
  }
}
