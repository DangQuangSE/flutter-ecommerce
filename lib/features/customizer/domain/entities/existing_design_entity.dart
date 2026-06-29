class ExistingDesignEntity {
  final String designMetadata;
  final String printingMaterialName;
  final int? printingMaterialId;
  final int numTextLines;
  final int numImages;
  final double totalPrintingPrice;

  const ExistingDesignEntity({
    required this.designMetadata,
    required this.printingMaterialName,
    this.printingMaterialId,
    this.numTextLines = 0,
    this.numImages = 0,
    this.totalPrintingPrice = 0.0,
  });
}
