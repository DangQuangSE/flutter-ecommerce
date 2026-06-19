import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';

sealed class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {
  const AddressInitial();
}

class AddressLoading extends AddressState {
  const AddressLoading();
}

class AddressLoaded extends AddressState {
  final List<AddressEntity> addresses;
  final String? message;
  final bool isSubmitting;

  const AddressLoaded({
    required this.addresses,
    this.message,
    this.isSubmitting = false,
  });

  AddressLoaded copyWith({
    List<AddressEntity>? addresses,
    String? message,
    bool? isSubmitting,
  }) {
    return AddressLoaded(
      addresses: addresses ?? this.addresses,
      message: message,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [addresses, message, isSubmitting];
}

class AddressError extends AddressState {
  final String message;

  const AddressError(this.message);

  @override
  List<Object?> get props => [message];
}
