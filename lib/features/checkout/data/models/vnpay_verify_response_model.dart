import 'package:flutter_ecommerce/features/checkout/domain/entities/vnpay_verify_entity.dart';

class VnpayVerifyResponseModel {
  final int orderId;
  final String status;
  final String paymentStatus;
  final String? txnRef;

  const VnpayVerifyResponseModel({
    required this.orderId,
    required this.status,
    required this.paymentStatus,
    this.txnRef,
  });

  factory VnpayVerifyResponseModel.fromJson(Map<String, dynamic> json) {
    return VnpayVerifyResponseModel(
      orderId: (json['orderId'] as num).toInt(),
      status: json['status'] as String? ?? 'PENDING',
      paymentStatus: json['paymentStatus'] as String? ?? 'PENDING',
      txnRef: json['txnRef'] as String?,
    );
  }

  VnpayVerifyEntity toEntity() => VnpayVerifyEntity(
        orderId: orderId,
        orderStatus: status,
        paymentStatus: paymentStatus,
        txnRef: txnRef,
      );
}
