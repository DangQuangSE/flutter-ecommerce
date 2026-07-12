import 'package:dio/dio.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/models/paged_result.dart';
import 'package:flutter_ecommerce/features/admin/data/datasources/admin_order_remote_datasource.dart';
import 'package:flutter_ecommerce/features/admin/data/models/admin_order_model.dart';
import 'package:flutter_ecommerce/features/admin/data/repositories/admin_order_repository_impl.dart';
import 'package:flutter_ecommerce/features/admin/domain/entities/admin_order_entity.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailingAdminOrderDataSource implements AdminOrderRemoteDataSource {
  @override
  Future<PagedResult<AdminOrderModel>> getOrders({
    String? search,
    String? status,
    int page = 0,
    int size = 10,
  }) {
    final request = RequestOptions(path: '/api/v1/admin/orders');
    throw DioException.badResponse(
      statusCode: 500,
      requestOptions: request,
      response: Response<Map<String, dynamic>>(
        requestOptions: request,
        statusCode: 500,
        data: const {'message': 'DioException: internal server details'},
      ),
    );
  }

  @override
  Future<AdminOrderModel> getOrderById(int id) => throw UnimplementedError();

  @override
  Future<AdminOrderModel> updateOrderStatus(int id, String status) =>
      throw UnimplementedError();
}

void main() {
  test('getOrders maps HTTP 500 without exposing internal details', () async {
    final repository =
        AdminOrderRepositoryImpl(_FailingAdminOrderDataSource());

    final result = await repository.getOrders();

    expect(
      result,
      isA<ResultFailure<PagedResult<AdminOrderEntity>>>(),
    );
    final failure =
        (result as ResultFailure<PagedResult<AdminOrderEntity>>).failure;
    expect(failure, isA<NetworkFailure>());
    expect((failure as NetworkFailure).statusCode, 500);
    expect(
      failure.message,
      'Hệ thống đang gặp sự cố. Vui lòng thử lại sau.',
    );
  });
}
