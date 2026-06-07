import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/repositories/admin_product_repository.dart';

class DeleteVariantUseCase {
  final AdminProductRepository _repository;

  DeleteVariantUseCase(this._repository);

  Future<Result<void>> call(int variantId) =>
      _repository.deleteVariant(variantId);
}
