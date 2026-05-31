import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';

abstract interface class ProductRepository {
  Future<Result<List<ProductEntity>>> getProducts({int page = 1, int limit = 20});
  Future<Result<ProductEntity>> getProductById(String id);
}
