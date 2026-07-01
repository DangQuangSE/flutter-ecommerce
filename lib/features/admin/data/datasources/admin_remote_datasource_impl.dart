import 'package:flutter_ecommerce/core/network/dio_client.dart';
import '../models/admin_stats_model.dart';
import '../models/admin_notification_model.dart';
import 'admin_remote_datasource.dart';

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  // ignore: unused_field
  final DioClient _dioClient;
  const AdminRemoteDataSourceImpl(this._dioClient);

  @override
  Future<AdminStatsModel> getAdminStats() async {
    final response = await _dioClient.dio.get('/api/v1/admin/analytics/dashboard-summary');
    return AdminStatsModel.fromJson(response.data['data']);
  }

  @override
  Future<List<AdminNotificationModel>> getAdminNotifications() async {
    final response = await _dioClient.dio.get('/api/v1/notifications/admin?page=0&size=50');
    final data = response.data['data']['content'] as List;
    return data.map((e) => AdminNotificationModel.fromJson(e)).toList();
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    await _dioClient.dio.put('/api/v1/notifications/admin/read-all', data: {});
  }
}
