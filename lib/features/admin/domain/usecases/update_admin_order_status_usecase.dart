import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/domain/entities/admin_order_entity.dart';
import 'package:flutter_ecommerce/features/admin/domain/repositories/admin_order_repository.dart';

class UpdateAdminOrderStatusUseCase {
  final AdminOrderRepository _repository;

  const UpdateAdminOrderStatusUseCase(this._repository);

  Future<Result<AdminOrderEntity>> call({
    required int orderId,
    required String status,
  }) =>
      _repository.updateOrderStatus(orderId, status);
}
