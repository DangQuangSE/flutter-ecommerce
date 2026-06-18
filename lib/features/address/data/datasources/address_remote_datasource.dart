import 'package:flutter_ecommerce/features/address/data/models/address_model.dart';

abstract interface class AddressRemoteDataSource {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> addAddress(AddressModel address);
  Future<AddressModel> updateAddress(int id, AddressModel address);
  Future<void> deleteAddress(int id);
  Future<void> setDefault(int id);
}
