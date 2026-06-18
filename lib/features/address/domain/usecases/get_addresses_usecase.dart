import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';
import 'package:flutter_ecommerce/features/address/domain/repositories/address_repository.dart';

class GetAddressesUseCase {
  const GetAddressesUseCase(this._repository);

  final AddressRepository _repository;

  Future<Result<List<AddressEntity>>> call() => _repository.getAddresses();
}
