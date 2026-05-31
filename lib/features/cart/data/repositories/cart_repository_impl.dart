import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';
import 'package:flutter_ecommerce/features/cart/domain/repositories/cart_repository.dart';

// In-memory store for MVP — cart does not persist across app restarts.
// Wire CartLocalDataSource in a future sprint for persistence.
class CartRepositoryImpl implements CartRepository {
  final List<CartItemEntity> _items = [];

  @override
  Future<Result<List<CartItemEntity>>> getCartItems() async =>
      Success(List.unmodifiable(_items));

  @override
  Future<Result<void>> addItem(CartItemEntity item) async {
    final index = _items.indexWhere((i) => i.productId == item.productId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + item.quantity,
      );
    } else {
      _items.add(item);
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> removeItem(String productId) async {
    _items.removeWhere((i) => i.productId == productId);
    return const Success(null);
  }

  @override
  Future<Result<void>> clearCart() async {
    _items.clear();
    return const Success(null);
  }
}
