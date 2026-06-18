import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/models/paged_response.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_catalog_entity.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';

abstract interface class ProductRepository {
  Future<Result<List<ProductEntity>>> getProducts(
      {int page = 1, int limit = 20});
  Future<Result<ProductEntity>> getProductById(String id);
  Future<Result<ProductEntity>> addProduct(ProductEntity product);
  Future<Result<ProductEntity>> updateProduct(ProductEntity product);
  Future<Result<bool>> deleteProduct(String id);

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
  });
}
