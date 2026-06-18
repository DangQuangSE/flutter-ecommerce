import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/models/paged_response.dart';
import 'package:flutter_ecommerce/features/admin/product/data/datasources/admin_product_datasource.dart';
import 'package:flutter_ecommerce/features/admin/product/data/datasources/admin_product_image_datasource.dart';
import 'package:flutter_ecommerce/features/admin/product/data/datasources/admin_product_variant_datasource.dart';
import 'package:flutter_ecommerce/features/admin/product/data/models/product_create_request_model.dart';
import 'package:flutter_ecommerce/features/admin/product/data/models/product_update_request_model.dart';
import 'package:flutter_ecommerce/features/admin/product/data/models/product_variant_request_model.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/admin_product_detail_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/admin_product_list_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_image_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_variant_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/create_product_params.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/create_variant_params.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/image_file_params.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/update_product_params.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/repositories/admin_product_repository.dart';

class AdminProductRepositoryImpl implements AdminProductRepository {
  final AdminProductDatasource _productDs;
  final AdminProductVariantDatasource _variantDs;
  final AdminProductImageDatasource _imageDs;

  AdminProductRepositoryImpl(this._productDs, this._variantDs, this._imageDs);

  @override
  Future<Result<PagedResponse<AdminProductListEntity>>> getProducts({
    String? keyword,
    int? categoryId,
    int? brandId,
    String? gender,
    String? status,
    bool? isFeatured,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final paged = await _productDs.getProducts(
        keyword: keyword,
        categoryId: categoryId,
        brandId: brandId,
        gender: gender,
        status: status,
        isFeatured: isFeatured,
        page: page,
        size: size,
      );
      final entityPaged = PagedResponse<AdminProductListEntity>(
        content: paged.content.map((m) => m.toEntity()).toList(),
        totalPages: paged.totalPages,
        totalElements: paged.totalElements,
        number: paged.number,
        size: paged.size,
      );
      return Success(entityPaged);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<AdminProductDetailEntity>> getProductById(int id) async {
    try {
      final model = await _productDs.getProductById(id);
      return Success(model.toEntity());
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<AdminProductDetailEntity>> createProduct(
      CreateProductParams params) async {
    try {
      final request = ProductCreateRequestModel(
        name: params.name,
        description: params.description,
        categoryId: params.categoryId,
        brandId: params.brandId,
        gender: params.gender.toJson(),
        isFeatured: params.isFeatured,
        status: params.status.toJson(),
        sizeGroupId: params.sizeGroupId,
      );
      final model = await _productDs.createProduct(request);
      return Success(model.toEntity());
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<AdminProductDetailEntity>> updateProduct(
      int id, UpdateProductParams params) async {
    try {
      final request = ProductUpdateRequestModel(
        name: params.name,
        description: params.description,
        categoryId: params.categoryId,
        brandId: params.brandId,
        gender: params.gender.toJson(),
        status: params.status.toJson(),
        isFeatured: params.isFeatured,
        sizeGroupId: params.sizeGroupId,
      );
      final model = await _productDs.updateProduct(id, request);
      return Success(model.toEntity());
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteProduct(int id) async {
    try {
      await _productDs.deleteProduct(id);
      return const Success(null);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<void>> restoreProduct(int id) async {
    try {
      await _productDs.restoreProduct(id);
      return const Success(null);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<ProductVariantEntity>> createVariant(
      int productId, CreateVariantParams params) async {
    try {
      final request = ProductVariantRequestModel(
        sku: params.sku,
        size: params.size,
        colorId: params.colorId,
        originalPrice: params.originalPrice,
        salePrice: params.salePrice,
        stockQuantity: params.stockQuantity,
        status: params.status.toJson(),
      );
      final model = await _variantDs.createVariant(productId, request);
      return Success(model.toEntity());
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<List<ProductVariantEntity>>> createVariantsBatch(
      int productId, List<CreateVariantParams> params) async {
    try {
      final requests = params
          .map((p) => ProductVariantRequestModel(
                sku: p.sku,
                size: p.size,
                colorId: p.colorId,
                originalPrice: p.originalPrice,
                salePrice: p.salePrice,
                stockQuantity: p.stockQuantity,
                status: p.status.toJson(),
              ))
          .toList();
      final models = await _variantDs.createVariantsBatch(productId, requests);
      return Success(models.map((m) => m.toEntity()).toList());
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<ProductVariantEntity>> updateVariant(
      int variantId, CreateVariantParams params) async {
    try {
      final request = ProductVariantRequestModel(
        sku: params.sku,
        size: params.size,
        colorId: params.colorId,
        originalPrice: params.originalPrice,
        salePrice: params.salePrice,
        stockQuantity: params.stockQuantity,
        status: params.status.toJson(),
      );
      final model = await _variantDs.updateVariant(variantId, request);
      return Success(model.toEntity());
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteVariant(int variantId) async {
    try {
      await _variantDs.deleteVariant(variantId);
      return const Success(null);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<ProductImageEntity>> addImage(
    int productId,
    ImageFileParams file, {
    bool isThumbnail = false,
    int sortOrder = 0,
    int? variantId,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final model = await _imageDs.addImage(
        productId,
        file.path,
        file.name,
        isThumbnail: isThumbnail,
        sortOrder: sortOrder,
        variantId: variantId,
        onSendProgress: onSendProgress,
      );
      return Success(model.toEntity());
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteImage(int imageId) async {
    try {
      await _imageDs.deleteImage(imageId);
      return const Success(null);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }
}
