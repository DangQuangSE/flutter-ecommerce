import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';
import 'package:flutter_ecommerce/features/address/domain/usecases/add_address_usecase.dart';
import 'package:flutter_ecommerce/features/address/domain/usecases/delete_address_usecase.dart';
import 'package:flutter_ecommerce/features/address/domain/usecases/get_addresses_usecase.dart';
import 'package:flutter_ecommerce/features/address/domain/usecases/set_default_address_usecase.dart';
import 'package:flutter_ecommerce/features/address/domain/usecases/update_address_usecase.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  AddressCubit({
    required GetAddressesUseCase getAddressesUseCase,
    required AddAddressUseCase addAddressUseCase,
    required UpdateAddressUseCase updateAddressUseCase,
    required DeleteAddressUseCase deleteAddressUseCase,
    required SetDefaultAddressUseCase setDefaultAddressUseCase,
  })  : _getAddresses = getAddressesUseCase,
        _addAddress = addAddressUseCase,
        _updateAddress = updateAddressUseCase,
        _deleteAddress = deleteAddressUseCase,
        _setDefault = setDefaultAddressUseCase,
        super(const AddressInitial());

  final GetAddressesUseCase _getAddresses;
  final AddAddressUseCase _addAddress;
  final UpdateAddressUseCase _updateAddress;
  final DeleteAddressUseCase _deleteAddress;
  final SetDefaultAddressUseCase _setDefault;

  Future<void> loadAddresses() async {
    emit(const AddressLoading());
    final result = await _getAddresses();
    switch (result) {
      case Success(:final data):
        emit(AddressLoaded(data));
      case ResultFailure(:final failure):
        emit(AddressError(failure.message));
    }
  }

  Future<bool> addAddress(AddressEntity address) async {
    final result = await _addAddress(address);
    switch (result) {
      case Success():
        await loadAddresses();
        return true;
      case ResultFailure(:final failure):
        emit(AddressError(failure.message));
        return false;
    }
  }

  Future<bool> updateAddress(AddressEntity address) async {
    final result = await _updateAddress(address);
    switch (result) {
      case Success():
        await loadAddresses();
        return true;
      case ResultFailure(:final failure):
        emit(AddressError(failure.message));
        return false;
    }
  }

  Future<void> deleteAddress(int id) async {
    final result = await _deleteAddress(id);
    switch (result) {
      case Success():
        await loadAddresses();
      case ResultFailure(:final failure):
        emit(AddressError(failure.message));
    }
  }

  Future<void> setDefault(int id) async {
    final result = await _setDefault(id);
    switch (result) {
      case Success():
        await loadAddresses();
      case ResultFailure(:final failure):
        emit(AddressError(failure.message));
    }
  }
}
