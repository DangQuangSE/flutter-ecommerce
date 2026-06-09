import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/checkout/domain/entities/vnpay_payment_session_entity.dart';
import 'package:flutter_ecommerce/features/checkout/domain/repositories/checkout_repository.dart';

class CreateVnpayPaymentUseCase {
  final CheckoutRepository _repository;

  const CreateVnpayPaymentUseCase(this._repository);

  Future<Result<VnpayPaymentSessionEntity>> call(int orderId) {
    return _repository.createVnpayPayment(orderId);
  }
}
