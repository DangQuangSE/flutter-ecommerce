class ExistingDesignEntity {
  final String? designImageUrl;
  final String? backDesignImageUrl;
  final String designMetadata;
  final String backDesignMetadata;
  final String printingMaterialName;
  final int? printingMaterialId;
  final int numTextLines;
  final int numImages;
  final double totalPrintingPrice;

  const ExistingDesignEntity({
    this.designImageUrl,
    this.backDesignImageUrl,
    required this.designMetadata,
    this.backDesignMetadata = '',
    required this.printingMaterialName,
    this.printingMaterialId,
    this.numTextLines = 0,
    this.numImages = 0,
    this.totalPrintingPrice = 0.0,
  });
}
