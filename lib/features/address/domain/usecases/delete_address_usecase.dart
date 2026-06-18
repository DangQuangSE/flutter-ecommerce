import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/address/domain/repositories/address_repository.dart';

class DeleteAddressUseCase {
  const DeleteAddressUseCase(this._repository);

  final AddressRepository _repository;

  Future<Result<void>> call(int id) => _repository.deleteAddress(id);
}
