import 'package:flutter_ecommerce/features/checkout/data/models/order_request_model.dart';
import 'package:flutter_ecommerce/features/checkout/data/models/order_response_model.dart';
import 'package:flutter_ecommerce/features/checkout/data/models/vnpay_create_response_model.dart';
import 'package:flutter_ecommerce/features/checkout/data/models/vnpay_verify_response_model.dart';

abstract interface class CheckoutRemoteDataSource {
  Future<OrderResponseModel> placeOrder(OrderRequestModel request);

  Future<VnpayCreateResponseModel> createVnpayPayment(int orderId);

  Future<VnpayVerifyResponseModel> verifyVnpayPayment(int orderId);
}
