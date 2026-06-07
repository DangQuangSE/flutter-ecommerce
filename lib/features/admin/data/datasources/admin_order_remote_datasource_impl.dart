import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/models/paged_result.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/admin/data/datasources/admin_order_remote_datasource.dart';
import 'package:flutter_ecommerce/features/admin/data/models/admin_order_model.dart';

class AdminOrderRemoteDataSourceImpl implements AdminOrderRemoteDataSource {
  final DioClient _dioClient;

  const AdminOrderRemoteDataSourceImpl(this._dioClient);

  @override
  Future<PagedResult<AdminOrderModel>> getOrders({
    String? search,
    String? status,
    int page = 0,
    int size = 10,
  }) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      ApiConstants.adminOrders,
      queryParameters: {
        'page': page,
        'size': size,
        'sort': 'createdAt,desc',
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null && status.isNotEmpty) 'status': status,
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

    return PagedResult.fromSpringPage(data, AdminOrderModel.fromJson);
  }

  @override
  Future<AdminOrderModel> getOrderById(int id) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      '${ApiConstants.adminOrders}/$id',
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    return AdminOrderModel.fromJson(data);
  }

  @override
  Future<AdminOrderModel> updateOrderStatus(int id, String status) async {
    final response = await _dioClient.dio.patch<Map<String, dynamic>>(
      '${ApiConstants.adminOrders}/$id/status',
      data: {'status': status},
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    return AdminOrderModel.fromJson(data);
  }
}
