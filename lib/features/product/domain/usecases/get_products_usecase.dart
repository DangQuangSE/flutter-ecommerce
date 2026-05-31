import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';
import 'package:flutter_ecommerce/features/product/domain/repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository _repository;
  const GetProductsUseCase(this._repository);

  Future<Result<List<ProductEntity>>> call({int page = 1}) =>
      _repository.getProducts(page: page);
}
