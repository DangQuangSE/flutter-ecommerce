import 'package:equatable/equatable.dart';

class OrderRequestEntity extends Equatable {
  final String userId;
  final String shippingAddress;
  final String paymentMethod;

  const OrderRequestEntity({
    required this.userId,
    required this.shippingAddress,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [userId, shippingAddress, paymentMethod];
}
