import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';

abstract interface class AddressRepository {
  Future<Result<List<AddressEntity>>> getAddresses();
  Future<Result<AddressEntity>> addAddress(AddressEntity address);
  Future<Result<AddressEntity>> updateAddress(AddressEntity address);
  Future<Result<void>> deleteAddress(int id);
  Future<Result<void>> setDefault(int id);
}
