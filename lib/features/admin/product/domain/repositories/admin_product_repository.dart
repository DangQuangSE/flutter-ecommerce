import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/models/paged_response.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/admin_product_detail_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/admin_product_list_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_image_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_variant_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/create_product_params.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/create_variant_params.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/image_file_params.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/update_product_params.dart';

abstract interface class AdminProductRepository {
  Future<Result<PagedResponse<AdminProductListEntity>>> getProducts({
    String? keyword,
    int? categoryId,
    int? brandId,
    String? gender,
    String? status,
    bool? isFeatured,
    int page = 0,
    int size = 20,
  });

  Future<Result<AdminProductDetailEntity>> getProductById(int id);

  Future<Result<AdminProductDetailEntity>> createProduct(
      CreateProductParams params);

  Future<Result<AdminProductDetailEntity>> updateProduct(
      int id, UpdateProductParams params);

  Future<Result<void>> deleteProduct(int id);

  Future<Result<void>> restoreProduct(int id);

  Future<Result<ProductVariantEntity>> createVariant(
      int productId, CreateVariantParams params);

  Future<Result<List<ProductVariantEntity>>> createVariantsBatch(
      int productId, List<CreateVariantParams> params);

  Future<Result<ProductVariantEntity>> updateVariant(
      int variantId, CreateVariantParams params);

  Future<Result<void>> deleteVariant(int variantId);

  Future<Result<ProductImageEntity>> addImage(
    int productId,
    ImageFileParams file, {
    bool isThumbnail,
    int sortOrder,
    int? variantId,
    void Function(int, int)? onSendProgress,
  });

  Future<Result<void>> deleteImage(int imageId);
}
