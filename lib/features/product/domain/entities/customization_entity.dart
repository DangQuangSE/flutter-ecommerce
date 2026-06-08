import 'package:equatable/equatable.dart';

class CustomizationEntity extends Equatable {
  final String productId;
  final String customText;
  final String textColor;
  final int colorHex;
  final String printMethod;
  final bool logoEnabled;
  final double textScale;
  final String layersJson;
  final int? customDesignId;

  const CustomizationEntity({
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

  CustomizationEntity copyWith({
    String? productId,
    String? customText,
    String? textColor,
    int? colorHex,
    String? printMethod,
    bool? logoEnabled,
    double? textScale,
    String? layersJson,
    int? customDesignId,
  }) {
    return CustomizationEntity(
      productId: productId ?? this.productId,
      customText: customText ?? this.customText,
      textColor: textColor ?? this.textColor,
      colorHex: colorHex ?? this.colorHex,
      printMethod: printMethod ?? this.printMethod,
      logoEnabled: logoEnabled ?? this.logoEnabled,
      textScale: textScale ?? this.textScale,
      layersJson: layersJson ?? this.layersJson,
      customDesignId: customDesignId ?? this.customDesignId,
    );
  }

  @override
  List<Object?> get props => [
        productId,
        customText,
        textColor,
        colorHex,
        printMethod,
        logoEnabled,
        textScale,
        layersJson,
        customDesignId,
      ];
}
