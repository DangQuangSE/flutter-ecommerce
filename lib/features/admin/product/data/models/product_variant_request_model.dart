class ProductVariantRequestModel {
  final String sku;
  final String size;
  final int colorId;
  final double originalPrice;
  final int stockQuantity;
  final String status;

  const ProductVariantRequestModel({
    required this.sku,
    required this.size,
    required this.colorId,
    required this.originalPrice,
    required this.stockQuantity,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'sku': sku,
        'size': size,
        'colorId': colorId,
        'originalPrice': originalPrice,
        'stockQuantity': stockQuantity,
        'status': status,
      };
}
