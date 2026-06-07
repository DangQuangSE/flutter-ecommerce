import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/admin_product_detail_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/repositories/admin_product_repository.dart';

class GetAdminProductDetailUseCase {
  final AdminProductRepository _repository;

  GetAdminProductDetailUseCase(this._repository);

  Future<Result<AdminProductDetailEntity>> call(int id) =>
      _repository.getProductById(id);
}
