import 'package:flutter_ecommerce/features/checkout/domain/entities/order_request_entity.dart';

class OrderRequestModel {
  final String shippingAddress;
  final String phoneNumber;
  final String? customerName;
  final String paymentMethod;
  final List<int> cartItemIds;

  const OrderRequestModel({
    required this.shippingAddress,
    required this.phoneNumber,
    this.customerName,
    required this.paymentMethod,
    required this.cartItemIds,
  });

  factory OrderRequestModel.fromEntity(OrderRequestEntity entity) {
    return OrderRequestModel(
      shippingAddress: entity.shippingAddress,
      phoneNumber: entity.phoneNumber,
      customerName: entity.customerName,
      paymentMethod: entity.paymentMethod,
      cartItemIds: entity.cartItemIds,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'shippingAddress': shippingAddress,
      'phoneNumber': phoneNumber,
      'paymentMethod': paymentMethod,
      'cartItemIds': cartItemIds,
    };
    final name = customerName?.trim();
    if (name != null && name.isNotEmpty) {
      json['customerName'] = name;
    }
    return json;
  }
}
