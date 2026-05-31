import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/order/domain/entities/order_entity.dart';

abstract interface class OrderRepository {
  Future<Result<List<OrderEntity>>> getOrders();
  Future<Result<OrderEntity>> getOrderById(String id);
}
