import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';
import 'package:flutter_ecommerce/features/product/domain/repositories/product_repository.dart';

class AddProductUseCase {
  final ProductRepository _repository;
  const AddProductUseCase(this._repository);

  Future<Result<ProductEntity>> call(ProductEntity product) =>
      _repository.addProduct(product);
}
