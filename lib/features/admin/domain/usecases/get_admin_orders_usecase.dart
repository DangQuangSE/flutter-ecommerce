import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/models/paged_result.dart';
import 'package:flutter_ecommerce/features/admin/domain/entities/admin_order_entity.dart';
import 'package:flutter_ecommerce/features/admin/domain/repositories/admin_order_repository.dart';

class GetAdminOrdersUseCase {
  final AdminOrderRepository _repository;

  const GetAdminOrdersUseCase(this._repository);

  Future<Result<PagedResult<AdminOrderEntity>>> call({
    String? search,
    String? status,
    int page = 0,
    int size = 10,
  }) =>
      _repository.getOrders(
        search: search,
        status: status,
        page: page,
        size: size,
      );
}
