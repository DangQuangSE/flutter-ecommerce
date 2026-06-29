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

  @override
  List<Object?> get props => [materials, priceConfigs, colors];
}
