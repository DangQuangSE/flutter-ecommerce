import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/models/paged_result.dart';
import 'package:flutter_ecommerce/features/admin/domain/entities/admin_order_entity.dart';

abstract interface class AdminOrderRepository {
  Future<Result<PagedResult<AdminOrderEntity>>> getOrders({
    String? search,
    String? status,
    int page = 0,
    int size = 10,
  });

  Future<Result<AdminOrderEntity>> getOrderById(int id);

  Future<Result<AdminOrderEntity>> updateOrderStatus(int id, String status);
}
