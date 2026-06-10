import 'package:equatable/equatable.dart';

class OrderRequestEntity extends Equatable {
  final String shippingAddress;
  final String phoneNumber;
  final String paymentMethod;
  final List<int> cartItemIds;

  const OrderRequestEntity({
    required this.shippingAddress,
    required this.phoneNumber,
    this.paymentMethod = 'BANK_TRANSFER',
    required this.cartItemIds,
  });

  @override
  List<Object?> get props =>
      [shippingAddress, phoneNumber, paymentMethod, cartItemIds];
}
