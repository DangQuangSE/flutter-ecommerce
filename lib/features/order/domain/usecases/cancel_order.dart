import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/order/domain/entities/order_entity.dart';
import 'package:flutter_ecommerce/features/order/domain/repositories/order_repository.dart';

class CancelOrder {
  final OrderRepository repository;

  CancelOrder(this.repository);

  Future<Result<OrderEntity>> call(CancelOrderParams params) async {
    return await repository.cancelOrder(params.orderId, params.reason);
  }
}

class CancelOrderParams {
  final int orderId;
  final String reason;

  CancelOrderParams({required this.orderId, required this.reason});
}
