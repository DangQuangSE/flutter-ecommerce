import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/notification/data/models/notification_model.dart';
import 'package:flutter_ecommerce/features/notification/data/datasources/notification_remote_datasource.dart';

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient _dioClient;

  NotificationRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _dioClient.dio.get('/api/v1/notifications?page=0&size=50');
    final data = response.data['data']['content'] as List;
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  @override
  Future<void> markAllAsRead() async {
    await _dioClient.dio.put('/api/v1/notifications/read-all', data: {});
  }

  @override
  Future<void> markAsRead(int id) async {
    // Currently backend only supports mark-all-as-read.
    // If backend supported single read, we would call it here.
    // For now, we fall back to markAllAsRead to fulfill the interface if needed.
    await _dioClient.dio.put('/api/v1/notifications/read-all', data: {});
  }
}
