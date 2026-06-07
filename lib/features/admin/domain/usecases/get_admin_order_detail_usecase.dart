import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/domain/entities/admin_order_entity.dart';
import 'package:flutter_ecommerce/features/admin/domain/repositories/admin_order_repository.dart';

class GetAdminOrderDetailUseCase {
  final AdminOrderRepository _repository;

  const GetAdminOrderDetailUseCase(this._repository);

  Future<Result<AdminOrderEntity>> call(int id) => _repository.getOrderById(id);
}
