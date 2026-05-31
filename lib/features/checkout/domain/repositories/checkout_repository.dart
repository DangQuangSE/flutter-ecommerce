import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/checkout/domain/entities/order_request_entity.dart';

abstract interface class CheckoutRepository {
  Future<Result<String>> placeOrder(OrderRequestEntity request);
}
