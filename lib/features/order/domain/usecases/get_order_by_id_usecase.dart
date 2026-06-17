import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/order/domain/entities/order_entity.dart';
import 'package:flutter_ecommerce/features/order/domain/repositories/order_repository.dart';

class GetOrderByIdUseCase {
  final OrderRepository _repository;

  const GetOrderByIdUseCase(this._repository);

  Future<Result<OrderEntity>> call(int id) => _repository.getOrderById(id);
}
