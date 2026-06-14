import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/models/paged_response.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_catalog_entity.dart';
import 'package:flutter_ecommerce/features/product/domain/repositories/product_repository.dart';

class GetProductCatalogUseCase {
  final ProductRepository _repository;
  const GetProductCatalogUseCase(this._repository);

  Future<Result<PagedResponse<ProductCatalogEntity>>> call({
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
  }) =>
      _repository.getCatalogProducts(
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
}
