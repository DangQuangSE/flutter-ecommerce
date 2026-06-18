import 'package:equatable/equatable.dart';

class OrderRequestEntity extends Equatable {
  final String shippingAddress;
  final String phoneNumber;
  final String? customerName;
  final String paymentMethod;
  final List<int> cartItemIds;
  final String? couponCode;

  const OrderRequestEntity({
    required this.shippingAddress,
    required this.phoneNumber,
    this.customerName,
    this.paymentMethod = 'COD',
    required this.cartItemIds,
    this.couponCode,
  });

  @override
  List<Object?> get props => [
        shippingAddress,
        phoneNumber,
        customerName,
        paymentMethod,
        cartItemIds,
        couponCode,
      ];
}
