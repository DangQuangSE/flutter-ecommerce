import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';
import 'package:flutter_ecommerce/features/address/domain/repositories/address_repository.dart';

class UpdateAddressUseCase {
  const UpdateAddressUseCase(this._repository);

  final AddressRepository _repository;

  Future<Result<AddressEntity>> call(AddressEntity address) =>
      _repository.updateAddress(address);
}
