import 'package:flutter_ecommerce/features/admin/product/data/models/product_image_model.dart';

abstract interface class AdminProductImageDatasource {
  Future<ProductImageModel> addImage(
    int productId,
    String filePath,
    String fileName, {
    bool isThumbnail = false,
    int sortOrder = 0,
    int? variantId,
    void Function(int sent, int total)? onSendProgress,
  });
  Future<void> deleteImage(int imageId);
}
