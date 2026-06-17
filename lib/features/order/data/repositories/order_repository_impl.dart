import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/models/paged_result.dart';
import 'package:flutter_ecommerce/features/order/data/datasources/order_remote_datasource.dart';
import 'package:flutter_ecommerce/features/order/domain/entities/order_entity.dart';
import 'package:flutter_ecommerce/features/order/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  const OrderRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<PagedResult<OrderEntity>>> getOrders({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final result = await _remoteDataSource.getOrders(page: page, size: size);
      return Success(result);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }

  @override
  Future<Result<OrderEntity>> getOrderById(int id) async {
    try {
      final order = await _remoteDataSource.getOrderById(id);
      return Success(order);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }
}
