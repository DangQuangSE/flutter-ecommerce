import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/models/paged_response.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/admin_product_list_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/repositories/admin_product_repository.dart';

class GetAdminProductsUseCase {
  final AdminProductRepository _repository;

  GetAdminProductsUseCase(this._repository);

  Future<Result<PagedResponse<AdminProductListEntity>>> call({
    String? keyword,
    int? categoryId,
    int? brandId,
    String? gender,
    String? status,
    bool? isFeatured,
    int page = 0,
    int size = 20,
  }) =>
      _repository.getProducts(
        keyword: keyword,
        categoryId: categoryId,
        brandId: brandId,
        gender: gender,
        status: status,
        isFeatured: isFeatured,
        page: page,
        size: size,
      );
}
