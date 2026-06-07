import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/admin_product_detail_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/create_product_params.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/repositories/admin_product_repository.dart';

class CreateProductUseCase {
  final AdminProductRepository _repository;

  CreateProductUseCase(this._repository);

  Future<Result<AdminProductDetailEntity>> call(CreateProductParams params) =>
      _repository.createProduct(params);
}
