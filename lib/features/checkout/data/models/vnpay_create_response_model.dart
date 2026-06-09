import 'package:flutter_ecommerce/features/checkout/domain/entities/vnpay_payment_session_entity.dart';

class VnpayCreateResponseModel {
  final int orderId;
  final String txnRef;
  final String paymentUrl;

  const VnpayCreateResponseModel({
    required this.orderId,
    required this.txnRef,
    required this.paymentUrl,
  });

  factory VnpayCreateResponseModel.fromJson(Map<String, dynamic> json) {
    return VnpayCreateResponseModel(
      orderId: (json['orderId'] as num).toInt(),
      txnRef: json['txnRef'] as String,
      paymentUrl: json['paymentUrl'] as String,
    );
  }

  VnpayPaymentSessionEntity toEntity() => VnpayPaymentSessionEntity(
        orderId: orderId,
        txnRef: txnRef,
        paymentUrl: paymentUrl,
      );
}
