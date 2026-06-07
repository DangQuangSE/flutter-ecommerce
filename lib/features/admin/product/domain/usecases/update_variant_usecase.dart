import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_variant_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/create_variant_params.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/repositories/admin_product_repository.dart';

class UpdateVariantUseCase {
  final AdminProductRepository _repository;

  UpdateVariantUseCase(this._repository);

  Future<Result<ProductVariantEntity>> call(
          int variantId, CreateVariantParams params) =>
      _repository.updateVariant(variantId, params);
}
