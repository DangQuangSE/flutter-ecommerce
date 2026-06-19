import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';

abstract interface class AddressRepository {
  Future<Result<List<AddressEntity>>> getAddresses();
  Future<Result<AddressEntity>> createAddress(AddressEntity address);
  Future<Result<AddressEntity>> updateAddress(int id, AddressEntity address);
  Future<Result<void>> deleteAddress(int id);
  Future<Result<AddressEntity>> setDefaultAddress(int id);
}
