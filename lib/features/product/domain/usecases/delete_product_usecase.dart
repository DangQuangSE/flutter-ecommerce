import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/product/domain/repositories/product_repository.dart';

class DeleteProductUseCase {
  final ProductRepository _repository;
  const DeleteProductUseCase(this._repository);

  Future<Result<bool>> call(String id) => _repository.deleteProduct(id);
}
