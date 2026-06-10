import 'package:flutter_ecommerce/features/checkout/domain/entities/order_request_entity.dart';

class OrderRequestModel {
  final String shippingAddress;
  final String phoneNumber;
  final String paymentMethod;
  final List<int> cartItemIds;

  const OrderRequestModel({
    required this.shippingAddress,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.cartItemIds,
  });

  factory OrderRequestModel.fromEntity(OrderRequestEntity entity) {
    return OrderRequestModel(
      shippingAddress: entity.shippingAddress,
      phoneNumber: entity.phoneNumber,
      paymentMethod: entity.paymentMethod,
      cartItemIds: entity.cartItemIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'shippingAddress': shippingAddress,
        'phoneNumber': phoneNumber,
        'paymentMethod': paymentMethod,
        'cartItemIds': cartItemIds,
      };
}
