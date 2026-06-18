import 'package:dio/dio.dart';
import 'package:flutter_ecommerce/features/location/data/datasources/location_remote_datasource.dart';
import 'package:flutter_ecommerce/features/location/data/models/location_model.dart';

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final Dio _dio;

  LocationRemoteDataSourceImpl()
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://provinces.open-api.vn/api',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  @override
  Future<List<LocationModel>> getProvinces() async {
    final response = await _dio.get<List<dynamic>>('/p/');
    final data = response.data;
    if (data == null) return [];
    return data
        .map((json) => LocationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<LocationModel>> getDistricts(int provinceCode) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/p/$provinceCode', queryParameters: {'depth': 2});
    final data = response.data;
    if (data == null) return [];
    final districts = data['districts'] as List<dynamic>?;
    if (districts == null) return [];
    return districts
        .map((json) => LocationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<LocationModel>> getWards(int districtCode) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/d/$districtCode', queryParameters: {'depth': 2});
    final data = response.data;
    if (data == null) return [];
    final wards = data['wards'] as List<dynamic>?;
    if (wards == null) return [];
    return wards
        .map((json) => LocationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
