import 'package:flutter_ecommerce/features/customizer/domain/entities/customization_entity.dart';

class CustomizationModel {
  final String productId;
  final String customText;
  final String textColor;
  final int colorHex;
  final String printMethod;
  final bool logoEnabled;
  final double textScale;
  final String layersJson;
  final int? customDesignId;

  const CustomizationModel({
    required this.productId,
    required this.customText,
    required this.textColor,
    required this.colorHex,
    required this.printMethod,
    required this.logoEnabled,
    this.textScale = 1.0,
    this.layersJson = '',
    this.customDesignId,
  });

  factory CustomizationModel.fromJson(Map<String, dynamic> json) {
    return CustomizationModel(
      productId: json['productId'] as String? ?? '',
      customText: json['customText'] as String? ?? '',
      textColor: json['textColor'] as String? ?? '',
      colorHex: json['colorHex'] as int? ?? 0xFF1A1C1F,
      printMethod: json['printMethod'] as String? ?? 'In chuyển nhiệt',
      logoEnabled: json['logoEnabled'] as bool? ?? false,
      textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
      layersJson: json['layersJson'] as String? ?? '',
      customDesignId: json['customDesignId'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'customText': customText,
        'textColor': textColor,
        'colorHex': colorHex,
        'printMethod': printMethod,
        'logoEnabled': logoEnabled,
        'textScale': textScale,
        'layersJson': layersJson,
        if (customDesignId != null) 'customDesignId': customDesignId,
      };

  CustomizationEntity toEntity() => CustomizationEntity(
        productId: productId,
        customText: customText,
        textColor: textColor,
        colorHex: colorHex,
        printMethod: printMethod,
        logoEnabled: logoEnabled,
        textScale: textScale,
        layersJson: layersJson,
        customDesignId: customDesignId,
      );

  factory CustomizationModel.fromEntity(CustomizationEntity entity) =>
      CustomizationModel(
        productId: entity.productId,
        customText: entity.customText,
        textColor: entity.textColor,
        colorHex: entity.colorHex,
        printMethod: entity.printMethod,
        logoEnabled: entity.logoEnabled,
        textScale: entity.textScale,
        layersJson: entity.layersJson,
        customDesignId: entity.customDesignId,
      );
}
