import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/admin_product_detail_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/update_product_params.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/repositories/admin_product_repository.dart';

class UpdateAdminProductUseCase {
  final AdminProductRepository _repository;

  UpdateAdminProductUseCase(this._repository);

  Future<Result<AdminProductDetailEntity>> call(
          int id, UpdateProductParams params) =>
      _repository.updateProduct(id, params);
}
