import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/product/data/datasources/product_remote_datasource.dart';
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
}
