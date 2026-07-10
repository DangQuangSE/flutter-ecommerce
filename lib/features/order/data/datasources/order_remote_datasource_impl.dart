import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/models/paged_result.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/order/data/datasources/order_remote_datasource.dart';
import 'package:flutter_ecommerce/features/order/data/models/order_model.dart';

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final DioClient _dioClient;

  const OrderRemoteDataSourceImpl(this._dioClient);

  @override
  Future<PagedResult<OrderModel>> getOrders({
    int page = 0,
    int size = 10,
  }) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      ApiConstants.orders,
      queryParameters: {
        'page': page,
        'size': size,
        'sort': 'createdAt,desc',
      },
    );

    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      return const PagedResult(
        content: [],
        totalElements: 0,
        totalPages: 0,
        page: 0,
        isLast: true,
      );
    }

    return PagedResult.fromSpringPage(data, OrderModel.fromJson);
  }

  @override
  Future<OrderModel> getOrderById(int id) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      '${ApiConstants.orders}/$id',
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    return OrderModel.fromJson(data);
  }

  @override
  Future<OrderModel> cancelOrder(int id, String reason) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      '${ApiConstants.orders}/$id/cancel',
      data: {
        'cancelReason': reason,
      },
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    return OrderModel.fromJson(data);
  }
}
