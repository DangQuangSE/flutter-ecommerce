import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/models/paged_response.dart';
import 'package:flutter_ecommerce/features/product/data/datasources/product_remote_datasource.dart';
import 'package:flutter_ecommerce/features/product/data/models/product_model.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_catalog_entity.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';
import 'package:flutter_ecommerce/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;
  const ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<ProductEntity>>> getProducts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final products =
          await _remoteDataSource.getProducts(page: page, limit: limit);
      return Success(products);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<ProductEntity>> getProductById(String id) async {
    try {
      final product = await _remoteDataSource.getProductById(id);
      return Success(product);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<ProductEntity>> addProduct(ProductEntity product) async {
    try {
      final model = ProductModel(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        categoryId: product.categoryId,
        stockQuantity: product.stockQuantity,
      );
      final result = await _remoteDataSource.addProduct(model);
      return Success(result);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<ProductEntity>> updateProduct(ProductEntity product) async {
    try {
      final model = ProductModel(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        categoryId: product.categoryId,
        stockQuantity: product.stockQuantity,
      );
      final result = await _remoteDataSource.updateProduct(model);
      return Success(result);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<bool>> deleteProduct(String id) async {
    try {
      final result = await _remoteDataSource.deleteProduct(id);
      return Success(result);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<PagedResponse<ProductCatalogEntity>>> getCatalogProducts({
    int page = 0,
    int size = 12,
    String? keyword,
    int? categoryId,
    int? brandId,
    String? gender,
    String? productSize,
    String? color,
    double? minPrice,
    double? maxPrice,
    String sort = 'id,desc',
  }) async {
    try {
      final paged = await _remoteDataSource.getCatalogProducts(
        page: page,
        size: size,
        keyword: keyword,
        categoryId: categoryId,
        brandId: brandId,
        gender: gender,
        productSize: productSize,
        color: color,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sort: sort,
      );
      return Success(PagedResponse(
        content: paged.content.map((m) => m.toEntity()).toList(),
        totalPages: paged.totalPages,
        totalElements: paged.totalElements,
        number: paged.number,
        size: paged.size,
      ));
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }
}
