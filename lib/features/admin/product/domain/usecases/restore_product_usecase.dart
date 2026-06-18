import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/repositories/admin_product_repository.dart';

class RestoreAdminProductUseCase {
  final AdminProductRepository _repository;

  RestoreAdminProductUseCase(this._repository);

  Future<Result<void>> call(int id) => _repository.restoreProduct(id);
}
