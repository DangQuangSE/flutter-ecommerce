import 'package:equatable/equatable.dart';

class VnpayVerifyEntity extends Equatable {
  final int orderId;
  final String orderStatus;
  final String paymentStatus;
  final String? txnRef;

  const VnpayVerifyEntity({
    required this.orderId,
    required this.orderStatus,
    required this.paymentStatus,
    this.txnRef,
  });

  bool get isSuccess => paymentStatus == 'SUCCESS';
  bool get isPending => paymentStatus == 'PENDING';
  bool get isFailed => paymentStatus == 'FAILED';

  @override
  List<Object?> get props => [orderId, orderStatus, paymentStatus, txnRef];
}
