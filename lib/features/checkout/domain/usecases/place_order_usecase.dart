import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/checkout/domain/entities/order_request_entity.dart';
import 'package:flutter_ecommerce/features/checkout/domain/repositories/checkout_repository.dart';

class PlaceOrderUseCase {
  final CheckoutRepository _repository;

  const PlaceOrderUseCase(this._repository);

  Future<Result<int>> call(OrderRequestEntity request) {
    return _repository.placeOrder(request);
  }
}
