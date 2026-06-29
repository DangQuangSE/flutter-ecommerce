class CustomDesignSpecEntity {
  final String materialName;
  final int numTextLines;
  final int numImages;
  final double totalPrintingPrice;
  final double materialBasePrice;
  final double textUnitPrice;
  final double imageUnitPrice;

  const CustomDesignSpecEntity({
    required this.materialName,
    required this.numTextLines,
    required this.numImages,
    required this.totalPrintingPrice,
    required this.materialBasePrice,
    required this.textUnitPrice,
    required this.imageUnitPrice,
  });
}
