import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/models/paged_result.dart';
import 'package:flutter_ecommerce/features/admin/data/datasources/admin_order_remote_datasource.dart';
import 'package:flutter_ecommerce/features/admin/domain/entities/admin_order_entity.dart';
import 'package:flutter_ecommerce/features/admin/domain/repositories/admin_order_repository.dart';

class AdminOrderRepositoryImpl implements AdminOrderRepository {
  final AdminOrderRemoteDataSource _remoteDataSource;

  const AdminOrderRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<PagedResult<AdminOrderEntity>>> getOrders({
    String? search,
    String? status,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final result = await _remoteDataSource.getOrders(
        search: search,
        status: status,
        page: page,
        size: size,
      );
      return Success(result);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }

  @override
  Future<Result<AdminOrderEntity>> getOrderById(int id) async {
    try {
      final order = await _remoteDataSource.getOrderById(id);
      return Success(order);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }

  @override
  Future<Result<AdminOrderEntity>> updateOrderStatus(
    int id,
    String status,
  ) async {
    try {
      final order = await _remoteDataSource.updateOrderStatus(id, status);
      return Success(order);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }
}
