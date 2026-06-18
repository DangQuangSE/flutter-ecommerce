import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/size/data/datasources/size_group_remote_datasource.dart';
import 'package:flutter_ecommerce/features/size/data/models/size_group_model.dart';

class SizeGroupRemoteDatasourceImpl implements SizeGroupRemoteDatasource {
  final DioClient _dioClient;

  const SizeGroupRemoteDatasourceImpl(this._dioClient);

  @override
  Future<List<SizeGroupModel>> getSizeGroups() async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      ApiConstants.sizeGroups,
    );
    final data = response.data?['data'] as List<dynamic>?;
    if (data == null) return [];
    return data
        .map((json) => SizeGroupModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SizeGroupModel> createSizeGroup(SizeGroupModel model) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      ApiConstants.adminSizeGroups,
      data: model.toJson(),
    );
    final data = response.data?['data'] as Map<String, dynamic>;
    return SizeGroupModel.fromJson(data);
  }

  @override
  Future<SizeGroupModel> updateSizeGroup(int id, SizeGroupModel model) async {
    final response = await _dioClient.dio.put<Map<String, dynamic>>(
      ApiConstants.adminSizeGroupById(id),
      data: model.toJson(),
    );
    final data = response.data?['data'] as Map<String, dynamic>;
    return SizeGroupModel.fromJson(data);
  }

  @override
  Future<void> deleteSizeGroup(int id) async {
    await _dioClient.dio.delete<void>(ApiConstants.adminSizeGroupById(id));
  }
}
