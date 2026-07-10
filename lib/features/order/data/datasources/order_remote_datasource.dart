import 'package:flutter_ecommerce/core/models/paged_result.dart';
import 'package:flutter_ecommerce/features/order/data/models/order_model.dart';

abstract interface class OrderRemoteDataSource {
  Future<PagedResult<OrderModel>> getOrders({
    int page = 0,
    int size = 10,
  });

  Future<OrderModel> getOrderById(int id);
  Future<OrderModel> cancelOrder(int id, String reason);
}
