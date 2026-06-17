import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/setting/data/datasources/site_setting_remote_datasource.dart';
import 'package:flutter_ecommerce/features/setting/data/models/site_setting_model.dart';

class SiteSettingRemoteDataSourceImpl implements SiteSettingRemoteDataSource {
  final DioClient _dioClient;

  const SiteSettingRemoteDataSourceImpl(this._dioClient);

  @override
  Future<SiteSettingModel> getSettings() async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      ApiConstants.settings,
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    return SiteSettingModel.fromJson(data);
  }

  @override
  Future<SiteSettingModel> updateSettings(SiteSettingModel settings) async {
    final response = await _dioClient.dio.put<Map<String, dynamic>>(
      ApiConstants.adminSettings,
      data: settings.toJson(),
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    return SiteSettingModel.fromJson(data);
  }
}
