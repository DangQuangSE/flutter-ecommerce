import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';

abstract interface class CartRepository {
  Future<Result<List<CartItemEntity>>> getCartItems();
  Future<Result<void>> addItem(CartItemEntity item);
  Future<Result<void>> removeItem(String productId);
  Future<Result<void>> clearCart();
}
