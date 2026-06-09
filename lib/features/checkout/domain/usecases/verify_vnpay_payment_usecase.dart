import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/checkout/domain/entities/vnpay_verify_entity.dart';
import 'package:flutter_ecommerce/features/checkout/domain/repositories/checkout_repository.dart';

class VerifyVnpayPaymentUseCase {
  final CheckoutRepository _repository;

  const VerifyVnpayPaymentUseCase(this._repository);

  Future<Result<VnpayVerifyEntity>> call(int orderId) {
    return _repository.verifyVnpayPayment(orderId);
  }
}
