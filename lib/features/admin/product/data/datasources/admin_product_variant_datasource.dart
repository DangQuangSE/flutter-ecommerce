import 'package:flutter_ecommerce/features/admin/product/data/models/product_variant_model.dart';
import 'package:flutter_ecommerce/features/admin/product/data/models/product_variant_request_model.dart';

abstract interface class AdminProductVariantDatasource {
  Future<ProductVariantModel> createVariant(
      int productId, ProductVariantRequestModel request);
  Future<ProductVariantModel> updateVariant(
      int variantId, ProductVariantRequestModel request);
  Future<void> deleteVariant(int variantId);
}
