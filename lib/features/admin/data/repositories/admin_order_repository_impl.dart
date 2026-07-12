import 'package:dio/dio.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/models/paged_result.dart';
import 'package:flutter_ecommerce/core/network/dio_error_mapper.dart';
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
  }) =>
      _guard(
        () => _remoteDataSource.getOrders(
          search: search,
          status: status,
          page: page,
          size: size,
        ),
      );

  @override
  Future<Result<AdminOrderEntity>> getOrderById(int id) =>
      _guard(() => _remoteDataSource.getOrderById(id));

  @override
  Future<Result<AdminOrderEntity>> updateOrderStatus(
    int id,
    String status,
  ) =>
      _guard(() => _remoteDataSource.updateOrderStatus(id, status));

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on DioException catch (e) {
      final failure = failureFromDioException(e);
      if (failure case NetworkFailure(statusCode: final code?)
          when code >= 500) {
        return ResultFailure(
          NetworkFailure(
            'Hệ thống đang gặp sự cố. Vui lòng thử lại sau.',
            statusCode: code,
          ),
        );
      }
      return ResultFailure(failure);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }
}
