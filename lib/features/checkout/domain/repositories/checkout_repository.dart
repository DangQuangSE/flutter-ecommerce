import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/checkout/domain/entities/order_request_entity.dart';
import 'package:flutter_ecommerce/features/checkout/domain/entities/vnpay_payment_session_entity.dart';
import 'package:flutter_ecommerce/features/checkout/domain/entities/vnpay_verify_entity.dart';

abstract interface class CheckoutRepository {
  Future<Result<int>> placeOrder(OrderRequestEntity request);

  Future<Result<VnpayPaymentSessionEntity>> createVnpayPayment(int orderId);

  Future<Result<VnpayVerifyEntity>> verifyVnpayPayment(int orderId);
}
