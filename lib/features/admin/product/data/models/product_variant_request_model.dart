class ProductVariantRequestModel {
  final String sku;
  final String size;
  final int colorId;
  final double originalPrice;
  final double? salePrice;
  final int stockQuantity;
  final String status;

  const ProductVariantRequestModel({
    required this.sku,
    required this.size,
    required this.colorId,
    required this.originalPrice,
    this.salePrice,
    required this.stockQuantity,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'sku': sku,
        'size': size,
        'colorId': colorId,
        'originalPrice': originalPrice,
        if (salePrice != null) 'salePrice': salePrice,
        'stockQuantity': stockQuantity,
        'status': status,
      };
}
