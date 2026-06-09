import 'package:equatable/equatable.dart';

class VnpayPaymentResult extends Equatable {
  final String? responseCode;
  final String? txnRef;
  final String? amount;
  final String? transactionNo;
  final String? secureHash;

  const VnpayPaymentResult({
    this.responseCode,
    this.txnRef,
    this.amount,
    this.transactionNo,
    this.secureHash,
  });

  bool get isSuccess => responseCode == '00';

  factory VnpayPaymentResult.fromUri(Uri uri) {
    return VnpayPaymentResult(
      responseCode: uri.queryParameters['vnp_ResponseCode'],
      txnRef: uri.queryParameters['vnp_TxnRef'],
      amount: uri.queryParameters['vnp_Amount'],
      transactionNo: uri.queryParameters['vnp_TransactionNo'],
      secureHash: uri.queryParameters['vnp_SecureHash'],
    );
  }

  @override
  List<Object?> get props =>
      [responseCode, txnRef, amount, transactionNo, secureHash];
}
