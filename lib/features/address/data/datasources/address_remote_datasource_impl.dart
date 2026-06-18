import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/address/data/datasources/address_remote_datasource.dart';
import 'package:flutter_ecommerce/features/address/data/models/address_model.dart';

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  const AddressRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<AddressModel>> getAddresses() async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      ApiConstants.addresses,
    );

    final data = response.data?['data'];
    if (data == null) return [];

    final list = data as List;
    return list
        .map((json) => AddressModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AddressModel> addAddress(AddressModel address) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      ApiConstants.addresses,
      data: address.toJson(),
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    return AddressModel.fromJson(data);
  }

  @override
  Future<AddressModel> updateAddress(int id, AddressModel address) async {
    final response = await _dioClient.dio.put<Map<String, dynamic>>(
      ApiConstants.addressById(id),
      data: address.toJson(),
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    return AddressModel.fromJson(data);
  }

  @override
  Future<void> deleteAddress(int id) async {
    await _dioClient.dio.delete<void>(ApiConstants.addressById(id));
  }

  @override
  Future<void> setDefault(int id) async {
    await _dioClient.dio.patch<void>(ApiConstants.addressSetDefault(id));
  }
}
