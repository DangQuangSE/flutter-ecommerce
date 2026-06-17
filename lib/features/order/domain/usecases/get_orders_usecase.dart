import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/models/paged_result.dart';
import 'package:flutter_ecommerce/features/order/domain/entities/order_entity.dart';
import 'package:flutter_ecommerce/features/order/domain/repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository _repository;

  const GetOrdersUseCase(this._repository);

  Future<Result<PagedResult<OrderEntity>>> call({
    int page = 0,
    int size = 10,
  }) =>
      _repository.getOrders(page: page, size: size);
}
