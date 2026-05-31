import 'package:equatable/equatable.dart';

class CustomizationEntity extends Equatable {
  final String productId;
  final String customText;
  final String textColor;
  final int colorHex;
  final String printMethod;
  final bool logoEnabled;
  final double textScale;

  const CustomizationEntity({
    required this.productId,
    required this.customText,
    required this.textColor,
    required this.colorHex,
    required this.printMethod,
    required this.logoEnabled,
    this.textScale = 1.0,
  });

  CustomizationEntity copyWith({
    String? productId,
    String? customText,
    String? textColor,
    int? colorHex,
    String? printMethod,
    bool? logoEnabled,
    double? textScale,
  }) {
    return CustomizationEntity(
      productId: productId ?? this.productId,
      customText: customText ?? this.customText,
      textColor: textColor ?? this.textColor,
      colorHex: colorHex ?? this.colorHex,
      printMethod: printMethod ?? this.printMethod,
      logoEnabled: logoEnabled ?? this.logoEnabled,
      textScale: textScale ?? this.textScale,
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
      ];
}
