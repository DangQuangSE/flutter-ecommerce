import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/checkout/domain/entities/vnpay_payment_session_entity.dart';

sealed class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

final class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

final class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

final class CheckoutAwaitingPayment extends CheckoutState {
  final VnpayPaymentSessionEntity session;

  const CheckoutAwaitingPayment(this.session);

  @override
  List<Object?> get props => [session];
}

final class CheckoutVerifying extends CheckoutState {
  final int orderId;

  const CheckoutVerifying(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

final class CheckoutSuccess extends CheckoutState {
  final int orderId;

  const CheckoutSuccess(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

final class CheckoutFailure extends CheckoutState {
  final String message;

  const CheckoutFailure(this.message);

  @override
  List<Object?> get props => [message];
}
