import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';

sealed class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

final class AddressInitial extends AddressState {
  const AddressInitial();
}

final class AddressLoading extends AddressState {
  const AddressLoading();
}

final class AddressLoaded extends AddressState {
  final List<AddressEntity> addresses;

  const AddressLoaded(this.addresses);

  AddressEntity? get defaultAddress =>
      addresses.where((a) => a.isDefault).firstOrNull;

  @override
  List<Object?> get props => [addresses];
}

final class AddressError extends AddressState {
  final String message;

  const AddressError(this.message);

  @override
  List<Object?> get props => [message];
}

final class AddressActionSuccess extends AddressState {
  final String message;
  final List<AddressEntity> addresses;

  const AddressActionSuccess({required this.message, required this.addresses});

  AddressEntity? get defaultAddress =>
      addresses.where((a) => a.isDefault).firstOrNull;

  @override
  List<Object?> get props => [message, addresses];
}
