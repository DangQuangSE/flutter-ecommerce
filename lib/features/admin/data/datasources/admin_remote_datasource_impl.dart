import 'package:flutter_ecommerce/core/network/dio_client.dart';
import '../models/admin_stats_model.dart';
import 'admin_remote_datasource.dart';

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  // ignore: unused_field
  final DioClient _dioClient;
  const AdminRemoteDataSourceImpl(this._dioClient);

  @override
  Future<AdminStatsModel> getAdminStats() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return AdminStatsModel.mockStats;
  }
}
