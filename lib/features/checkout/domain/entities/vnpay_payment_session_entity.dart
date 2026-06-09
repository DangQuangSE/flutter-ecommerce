import 'package:equatable/equatable.dart';

class VnpayPaymentSessionEntity extends Equatable {
  final int orderId;
  final String txnRef;
  final String paymentUrl;

  const VnpayPaymentSessionEntity({
    required this.orderId,
    required this.txnRef,
    required this.paymentUrl,
  });

  @override
  List<Object?> get props => [orderId, txnRef, paymentUrl];
}
