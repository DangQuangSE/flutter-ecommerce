import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/models/paged_result.dart';
import 'package:flutter_ecommerce/features/order/domain/entities/order_entity.dart';

abstract interface class OrderRepository {
  Future<Result<PagedResult<OrderEntity>>> getOrders({
    int page = 0,
    int size = 10,
  });

  Future<Result<OrderEntity>> getOrderById(int id);
  Future<Result<OrderEntity>> cancelOrder(int id, String reason);
}
