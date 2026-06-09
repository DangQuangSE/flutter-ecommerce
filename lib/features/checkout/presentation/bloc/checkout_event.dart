import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/checkout/domain/entities/order_request_entity.dart';
import 'package:flutter_ecommerce/features/payment/domain/entities/vnpay_payment_result.dart';

sealed class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

final class CheckoutSubmitted extends CheckoutEvent {
  final OrderRequestEntity request;

  const CheckoutSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}

final class CheckoutPaymentReturned extends CheckoutEvent {
  final int orderId;
  final VnpayPaymentResult? result;

  const CheckoutPaymentReturned({
    required this.orderId,
    this.result,
  });

  @override
  List<Object?> get props => [orderId, result];
}

final class CheckoutRetryVerify extends CheckoutEvent {
  final int orderId;

  const CheckoutRetryVerify(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
