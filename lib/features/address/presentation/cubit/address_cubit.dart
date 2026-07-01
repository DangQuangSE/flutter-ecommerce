import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';
import 'package:flutter_ecommerce/features/address/domain/repositories/address_repository.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final AddressRepository _repository;

  AddressCubit(this._repository) : super(const AddressInitial());

  List<AddressEntity> _currentAddresses() {
    final currentState = state;
    if (currentState is AddressLoaded) {
      return currentState.addresses;
    }
    return const [];
  }

  Future<void> loadAddresses() async {
    emit(const AddressLoading());
    final result = await _repository.getAddresses();
    switch (result) {
      case Success(:final data):
        emit(AddressLoaded(addresses: data));
      case ResultFailure(:final failure):
        emit(AddressError(failure.message));
    }
  }

  Future<void> createAddress(AddressEntity address) async {
    final currentAddresses = _currentAddresses();
    emit(AddressLoaded(addresses: currentAddresses, isSubmitting: true));
    final result = await _repository.createAddress(address);
    switch (result) {
      case Success(:final data):
        final updatedList = List<AddressEntity>.from(currentAddresses)
          ..insert(0, data);
        emit(AddressLoaded(
          addresses: updatedList,
          message: AppStrings.addressCreated,
        ));
      case ResultFailure(:final failure):
        emit(AddressError(failure.message));
    }
  }

  Future<void> updateAddress(int id, AddressEntity address) async {
    final currentAddresses = _currentAddresses();
    emit(AddressLoaded(addresses: currentAddresses, isSubmitting: true));
    final result = await _repository.updateAddress(id, address);
    switch (result) {
      case Success(:final data):
        final updatedList =
            currentAddresses.map((a) => a.id == id ? data : a).toList();
        emit(AddressLoaded(
          addresses: updatedList,
          message: AppStrings.addressUpdated,
        ));
      case ResultFailure(:final failure):
        emit(AddressError(failure.message));
    }
  }

  Future<void> deleteAddress(int id) async {
    final currentAddresses = _currentAddresses();
    emit(AddressLoaded(addresses: currentAddresses, isSubmitting: true));
    final result = await _repository.deleteAddress(id);
    switch (result) {
      case Success():
        final updatedList =
            currentAddresses.where((a) => a.id != id).toList();
        emit(AddressLoaded(
          addresses: updatedList,
          message: AppStrings.addressDeleted,
        ));
      case ResultFailure(:final failure):
        emit(AddressError(failure.message));
    }
  }

  Future<void> setDefaultAddress(int id) async {
    final currentAddresses = _currentAddresses();
    final optimisticList = currentAddresses.map((a) {
      if (a.id == id) {
        return a.copyWith(isDefault: true);
      }
      return a.copyWith(isDefault: false);
    }).toList();

    emit(AddressLoaded(addresses: optimisticList, isSubmitting: true));

    final result = await _repository.setDefaultAddress(id);
    switch (result) {
      case Success(:final data):
        final updatedList = currentAddresses.map((a) {
          if (a.id == id) {
            return data;
          }
          return a.copyWith(isDefault: false);
        }).toList();
        emit(AddressLoaded(
          addresses: updatedList,
          message: AppStrings.addressSetDefaultSuccess,
        ));
      case ResultFailure(:final failure):
        emit(AddressError(failure.message));
    }
  }
}
