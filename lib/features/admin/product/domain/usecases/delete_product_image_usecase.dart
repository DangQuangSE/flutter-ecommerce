import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/repositories/admin_product_repository.dart';

class DeleteProductImageUseCase {
  final AdminProductRepository _repository;

  DeleteProductImageUseCase(this._repository);

  Future<Result<void>> call(int imageId) => _repository.deleteImage(imageId);
}
