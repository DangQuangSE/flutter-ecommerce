import 'package:flutter_ecommerce/core/models/paged_response.dart';
import 'package:flutter_ecommerce/features/product/data/models/product_catalog_model.dart';
import 'package:flutter_ecommerce/features/product/data/models/product_model.dart';

abstract interface class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({int page = 1, int limit = 20});
  Future<ProductModel> getProductById(String id);
  Future<ProductModel> addProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<bool> deleteProduct(String id);

  Future<PagedResponse<ProductCatalogModel>> getCatalogProducts({
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
