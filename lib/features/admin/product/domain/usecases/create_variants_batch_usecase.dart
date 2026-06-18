import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_variant_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/create_variant_params.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/repositories/admin_product_repository.dart';

class CreateVariantsBatchUseCase {
  final AdminProductRepository _repository;

  CreateVariantsBatchUseCase(this._repository);

  Future<Result<List<ProductVariantEntity>>> call(
          int productId, List<CreateVariantParams> params) =>
      _repository.createVariantsBatch(productId, params);
}
