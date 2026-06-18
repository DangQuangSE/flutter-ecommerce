import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';

abstract interface class CartRepository {
  /// Fetch the current user's cart from the backend.
  Future<Result<List<CartItemEntity>>> getCartItems();

  /// Add or update a cart item by [variantId] and [quantity].
  /// If [isReplace] is true, quantity replaces instead of adding.
  Future<Result<List<CartItemEntity>>> addOrUpdateItem({
    required int variantId,
    required int quantity,
    bool isReplace = false,
    int? customDesignId,
  });

  /// Remove a cart item by its backend [itemId].
  Future<Result<List<CartItemEntity>>> removeItem(int itemId);
}
