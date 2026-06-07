import 'package:flutter_ecommerce/core/models/paged_result.dart';
import 'package:flutter_ecommerce/features/admin/data/models/admin_order_model.dart';

abstract interface class AdminOrderRemoteDataSource {
  Future<PagedResult<AdminOrderModel>> getOrders({
    String? search,
    String? status,
    int page = 0,
    int size = 10,
  });

  Future<AdminOrderModel> getOrderById(int id);

  Future<AdminOrderModel> updateOrderStatus(int id, String status);
}
