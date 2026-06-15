import 'package:equatable/equatable.dart';

class PrintingMaterialEntity extends Equatable {
  final int id;
  final String name;
  final String description;
  final double basePrice;
  final bool isActive;

  const PrintingMaterialEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.isActive,
  });

  factory PrintingMaterialEntity.fromJson(Map<String, dynamic> json) {
    return PrintingMaterialEntity(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, name, description, basePrice, isActive];
}

class PrintingPriceConfigEntity extends Equatable {
  final int id;
  final String type; // TEXT, IMAGE
  final double unitPrice;
  final String description;

  const PrintingPriceConfigEntity({
    required this.id,
    required this.type,
    required this.unitPrice,
    required this.description,
  });

  factory PrintingPriceConfigEntity.fromJson(Map<String, dynamic> json) {
    return PrintingPriceConfigEntity(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, type, unitPrice, description];
}

class PrintingColorEntity extends Equatable {
  final int id;
  final String name;
  final String hexCode;
  final bool isActive;

  const PrintingColorEntity({
    required this.id,
    required this.name,
    required this.hexCode,
    required this.isActive,
  });

  factory PrintingColorEntity.fromJson(Map<String, dynamic> json) {
    return PrintingColorEntity(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      hexCode: json['hexCode'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, name, hexCode, isActive];
}

class PrintingConfigEntity extends Equatable {
  final List<PrintingMaterialEntity> materials;
  final List<PrintingPriceConfigEntity> priceConfigs;
  final List<PrintingColorEntity> colors;

  const PrintingConfigEntity({
    required this.materials,
    required this.priceConfigs,
    required this.colors,
  });

  factory PrintingConfigEntity.fromJson(Map<String, dynamic> json) {
    final materialsList = (json['materials'] as List? ?? [])
        .map((e) => PrintingMaterialEntity.fromJson(e as Map<String, dynamic>))
        .toList();
    final priceConfigsList = (json['priceConfigs'] as List? ?? [])
        .map((e) => PrintingPriceConfigEntity.fromJson(e as Map<String, dynamic>))
        .toList();
    final colorsList = (json['colors'] as List? ?? [])
        .map((e) => PrintingColorEntity.fromJson(e as Map<String, dynamic>))
        .toList();
    return PrintingConfigEntity(
      materials: materialsList,
      priceConfigs: priceConfigsList,
      colors: colorsList,
    );
  }

  @override
  List<Object?> get props => [materials, priceConfigs, colors];
}
