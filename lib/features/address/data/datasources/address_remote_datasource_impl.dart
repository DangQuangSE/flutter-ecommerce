import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/address/data/datasources/address_remote_datasource.dart';
import 'package:flutter_ecommerce/features/address/data/models/address_model.dart';

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final DioClient _dioClient;

  const AddressRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<AddressModel>> getAddresses() async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>
      (ApiConstants.addresses,
    );

    final data = response.data?['data'] as List?;
    if (data == null) return [];

    return data
        .map((json) => AddressModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AddressModel> createAddress(AddressModel address) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>
      (ApiConstants.addresses,
      data: address.toJson(),
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    return AddressModel.fromJson(data);
  }

  @override
  Future<AddressModel> updateAddress(int id, AddressModel address) async {
    final response = await _dioClient.dio.put<Map<String, dynamic>>(
      '${ApiConstants.addresses}/$id',
      data: address.toJson(),
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    return AddressModel.fromJson(data);
  }

  @override
  Future<void> deleteAddress(int id) async {
    await _dioClient.dio.delete<void>('${ApiConstants.addresses}/$id');
  }

  @override
  Future<AddressModel> setDefaultAddress(int id) async {
    final response = await _dioClient.dio.patch<Map<String, dynamic>>(
      '${ApiConstants.addresses}/$id/default',
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    return AddressModel.fromJson(data);
  }
}
